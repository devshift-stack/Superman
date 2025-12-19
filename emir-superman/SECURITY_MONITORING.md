# 🔒 Security Monitoring Setup - Wazuh/CrowdSec + Slack

**Für alle deine Server (Hetzner, Railway, etc.)**

---

## 🎯 Optionen

| Option | Server | Aufwand | Kosten |
|-------|--------|---------|-------|
| **CrowdSec** | Auf jedem Server | 10 Min | Kostenlos |
| **Wazuh Cloud** | Hosted | 5 Min | Kostenlos bis 5 Agents |
| **Wazuh Self-hosted** | Eigener Server | 30 Min | Kostenlos |

**Empfehlung:** CrowdSec (leichtgewichtig, einfach, kostenlos)

---

## 📡 Slack-Webhook erstellen

1. Gehe zu: https://api.slack.com/apps
2. "Create New App" → "From scratch"
3. App-Name: "Security Alerts"
4. Workspace auswählen
5. "Incoming Webhooks" aktivieren
6. "Add New Webhook to Workspace"
7. Channel wählen (z.B. `#security-alerts`)
8. Webhook-URL kopieren

---

## 🚀 Setup auf Server

### Option 1: CrowdSec (Empfohlen)

```bash  h
# Auf Server
export SLACK_WEBHOOK_URL="https://hooks.slack.com/services/YOUR/WEBHOOK/URL"
export MONITORING_TYPE="crowdsec"

# Script hochladen
scp security-monitoring-setup.sh root@49.13.158.176:/root/

# Auf Server ausführen
ssh root@49.13.158.176
chmod +x security-monitoring-setup.sh
./security-monitoring-setup.sh
```

### Option 2: Wazuh Cloud

```bash
# Auf Server
export SLACK_WEBHOOK_URL="https://hooks.slack.com/services/YOUR/WEBHOOK/URL"
export MONITORING_TYPE="wazuh-cloud"
export WAZUH_REGISTRATION_PASSWORD="dein-password-von-cloud.wazuh.com"

# Script ausführen
./security-monitoring-setup.sh
```

---

## 📊 Was wird überwacht?

**CrowdSec:**
- ✅ Brute-Force Angriffe
- ✅ Port Scans
- ✅ DDoS-Versuche
- ✅ Verdächtige IPs
- ✅ File Integrity (optional)

**Wazuh:**
- ✅ Alles von CrowdSec +
- ✅ Vulnerability Scans
- ✅ Rootkit Detection
- ✅ Compliance Checks
- ✅ Log Analysis

---

## 🔔 Slack-Alerts

**Du bekommst Alerts für:**
- 🚨 Brute-Force erkannt
- 🚨 Port Scan erkannt
- 🚨 File geändert: /etc/passwd
- 🚨 Neue CVE gefunden
- 🚨 Rootkit erkannt

**Format:**
```
🚨 Security Alert
Server: superman-v1
Event: Brute-Force
Source IP: 192.168.1.100
Reason: Multiple failed SSH attempts
Time: 2024-12-18 23:45:00
```

---

## 🧪 Testen

```bash
# Slack-Test senden
curl -X POST -H 'Content-type: application/json' \
  --data '{"text":"🧪 Test Alert von '$(hostname)'"}' \
  $SLACK_WEBHOOK_URL
```

---

## 📋 Checkliste

**Setup:**
- [ ] Slack-Webhook erstellt
- [ ] Script auf Server hochgeladen
- [ ] Environment Variables gesetzt
- [ ] Script ausgeführt
- [ ] Slack-Test erfolgreich

**Verifizierung:**
- [ ] CrowdSec/Wazuh läuft: `systemctl status crowdsec` oder `systemctl status wazuh-agent`
- [ ] Alerts kommen in Slack an
- [ ] Test-Alert gesendet

---

## 🔧 Troubleshooting

**CrowdSec läuft nicht:**
```bash
systemctl status crowdsec
journalctl -u crowdsec -f
```

**Slack-Alerts kommen nicht an:**
```bash
# Webhook testen
curl -X POST -H 'Content-type: application/json' \
  --data '{"text":"Test"}' $SLACK_WEBHOOK_URL

# CrowdSec Notifications prüfen
cscli notifications list
```

**Wazuh Agent verbindet nicht:**
```bash
systemctl status wazuh-agent
/var/ossec/bin/agent-auth -m cloud.wazuh.com -P YOUR_PASSWORD
```

---

**Fertig!** 🎉

Deine Server sind jetzt überwacht und du bekommst alle Security-Alerts in Slack!

