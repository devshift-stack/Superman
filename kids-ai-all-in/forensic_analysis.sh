#!/bin/bash

# Forensisches Analyse-Tool
# Analysiert: WER (Prozess/User), WIE (Zugriffsweg), WOHER (Herkunft/IP)

LOG_FILE="/Users/dsselmanovic/cursor project/kids-ai-all-in/.cursor/debug.log"
TARGET_SERVER="46.62.254.77"
SUSPICIOUS_PID="2144884"

# Logging-Funktion
log() {
    local message="$1"
    local data="$2"
    local timestamp=$(python3 -c "import time; print(int(time.time() * 1000))" 2>/dev/null || date +%s000)
    local log_entry="{\"id\":\"log_${timestamp}_$$\",\"timestamp\":${timestamp},\"location\":\"forensic_analysis.sh\",\"message\":\"${message}\",\"data\":${data},\"sessionId\":\"forensic-analysis\",\"runId\":\"run1\"}"
    echo "$log_entry" >> "$LOG_FILE"
}

echo "=========================================="
echo "  FORENSISCHE ANALYSE: WER, WIE, WOHER"
echo "=========================================="
echo ""
echo "Ziel-Server: $TARGET_SERVER"
echo "Verdächtiger Prozess: PID $SUSPICIOUS_PID"
echo ""

log "Forensische Analyse gestartet" "{\"server\":\"$TARGET_SERVER\",\"pid\":\"$SUSPICIOUS_PID\"}"

# ============================================
# 1. WER - Prozess-Details
# ============================================
echo "=== 1. WER - Prozess-Identifikation ==="
echo ""

PROCESS_INFO=$(ssh -o ConnectTimeout=10 -o StrictHostKeyChecking=no root@"$TARGET_SERVER" "
    echo '=== PROZESS-DETAILS ==='
    if [ -d /proc/$SUSPICIOUS_PID ]; then
        echo 'PID:' $SUSPICIOUS_PID
        echo 'COMMAND:' \$(cat /proc/$SUSPICIOUS_PID/cmdline | tr '\\0' ' ')
        echo 'EXE:' \$(readlink /proc/$SUSPICIOUS_PID/exe 2>/dev/null || echo 'N/A')
        echo 'CWD:' \$(readlink /proc/$SUSPICIOUS_PID/cwd 2>/dev/null || echo 'N/A')
        echo 'USER:' \$(stat -c '%U:%G' /proc/$SUSPICIOUS_PID 2>/dev/null || ps -o user= -p $SUSPICIOUS_PID)
        echo 'UID/GID:' \$(cat /proc/$SUSPICIOUS_PID/status | grep -E '^Uid|^Gid' | head -2)
        echo 'STARTED:' \$(ps -o lstart= -p $SUSPICIOUS_PID 2>/dev/null || echo 'N/A')
        echo 'RUNTIME:' \$(ps -o etime= -p $SUSPICIOUS_PID 2>/dev/null || echo 'N/A')
        echo 'PARENT PID:' \$(cat /proc/$SUSPICIOUS_PID/status | grep PPid | awk '{print \$2}')
        echo 'CHILDREN:' \$(pgrep -P $SUSPICIOUS_PID 2>/dev/null | tr '\\n' ' ' || echo 'Keine')
        echo ''
        echo '=== PROZESS-Umgebung ==='
        cat /proc/$SUSPICIOUS_PID/environ 2>/dev/null | tr '\\0' '\\n' | grep -E 'PATH|HOME|USER|SHELL|PWD' || echo 'Keine relevanten Umgebungsvariablen'
        echo ''
        echo '=== DATEI-DESCRIPTORS ==='
        ls -la /proc/$SUSPICIOUS_PID/fd/ 2>/dev/null | head -20 || echo 'Keine Zugriff'
    else
        echo 'Prozess existiert nicht mehr!'
    fi
" 2>&1)

echo "$PROCESS_INFO"
log "Prozess-Details gesammelt" "{\"info\":\"$(echo "$PROCESS_INFO" | head -5 | tr '\n' ' ')\"}"

# ============================================
# 2. WIE - Zugriffsweg und Container
# ============================================
echo ""
echo "=== 2. WIE - Zugriffsweg und Container ==="
echo ""

CONTAINER_INFO=$(ssh -o ConnectTimeout=10 -o StrictHostKeyChecking=no root@"$TARGET_SERVER" "
    echo '=== CONTAINER-ZUORDNUNG ==='
    # Finde Container, in dem der Prozess läuft
    CONTAINER_ID=\$(docker ps -q --filter 'name=crm-postgres' 2>/dev/null | head -1)
    if [ ! -z \"\$CONTAINER_ID\" ]; then
        echo 'Container ID:' \$CONTAINER_ID
        echo 'Container Name:' \$(docker ps --format '{{.Names}}' --filter id=\$CONTAINER_ID)
        echo ''
        echo '=== CONTAINER-DETAILS ==='
        docker inspect \$CONTAINER_ID 2>/dev/null | grep -E 'Image|Created|State|Mounts' | head -10
        echo ''
        echo '=== PROZESS IM CONTAINER ==='
        docker exec \$CONTAINER_ID ps aux 2>/dev/null | grep -E 'mysql|2144884' || echo 'Prozess nicht im Container sichtbar'
        echo ''
        echo '=== CONTAINER-LOGS (letzte 50 Zeilen) ==='
        docker logs --tail 50 \$CONTAINER_ID 2>/dev/null | tail -20 || echo 'Keine Logs verfügbar'
    else
        echo 'Container crm-postgres nicht gefunden!'
        echo ''
        echo '=== ALLE CONTAINER ==='
        docker ps -a --format 'table {{.Names}}\t{{.Image}}\t{{.Status}}\t{{.CreatedAt}}' 2>/dev/null || echo 'Docker nicht verfügbar'
    fi
    echo ''
    echo '=== DOCKER-NETZWERK ==='
    docker network ls 2>/dev/null
    echo ''
    echo '=== VOLUMES UND MOUNTS ==='
    docker volume ls 2>/dev/null | head -10
" 2>&1)

echo "$CONTAINER_INFO"
log "Container-Informationen gesammelt" "{\"has_container\":\"$(echo "$CONTAINER_INFO" | grep -q 'Container ID' && echo 'yes' || echo 'no')\"}"

# ============================================
# 3. WOHER - Netzwerkverbindungen
# ============================================
echo ""
echo "=== 3. WOHER - Netzwerkverbindungen ==="
echo ""

NETWORK_INFO=$(ssh -o ConnectTimeout=10 -o StrictHostKeyChecking=no root@"$TARGET_SERVER" "
    echo '=== AKTIVE VERBINDUNGEN DES PROZESSES ==='
    if [ -d /proc/$SUSPICIOUS_PID ]; then
        # Netzwerkverbindungen
        ss -tnp 2>/dev/null | grep $SUSPICIOUS_PID || netstat -tnp 2>/dev/null | grep $SUSPICIOUS_PID || echo 'Keine direkten Verbindungen gefunden'
        echo ''
        echo '=== ALLE VERBINDUNGEN VOM PROZESS ==='
        for fd in /proc/$SUSPICIOUS_PID/fd/*; do
            TARGET=\$(readlink \"\$fd\" 2>/dev/null)
            if echo \"\$TARGET\" | grep -q socket; then
                echo \"FD: \$fd -> \$TARGET\"
            fi
        done
        echo ''
    echo '=== VERBINDUNGEN NACH IP ==='
    ss -tnp 2>/dev/null | grep -E 'ESTAB|ESTABLISHED' | awk '{print \$5}' | cut -d: -f1 | sort | uniq -c | sort -rn | head -10
    echo ''
    echo '=== VERBINDUNGEN DES PROZESSES (detailliert) ==='
    # Versuche alle Verbindungen des Prozesses zu finden
    lsof -p $SUSPICIOUS_PID -i 2>/dev/null | grep -v COMMAND || \
    netstat -tnp 2>/dev/null | grep $SUSPICIOUS_PID || \
    ss -tnp 2>/dev/null | grep $SUSPICIOUS_PID || \
    echo 'Keine Netzwerkverbindungen direkt sichtbar'
    echo ''
    echo '=== ALLE EXTERNE VERBINDUNGEN (mit Prozess-Info) ==='
    ss -tnp 2>/dev/null | grep -E 'ESTAB|ESTABLISHED' | grep -v '127.0.0.1' | grep -v '::1' | while read line; do
        echo \"\$line\"
        # Extrahiere IP und Port
        REMOTE_IP=\$(echo \"\$line\" | awk '{print \$5}' | cut -d: -f1)
        REMOTE_PORT=\$(echo \"\$line\" | awk '{print \$5}' | cut -d: -f2)
        if [ ! -z \"\$REMOTE_IP\" ] && [ \"\$REMOTE_IP\" != \"\" ]; then
            echo \"  -> Ziel: \$REMOTE_IP:\$REMOTE_PORT\"
        fi
    done
    else
        echo 'Prozess existiert nicht mehr!'
    fi
    echo ''
    echo '=== EXTERNE VERBINDUNGEN (verdächtige IPs) ==='
    ss -tnp 2>/dev/null | grep -E 'ESTAB|ESTABLISHED' | grep -v '127.0.0.1' | grep -v '::1' | awk '{print \$5}' | cut -d: -f1 | sort | uniq | while read ip; do
        if [ ! -z \"\$ip\" ]; then
            echo \"IP: \$ip\"
            # Versuche Reverse DNS
            host \$ip 2>/dev/null | head -1 || echo '  (kein Reverse DNS)'
            # IP-Geolocation (wenn verfügbar)
            whois \$ip 2>/dev/null | grep -iE 'country|org|netname' | head -3 || echo '  (keine WHOIS-Info)'
        fi
    done
" 2>&1)

echo "$NETWORK_INFO"
log "Netzwerk-Informationen gesammelt" "{\"connections_found\":\"$(echo "$NETWORK_INFO" | grep -c 'ESTAB' || echo '0')\"}"

# ============================================
# 4. ZEITLINIE - Wann wurde es installiert?
# ============================================
echo ""
echo "=== 4. ZEITLINIE - Wann wurde es installiert? ==="
echo ""

TIMELINE_INFO=$(ssh -o ConnectTimeout=10 -o StrictHostKeyChecking=no root@"$TARGET_SERVER" "
    echo '=== PROZESS-STARTZEIT ==='
    if [ -d /proc/$SUSPICIOUS_PID ]; then
        START_TIME=\$(stat -c '%Y' /proc/$SUSPICIOUS_PID 2>/dev/null)
        if [ ! -z \"\$START_TIME\" ]; then
            echo \"Start-Zeitstempel: \$START_TIME\"
            echo \"Start-Datum: \$(date -d @\$START_TIME 2>/dev/null || date -r \$START_TIME 2>/dev/null)\"
        fi
        ps -o lstart= -p $SUSPICIOUS_PID 2>/dev/null
    fi
    echo ''
    echo '=== SYSTEM-LOGS (auth.log) ==='
    echo 'Letzte SSH-Logins:'
    grep -E 'Accepted|Failed' /var/log/auth.log 2>/dev/null | tail -20 || \
    grep -E 'Accepted|Failed' /var/log/secure 2>/dev/null | tail -20 || \
    journalctl -u ssh -n 50 2>/dev/null | grep -E 'Accepted|Failed' | tail -20 || \
    echo 'Keine Auth-Logs verfügbar'
    echo ''
    echo '=== DOCKER-LOGS (Zeitpunkt der Infektion) ==='
    CONTAINER_ID=\$(docker ps -q --filter 'name=crm-postgres' 2>/dev/null | head -1)
    if [ ! -z \"\$CONTAINER_ID\" ]; then
        echo 'Container erstellt:'
        docker inspect \$CONTAINER_ID 2>/dev/null | grep Created | head -1
        echo ''
        echo 'Erste Logs mit verdächtigen Aktivitäten:'
        docker logs \$CONTAINER_ID 2>/dev/null | grep -iE 'mysql|exec|download|wget|curl' | head -10 || echo 'Keine verdächtigen Logs'
    fi
    echo ''
    echo '=== CRON-JOBS ==='
    echo 'System-Cron:'
    cat /etc/crontab 2>/dev/null | grep -v '^#' | grep -v '^$' || echo 'Keine System-Cron-Jobs'
    echo ''
    echo 'User-Cron:'
    for user in \$(cut -d: -f1 /etc/passwd); do
        crontab -u \$user -l 2>/dev/null | grep -v '^#' | grep -v '^$' && echo \"  (von User: \$user)\" || true
    done
" 2>&1)

echo "$TIMELINE_INFO"
log "Zeitlinie-Informationen gesammelt" "{\"timeline_available\":\"$(echo "$TIMELINE_INFO" | grep -q 'Start-Datum' && echo 'yes' || echo 'no')\"}"

# ============================================
# 5. DATEI-SYSTEM - Wo liegt die Binary?
# ============================================
echo ""
echo "=== 5. DATEI-SYSTEM - Wo liegt die Binary? ==="
echo ""

FILESYSTEM_INFO=$(ssh -o ConnectTimeout=10 -o StrictHostKeyChecking=no root@"$TARGET_SERVER" "
    echo '=== BINARY-LOKALISATION ==='
    if [ -d /proc/$SUSPICIOUS_PID ]; then
        EXE_PATH=\$(readlink /proc/$SUSPICIOUS_PID/exe 2>/dev/null)
        echo \"Exe-Pfad: \$EXE_PATH\"
        if [ ! -z \"\$EXE_PATH\" ] && [ \"\$EXE_PATH\" != \"N/A\" ]; then
            echo ''
            echo '=== DATEI-DETAILS ==='
            ls -lah \"\$EXE_PATH\" 2>/dev/null || echo 'Datei existiert nicht mehr (gelöscht nach Start)'
            echo ''
            echo '=== DATEI-TYP ==='
            file \"\$EXE_PATH\" 2>/dev/null || echo 'Datei nicht analysierbar'
            echo ''
            echo '=== HASH (MD5) ==='
            md5sum \"\$EXE_PATH\" 2>/dev/null || md5 \"\$EXE_PATH\" 2>/dev/null || echo 'Hash nicht berechenbar'
            echo ''
            echo '=== ÄHNLICHE DATEIEN ==='
            find /tmp -name '*mysql*' -o -name '*miner*' -o -name '*crypto*' 2>/dev/null | head -10
            find /var/tmp -name '*mysql*' -o -name '*miner*' -o -name '*crypto*' 2>/dev/null | head -10
        fi
    fi
    echo ''
    echo '=== VERDÄCHTIGE DATEIEN IN /tmp ==='
    ls -lah /tmp/ | grep -E 'mysql|miner|crypto|\.sh$|\.py$' | head -20 || echo 'Keine verdächtigen Dateien gefunden'
    echo ''
    echo '=== VERDÄCHTIGE CRON-DATEIEN ==='
    find /etc/cron* -type f -exec ls -lah {} \; 2>/dev/null | head -20
" 2>&1)

echo "$FILESYSTEM_INFO"
log "Dateisystem-Informationen gesammelt" "{\"exe_path\":\"$(echo "$FILESYSTEM_INFO" | grep 'Exe-Pfad' | cut -d: -f2 | xargs)\"}"

# ============================================
# 6. ZUSAMMENFASSUNG
# ============================================
echo ""
echo "=========================================="
echo "  ZUSAMMENFASSUNG: WER, WIE, WOHER"
echo "=========================================="
echo ""

SUMMARY=$(ssh -o ConnectTimeout=10 -o StrictHostKeyChecking=no root@"$TARGET_SERVER" "
    echo 'WER:'
    if [ -d /proc/$SUSPICIOUS_PID ]; then
        echo \"  - Prozess: PID $SUSPICIOUS_PID\"
        echo \"  - Command: \$(cat /proc/$SUSPICIOUS_PID/cmdline 2>/dev/null | tr '\\0' ' ' | head -c 100)\"
        echo \"  - User: \$(ps -o user= -p $SUSPICIOUS_PID 2>/dev/null)\"
        echo \"  - Exe: \$(readlink /proc/$SUSPICIOUS_PID/exe 2>/dev/null || echo 'GELÖSCHT')\"
    else
        echo '  - Prozess existiert nicht mehr!'
    fi
    echo ''
    echo 'WIE:'
    CONTAINER_ID=\$(docker ps -q --filter 'name=crm-postgres' 2>/dev/null | head -1)
    if [ ! -z \"\$CONTAINER_ID\" ]; then
        echo \"  - Läuft in Container: \$(docker ps --format '{{.Names}}' --filter id=\$CONTAINER_ID)\"
        echo \"  - Container ID: \$CONTAINER_ID\"
    else
        echo '  - Läuft direkt auf Host (nicht in Container)'
    fi
    echo ''
    echo 'WOHER:'
    echo '  - Externe Verbindungen des Prozesses:'
    lsof -p $SUSPICIOUS_PID -i 2>/dev/null | grep -v COMMAND | awk '{print \"    -> \" \$8 \" \" \$9}' | head -5 || \
    ss -tnp 2>/dev/null | grep $SUSPICIOUS_PID | grep -v '127.0.0.1' | awk '{print \"    -> \" \$5}' | head -5 || \
    echo '    (keine direkten Verbindungen gefunden - möglicherweise über Parent-Prozess)'
    echo ''
    echo '  - Parent-Prozess Verbindungen:'
    PARENT_PID=\$(cat /proc/$SUSPICIOUS_PID/status 2>/dev/null | grep PPid | awk '{print \$2}')
    if [ ! -z \"\$PARENT_PID\" ] && [ \"\$PARENT_PID\" != \"1\" ]; then
        lsof -p \$PARENT_PID -i 2>/dev/null | grep -v COMMAND | awk '{print \"    -> \" \$8 \" \" \$9}' | head -5 || echo '    (keine Verbindungen)'
    fi
    echo ''
    echo '  - Alle verdächtigen externen IPs auf dem System:'
    ss -tnp 2>/dev/null | grep -E 'ESTAB|ESTABLISHED' | grep -v '127.0.0.1' | awk '{print \$5}' | cut -d: -f1 | sort | uniq | head -10 | while read ip; do
        if [ ! -z \"\$ip\" ]; then
            echo \"    \$ip\"
        fi
    done
" 2>&1)

echo "$SUMMARY"

log "Forensische Analyse abgeschlossen" "{\"summary\":\"complete\"}"

echo ""
echo "=== Analyse abgeschlossen ==="
echo "Detaillierte Informationen siehe oben."
echo ""

