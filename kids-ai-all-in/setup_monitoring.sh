#!/bin/bash

# Setup-Skript für automatisches Security-Monitoring
# Installiert Cron-Job für regelmäßige Überwachung

SCRIPT_DIR="/Users/dsselmanovic/cursor project/kids-ai-all-in"
MONITOR_SCRIPT="$SCRIPT_DIR/security_monitor.sh"
CRON_LOG="$SCRIPT_DIR/monitoring_cron.log"

echo "=========================================="
echo "  SECURITY MONITORING SETUP"
echo "=========================================="
echo ""

# Prüfe ob Skript existiert
if [ ! -f "$MONITOR_SCRIPT" ]; then
    echo "❌ Fehler: $MONITOR_SCRIPT nicht gefunden!"
    exit 1
fi

# Mache Skript ausführbar
chmod +x "$MONITOR_SCRIPT"
echo "✓ Skript ausführbar gemacht"

# Erstelle Cron-Job
CRON_ENTRY="*/15 * * * * $MONITOR_SCRIPT >> $CRON_LOG 2>&1"

# Prüfe ob bereits ein Cron-Job existiert
if crontab -l 2>/dev/null | grep -q "$MONITOR_SCRIPT"; then
    echo "⚠️  Cron-Job existiert bereits"
    echo "Aktueller Eintrag:"
    crontab -l | grep "$MONITOR_SCRIPT"
    echo ""
    read -p "Möchtest du den bestehenden Eintrag ersetzen? (j/n): " replace
    if [ "$replace" = "j" ] || [ "$replace" = "J" ]; then
        # Entferne alten Eintrag
        crontab -l 2>/dev/null | grep -v "$MONITOR_SCRIPT" | crontab -
        # Füge neuen Eintrag hinzu
        (crontab -l 2>/dev/null; echo "$CRON_ENTRY") | crontab -
        echo "✓ Cron-Job aktualisiert"
    fi
else
    # Füge neuen Cron-Job hinzu
    (crontab -l 2>/dev/null; echo "$CRON_ENTRY") | crontab -
    echo "✓ Cron-Job hinzugefügt (läuft alle 15 Minuten)"
fi

echo ""
echo "=========================================="
echo "  SETUP ABGESCHLOSSEN"
echo "=========================================="
echo ""
echo "Monitoring läuft jetzt automatisch alle 15 Minuten"
echo ""
echo "Nützliche Befehle:"
echo "  - Cron-Jobs anzeigen: crontab -l"
echo "  - Cron-Log anzeigen: tail -f $CRON_LOG"
echo "  - Alerts anzeigen: tail -f $SCRIPT_DIR/security_alerts.log"
echo "  - Reports anzeigen: ls -lth $SCRIPT_DIR/security_reports/"
echo "  - Manuell ausführen: $MONITOR_SCRIPT"
echo ""

