#!/bin/bash
# Lokales Deployment-Script - Führt alle Schritte aus

set -e

SERVER_IP="49.13.158.176"
SERVER_USER="root"
PROJECT_DIR="/root/Superman/emir-superman"

echo "🚀 Supervisor Deployment zu Hetzner Server"
echo "=========================================="
echo "Server: $SERVER_USER@$SERVER_IP"
echo ""

# 1. Script hochladen
echo "📤 Lade deploy.sh zum Server hoch..."
scp deploy.sh $SERVER_USER@$SERVER_IP:/root/deploy.sh

# 2. Installation auf Server
echo ""
echo "📦 Führe Installation auf Server aus..."
ssh $SERVER_USER@$SERVER_IP << 'ENDSSH'
chmod +x /root/deploy.sh
/root/deploy.sh
ENDSSH

# 3. Code deployen
echo ""
echo "📤 Deploye Code zum Server..."
ssh $SERVER_USER@$SERVER_IP << 'ENDSSH'
cd /root
if [ -d "Superman" ]; then
    echo "📁 Repository existiert bereits, aktualisiere..."
    cd Superman
    git pull
else
    echo "📁 Klone Repository..."
    git clone https://github.com/devshift-stack/Superman.git
fi
cd Superman/emir-superman
npm install
ENDSSH

# 4. .env Datei prüfen
echo ""
echo "📝 Prüfe .env Datei..."
ssh $SERVER_USER@$SERVER_IP << 'ENDSSH'
cd /root/Superman/emir-superman
if [ ! -f ".env" ]; then
    echo "⚠️ .env Datei nicht gefunden!"
    echo "Erstelle .env aus .env.example..."
    cp .env.example .env
    echo ""
    echo "⚠️ WICHTIG: Bearbeite .env und füge deine API-Keys ein!"
    echo "Befehl: ssh root@49.13.158.176 'nano /root/Superman/emir-superman/.env'"
else
    echo "✅ .env Datei existiert bereits"
fi
ENDSSH

# 5. Server starten
echo ""
echo "🚀 Starte Supervisor..."
ssh $SERVER_USER@$SERVER_IP << 'ENDSSH'
cd /root/Superman/emir-superman
if command -v pm2 &> /dev/null; then
    pm2 stop supervisor 2>/dev/null || true
    pm2 start server.js --name supervisor
    pm2 save
    echo "✅ Supervisor läuft mit PM2"
    pm2 status
else
    echo "⚠️ PM2 nicht gefunden, starte direkt..."
    nohup node server.js > server.log 2>&1 &
    echo "✅ Supervisor gestartet (PID: $!)"
fi
ENDSSH

echo ""
echo "✅ Deployment abgeschlossen!"
echo ""
echo "🔍 Teste Server:"
echo "curl http://$SERVER_IP:3000/health"
echo ""
echo "📊 PM2 Status prüfen:"
echo "ssh $SERVER_USER@$SERVER_IP 'pm2 status'"

