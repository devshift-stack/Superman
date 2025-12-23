# Multi-Model Arena Deployment Guide

Complete deployment guide for the Superman Multi-Model Arena system.

## System Architecture

```
┌─────────────────────────────────────────────┐
│  VPS 46.224.147.155                         │
│                                             │
│  ┌──────────────────┐  ┌─────────────────┐ │
│  │  Port 8080       │  │  Port 3333      │ │
│  │  ai-voice        │  │  mini-arena     │ │
│  │  (sipgate)       │──│  (Multi-Model)  │ │
│  └──────────────────┘  └─────────────────┘ │
│         │                      │            │
│         │                      ├── OpenAI   │
│         │                      ├── Claude   │
│         └──────────────────────├── ElevenLabs
│                                              │
└─────────────────────────────────────────────┘
```

## Quick Start

### Local Development

```bash
# Clone repo
cd /path/to/Superman

# Install dependencies
npm install

# Configure environment
cp arena/.env.example arena/.env
nano arena/.env  # Add your API keys

# Start locally
npm run arena:dev
```

### VPS Deployment

**Option 1: Automated Script**

```bash
# From your local machine (Mac)
./arena/deploy-mini-arena.sh 46.224.147.155 root
```

**Option 2: Manual Setup**

See [arena/VPS-DEPLOY.md](arena/VPS-DEPLOY.md) for detailed step-by-step instructions.

## Services

### Mini-Arena (Port 3333)

Multi-model routing service with TTS capabilities.

**Location:** `/opt/mini-arena`
**Endpoints:**
- `GET /health` - Health check
- `POST /arena/run` - Single model execution
- `POST /arena/run-dual` - Dual mode (Claude builds, OpenAI verifies)
- `POST /tts` - Text-to-speech generation
- `POST /tts/stream` - Streaming TTS
- `GET /voices` - List available voices

**Start:**
```bash
ssh root@46.224.147.155
cd /opt/mini-arena
node src/index.js
```

### AI-Voice (Port 8080)

sipgate webhook integration.

**Location:** `/opt/ai-voice`
**Endpoints:**
- `GET /health` - Health check
- `POST /webhooks/sipgate` - sipgate call webhook

**Start:**
```bash
ssh root@46.224.147.155
cd /opt/ai-voice
node src/server.js
```

## Integration Example

Connect sipgate webhooks to Mini-Arena TTS:

```javascript
// In /opt/ai-voice/src/server.js
app.post("/webhooks/sipgate", async (req, res) => {
  const { event, from, callId } = req.body;

  if (event === "newCall") {
    // Generate welcome message with ElevenLabs via Mini-Arena
    const response = await fetch("http://localhost:3333/tts", {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({
        text: "Willkommen bei unserem Service. Bitte bleiben Sie dran.",
        voice_id: "EXAVITQu4vr4xnSDxMaL"
      })
    });

    const audioBuffer = await response.arrayBuffer();

    // Return sipgate XML response with audio
    res.set("Content-Type", "application/xml");
    res.send(`<?xml version="1.0" encoding="UTF-8"?>
<Response>
  <Play>https://yourserver.com/audio/${callId}.mp3</Play>
  <Gather>
    <Say voice="de-DE">Drücken Sie 1 für den Vertrieb, 2 für Support.</Say>
  </Gather>
</Response>`);
  }
});
```

## Production Setup

### systemd Service (Mini-Arena)

```bash
ssh root@46.224.147.155

cat > /etc/systemd/system/mini-arena.service <<'EOF'
[Unit]
Description=Mini-Arena Multi-Model Service
After=network.target

[Service]
Type=simple
User=root
WorkingDirectory=/opt/mini-arena
ExecStart=/usr/bin/node src/index.js
Restart=always
RestartSec=10
StandardOutput=syslog
StandardError=syslog
SyslogIdentifier=mini-arena

Environment=NODE_ENV=production

[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reload
systemctl enable mini-arena
systemctl start mini-arena
```

### systemd Service (AI-Voice)

```bash
cat > /etc/systemd/system/ai-voice.service <<'EOF'
[Unit]
Description=AI Voice Service (sipgate)
After=network.target

[Service]
Type=simple
User=root
WorkingDirectory=/opt/ai-voice
ExecStart=/usr/bin/node src/server.js
Restart=always
RestartSec=10
StandardOutput=syslog
StandardError=syslog
SyslogIdentifier=ai-voice

Environment=NODE_ENV=production

[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reload
systemctl enable ai-voice
systemctl start ai-voice
```

### Firewall Configuration

```bash
# Open required ports
ufw allow 8080/tcp   # sipgate webhook
ufw allow 3333/tcp   # mini-arena
ufw enable
```

## Monitoring

### Check Service Status

```bash
# Mini-Arena
systemctl status mini-arena
journalctl -u mini-arena -f

# AI-Voice
systemctl status ai-voice
journalctl -u ai-voice -f
```

### Health Checks

```bash
# Local
curl http://localhost:3333/health
curl http://localhost:8080/health

# External
curl http://46.224.147.155:3333/health
curl http://46.224.147.155:8080/health
```

### Logs

```bash
# Real-time logs
tail -f /tmp/mini-arena.log
tail -f /tmp/ai-voice.log

# Or with systemd
journalctl -u mini-arena -f --since "5 minutes ago"
```

## API Keys Required

1. **OpenAI**: https://platform.openai.com/api-keys
2. **Anthropic**: https://console.anthropic.com/settings/keys
3. **ElevenLabs**: https://elevenlabs.io/app/settings/api-keys

Store in `/opt/mini-arena/.env` on VPS.

## Troubleshooting

### Port Already in Use

```bash
lsof -i :3333
kill <PID>
```

### Service Won't Start

```bash
# Check logs
journalctl -u mini-arena -n 50

# Check .env
cat /opt/mini-arena/.env

# Test manually
cd /opt/mini-arena
node src/index.js
```

### Module Not Found

```bash
cd /opt/mini-arena
rm -rf node_modules package-lock.json
npm install
```

## Next Steps

- [ ] Configure API keys in `.env`
- [ ] Set up systemd services for auto-restart
- [ ] Configure sipgate webhook URL
- [ ] Test TTS integration
- [ ] Monitor service logs
- [ ] Set up backup strategy
- [ ] Configure SSL/TLS (optional)
- [ ] Set up monitoring/alerting

## Support

Check documentation:
- [Arena README](arena/README.md)
- [ElevenLabs Guide](arena/ELEVENLABS.md)
- [VPS Deploy Guide](arena/VPS-DEPLOY.md)
