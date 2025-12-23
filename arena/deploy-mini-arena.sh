#!/bin/bash
set -e

# Mini-Arena VPS Deployment Script
# Usage: ./deploy-mini-arena.sh <VPS_IP> [SSH_USER]

VPS_IP="${1:-46.224.147.155}"
SSH_USER="${2:-root}"
VPS_DIR="/opt/mini-arena"

echo "🚀 Deploying Mini-Arena to ${SSH_USER}@${VPS_IP}"

# 1. Create directory structure
echo "📁 Creating directory structure..."
ssh "${SSH_USER}@${VPS_IP}" "mkdir -p ${VPS_DIR}/src/{services,supervisor,providers,prompts,utils}"

# 2. Copy source files
echo "📤 Copying source files..."
scp -r arena/src/services "${SSH_USER}@${VPS_IP}:${VPS_DIR}/src/"
scp -r arena/src/supervisor "${SSH_USER}@${VPS_IP}:${VPS_DIR}/src/"
scp -r arena/src/providers "${SSH_USER}@${VPS_IP}:${VPS_DIR}/src/"
scp arena/src/index.ts "${SSH_USER}@${VPS_IP}:${VPS_DIR}/src/index.js"

# 3. Create package.json for ES modules
echo "📦 Creating package.json..."
ssh "${SSH_USER}@${VPS_IP}" "cat > ${VPS_DIR}/package.json" <<'PACKAGE_EOF'
{
  "name": "mini-arena",
  "version": "1.0.0",
  "type": "module",
  "scripts": {
    "start": "node src/index.js"
  },
  "dependencies": {
    "@anthropic-ai/sdk": "^0.71.2",
    "@elevenlabs/elevenlabs-js": "^2.28.0",
    "dotenv": "^17.2.3",
    "express": "^5.2.1",
    "openai": "^6.14.0"
  }
}
PACKAGE_EOF

# 4. Copy or create .env
echo "⚙️  Setting up environment..."
if [ -f arena/.env ]; then
  echo "📋 Copying existing .env..."
  scp arena/.env "${SSH_USER}@${VPS_IP}:${VPS_DIR}/"
else
  echo "📝 Creating .env template..."
  ssh "${SSH_USER}@${VPS_IP}" "cat > ${VPS_DIR}/.env" <<'ENV_EOF'
PORT=3333

# OpenAI
OPENAI_API_KEY=REPLACE_WITH_YOUR_KEY
OPENAI_MODEL=gpt-4

# Anthropic
ANTHROPIC_API_KEY=REPLACE_WITH_YOUR_KEY
ANTHROPIC_MODEL=claude-sonnet-4-5-20250929
ANTHROPIC_VERSION=2023-06-01

# ElevenLabs TTS
ELEVENLABS_API_KEY=REPLACE_WITH_YOUR_KEY
ELEVENLABS_VOICE_ID=EXAVITQu4vr4xnSDxMaL

# Policy
ALLOW_PRICING=false
ALLOW_LEGAL=false
ENV_EOF
  echo "⚠️  WARNING: .env created with placeholders. Update keys on VPS!"
fi

# 5. Install dependencies
echo "📦 Installing npm dependencies..."
ssh "${SSH_USER}@${VPS_IP}" "cd ${VPS_DIR} && npm install"

# 6. Stop existing service if running
echo "⏹️  Stopping existing service..."
ssh "${SSH_USER}@${VPS_IP}" "pkill -f 'node src/index.js' || true"
sleep 2

# 7. Start service
echo "▶️  Starting Mini-Arena..."
ssh "${SSH_USER}@${VPS_IP}" "cd ${VPS_DIR} && nohup node src/index.js > /tmp/mini-arena.log 2>&1 &"

# 8. Wait and test
sleep 3
echo ""
echo "🔍 Testing deployment..."

# Health check
if curl -sf "http://${VPS_IP}:3333/health" > /dev/null; then
  echo "✅ Health check: OK"
  curl -s "http://${VPS_IP}:3333/health" | jq . || curl -s "http://${VPS_IP}:3333/health"
else
  echo "❌ Health check: FAILED"
  echo "Check logs: ssh ${SSH_USER}@${VPS_IP} 'tail -100 /tmp/mini-arena.log'"
  exit 1
fi

echo ""
echo "✅ Deployment complete!"
echo ""
echo "Available endpoints:"
echo "  Health:       http://${VPS_IP}:3333/health"
echo "  Arena Run:    POST http://${VPS_IP}:3333/arena/run"
echo "  Arena Dual:   POST http://${VPS_IP}:3333/arena/run-dual"
echo "  TTS:          POST http://${VPS_IP}:3333/tts"
echo "  TTS Stream:   POST http://${VPS_IP}:3333/tts/stream"
echo "  Voices:       GET http://${VPS_IP}:3333/voices"
echo ""
echo "View logs:"
echo "  ssh ${SSH_USER}@${VPS_IP} 'tail -f /tmp/mini-arena.log'"
echo ""
echo "⚠️  IMPORTANT: Update API keys in ${VPS_DIR}/.env on VPS!"
echo "  ssh ${SSH_USER}@${VPS_IP} 'nano ${VPS_DIR}/.env'"
