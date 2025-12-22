#!/bin/bash

# Security-Monitoring-Tool
# Überwacht Server kontinuierlich auf verdächtige Aktivitäten

LOG_FILE="/Users/dsselmanovic/cursor project/kids-ai-all-in/.cursor/debug.log"
ALERT_LOG="/Users/dsselmanovic/cursor project/kids-ai-all-in/security_alerts.log"
REPORT_DIR="/Users/dsselmanovic/cursor project/kids-ai-all-in/security_reports"

# Logging-Funktion
log() {
    local message="$1"
    local data="$2"
    local timestamp=$(python3 -c "import time; print(int(time.time() * 1000))" 2>/dev/null || date +%s000)
    local log_entry="{\"id\":\"log_${timestamp}_$$\",\"timestamp\":${timestamp},\"location\":\"security_monitor.sh\",\"message\":\"${message}\",\"data\":${data},\"sessionId\":\"security-monitoring\",\"runId\":\"run1\"}"
    echo "$log_entry" >> "$LOG_FILE"
}

# Alert-Funktion
alert() {
    local severity="$1"
    local server="$2"
    local message="$3"
    local details="$4"
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    
    echo "[$timestamp] [$severity] [$server] $message" >> "$ALERT_LOG"
    echo "$details" >> "$ALERT_LOG"
    echo "---" >> "$ALERT_LOG"
    
    log "Security Alert" "{\"severity\":\"$severity\",\"server\":\"$server\",\"message\":\"$message\"}"
    
    # Console-Output mit Farben
    case "$severity" in
        "CRITICAL")
            echo -e "\033[1;31m[CRITICAL] $server: $message\033[0m"
            ;;
        "WARNING")
            echo -e "\033[1;33m[WARNING] $server: $message\033[0m"
            ;;
        "INFO")
            echo -e "\033[1;36m[INFO] $server: $message\033[0m"
            ;;
    esac
}

# Server-Konfiguration
SERVERS=(
    "videose|77.42.46.56"
    "crm|46.62.254.77"
    "sipgate|116.203.245.77"
    "Scrap|91.98.78.198"
)

# Thresholds
CPU_THRESHOLD=90
LOAD_THRESHOLD=10
MEMORY_THRESHOLD=90
SUSPICIOUS_PATHS=("/tmp" "/var/tmp" "/dev/shm")
SUSPICIOUS_NAMES=("mysql" "miner" "crypto" "xmr" "xmrig" "stratum")

mkdir -p "$REPORT_DIR"
REPORT_FILE="$REPORT_DIR/security_report_$(date +%Y%m%d_%H%M%S).txt"

echo "=========================================="
echo "  SECURITY MONITORING TOOL"
echo "=========================================="
echo "Startzeit: $(date)"
echo "Report: $REPORT_FILE"
echo ""

log "Security Monitoring gestartet" "{\"servers\":${#SERVERS[@]}}"

# ============================================
# 1. CPU und Load Monitoring
# ============================================
check_cpu_load() {
    local server_name="$1"
    local ip="$2"
    
    local stats=$(ssh -o ConnectTimeout=10 -o StrictHostKeyChecking=no root@"$ip" "
        echo 'CPU:' \$(top -bn1 | grep 'Cpu(s)' | sed 's/.*, *\([0-9.]*\)%* id.*/\1/' | awk '{printf \"%.1f\", 100 - \$1}')
        echo 'LOAD:' \$(uptime | awk -F'load average:' '{print \$2}' | awk '{print \$1}' | tr -d ',')
        echo 'MEM:' \$(free | grep Mem | awk '{printf \"%.1f\", (\$3/\$2) * 100}')
    " 2>&1)
    
    if [ $? -eq 0 ]; then
        local cpu=$(echo "$stats" | grep "^CPU:" | cut -d' ' -f2)
        local load=$(echo "$stats" | grep "^LOAD:" | cut -d' ' -f2)
        local mem=$(echo "$stats" | grep "^MEM:" | cut -d' ' -f2)
        
        # CPU Check
        if [ ! -z "$cpu" ] && (( $(echo "$cpu > $CPU_THRESHOLD" | bc -l 2>/dev/null || echo 0) )); then
            alert "CRITICAL" "$server_name" "Hohe CPU-Auslastung: ${cpu}%" "CPU: $cpu%, Load: $load, Memory: $mem%"
        fi
        
        # Load Check
        if [ ! -z "$load" ] && (( $(echo "$load > $LOAD_THRESHOLD" | bc -l 2>/dev/null || echo 0) )); then
            alert "WARNING" "$server_name" "Hohe Load: $load" "CPU: $cpu%, Load: $load, Memory: $mem%"
        fi
        
        # Memory Check
        if [ ! -z "$mem" ] && (( $(echo "$mem > $MEMORY_THRESHOLD" | bc -l 2>/dev/null || echo 0) )); then
            alert "WARNING" "$server_name" "Hohe Memory-Auslastung: ${mem}%" "CPU: $cpu%, Load: $load, Memory: $mem%"
        fi
        
        echo "$server_name|$ip|CPU:$cpu|LOAD:$load|MEM:$mem" >> "$REPORT_FILE"
    else
        alert "WARNING" "$server_name" "Verbindungsfehler" "SSH-Verbindung fehlgeschlagen"
    fi
}

# ============================================
# 2. Verdächtige Prozesse erkennen
# ============================================
check_suspicious_processes() {
    local server_name="$1"
    local ip="$2"
    
    local processes=$(ssh -o ConnectTimeout=10 -o StrictHostKeyChecking=no root@"$ip" "
        ps aux --sort=-%cpu | head -20 | while read line; do
            for suspicious in ${SUSPICIOUS_NAMES[@]}; do
                if echo \"\$line\" | grep -qi \"\$suspicious\"; then
                    echo \"\$line\"
                fi
            done
        done
    " 2>&1)
    
    if [ ! -z "$processes" ] && [ "$processes" != "" ]; then
        while IFS= read -r proc_line; do
            if [ ! -z "$proc_line" ]; then
                local pid=$(echo "$proc_line" | awk '{print $2}')
                local cpu=$(echo "$proc_line" | awk '{print $3}')
                local cmd=$(echo "$proc_line" | awk '{for(i=11;i<=NF;i++) printf "%s ", $i; print ""}')
                local exe_path=$(ssh -o ConnectTimeout=10 -o StrictHostKeyChecking=no root@"$ip" "readlink /proc/$pid/exe 2>/dev/null || echo 'N/A'" 2>&1)
                
                # Prüfe ob in verdächtigem Pfad
                local is_suspicious=false
                for path in "${SUSPICIOUS_PATHS[@]}"; do
                    if echo "$exe_path" | grep -q "$path"; then
                        is_suspicious=true
                        break
                    fi
                done
                
                if [ "$is_suspicious" = true ] || [ "$exe_path" = "N/A" ]; then
                    alert "CRITICAL" "$server_name" "Verdächtiger Prozess gefunden: PID $pid" "CPU: ${cpu}%, Command: $cmd, Exe: $exe_path"
                    echo "VERDÄCHTIG: $server_name - PID $pid - $cmd - $exe_path" >> "$REPORT_FILE"
                fi
            fi
        done <<< "$processes"
    fi
}

# ============================================
# 3. Netzwerk-Monitoring
# ============================================
check_network_connections() {
    local server_name="$1"
    local ip="$2"
    
    local connections=$(ssh -o ConnectTimeout=10 -o StrictHostKeyChecking=no root@"$ip" "
        ss -tnp 2>/dev/null | grep -E 'ESTAB|ESTABLISHED' | grep -v '127.0.0.1' | grep -v '::1' | awk '{print \$5}' | cut -d: -f1 | sort | uniq -c | sort -rn | head -10
    " 2>&1)
    
    if [ ! -z "$connections" ] && [ "$connections" != "" ]; then
        echo "=== Netzwerk-Verbindungen: $server_name ===" >> "$REPORT_FILE"
        echo "$connections" >> "$REPORT_FILE"
        
        # Prüfe auf bekannte verdächtige IPs
        while IFS= read -r conn_line; do
            if [ ! -z "$conn_line" ]; then
                local count=$(echo "$conn_line" | awk '{print $1}')
                local remote_ip=$(echo "$conn_line" | awk '{print $2}')
                
                # Viele Verbindungen zu einer IP = verdächtig
                if [ ! -z "$count" ] && [ "$count" -gt 5 ]; then
                    alert "WARNING" "$server_name" "Viele Verbindungen zu $remote_ip: $count" "Möglicherweise verdächtige Aktivität"
                fi
            fi
        done <<< "$connections"
    fi
}

# ============================================
# 4. Dateisystem-Check
# ============================================
check_filesystem() {
    local server_name="$1"
    local ip="$2"
    
    local suspicious_files=$(ssh -o ConnectTimeout=10 -o StrictHostKeyChecking=no root@"$ip" "
        for path in /tmp /var/tmp /dev/shm; do
            if [ -d \"\$path\" ]; then
                find \"\$path\" -type f -name '*mysql*' -o -name '*miner*' -o -name '*crypto*' -o -name '*.sh' -o -name '*.py' 2>/dev/null | head -20
            fi
        done
    " 2>&1)
    
    if [ ! -z "$suspicious_files" ] && [ "$suspicious_files" != "" ]; then
        alert "WARNING" "$server_name" "Verdächtige Dateien in /tmp gefunden" "$suspicious_files"
        echo "=== Verdächtige Dateien: $server_name ===" >> "$REPORT_FILE"
        echo "$suspicious_files" >> "$REPORT_FILE"
    fi
}

# ============================================
# 5. Container-Sicherheit
# ============================================
check_containers() {
    local server_name="$1"
    local ip="$2"
    
    local containers=$(ssh -o ConnectTimeout=10 -o StrictHostKeyChecking=no root@"$ip" "
        docker ps --format '{{.Names}}|{{.Image}}|{{.Status}}' 2>/dev/null
    " 2>&1)
    
    if [ ! -z "$containers" ] && [ "$containers" != "" ]; then
        echo "=== Container: $server_name ===" >> "$REPORT_FILE"
        
        while IFS='|' read -r name image status; do
            if [ ! -z "$name" ]; then
                echo "$name|$image|$status" >> "$REPORT_FILE"
                
                # Prüfe auf verdächtige Prozesse in Containern
                local container_procs=$(ssh -o ConnectTimeout=10 -o StrictHostKeyChecking=no root@"$ip" "
                    docker exec $name ps aux 2>/dev/null | grep -E 'mysql|miner|crypto' | head -5
                " 2>&1)
                
                if [ ! -z "$container_procs" ] && [ "$container_procs" != "" ]; then
                    alert "CRITICAL" "$server_name" "Verdächtige Prozesse in Container $name" "$container_procs"
                fi
            fi
        done <<< "$containers"
    fi
}

# ============================================
# 6. SSH-Login-Monitoring
# ============================================
check_ssh_logins() {
    local server_name="$1"
    local ip="$2"
    
    local failed_logins=$(ssh -o ConnectTimeout=10 -o StrictHostKeyChecking=no root@"$ip" "
        grep -E 'Failed password|Invalid user' /var/log/auth.log 2>/dev/null | tail -20 | \
        awk '{print \$11}' | sort | uniq -c | sort -rn | head -10 || \
        grep -E 'Failed password|Invalid user' /var/log/secure 2>/dev/null | tail -20 | \
        awk '{print \$11}' | sort | uniq -c | sort -rn | head -10 || \
        echo 'Keine Logs verfügbar'
    " 2>&1)
    
    if [ ! -z "$failed_logins" ] && [ "$failed_logins" != "" ] && [ "$failed_logins" != "Keine Logs verfügbar" ]; then
        echo "=== Fehlgeschlagene SSH-Logins: $server_name ===" >> "$REPORT_FILE"
        echo "$failed_logins" >> "$REPORT_FILE"
        
        # Prüfe auf Brute-Force
        while IFS= read -r login_line; do
            if [ ! -z "$login_line" ]; then
                local count=$(echo "$login_line" | awk '{print $1}')
                local source_ip=$(echo "$login_line" | awk '{print $2}')
                
                if [ ! -z "$count" ] && [ "$count" -gt 10 ]; then
                    alert "WARNING" "$server_name" "Möglicher Brute-Force-Angriff von $source_ip: $count Versuche" "SSH-Brute-Force erkannt"
                fi
            fi
        done <<< "$failed_logins"
    fi
}

# ============================================
# Haupt-Scan
# ============================================
echo "Starte Security-Scan..."
echo ""

for server_entry in "${SERVERS[@]}"; do
    IFS='|' read -r server_name ip <<< "$server_entry"
    
    echo "Scanne: $server_name ($ip)"
    
    check_cpu_load "$server_name" "$ip"
    check_suspicious_processes "$server_name" "$ip"
    check_network_connections "$server_name" "$ip"
    check_filesystem "$server_name" "$ip"
    check_containers "$server_name" "$ip"
    check_ssh_logins "$server_name" "$ip"
    
    echo "  ✓ Abgeschlossen"
    echo ""
done

# ============================================
# Zusammenfassung
# ============================================
echo "=========================================="
echo "  SCAN ABGESCHLOSSEN"
echo "=========================================="
echo ""
echo "Report: $REPORT_FILE"
echo "Alerts: $ALERT_LOG"
echo ""

if [ -f "$ALERT_LOG" ]; then
    CRITICAL_COUNT=$(grep -c "\[CRITICAL\]" "$ALERT_LOG" 2>/dev/null || echo "0")
    WARNING_COUNT=$(grep -c "\[WARNING\]" "$ALERT_LOG" 2>/dev/null || echo "0")
    
    echo "Zusammenfassung:"
    echo "  - Kritische Alerts: $CRITICAL_COUNT"
    echo "  - Warnungen: $WARNING_COUNT"
    echo ""
    
    if [ "$CRITICAL_COUNT" -gt 0 ]; then
        echo "⚠️  KRITISCHE PROBLEME GEFUNDEN!"
        echo "Bitte prüfe: $ALERT_LOG"
    fi
fi

log "Security Monitoring abgeschlossen" "{\"report\":\"$REPORT_FILE\"}"

