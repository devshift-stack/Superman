#!/bin/bash

# Deployment-Script für Premium Sales Agents Backend
# Deployt auf Server und startet System

set -e

echo "🚀 Premium Sales Agents - Deployment"
echo "===================================="
echo ""

# Farben
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

# Konfiguration
SERVER_HOST="${DEPLOY_HOST:-localhost}"
SERVER_USER="${DEPLOY_USER:-root}"
SERVER_PORT="${DEPLOY_PORT:-22}"
DEPLOY_PATH="${DEPLOY_PATH:-/opt/callcenter-ai}"
NODE_VERSION="18"

echo -e "${YELLOW}Konfiguration:${NC}"
echo "  Server: ${SERVER_USER}@${SERVER_HOST}:${SERVER_PORT}"
echo "  Pfad: ${DEPLOY_PATH}"
echo "  Node.js: ${NODE_VERSION}"
echo ""

# Prüfe ob auf Server deployt werden soll
if [ "$SERVER_HOST" != "localhost" ]; then
    echo -e "${YELLOW}Deploye auf Remote-Server...${NC}"
    
    # Erstelle Deployment-Package
    echo "📦 Erstelle Deployment-Package..."
    tar -czf /tmp/callcenter-ai-deploy.tar.gz \
        --exclude='node_modules' \
        --exclude='.git' \
        --exclude='*.log' \
        *.js *.json *.md voice_config.json 2>/dev/null || true
    
    # Kopiere auf Server
    echo "📤 Kopiere auf Server..."
    scp -P ${SERVER_PORT} /tmp/callcenter-ai-deploy.tar.gz ${SERVER_USER}@${SERVER_HOST}:/tmp/
    
    # Deploy auf Server
    echo "🔧 Installiere auf Server..."
    ssh -p ${SERVER_PORT} ${SERVER_USER}@${SERVER_HOST} << EOF
        set -e
        mkdir -p ${DEPLOY_PATH}
        cd ${DEPLOY_PATH}
        tar -xzf /tmp/callcenter-ai-deploy.tar.gz
        rm /tmp/callcenter-ai-deploy.tar.gz
        
        # Node.js installieren falls nicht vorhanden
        if ! command -v node &> /dev/null; then
            echo "📦 Installiere Node.js..."
            curl -fsSL https://deb.nodesource.com/setup_${NODE_VERSION}.x | bash -
            apt-get install -y nodejs
        fi
        
        # Dependencies installieren
        echo "📦 Installiere Dependencies..."
        npm install --production
        
        # PM2 installieren (falls nicht vorhanden)
        if ! command -v pm2 &> /dev/null; then
            npm install -g pm2
        fi
        
        # Service starten/restarten
        echo "🚀 Starte Service..."
        pm2 delete callcenter-ai 2>/dev/null || true
        pm2 start server.js --name callcenter-ai
        pm2 save
        pm2 startup
        
        echo "✅ Deployment abgeschlossen!"
        pm2 status
EOF
    
    echo -e "${GREEN}✅ Deployment erfolgreich!${NC}"
    echo ""
    echo "🔗 Server-URLs:"
    echo "  API: http://${SERVER_HOST}:3000"
    echo "  Health: http://${SERVER_HOST}:3000/api/v1/health"
    echo ""
    echo "📊 Status prüfen:"
    echo "  ssh ${SERVER_USER}@${SERVER_HOST} 'pm2 status'"
    
else
    echo -e "${YELLOW}Lokales Deployment...${NC}"
    
    # Lokale Installation
    if ! command -v node &> /dev/null; then
        echo -e "${RED}❌ Node.js nicht gefunden!${NC}"
        echo "   Installiere Node.js 18+ und versuche es erneut."
        exit 1
    fi
    
    echo "📦 Installiere Dependencies..."
    npm install
    
    echo "🚀 Starte Backend..."
    echo ""
    echo -e "${GREEN}Backend läuft auf: http://localhost:3000${NC}"
    echo ""
    echo "Teste mit:"
    echo "  curl http://localhost:3000/api/v1/health"
    echo ""
    
    # Starte Server
    node server.js
fi

