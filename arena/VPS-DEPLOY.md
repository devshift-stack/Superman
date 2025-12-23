# VPS Deployment Guide - Mini-Arena

Deploy Mini-Arena (OpenAI + Claude + ElevenLabs) auf deinem VPS 46.224.147.155

## Schnell-Deploy (Copy & Paste)

Führe diese Befehle auf deinem lokalen Mac aus:

### 1. Dateien auf VPS kopieren

```bash
# Von deinem lokalen Superman Repo aus
cd /path/to/Superman

# VPS vorbereiten
ssh root@46.224.147.155 "mkdir -p /opt/mini-arena"

# Dateien kopieren
scp -r arena/src root@46.224.147.155:/opt/mini-arena/
scp arena/package.json root@46.224.147.155:/opt/mini-arena/
scp arena/.env.example root@46.224.147.155:/opt/mini-arena/
scp package.json root@46.224.147.155:/opt/mini-arena/package-root.json
```

### 2. Auf VPS einloggen und einrichten

```bash
ssh root@46.224.147.155
```

Im VPS:

```bash
cd /opt/mini-arena

# package.json für ES modules anpassen
cat > package.json <<'EOF'
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
EOF

# Dependencies installieren
npm install

# .env erstellen
cat > .env <<'EOF'
PORT=3333

# OpenAI
OPENAI_API_KEY=DEIN_OPENAI_KEY
OPENAI_MODEL=gpt-4

# Anthropic
ANTHROPIC_API_KEY=DEIN_ANTHROPIC_KEY
ANTHROPIC_MODEL=claude-sonnet-4-5-20250929
ANTHROPIC_VERSION=2023-06-01

# ElevenLabs TTS
ELEVENLABS_API_KEY=DEIN_ELEVENLABS_KEY
ELEVENLABS_VOICE_ID=EXAVITQu4vr4xnSDxMaL

# Policy
ALLOW_PRICING=false
ALLOW_LEGAL=false
EOF

# !!! WICHTIG: Editiere .env und setze echte API Keys
nano .env
```

### 3. Service starten

```bash
# Im Hintergrund starten
nohup node src/index.js > /tmp/mini-arena.log 2>&1 &

# Logs anschauen
tail -f /tmp/mini-arena.log

# Testen
curl http://localhost:3333/health
```

### 4. Extern testen

Vom Mac/Client:

```bash
# Health Check
curl http://46.224.147.155:3333/health

# Voices abrufen
curl http://46.224.147.155:3333/voices

# TTS Test (mit echtem API Key)
curl -X POST http://46.224.147.155:3333/tts \
  -H "Content-Type: application/json" \
  -d '{"text":"Hallo, ich bin dein KI Assistent"}' \
  --output test-audio.mp3
```

## Firewall Regel

Falls Port 3333 nicht erreichbar ist, öffne ihn:

**Hetzner Cloud Console:**
1. Gehe zu deinem Server
2. Firewalls → Rules
3. Add Rule: TCP, Port 3333, Source: 0.0.0.0/0

**Oder via UFW:**
```bash
ssh root@46.224.147.155 "ufw allow 3333/tcp"
```

## Production Setup mit systemd

Für automatischen Neustart nach Reboot:

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

# Service aktivieren
systemctl daemon-reload
systemctl enable mini-arena
systemctl start mini-arena

# Status prüfen
systemctl status mini-arena

# Logs anschauen
journalctl -u mini-arena -f
```

## Verfügbare Endpoints

Nach erfolgreichem Deployment:

```
http://46.224.147.155:3333/health              - Health Check
http://46.224.147.155:3333/arena/run           - Single Model Run
http://46.224.147.155:3333/arena/run-dual      - Dual Mode (Claude + OpenAI)
http://46.224.147.155:3333/tts                 - Text-to-Speech
http://46.224.147.155:3333/tts/stream          - TTS Streaming
http://46.224.147.155:3333/voices              - Voice List
```

## Beide Services parallel

Du kannst beide Services gleichzeitig laufen lassen:

- **Port 8080**: `/opt/ai-voice` (sipgate Webhook Server)
- **Port 3333**: `/opt/mini-arena` (Multi-Model Arena + TTS)

Verbinde sie, indem der sipgate Server die Mini-Arena aufruft:

```javascript
// In /opt/ai-voice/src/server.js
app.post("/webhooks/sipgate", async (req, res) => {
  const { event, from } = req.body;

  if (event === "newCall") {
    // Rufe Mini-Arena TTS auf
    const ttsResponse = await fetch("http://localhost:3333/tts", {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({
        text: "Willkommen! Bitte bleiben Sie dran."
      })
    });

    const audioBuffer = await ttsResponse.arrayBuffer();
    // ... Audio über SIP/RTP streamen
  }
});
```

## Troubleshooting

**Port bereits belegt:**
```bash
lsof -i :3333
kill <PID>
```

**Node version:**
```bash
node -v  # Sollte v20+ sein
```

**Logs:**
```bash
tail -f /tmp/mini-arena.log
# oder mit systemd:
journalctl -u mini-arena -f
```

**Neustart:**
```bash
# Manuell:
pkill -f "node src/index.js"
cd /opt/mini-arena && nohup node src/index.js > /tmp/mini-arena.log 2>&1 &

# Mit systemd:
systemctl restart mini-arena
```
