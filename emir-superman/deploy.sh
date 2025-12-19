#!/bin/bash
# Deployment Script für Hetzner Server

set -e

echo "🚀 Supervisor Deployment Script"
echo "================================"

# Prüfe ob auf Server
if [ ! -f "/etc/os-release" ]; then
    echo "❌ Bitte auf dem Server ausführen!"
    exit 1
fi

# OS erkennen
if grep -q "CentOS" /etc/os-release || grep -q "Rocky" /etc/os-release; then
    OS="centos"
elif grep -q "Ubuntu" /etc/os-release || grep -q "Debian" /etc/os-release; then
    OS="ubuntu"
else
    echo "⚠️ Unbekanntes OS, versuche Ubuntu-Befehle..."
    OS="ubuntu"
fi

echo "📦 OS erkannt: $OS"

# 1. System Update
echo ""
echo "📦 System Update..."
if [ "$OS" = "centos" ]; then
    yum update -y
else
    apt update && apt upgrade -y
fi

# 2. Node.js installieren
echo ""
echo "📦 Node.js installieren..."
if ! command -v node &> /dev/null; then
    if [ "$OS" = "centos" ]; then
        curl -fsSL https://rpm.nodesource.com/setup_20.x | bash -
        yum install -y nodejs
    else
        curl -fsSL https://deb.nodesource.com/setup_20.x | bash -
        apt-get install -y nodejs
    fi
else
    echo "✅ Node.js bereits installiert: $(node --version)"
fi

# 3. Redis installieren
echo ""
echo "📦 Redis installieren..."
if ! command -v redis-cli &> /dev/null; then
    if [ "$OS" = "centos" ]; then
        yum install -y redis
        systemctl start redis
        systemctl enable redis
    else
        apt install -y redis-server
        systemctl start redis-server
        systemctl enable redis-server
    fi
    redis-cli ping || echo "⚠️ Redis startet..."
else
    echo "✅ Redis bereits installiert"
    systemctl start redis 2>/dev/null || systemctl start redis-server 2>/dev/null || true
fi

# 4. Git installieren
echo ""
echo "📦 Git installieren..."
if ! command -v git &> /dev/null; then
    if [ "$OS" = "centos" ]; then
        yum install -y git
    else
        apt install -y git
    fi
else
    echo "✅ Git bereits installiert: $(git --version)"
fi

# 5. PM2 installieren (für Process Management)
echo ""
echo "📦 PM2 installieren..."
if ! command -v pm2 &> /dev/null; then
    npm install -g pm2
else
    echo "✅ PM2 bereits installiert"
fi

echo ""
echo "✅ Installation abgeschlossen!"
echo ""
echo "📊 Versions-Check:"
node --version
npm --version
redis-cli --version 2>/dev/null || echo "Redis: installiert"
git --version
pm2 --version

echo ""
echo "🎯 Nächste Schritte:"
echo "1. Code klonen: git clone <dein-repo>"
echo "2. .env Datei erstellen mit API-Keys"
echo "3. npm install"
echo "4. pm2 start server.js"

