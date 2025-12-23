#!/bin/bash
set -e

# VPS Deployment Script for Mini-Arena with ElevenLabs TTS
# Usage: ./deploy-vps.sh <VPS_IP> [SSH_USER]

VPS_IP="${1:-}"
SSH_USER="${2:-root}"
VPS_DIR="/opt/ai-voice"

if [ -z "$VPS_IP" ]; then
  echo "Usage: $0 <VPS_IP> [SSH_USER]"
  echo "Example: $0 46.224.147.155 root"
  exit 1
fi

echo "🚀 Deploying Mini-Arena to VPS: $SSH_USER@$VPS_IP"

# 1. Stop running service
echo "⏹️  Stopping existing service..."
ssh "$SSH_USER@$VPS_IP" "pkill -f 'node.*server.js' || true" || true

# 2. Create directory
echo "📁 Creating directory structure..."
ssh "$SSH_USER@$VPS_IP" "mkdir -p $VPS_DIR/arena/src/services $VPS_DIR/arena/src/supervisor $VPS_DIR/arena/src/providers $VPS_DIR/arena/src/prompts $VPS_DIR/arena/src/utils"

# 3. Copy files
echo "📤 Copying files..."
scp -r arena/src "$SSH_USER@$VPS_IP:$VPS_DIR/arena/"
scp arena/package.json "$SSH_USER@$VPS_IP:$VPS_DIR/arena/"
scp arena/.env.example "$SSH_USER@$VPS_IP:$VPS_DIR/arena/"

# 4. Copy .env if exists (or create from example)
if [ -f arena/.env ]; then
  echo "📋 Copying .env configuration..."
  scp arena/.env "$SSH_USER@$VPS_IP:$VPS_DIR/arena/"
else
  echo "⚠️  No .env file found locally, creating from .env.example on VPS..."
  ssh "$SSH_USER@$VPS_IP" "cp $VPS_DIR/arena/.env.example $VPS_DIR/arena/.env"
fi

# 5. Install dependencies
echo "📦 Installing dependencies..."
ssh "$SSH_USER@$VPS_IP" "cd $VPS_DIR/arena && npm install"

# 6. Start service
echo "▶️  Starting service..."
ssh "$SSH_USER@$VPS_IP" "cd $VPS_DIR/arena && nohup node src/index.js > /tmp/arena.log 2>&1 &"

# 7. Wait and test
sleep 3
echo "🔍 Testing endpoints..."
echo ""
echo "Health Check:"
curl -s "http://$VPS_IP:3333/health" | jq . || echo "Failed to connect"
echo ""

echo "✅ Deployment complete!"
echo ""
echo "Available endpoints:"
echo "  Health:       http://$VPS_IP:3333/health"
echo "  Arena Run:    POST http://$VPS_IP:3333/arena/run"
echo "  Arena Dual:   POST http://$VPS_IP:3333/arena/run-dual"
echo "  TTS:          POST http://$VPS_IP:3333/tts"
echo "  TTS Stream:   POST http://$VPS_IP:3333/tts/stream"
echo "  Voices:       GET http://$VPS_IP:3333/voices"
echo ""
echo "View logs:"
echo "  ssh $SSH_USER@$VPS_IP 'tail -f /tmp/arena.log'"
