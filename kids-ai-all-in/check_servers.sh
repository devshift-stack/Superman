#!/bin/bash

# Server-Überwachungsskript
# Prüft alle Server auf CPU-Auslastung und laufende Services

LOG_FILE="/Users/dsselmanovic/cursor project/kids-ai-all-in/.cursor/debug.log"

# Logging-Funktion
log() {
    local message="$1"
    local data="$2"
    local timestamp=$(python3 -c "import time; print(int(time.time() * 1000))" 2>/dev/null || date +%s000)
    local log_entry="{\"id\":\"log_${timestamp}_$$\",\"timestamp\":${timestamp},\"location\":\"check_servers.sh\",\"message\":\"${message}\",\"data\":${data},\"sessionId\":\"server-monitoring\",\"runId\":\"run1\"}"
    echo "$log_entry" >> "$LOG_FILE"
}

# Server-Konfiguration (Name|IP)
SERVERS=(
    "videose|77.42.46.56"
    "crm|46.62.254.77"
    "sipgate|116.203.245.77"
    "Scrap|91.98.78.198"
)

echo "=== Server-Überwachung gestartet ==="
echo ""

# Ergebnisse
RESULTS_FILE=$(mktemp)

for server_entry in "${SERVERS[@]}"; do
    IFS='|' read -r server_name ip <<< "$server_entry"
    
    echo "Prüfe Server: $server_name ($ip)"
    
    # SSH-Befehl mit Timeout - CPU-Auslastung direkt berechnen
    ssh_output=$(ssh -o ConnectTimeout=10 -o StrictHostKeyChecking=no root@"$ip" "
        echo 'HOSTNAME:' \$(hostname)
        echo 'UPTIME:' \$(uptime)
        echo 'CPU:' \$(top -bn1 | grep 'Cpu(s)' | sed 's/.*, *\([0-9.]*\)%* id.*/\1/' | awk '{printf \"%.1f\", 100 - \$1}')
        echo 'LOAD:' \$(uptime | awk -F'load average:' '{print \$2}' | awk '{print \$1}' | tr -d ',')
        echo 'DOCKER_START'
        docker ps --format '{{.Names}}|{{.Status}}|{{.CPUPerc}}|{{.MemUsage}}' 2>/dev/null || echo 'KEIN_DOCKER'
        echo 'DOCKER_END'
    " 2>&1)
    
    ssh_exit_code=$?
    
    if [ $ssh_exit_code -eq 0 ]; then
        # Parse Output
        hostname=$(echo "$ssh_output" | grep "^HOSTNAME:" | cut -d' ' -f2-)
        uptime_line=$(echo "$ssh_output" | grep "^UPTIME:" | cut -d' ' -f2-)
        cpu_usage=$(echo "$ssh_output" | grep "^CPU:" | cut -d' ' -f2)
        load_avg=$(echo "$ssh_output" | grep "^LOAD:" | cut -d' ' -f2)
        
        # Fallback: CPU aus Load schätzen (wenn top nicht verfügbar)
        if [ -z "$cpu_usage" ] || [ "$cpu_usage" == "" ]; then
            if [ ! -z "$load_avg" ] && [ "$load_avg" != "" ]; then
                # Grobe Schätzung basierend auf Load
                cpu_usage=$(echo "$load_avg" | awk '{printf "%.1f", $1 * 6.25}')
            else
                cpu_usage="N/A"
            fi
        fi
        
        # Status bestimmen
        if [ "$cpu_usage" == "N/A" ] || [ -z "$cpu_usage" ]; then
            status="❓ UNBEKANNT"
        else
            cpu_num=$(echo "$cpu_usage" | cut -d. -f1 | tr -d '[:alpha:]')
            if [ ! -z "$cpu_num" ] && [ "$cpu_num" -gt 90 ] 2>/dev/null; then
                status="⚠️ KRITISCH"
            elif [ ! -z "$cpu_num" ] && [ "$cpu_num" -gt 70 ] 2>/dev/null; then
                status="🟡 HOCH"
            else
                status="✅ OK"
            fi
        fi
        
        log "Server geprüft" "{\"server\":\"$server_name\",\"ip\":\"$ip\",\"cpu\":\"$cpu_usage\",\"load\":\"$load_avg\",\"status\":\"$status\"}"
        
        echo "$server_name|$ip|$cpu_usage|$load_avg|$status" >> "$RESULTS_FILE"
        
        echo "  ✅ Verbunden - CPU: ~${cpu_usage}%, Load: $load_avg"
    else
        log "Server-Verbindungsfehler" "{\"server\":\"$server_name\",\"ip\":\"$ip\",\"error\":\"SSH failed\"}"
        echo "$server_name|$ip|FEHLER|N/A|❌ OFFLINE" >> "$RESULTS_FILE"
        echo "  ❌ Verbindungsfehler"
    fi
    
    echo ""
done

# Übersichtstabelle ausgeben
echo "=== SERVER-ÜBERSICHT ==="
echo ""
printf "%-12s | %-15s | %-8s | %-8s | %-15s\n" "Server" "IP" "CPU %" "Load" "Status"
echo "------------|-----------------|---------|---------|---------------"

if [ -f "$RESULTS_FILE" ]; then
    while IFS='|' read -r name ip cpu load status; do
        printf "%-12s | %-15s | %-8s | %-8s | %-15s\n" "$name" "$ip" "$cpu" "$load" "$status"
    done < "$RESULTS_FILE"
fi

echo ""
echo "=== Detaillierte Informationen ==="
echo ""

# Detaillierte Infos für jeden Server
for server_entry in "${SERVERS[@]}"; do
    IFS='|' read -r server_name ip <<< "$server_entry"
    
    echo "--- $server_name ($ip) ---"
    
    ssh -o ConnectTimeout=10 -o StrictHostKeyChecking=no root@"$ip" "
        echo 'Hostname:' \$(hostname)
        echo 'Uptime:' \$(uptime)
        echo ''
        echo 'Top 10 CPU-Prozesse:'
        ps aux --sort=-%cpu | head -11 | awk '{printf \"%-10s %6s %5s%% %5s%% %8s %s\\n\", \$1, \$2, \$3, \$4, \$6, \$11}'
        echo ''
        echo 'Docker Container:'
        docker ps --format 'table {{.Names}}\t{{.Status}}\t{{.CPUPerc}}\t{{.MemUsage}}' 2>/dev/null || echo 'Kein Docker installiert'
        echo ''
        echo 'Speicher:'
        free -h 2>/dev/null || echo 'free command nicht verfügbar'
        echo ''
    " 2>&1
    
    echo ""
done

# Cleanup
rm -f "$RESULTS_FILE"

log "Überwachung abgeschlossen" "{\"servers_checked\":${#SERVERS[@]}}"

echo "=== Überwachung abgeschlossen ==="
