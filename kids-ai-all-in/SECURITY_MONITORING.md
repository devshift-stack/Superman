# Security Monitoring System

Ein umfassendes Security-Monitoring-System zur kontinuierlichen Überwachung und Absicherung Ihrer Server.

## 📋 Übersicht

Das System besteht aus drei Hauptkomponenten:

1. **security_monitor.sh** - Hauptüberwachungstool
2. **setup_monitoring.sh** - Automatische Einrichtung
3. **security_response.sh** - Automatische Gegenmaßnahmen

## 🚀 Schnellstart

### 1. Einrichtung

```bash
./setup_monitoring.sh
```

Dies installiert einen Cron-Job, der alle 15 Minuten automatisch scannt.

### 2. Manueller Scan

```bash
./security_monitor.sh
```

### 3. Automatische Response

```bash
./security_response.sh auto
```

## 📊 Überwachte Bereiche

### 1. CPU & Load Monitoring
- **Threshold**: CPU > 90%, Load > 10
- **Alert**: CRITICAL bei Überschreitung

### 2. Verdächtige Prozesse
Erkennt Prozesse mit verdächtigen Namen oder in verdächtigen Pfaden:
- Namen: `mysql`, `miner`, `crypto`, `xmr`, `xmrig`, `stratum`
- Pfade: `/tmp`, `/var/tmp`, `/dev/shm`
- Gelöschte Binaries (N/A Exe-Pfad)

### 3. Netzwerk-Monitoring
- Externe Verbindungen
- Verdächtige IPs
- Brute-Force-Erkennung (>10 Verbindungen)

### 4. Dateisystem-Check
- Verdächtige Dateien in `/tmp`, `/var/tmp`, `/dev/shm`
- Dateien mit verdächtigen Namen

### 5. Container-Sicherheit
- Überwachung aller Docker-Container
- Verdächtige Prozesse in Containern

### 6. SSH-Login-Monitoring
- Fehlgeschlagene Login-Versuche
- Brute-Force-Erkennung

## 📁 Ausgabe-Dateien

### Reports
- **Ort**: `security_reports/security_report_YYYYMMDD_HHMMSS.txt`
- **Inhalt**: Detaillierte Scan-Ergebnisse

### Alerts
- **Ort**: `security_alerts.log`
- **Inhalt**: Alle Sicherheitswarnungen mit Zeitstempel

### Responses
- **Ort**: `security_responses.log`
- **Inhalt**: Durchgeführte Gegenmaßnahmen

### Cron-Log
- **Ort**: `monitoring_cron.log`
- **Inhalt**: Ausgabe der automatischen Scans

## 🔧 Manuelle Response-Befehle

### Prozess stoppen
```bash
./security_response.sh kill <server> <ip> <pid>
# Beispiel:
./security_response.sh kill crm 46.62.254.77 2144884
```

### Container neu starten
```bash
./security_response.sh restart <server> <ip> <container>
# Beispiel:
./security_response.sh restart crm 46.62.254.77 crm-postgres
```

### IP blockieren
```bash
./security_response.sh block <server> <ip> <block_ip>
# Beispiel:
./security_response.sh block crm 46.62.254.77 115.190.140.2
```

### Dateien bereinigen
```bash
./security_response.sh cleanup <server> <ip>
# Beispiel:
./security_response.sh cleanup crm 46.62.254.77
```

## 📈 Monitoring

### Cron-Job anzeigen
```bash
crontab -l
```

### Live-Logs anzeigen
```bash
# Alerts
tail -f security_alerts.log

# Cron-Ausgabe
tail -f monitoring_cron.log

# Responses
tail -f security_responses.log
```

### Reports anzeigen
```bash
# Neueste Reports
ls -lth security_reports/

# Report anzeigen
cat security_reports/security_report_*.txt | less
```

## ⚙️ Konfiguration

### Server-Liste anpassen
Bearbeite `security_monitor.sh`:
```bash
SERVERS=(
    "videose|77.42.46.56"
    "crm|46.62.254.77"
    "sipgate|116.203.245.77"
    "Scrap|91.98.78.198"
)
```

### Thresholds anpassen
Bearbeite `security_monitor.sh`:
```bash
CPU_THRESHOLD=90
LOAD_THRESHOLD=10
MEMORY_THRESHOLD=90
```

### Scan-Intervall ändern
Bearbeite `setup_monitoring.sh`:
```bash
# Alle 15 Minuten (aktuell)
CRON_ENTRY="*/15 * * * * $MONITOR_SCRIPT >> $CRON_LOG 2>&1"

# Alle 5 Minuten
CRON_ENTRY="*/5 * * * * $MONITOR_SCRIPT >> $CRON_LOG 2>&1"

# Stündlich
CRON_ENTRY="0 * * * * $MONITOR_SCRIPT >> $CRON_LOG 2>&1"
```

## 🛡️ Best Practices

1. **Regelmäßige Reviews**: Prüfe `security_alerts.log` täglich
2. **Automatische Responses**: Nutze `security_response.sh auto` vorsichtig
3. **Backup vor Response**: Erstelle Backups vor automatischen Aktionen
4. **Log-Rotation**: Richte Log-Rotation für große Log-Dateien ein
5. **Benachrichtigungen**: Erweitere das System um E-Mail/Slack-Benachrichtigungen

## 🔍 Beispiel-Workflow

### 1. Täglicher Check
```bash
# Alerts prüfen
grep CRITICAL security_alerts.log | tail -20

# Neueste Reports
ls -lth security_reports/ | head -5
```

### 2. Bei kritischem Alert
```bash
# Detaillierte Analyse
./forensic_analysis.sh

# Automatische Response
./security_response.sh auto

# Oder manuell
./security_response.sh kill crm 46.62.254.77 <PID>
./security_response.sh restart crm 46.62.254.77 crm-postgres
```

### 3. Wöchentliche Review
```bash
# Zusammenfassung
echo "=== Kritische Alerts diese Woche ==="
grep CRITICAL security_alerts.log | grep "$(date +%Y-%m-%d -d '7 days ago')"

echo "=== Top verdächtige IPs ==="
grep "Viele Verbindungen" security_alerts.log | awk '{print $NF}' | sort | uniq -c | sort -rn
```

## 📞 Support

Bei Fragen oder Problemen:
1. Prüfe die Logs: `security_alerts.log`, `monitoring_cron.log`
2. Führe manuellen Scan aus: `./security_monitor.sh`
3. Prüfe SSH-Verbindungen zu den Servern

## 🔐 Sicherheitshinweise

- **SSH-Keys**: Stelle sicher, dass SSH-Keys sicher gespeichert sind
- **Berechtigungen**: Skripte sollten nur von autorisierten Benutzern ausgeführt werden
- **Logs**: Enthalten möglicherweise sensible Informationen - sicher aufbewahren
- **Automatische Responses**: Teste vor Produktionseinsatz gründlich

