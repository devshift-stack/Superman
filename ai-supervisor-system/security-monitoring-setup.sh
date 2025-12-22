#!/bin/bash
# Security Monitoring Setup - Wazuh/CrowdSec + Slack Integration

set -e

echo "🔒 Security Monitoring Setup"
echo "============================="
echo ""

# Konfiguration
SLACK_WEBHOOK_URL="${SLACK_WEBHOOK_URL:-}"
MONITORING_TYPE="${MONITORING_TYPE:-crowdsec}"  # wazuh-cloud, wazuh-self, crowdsec

if [ -z "$SLACK_WEBHOOK_URL" ]; then
    echo "⚠️ SLACK_WEBHOOK_URL nicht gesetzt!"
    echo "Bitte setze: export SLACK_WEBHOOK_URL='https://hooks.slack.com/services/...'"
    exit 1
fi

# OS erkennen
if grep -q "CentOS" /etc/os-release || grep -q "Rocky" /etc/os-release; then
    OS="centos"
    PKG_MGR="yum"
elif grep -q "Ubuntu" /etc/os-release || grep -q "Debian" /etc/os-release; then
    OS="ubuntu"
    PKG_MGR="apt"
else
    echo "⚠️ Unbekanntes OS"
    exit 1
fi

echo "📦 OS: $OS"
echo "🔧 Monitoring: $MONITORING_TYPE"
echo ""

# CrowdSec Setup (empfohlen - leichtgewichtig)
setup_crowdsec() {
    echo "🔒 Installiere CrowdSec..."
    
    if [ "$OS" = "centos" ]; then
        curl -s https://packagecloud.io/install/repositories/crowdsec/crowdsec/script.rpm.sh | bash
        $PKG_MGR install -y crowdsec
    else
        curl -s https://packagecloud.io/install/repositories/crowdsec/crowdsec/script.deb.sh | bash
        $PKG_MGR install -y crowdsec
    fi
    
    # CrowdSec starten
    systemctl enable crowdsec
    systemctl start crowdsec
    
    # Slack Notification Setup
    echo ""
    echo "📡 Richte Slack-Integration ein..."
    
    cat > /etc/crowdsec/notifications/slack.yaml << EOF
name: slack_default
format: |
  🚨 *Security Alert*
  *Server:* \${hostname}
  *Event:* \${alert.alert_type}
  *Source IP:* \${alert.source_ip}
  *Reason:* \${alert.reason}
  *Time:* \${alert.timestamp}
url: $SLACK_WEBHOOK_URL
method: POST
type: http
EOF
    
    # CrowdSec Notification aktivieren
    cscli notifications add slack_default
    
    echo "✅ CrowdSec installiert und Slack-Integration aktiviert"
}

# Wazuh Cloud Setup
setup_wazuh_cloud() {
    echo "🔒 Installiere Wazuh Agent (Cloud)..."
    
    WAZUH_MANAGER="${WAZUH_MANAGER:-cloud.wazuh.com}"
    WAZUH_REGISTRATION_PASSWORD="${WAZUH_REGISTRATION_PASSWORD:-}"
    
    if [ -z "$WAZUH_REGISTRATION_PASSWORD" ]; then
        echo "⚠️ WAZUH_REGISTRATION_PASSWORD nicht gesetzt!"
        echo "Hole dir das Passwort von: https://cloud.wazuh.com"
        exit 1
    fi
    
    if [ "$OS" = "centos" ]; then
        curl -s https://packages.wazuh.com/key/GPG-KEY-WAZUH | gpg --import
        cat > /etc/yum.repos.d/wazuh.repo << EOF
[wazuh]
gpgcheck=1
gpgkey=https://packages.wazuh.com/key/GPG-KEY-WAZUH
enabled=1
name=EL-\$releasever - Wazuh
baseurl=https://packages.wazuh.com/4.x/yum/
protect=1
EOF
        $PKG_MGR install -y wazuh-agent
    else
        curl -s https://packages.wazuh.com/key/GPG-KEY-WAZUH | gpg --import
        echo "deb https://packages.wazuh.com/4.x/apt/ stable main" | tee /etc/apt/sources.list.d/wazuh.list
        $PKG_MGR update
        $PKG_MGR install -y wazuh-agent
    fi
    
    # Wazuh Agent konfigurieren
    sed -i "s/MANAGER_IP/$WAZUH_MANAGER/g" /var/ossec/etc/ossec.conf
    
    # Registrieren
    /var/ossec/bin/agent-auth -m $WAZUH_MANAGER -P $WAZUH_REGISTRATION_PASSWORD
    
    systemctl enable wazuh-agent
    systemctl start wazuh-agent
    
    echo "✅ Wazuh Agent installiert"
    echo "⚠️ Slack-Integration muss in Wazuh Cloud Dashboard konfiguriert werden"
}

# Slack Webhook Test
test_slack() {
    echo ""
    echo "🧪 Teste Slack-Integration..."
    
    curl -X POST -H 'Content-type: application/json' \
        --data '{"text":"✅ Security Monitoring aktiviert auf '$(hostname)'"}' \
        $SLACK_WEBHOOK_URL
    
    echo ""
    echo "✅ Slack-Test gesendet - prüfe deinen Slack-Channel!"
}

# Main
case $MONITORING_TYPE in
    crowdsec)
        setup_crowdsec
        test_slack
        ;;
    wazuh-cloud)
        setup_wazuh_cloud
        test_slack
        ;;
    *)
        echo "❌ Unbekannter Monitoring-Typ: $MONITORING_TYPE"
        echo "Verfügbar: crowdsec, wazuh-cloud"
        exit 1
        ;;
esac

echo ""
echo "✅ Security Monitoring Setup abgeschlossen!"
echo ""
echo "📊 Status prüfen:"
if [ "$MONITORING_TYPE" = "crowdsec" ]; then
    echo "  cscli metrics"
    echo "  cscli alerts list"
else
    echo "  systemctl status wazuh-agent"
fi

