#!/bin/bash

# Detaillierte Forensische Analyse
# Untersucht genau: Wer hat sich wann eingeloggt und was ist passiert?

LOG_FILE="/Users/dsselmanovic/cursor project/kids-ai-all-in/.cursor/debug.log"
TARGET_SERVER="46.62.254.77"
REPORT_FILE="/Users/dsselmanovic/cursor project/kids-ai-all-in/forensic_detailed_report_$(date +%Y%m%d_%H%M%S).txt"

# Logging-Funktion
log() {
    local message="$1"
    local data="$2"
    local timestamp=$(python3 -c "import time; print(int(time.time() * 1000))" 2>/dev/null || date +%s000)
    local log_entry="{\"id\":\"log_${timestamp}_$$\",\"timestamp\":${timestamp},\"location\":\"detailed_forensic.sh\",\"message\":\"${message}\",\"data\":${data},\"sessionId\":\"detailed-forensic\",\"runId\":\"run1\"}"
    echo "$log_entry" >> "$LOG_FILE"
}

echo "=========================================="
echo "  DETAILLIERTE FORENSISCHE ANALYSE"
echo "=========================================="
echo "Server: $TARGET_SERVER"
echo "Report: $REPORT_FILE"
echo ""

log "Detaillierte Forensische Analyse gestartet" "{\"server\":\"$TARGET_SERVER\"}"

# ============================================
# 1. SSH-LOGIN-ANALYSE (Detailliert)
# ============================================
echo "=== 1. SSH-LOGIN-ANALYSE ===" | tee -a "$REPORT_FILE"
echo ""

SSH_ANALYSIS=$(ssh -o ConnectTimeout=10 -o StrictHostKeyChecking=no root@"$TARGET_SERVER" "
    echo '=== ALLE SSH-LOGINS (letzte 7 Tage) ==='
    
    # Versuche verschiedene Log-Dateien
    for logfile in /var/log/auth.log /var/log/secure /var/log/messages; do
        if [ -f \"\$logfile\" ]; then
            echo \"--- Log: \$logfile ---\"
            grep -E 'Accepted|Failed|Invalid' \"\$logfile\" 2>/dev/null | \
            awk -v days=7 '\$1 >= \"\$(date -d \"-\"days\" days\" +%Y-%m-%d 2>/dev/null || date -v-\"days\"d +%Y-%m-%d 2>/dev/null)\" {print}' | \
            tail -100
            break
        fi
    done
    
    # Systemd Journal
    echo ''
    echo '--- Systemd Journal (SSH) ---'
    journalctl -u ssh -n 200 --no-pager 2>/dev/null | grep -E 'Accepted|Failed|Invalid' | tail -50 || \
    journalctl _SYSTEMD_UNIT=sshd.service -n 200 --no-pager 2>/dev/null | grep -E 'Accepted|Failed|Invalid' | tail -50 || \
    echo 'Journal nicht verfügbar'
    
    echo ''
    echo '=== ERFOLGREICHE LOGINS (Detailliert) ==='
    for logfile in /var/log/auth.log /var/log/secure; do
        if [ -f \"\$logfile\" ]; then
            grep 'Accepted' \"\$logfile\" 2>/dev/null | tail -50 | while read line; do
                TIMESTAMP=\$(echo \"\$line\" | awk '{print \$1 \" \" \$2 \" \" \$3}')
                METHOD=\$(echo \"\$line\" | grep -oE 'publickey|password|keyboard-interactive')
                USER=\$(echo \"\$line\" | grep -oE 'for [^ ]+' | awk '{print \$2}')
                IP=\$(echo \"\$line\" | grep -oE 'from [0-9.]+' | awk '{print \$2}')
                PORT=\$(echo \"\$line\" | grep -oE 'port [0-9]+' | awk '{print \$2}')
                KEY=\$(echo \"\$line\" | grep -oE 'SHA256:[A-Za-z0-9+/=]+' || echo 'N/A')
                echo \"\$TIMESTAMP | \$METHOD | \$USER | \$IP:\$PORT | Key: \$KEY\"
            done
            break
        fi
    done
    
    echo ''
    echo '=== FEHLGESCHLAGENE LOGIN-VERSUCHE ==='
    for logfile in /var/log/auth.log /var/log/secure; do
        if [ -f \"\$logfile\" ]; then
            grep -E 'Failed password|Invalid user' \"\$logfile\" 2>/dev/null | tail -50 | while read line; do
                TIMESTAMP=\$(echo \"\$line\" | awk '{print \$1 \" \" \$2 \" \" \$3}')
                TYPE=\$(echo \"\$line\" | grep -oE 'Failed password|Invalid user')
                USER=\$(echo \"\$line\" | grep -oE 'for [^ ]+|user [^ ]+' | awk '{print \$2}')
                IP=\$(echo \"\$line\" | grep -oE 'from [0-9.]+' | awk '{print \$2}')
                echo \"\$TIMESTAMP | \$TYPE | User: \$USER | \$IP\"
            done
            break
        fi
    done
    
    echo ''
    echo '=== IP-STATISTIKEN ==='
    echo 'Erfolgreiche Logins nach IP:'
    for logfile in /var/log/auth.log /var/log/secure; do
        if [ -f \"\$logfile\" ]; then
            grep 'Accepted' \"\$logfile\" 2>/dev/null | grep -oE 'from [0-9.]+' | awk '{print \$2}' | sort | uniq -c | sort -rn | head -20
            break
        fi
    done
    
    echo ''
    echo 'Fehlgeschlagene Versuche nach IP:'
    for logfile in /var/log/auth.log /var/log/secure; do
        if [ -f \"\$logfile\" ]; then
            grep -E 'Failed password|Invalid user' \"\$logfile\" 2>/dev/null | grep -oE 'from [0-9.]+' | awk '{print \$2}' | sort | uniq -c | sort -rn | head -20
            break
        fi
    done
" 2>&1)

echo "$SSH_ANALYSIS" | tee -a "$REPORT_FILE"
log "SSH-Login-Analyse abgeschlossen" "{\"lines\":$(echo "$SSH_ANALYSIS" | wc -l)}"

# ============================================
# 2. SSH-KEY-ANALYSE
# ============================================
echo ""
echo "=== 2. SSH-KEY-ANALYSE ===" | tee -a "$REPORT_FILE"
echo ""

SSH_KEY_ANALYSIS=$(ssh -o ConnectTimeout=10 -o StrictHostKeyChecking=no root@"$TARGET_SERVER" "
    echo '=== AUTORISIERTE SSH-KEYS ==='
    echo 'Root authorized_keys:'
    cat /root/.ssh/authorized_keys 2>/dev/null | while read line; do
        if [ ! -z \"\$line\" ] && [ \"\$line\" != \"\" ]; then
            KEY_TYPE=\$(echo \"\$line\" | awk '{print \$1}')
            KEY_FINGERPRINT=\$(echo \"\$line\" | ssh-keygen -lf - 2>/dev/null | awk '{print \$2}' || echo 'N/A')
            COMMENT=\$(echo \"\$line\" | awk '{print \$3}')
            echo \"  Type: \$KEY_TYPE | Fingerprint: \$KEY_FINGERPRINT | Comment: \$COMMENT\"
        fi
    done || echo 'Keine authorized_keys gefunden'
    
    echo ''
    echo '=== SSH-KONFIGURATION ==='
    echo 'sshd_config wichtige Einstellungen:'
    grep -E '^PermitRootLogin|^PasswordAuthentication|^PubkeyAuthentication|^AuthorizedKeysFile' /etc/ssh/sshd_config 2>/dev/null || echo 'Konfiguration nicht lesbar'
    
    echo ''
    echo '=== AKTIVE SSH-SESSIONS ==='
    who
    echo ''
    echo '=== SSH-PROZESSE ==='
    ps aux | grep sshd | grep -v grep | head -10
" 2>&1)

echo "$SSH_KEY_ANALYSIS" | tee -a "$REPORT_FILE"
log "SSH-Key-Analyse abgeschlossen" "{\"keys_found\":$(echo "$SSH_KEY_ANALYSIS" | grep -c 'Type:' || echo '0')}"

# ============================================
# 3. TIMELINE DER EREIGNISSE
# ============================================
echo ""
echo "=== 3. TIMELINE DER EREIGNISSE ===" | tee -a "$REPORT_FILE"
echo ""

TIMELINE=$(ssh -o ConnectTimeout=10 -o StrictHostKeyChecking=no root@"$TARGET_SERVER" "
    echo '=== KRITISCHE ZEITPUNKTE ==='
    echo ''
    echo '1. Container erstellt:'
    docker inspect crm-postgres 2>/dev/null | grep Created | head -1
    echo ''
    echo '2. Verdächtiger Prozess gestartet:'
    if [ -d /proc/2144884 ]; then
        START_TIME=\$(stat -c '%Y' /proc/2144884 2>/dev/null)
        if [ ! -z \"\$START_TIME\" ]; then
            echo \"   Start-Zeitstempel: \$START_TIME\"
            echo \"   Start-Datum: \$(date -d @\$START_TIME 2>/dev/null || date -r \$START_TIME 2>/dev/null)\"
        fi
        ps -o lstart= -p 2144884 2>/dev/null
    else
        echo '   Prozess existiert nicht mehr'
    fi
    echo ''
    echo '=== SSH-LOGINS UM DIE ZEIT DER INFECTION ==='
    INFECTION_TIME='2025-12-18 06:29'
    for logfile in /var/log/auth.log /var/log/secure; do
        if [ -f \"\$logfile\" ]; then
            echo \"Logins am 18.12.2025 um 06:xx:\"
            grep 'Accepted' \"\$logfile\" 2>/dev/null | grep 'Dec 18.*06:' | head -20
            echo ''
            echo \"Logins am 18.12.2025 um 05:xx (Stunde davor):\"
            grep 'Accepted' \"\$logfile\" 2>/dev/null | grep 'Dec 18.*05:' | head -20
            echo ''
            echo \"Logins am 18.12.2025 um 07:xx (Stunde danach):\"
            grep 'Accepted' \"\$logfile\" 2>/dev/null | grep 'Dec 18.*07:' | head -20
            break
        fi
    done
    echo ''
    echo '=== ALLE LOGINS AM 18.12.2025 ==='
    for logfile in /var/log/auth.log /var/log/secure; do
        if [ -f \"\$logfile\" ]; then
            grep 'Accepted' \"\$logfile\" 2>/dev/null | grep 'Dec 18' | while read line; do
                TIMESTAMP=\$(echo \"\$line\" | awk '{print \$1 \" \" \$2 \" \" \$3}')
                IP=\$(echo \"\$line\" | grep -oE 'from [0-9.]+' | awk '{print \$2}')
                METHOD=\$(echo \"\$line\" | grep -oE 'publickey|password')
                KEY=\$(echo \"\$line\" | grep -oE 'SHA256:[A-Za-z0-9+/=]+' || echo 'N/A')
                echo \"\$TIMESTAMP | \$IP | \$METHOD | Key: \$KEY\"
            done
            break
        fi
    done
" 2>&1)

echo "$TIMELINE" | tee -a "$REPORT_FILE"
log "Timeline-Analyse abgeschlossen" "{\"events_found\":$(echo "$TIMELINE" | grep -c 'Accepted' || echo '0')}"

# ============================================
# 4. IP-VERGLEICH UND GEOLOCATION
# ============================================
echo ""
echo "=== 4. IP-ANALYSE UND VERGLEICH ===" | tee -a "$REPORT_FILE"
echo ""

IP_ANALYSIS=$(ssh -o ConnectTimeout=10 -o StrictHostKeyChecking=no root@"$TARGET_SERVER" "
    echo '=== ALLE EINZIGARTIGEN IPs MIT LOGINS ==='
    for logfile in /var/log/auth.log /var/log/secure; do
        if [ -f \"\$logfile\" ]; then
            grep 'Accepted' \"\$logfile\" 2>/dev/null | grep -oE 'from [0-9.]+' | awk '{print \$2}' | sort | uniq | while read ip; do
                if [ ! -z \"\$ip\" ]; then
                    COUNT=\$(grep \"\$ip\" \"\$logfile\" | grep -c 'Accepted' 2>/dev/null || echo '0')
                    FIRST=\$(grep \"\$ip\" \"\$logfile\" | grep 'Accepted' | head -1 | awk '{print \$1 \" \" \$2 \" \" \$3}')
                    LAST=\$(grep \"\$ip\" \"\$logfile\" | grep 'Accepted' | tail -1 | awk '{print \$1 \" \" \$2 \" \" \$3}')
                    KEY=\$(grep \"\$ip\" \"\$logfile\" | grep 'Accepted' | head -1 | grep -oE 'SHA256:[A-Za-z0-9+/=]+' || echo 'Verschiedene Keys')
                    echo \"IP: \$ip | Logins: \$COUNT | Erster: \$FIRST | Letzter: \$LAST | Key: \$KEY\"
                fi
            done
            break
        fi
    done
" 2>&1)

echo "$IP_ANALYSIS" | tee -a "$REPORT_FILE"

# Prüfe bekannte IPs
echo ""
echo "=== IP-VERGLEICH MIT DEINEM SYSTEM ===" | tee -a "$REPORT_FILE"
MY_IP=$(curl -s ifconfig.me 2>/dev/null || curl -s ipinfo.io/ip 2>/dev/null || echo "N/A")
echo "Deine aktuelle öffentliche IP: $MY_IP" | tee -a "$REPORT_FILE"

if [ "$MY_IP" != "N/A" ]; then
    echo ""
    echo "Vergleich mit Server-Logins:" | tee -a "$REPORT_FILE"
    echo "$IP_ANALYSIS" | grep "$MY_IP" | tee -a "$REPORT_FILE" || echo "Deine IP wurde nicht in den Logins gefunden" | tee -a "$REPORT_FILE"
fi

log "IP-Analyse abgeschlossen" "{\"my_ip\":\"$MY_IP\"}"

# ============================================
# 5. BRUTE-FORCE vs LEGITIME LOGINS
# ============================================
echo ""
echo "=== 5. BRUTE-FORCE vs LEGITIME LOGINS ===" | tee -a "$REPORT_FILE"
echo ""

BRUTE_ANALYSIS=$(ssh -o ConnectTimeout=10 -o StrictHostKeyChecking=no root@"$TARGET_SERVER" "
    echo '=== BRUTE-FORCE-ANALYSE ==='
    echo ''
    echo 'IPs mit vielen fehlgeschlagenen Versuchen (>10):'
    for logfile in /var/log/auth.log /var/log/secure; do
        if [ -f \"\$logfile\" ]; then
            grep -E 'Failed password|Invalid user' \"\$logfile\" 2>/dev/null | \
            grep -oE 'from [0-9.]+' | awk '{print \$2}' | sort | uniq -c | sort -rn | \
            awk '\$1 > 10 {print \"  \" \$2 \": \" \$1 \" fehlgeschlagene Versuche\"}'
            break
        fi
    done
    echo ''
    echo '=== IPs MIT ERFOLGREICHEN LOGINS ==='
    for logfile in /var/log/auth.log /var/log/secure; do
        if [ -f \"\$logfile\" ]; then
            grep 'Accepted' \"\$logfile\" 2>/dev/null | \
            grep -oE 'from [0-9.]+' | awk '{print \$2}' | sort | uniq -c | sort -rn | \
            head -20 | while read count ip; do
                FAILED=\$(grep \"\$ip\" \"\$logfile\" | grep -cE 'Failed password|Invalid user' 2>/dev/null || echo '0')
                METHOD=\$(grep \"\$ip\" \"\$logfile\" | grep 'Accepted' | head -1 | grep -oE 'publickey|password' || echo 'N/A')
                RATIO=\$(echo \"scale=2; \$FAILED / \$count\" | bc 2>/dev/null || echo 'N/A')
                if [ \"\$FAILED\" -gt 0 ]; then
                    echo \"  \$ip: \$count erfolgreich, \$FAILED fehlgeschlagen (Ratio: \$RATIO) - Methode: \$METHOD\"
                else
                    echo \"  \$ip: \$count erfolgreich, 0 fehlgeschlagen - Methode: \$METHOD [VERDÄCHTIG: Nur Erfolg, kein Versuch]\"
                fi
            done
            break
        fi
    done
    echo ''
    echo '=== ZUSAMMENFASSUNG ==='
    echo 'Legitime Logins (Public Key, keine fehlgeschlagenen Versuche):'
    for logfile in /var/log/auth.log /var/log/secure; do
        if [ -f \"\$logfile\" ]; then
            grep 'Accepted.*publickey' \"\$logfile\" 2>/dev/null | \
            grep -oE 'from [0-9.]+' | awk '{print \$2}' | sort | uniq | while read ip; do
                FAILED=\$(grep \"\$ip\" \"\$logfile\" | grep -cE 'Failed password|Invalid user' 2>/dev/null || echo '0')
                if [ \"\$FAILED\" -eq 0 ]; then
                    echo \"  \$ip - Nur Public Key, keine Fehlversuche\"
                fi
            done
            break
        fi
    done
" 2>&1)

echo "$BRUTE_ANALYSIS" | tee -a "$REPORT_FILE"
log "Brute-Force-Analyse abgeschlossen" "{\"analysis_complete\":true}"

# ============================================
# 6. KORRELATION: LOGINS vs MALWARE
# ============================================
echo ""
echo "=== 6. KORRELATION: LOGINS vs MALWARE-INSTALLATION ===" | tee -a "$REPORT_FILE"
echo ""

CORRELATION=$(ssh -o ConnectTimeout=10 -o StrictHostKeyChecking=no root@"$TARGET_SERVER" "
    echo '=== LOGINS KURZ VOR MALWARE-START ==='
    MALWARE_START='2025-12-18 06:29'
    echo \"Malware gestartet: \$MALWARE_START\"
    echo ''
    echo 'Logins in den 2 Stunden davor (04:29 - 06:29):'
    for logfile in /var/log/auth.log /var/log/secure; do
        if [ -f \"\$logfile\" ]; then
            grep 'Accepted' \"\$logfile\" 2>/dev/null | grep 'Dec 18' | \
            awk '\$3 >= \"04:29:00\" && \$3 <= \"06:29:00\" {print}' | \
            while read line; do
                TIMESTAMP=\$(echo \"\$line\" | awk '{print \$1 \" \" \$2 \" \" \$3}')
                IP=\$(echo \"\$line\" | grep -oE 'from [0-9.]+' | awk '{print \$2}')
                METHOD=\$(echo \"\$line\" | grep -oE 'publickey|password')
                KEY=\$(echo \"\$line\" | grep -oE 'SHA256:[A-Za-z0-9+/=]+' || echo 'N/A')
                echo \"  \$TIMESTAMP | \$IP | \$METHOD | Key: \$KEY\"
            done
            break
        fi
    done
    echo ''
    echo '=== LOGINS KURZ NACH MALWARE-START ==='
    echo 'Logins in den 2 Stunden danach (06:29 - 08:29):'
    for logfile in /var/log/auth.log /var/log/secure; do
        if [ -f \"\$logfile\" ]; then
            grep 'Accepted' \"\$logfile\" 2>/dev/null | grep 'Dec 18' | \
            awk '\$3 >= \"06:29:00\" && \$3 <= \"08:29:00\" {print}' | \
            while read line; do
                TIMESTAMP=\$(echo \"\$line\" | awk '{print \$1 \" \" \$2 \" \" \$3}')
                IP=\$(echo \"\$line\" | grep -oE 'from [0-9.]+' | awk '{print \$2}')
                METHOD=\$(echo \"\$line\" | grep -oE 'publickey|password')
                KEY=\$(echo \"\$line\" | grep -oE 'SHA256:[A-Za-z0-9+/=]+' || echo 'N/A')
                echo \"  \$TIMESTAMP | \$IP | \$METHOD | Key: \$KEY\"
            done
            break
        fi
    done
" 2>&1)

echo "$CORRELATION" | tee -a "$REPORT_FILE"
log "Korrelations-Analyse abgeschlossen" "{\"correlation_complete\":true}"

# ============================================
# ZUSAMMENFASSUNG
# ============================================
echo ""
echo "==========================================" | tee -a "$REPORT_FILE"
echo "  ZUSAMMENFASSUNG" | tee -a "$REPORT_FILE"
echo "==========================================" | tee -a "$REPORT_FILE"
echo ""

SUMMARY=$(cat <<EOF
ANALYSE-ERGEBNISSE:

1. SSH-LOGINS:
   - Erfolgreiche Logins wurden analysiert
   - Fehlgeschlagene Versuche wurden gezählt
   - IPs wurden kategorisiert

2. AUTHENTIFIZIERUNG:
   - Public Key vs Password Logins
   - SSH-Key-Fingerprints
   - Autorisiere Keys

3. TIMELINE:
   - Container-Erstellung: 15.12.2025 17:31
   - Malware-Start: 18.12.2025 06:29
   - Logins um diese Zeit wurden identifiziert

4. IP-VERGLEICH:
   - Deine aktuelle IP: $MY_IP
   - Vergleich mit Server-Logins durchgeführt

5. BRUTE-FORCE vs LEGITIM:
   - IPs mit vielen Fehlversuchen = Brute-Force
   - IPs mit nur erfolgreichen Public Key Logins = Legitim
   - Verdächtige IPs identifiziert

6. KORRELATION:
   - Logins vor/nach Malware-Installation
   - Mögliche Angreifer-IPs identifiziert

NÄCHSTE SCHRITTE:
- Prüfe den Report: $REPORT_FILE
- Vergleiche IPs mit deinen bekannten Systemen
- Prüfe SSH-Keys auf deinem System
EOF
)

echo "$SUMMARY" | tee -a "$REPORT_FILE"

log "Detaillierte Forensische Analyse abgeschlossen" "{\"report\":\"$REPORT_FILE\"}"

echo ""
echo "=== Analyse abgeschlossen ==="
echo "Detaillierter Report: $REPORT_FILE"
echo ""

