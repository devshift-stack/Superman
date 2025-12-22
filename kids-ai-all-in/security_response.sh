#!/bin/bash

# Automatisches Response-Tool
# Führt automatische Gegenmaßnahmen bei erkannten Bedrohungen durch

LOG_FILE="/Users/dsselmanovic/cursor project/kids-ai-all-in/.cursor/debug.log"
RESPONSE_LOG="/Users/dsselmanovic/cursor project/kids-ai-all-in/security_responses.log"

# Logging-Funktion
log() {
    local message="$1"
    local data="$2"
    local timestamp=$(python3 -c "import time; print(int(time.time() * 1000))" 2>/dev/null || date +%s000)
    local log_entry="{\"id\":\"log_${timestamp}_$$\",\"timestamp\":${timestamp},\"location\":\"security_response.sh\",\"message\":\"${message}\",\"data\":${data},\"sessionId\":\"security-response\",\"runId\":\"run1\"}"
    echo "$log_entry" >> "$LOG_FILE"
}

# Response-Funktion
respond() {
    local action="$1"
    local server="$2"
    local ip="$3"
    local details="$4"
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    
    echo "[$timestamp] [$action] [$server] $details" >> "$RESPONSE_LOG"
    log "Security Response" "{\"action\":\"$action\",\"server\":\"$server\",\"details\":\"$details\"}"
    
    echo -e "\033[1;32m[RESPONSE] $server: $action\033[0m"
    echo "  Details: $details"
}

# ============================================
# 1. Verdächtigen Prozess stoppen
# ============================================
kill_suspicious_process() {
    local server="$1"
    local ip="$2"
    local pid="$3"
    
    respond "KILL_PROCESS" "$server" "$ip" "Stoppe verdächtigen Prozess PID $pid"
    
    ssh -o ConnectTimeout=10 -o StrictHostKeyChecking=no root@"$ip" "
        if [ -d /proc/$pid ]; then
            kill -9 $pid 2>/dev/null
            echo 'Prozess $pid gestoppt'
            
            # Prüfe Parent-Prozess
            PARENT=\$(cat /proc/$pid/status 2>/dev/null | grep PPid | awk '{print \$2}')
            if [ ! -z \"\$PARENT\" ] && [ \"\$PARENT\" != \"1\" ]; then
                kill -9 \$PARENT 2>/dev/null
                echo 'Parent-Prozess \$PARENT gestoppt'
            fi
        else
            echo 'Prozess existiert nicht mehr'
        fi
    " 2>&1
}

# ============================================
# 2. Container neu starten
# ============================================
restart_container() {
    local server="$1"
    local ip="$2"
    local container="$3"
    
    respond "RESTART_CONTAINER" "$server" "$ip" "Starte Container $container neu"
    
    ssh -o ConnectTimeout=10 -o StrictHostKeyChecking=no root@"$ip" "
        docker restart $container 2>/dev/null && echo 'Container $container neu gestartet' || echo 'Fehler beim Neustart'
    " 2>&1
}

# ============================================
# 3. IP blockieren (iptables)
# ============================================
block_ip() {
    local server="$1"
    local ip="$2"
    local block_ip="$3"
    
    respond "BLOCK_IP" "$server" "$ip" "Blockiere verdächtige IP $block_ip"
    
    ssh -o ConnectTimeout=10 -o StrictHostKeyChecking=no root@"$ip" "
        iptables -A INPUT -s $block_ip -j DROP 2>/dev/null && \
        echo 'IP $block_ip blockiert' || \
        echo 'Fehler beim Blockieren (iptables nicht verfügbar?)'
    " 2>&1
}

# ============================================
# 4. Verdächtige Dateien löschen
# ============================================
cleanup_suspicious_files() {
    local server="$1"
    local ip="$2"
    
    respond "CLEANUP_FILES" "$server" "$ip" "Bereinige verdächtige Dateien"
    
    ssh -o ConnectTimeout=10 -o StrictHostKeyChecking=no root@"$ip" "
        for path in /tmp /var/tmp /dev/shm; do
            if [ -d \"\$path\" ]; then
                find \"\$path\" -type f \\( -name '*mysql*' -o -name '*miner*' -o -name '*crypto*' \\) -delete 2>/dev/null
                echo 'Bereinigt: \$path'
            fi
        done
    " 2>&1
}

# ============================================
# 5. Automatische Response basierend auf Alert-Log
# ============================================
auto_respond() {
    local alert_log="/Users/dsselmanovic/cursor project/kids-ai-all-in/security_alerts.log"
    
    if [ ! -f "$alert_log" ]; then
        echo "Keine Alerts gefunden"
        return
    fi
    
    # Suche nach kritischen Alerts
    while IFS= read -r alert_line; do
        if echo "$alert_line" | grep -q "\[CRITICAL\]"; then
            server=$(echo "$alert_line" | awk '{print $3}' | tr -d '[]')
            
            # Extrahiere IP für Server
            case "$server" in
                "videose") ip="77.42.46.56" ;;
                "crm") ip="46.62.254.77" ;;
                "sipgate") ip="116.203.245.77" ;;
                "Scrap") ip="91.98.78.198" ;;
                *) continue ;;
            esac
            
            # Wenn verdächtiger Prozess
            if echo "$alert_line" | grep -q "Verdächtiger Prozess"; then
                pid=$(echo "$alert_line" | grep -oP 'PID \K[0-9]+')
                if [ ! -z "$pid" ]; then
                    kill_suspicious_process "$server" "$ip" "$pid"
                    
                    # Wenn in Container, Container neu starten
                    if echo "$alert_line" | grep -q "Container"; then
                        container=$(echo "$alert_line" | grep -oP 'Container \K[^ ]+')
                        if [ ! -z "$container" ]; then
                            restart_container "$server" "$ip" "$container"
                        fi
                    fi
                fi
            fi
        fi
    done < "$alert_log"
}

# ============================================
# Hauptfunktion
# ============================================
echo "=========================================="
echo "  SECURITY RESPONSE TOOL"
echo "=========================================="
echo ""

# Beispiel: Automatische Response
# auto_respond

# Oder manuelle Response
if [ "$1" = "kill" ] && [ ! -z "$2" ] && [ ! -z "$3" ]; then
    kill_suspicious_process "$2" "$3" "$4"
elif [ "$1" = "restart" ] && [ ! -z "$2" ] && [ ! -z "$3" ] && [ ! -z "$4" ]; then
    restart_container "$2" "$3" "$4"
elif [ "$1" = "block" ] && [ ! -z "$2" ] && [ ! -z "$3" ] && [ ! -z "$4" ]; then
    block_ip "$2" "$3" "$4"
elif [ "$1" = "cleanup" ] && [ ! -z "$2" ] && [ ! -z "$3" ]; then
    cleanup_suspicious_files "$2" "$3"
elif [ "$1" = "auto" ]; then
    auto_respond
else
    echo "Verwendung:"
    echo "  $0 kill <server> <ip> <pid>     - Prozess stoppen"
    echo "  $0 restart <server> <ip> <container> - Container neu starten"
    echo "  $0 block <server> <ip> <block_ip> - IP blockieren"
    echo "  $0 cleanup <server> <ip>       - Dateien bereinigen"
    echo "  $0 auto                        - Automatische Response"
    echo ""
    echo "Beispiele:"
    echo "  $0 kill crm 46.62.254.77 2144884"
    echo "  $0 restart crm 46.62.254.77 crm-postgres"
    echo "  $0 block crm 46.62.254.77 115.190.140.2"
fi

