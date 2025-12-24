# Superman Multi-Model Arena - Quick Start Guide

Vollständiges AI-Telefonie-System mit intelligenter Gesprächssteuerung.

## System-Übersicht

```
┌────────────────────────────────────────────────────────────────┐
│                    VPS 46.224.147.155                          │
│                                                                │
│  ┌────────────────┐  ┌──────────────────┐  ┌───────────────┐  │
│  │ Call Supervisor│  │   Mini-Arena     │  │  ElevenLabs   │  │
│  │   Port 8080    │──│   Port 3333      │──│     TTS       │  │
│  │                │  │                  │  │               │  │
│  │ - sipgate     │  │ - OpenAI API     │  │ - Voice Gen   │  │
│  │ - Webhooks    │  │ - Anthropic API  │  │ - Streaming   │  │
│  │ - Session Mgmt│  │ - Routing Logic  │  │ - 29 Sprachen │  │
│  │ - Scenarios   │  │ - Policy Checks  │  │               │  │
│  └────────────────┘  └──────────────────┘  └───────────────┘  │
│         │                     │                     │          │
└─────────┼─────────────────────┼─────────────────────┼──────────┘
          │                     │                     │
    ┌─────▼─────┐         ┌─────▼──────┐      ┌──────▼────┐
    │  sipgate  │         │   OpenAI   │      │ ElevenLabs│
    │  Anrufe   │         │  + Claude  │      │    API    │
    └───────────┘         └────────────┘      └───────────┘
```

## 🚀 5-Minuten Setup (Lokal)

### 1. Repository klonen & Dependencies

```bash
cd /path/to/Superman
npm install
```

### 2. API Keys konfigurieren

```bash
# Mini-Arena konfigurieren
cp arena/.env.example arena/.env
nano arena/.env
```

Trage ein:
- `OPENAI_API_KEY` - https://platform.openai.com/api-keys
- `ANTHROPIC_API_KEY` - https://console.anthropic.com/settings/keys
- `ELEVENLABS_API_KEY` - https://elevenlabs.io/app/settings/api-keys

### 3. Services starten

```bash
# Terminal 1: Mini-Arena (Port 3333)
npm run arena:dev

# Terminal 2: Call Supervisor (Port 8080)
npm run supervisor:dev
```

### 4. Testen

```bash
# Health Checks
curl http://localhost:3333/health
curl http://localhost:8080/health

# TTS Test
curl -X POST http://localhost:3333/tts \
  -H "Content-Type: application/json" \
  -d '{"text":"Hallo, ich bin dein KI Assistent"}' \
  --output test.mp3 && open test.mp3

# Voices
curl http://localhost:3333/voices | jq .
```

## 🌐 VPS Deployment

### Option 1: Automatisch (Empfohlen)

```bash
# Mini-Arena deployen
./arena/deploy-mini-arena.sh 46.224.147.155 root

# Call Supervisor deployen
ssh root@46.224.147.155 "mkdir -p /opt/call-supervisor"
scp -r supervisor/* root@46.224.147.155:/opt/call-supervisor/
ssh root@46.224.147.155 "cd /opt/call-supervisor && npm install && npm start &"
```

### Option 2: Manuell

Siehe [DEPLOYMENT.md](DEPLOYMENT.md) für detaillierte Anleitung.

### API Keys auf VPS setzen

```bash
ssh root@46.224.147.155
nano /opt/mini-arena/.env

# Trage echte Keys ein:
OPENAI_API_KEY=sk-...
ANTHROPIC_API_KEY=sk-ant-...
ELEVENLABS_API_KEY=...
```

## 📞 sipgate Integration

### 1. Webhook konfigurieren

In deinem sipgate Dashboard:

**Webhook URL:**
```
http://46.224.147.155:8080/webhooks/sipgate
```

**Events aktivieren:**
- [x] newCall
- [x] answer
- [x] hangup
- [x] dtmf

### 2. Testanruf

Rufe deine sipgate-Nummer an:

1. **Begrüßung** wird automatisch per TTS abgespielt
2. **DTMF-Menü**:
   - `1` → Vertrieb
   - `2` → Support
   - `3` → Allgemeine Anfrage
   - `0` → Mitarbeiter
3. **Intelligente Weiterleitung** basierend auf Kontext
4. **Eskalation** bei Bedarf

## 🎯 Conversation Scenarios

### Support (Taste 2)
- **Trigger**: "hilfe", "problem", "fehler"
- **Flow**: Greeting → Intent → Processing → Response
- **AI Model**: Anthropic Claude (gut für technische Problemlösung)
- **Example**: "Meine App stürzt ab" → Claude analysiert → Lösung

### Sales (Taste 1)
- **Trigger**: "kaufen", "preis", "angebot"
- **Flow**: Greeting → Intent → Angebot → Closing
- **AI Model**: OpenAI (strukturierte Angebote)
- **Example**: "Was kostet Premium?" → OpenAI erstellt Angebot

### Emergency (Keyword)
- **Trigger**: "notfall", "dringend", "sofort"
- **Flow**: Greeting → Sofortige Weiterleitung
- **Action**: Transfer zu Mitarbeiter

### General (Taste 3)
- **Trigger**: "frage", "information"
- **Flow**: Standard-Gesprächsflow
- **AI Model**: Mixed (OpenAI + Claude)

## 🛠️ Architektur-Komponenten

### 1. Mini-Arena (Port 3333)
- Multi-Model Routing (OpenAI vs Claude)
- Policy Enforcement (STOP-Gate)
- Evidence-based Verification
- ElevenLabs TTS Integration

**Hauptdateien:**
- `arena/src/index.ts` - Express Server
- `arena/src/supervisor/router.ts` - Routing Logic
- `arena/src/services/elevenlabs.ts` - TTS Service

### 2. Call Supervisor (Port 8080)
- Session Management
- Conversation Orchestration
- Scenario Detection
- Decision Engine

**Hauptdateien:**
- `supervisor/server.ts` - sipgate Webhook Handler
- `supervisor/conversationSupervisor.ts` - Decision Logic
- `supervisor/scenarios.ts` - Conversation Flows
- `supervisor/sessionManager.ts` - State Management

## 📊 Monitoring & Debugging

### Logs anschauen

**Lokal:**
```bash
# Arena Logs
tail -f arena-output.log

# Supervisor Logs
tail -f supervisor-output.log
```

**VPS (mit systemd):**
```bash
# Arena
journalctl -u mini-arena -f

# Supervisor
journalctl -u call-supervisor -f
```

### Session Status

```bash
# Aktive Calls anzeigen
curl http://46.224.147.155:8080/sessions/<callId>

# Health Status
curl http://46.224.147.155:8080/health
curl http://46.224.147.155:3333/health
```

### Performance Metrics

```bash
# Anzahl aktiver Sessions
curl http://localhost:8080/stats  # TODO: Implementieren

# TTS Latency
time curl -X POST http://localhost:3333/tts -d '{"text":"Test"}'
```

## 🔧 Customization

### Neue Conversation Scenarios

In `supervisor/scenarios.ts`:

```typescript
export const scenarios = {
  myScenario: {
    name: "Mein Custom Szenario",
    triggers: ["keyword1", "keyword2"],
    flow: ["greeting", "intent_detection", "response"],
    arenaConfig: {
      provider: "anthropic",
      mode: "build"
    },
    responses: {
      greeting: ["Willkommen..."],
      intent_detection: ["Was möchten Sie?"],
      response: ["Hier ist die Antwort:"]
    }
  }
};
```

### Eigene Stimmen (ElevenLabs)

```bash
# Verfügbare Stimmen
curl http://localhost:3333/voices

# Eigene Stimme verwenden
curl -X POST http://localhost:3333/tts \
  -d '{"text":"Test","voice_id":"YOUR_VOICE_ID"}'
```

### Arena-Routing anpassen

In `arena/src/supervisor/router.ts`:

```typescript
function chooseProvider(req: ArenaRequest): Provider {
  // Custom Logic hier
  if (req.task.includes("code")) return "anthropic";
  if (req.task.includes("verify")) return "openai";
  return "openai";
}
```

## 🚨 Troubleshooting

### Mini-Arena startet nicht

```bash
# Check Node version
node -v  # Sollte v20+ sein

# Dependencies neu installieren
cd arena && rm -rf node_modules && npm install
```

### TTS schlägt fehl

```bash
# Check ElevenLabs API Key
curl -H "xi-api-key: YOUR_KEY" https://api.elevenlabs.io/v1/user

# Check Arena läuft
curl http://localhost:3333/health
```

### sipgate Webhook kommt nicht an

```bash
# Firewall prüfen
ufw status
ufw allow 8080/tcp

# Server erreichbar?
curl http://46.224.147.155:8080/health
```

### Session-Fehler

```bash
# Manuell Session erstellen
curl -X POST http://localhost:8080/test/session \
  -d '{"callId":"test123","from":"+49123","to":"+49456"}'
```

## 📈 Production Checklist

- [ ] API Keys in .env gesetzt (nicht committed!)
- [ ] Firewall Ports offen (8080, 3333)
- [ ] systemd Services eingerichtet
- [ ] Logs-Rotation konfiguriert
- [ ] Monitoring aufgesetzt
- [ ] Backup-Strategie definiert
- [ ] sipgate Webhook URL konfiguriert
- [ ] Test-Anruf erfolgreich
- [ ] Eskalation zu Mitarbeiter getestet
- [ ] TTS Qualität geprüft

## 🎓 Weitere Dokumentation

- [DEPLOYMENT.md](DEPLOYMENT.md) - Komplette Deployment-Anleitung
- [arena/README.md](arena/README.md) - Mini-Arena Details
- [arena/ELEVENLABS.md](arena/ELEVENLABS.md) - TTS Integration
- [arena/VPS-DEPLOY.md](arena/VPS-DEPLOY.md) - VPS Setup Guide
- [supervisor/README.md](supervisor/README.md) - Supervisor Details

## 🆘 Support

Bei Problemen:

1. Check Logs (journalctl oder tail -f)
2. Check Health Endpoints
3. Check API Keys
4. Check Firewall
5. Check sipgate Webhook Config

## 🎉 Los geht's!

```bash
# Lokal starten
npm run arena:dev      # Terminal 1
npm run supervisor:dev  # Terminal 2

# Oder VPS deployen
./arena/deploy-mini-arena.sh 46.224.147.155 root

# Dann: sipgate Webhook konfigurieren und testen!
```

Viel Erfolg mit deinem AI-Telefonie-System! 🚀
