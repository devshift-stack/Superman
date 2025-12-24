# Call Supervisor - Intelligente Gesprächssteuerung

Der Call Supervisor ist das "Gehirn" des Systems - er orchestriert Telefongespräche intelligent zwischen sipgate, ElevenLabs TTS und der Multi-Model Arena.

## Architektur

```
┌─────────────────────────────────────────────────────────┐
│                   Call Supervisor                        │
│                                                          │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐  │
│  │  Session     │  │  Scenario    │  │  Decision    │  │
│  │  Manager     │  │  Engine      │  │  Engine      │  │
│  └──────────────┘  └──────────────┘  └──────────────┘  │
│         │                 │                  │          │
└─────────┼─────────────────┼──────────────────┼──────────┘
          │                 │                  │
          ▼                 ▼                  ▼
    ┌─────────┐       ┌──────────┐      ┌──────────┐
    │ sipgate │◄─────►│  Arena   │◄────►│ElevenLabs│
    │Webhooks │       │ (3333)   │      │   TTS    │
    └─────────┘       └──────────┘      └──────────┘
```

## Features

### 1. Session Management
- Verwaltet aktive Anrufe und Gesprächszustand
- In-Memory Store (für Production: Redis empfohlen)
- Automatische Cleanup nach 30 Minuten

### 2. Conversation Scenarios
Vordefinierte Gesprächsszenarien:
- **Support**: Technische Hilfe und Problemlösung
- **Sales**: Vertriebsanfragen und Angebote
- **General**: Allgemeine Informationen
- **Emergency**: Dringende Fälle mit sofortiger Eskalation

### 3. Conversation Phases
Jedes Gespräch durchläuft Phasen:
1. **Greeting** - Begrüßung
2. **Intent Detection** - Absicht erkennen
3. **Processing** - Anfrage verarbeiten
4. **Response** - Antwort generieren
5. **Escalation** - An Mitarbeiter weiterleiten (optional)
6. **Closing** - Gespräch beenden

### 4. Intelligent Decision Making
- Automatische Szenario-Erkennung basierend auf Keywords
- Sentiment-Analyse (positiv/neutral/negativ)
- Komplexitäts-Bewertung → Bei Bedarf Arena einbeziehen
- Eskalations-Logik bei Unzufriedenheit

### 5. Multi-Model Arena Integration
- Komplexe Anfragen werden an Arena weitergeleitet
- Provider-Auswahl basierend auf Szenario
- Support → Anthropic (Code/Build)
- Sales → OpenAI (Verify/Structured)

## Installation

```bash
cd supervisor
npm install
```

## Konfiguration

Keine .env nötig - nutzt direkt die Mini-Arena auf localhost:3333

## Start

```bash
# Development
npm run dev

# Production
npm start
```

## Endpoints

### sipgate Webhooks
```
POST /webhooks/sipgate
```
Empfängt Events: newCall, answer, hangup

```
POST /webhooks/sipgate/dtmf
```
Empfängt DTMF-Eingaben (Tastenwahl)

### Debugging
```
GET /sessions/:callId
```
Zeigt Session-Details

```
GET /health
```
Health Check

## Beispiel-Flow

### Neuer Anruf (Support)

1. **sipgate** sendet `newCall` Event
2. **Supervisor** erstellt Session
3. **Supervisor** erkennt Intent: "Support"
4. **Supervisor** generiert Begrüßung
5. **Mini-Arena TTS** erstellt Audio
6. **sipgate** spielt Audio ab
7. User wählt Taste "2" (Support)
8. **Supervisor** verarbeitet DTMF
9. **Supervisor** fragt Arena nach Lösung
10. **Arena** generiert Antwort (Anthropic)
11. **TTS** spricht Antwort
12. Bei Unzufriedenheit → **Escalation**
13. Bei Zufriedenheit → **Closing**

## Conversation Scenarios

### Support Scenario

**Triggers:** `hilfe`, `problem`, `fehler`, `bug`

**Flow:**
```
Greeting → Intent Detection → Processing → Response → Closing
```

**Arena Config:**
- Provider: Anthropic (gut für technische Problemlösung)
- Mode: build

**Example:**
```
User: "Meine App stürzt ab"
→ Scenario: Support
→ Phase: Intent Detection
→ Arena: Anthropic analysiert Problem
→ Response: "Versuchen Sie bitte, den Cache zu löschen..."
```

### Sales Scenario

**Triggers:** `kaufen`, `preis`, `angebot`

**Flow:**
```
Greeting → Intent Detection → Processing → Response → Closing
```

**Arena Config:**
- Provider: OpenAI (gut für strukturierte Angebote)
- Mode: verify

**Example:**
```
User: "Was kostet Ihr Premium-Paket?"
→ Scenario: Sales
→ Phase: Processing
→ Arena: OpenAI erstellt Angebot
→ Response: "Unser Premium-Paket kostet 49€/Monat..."
```

### Emergency Scenario

**Triggers:** `notfall`, `dringend`, `sofort`

**Flow:**
```
Greeting → Escalation (direkt!)
```

**Example:**
```
User: "Notfall! Server down!"
→ Scenario: Emergency
→ Action: Transfer to +49301234567
```

## Integration mit Mini-Arena

Der Supervisor ruft die Mini-Arena für:

### 1. TTS Generation
```javascript
fetch("http://localhost:3333/tts", {
  method: "POST",
  body: JSON.stringify({
    text: "Willkommen beim Support",
    voice_id: "EXAVITQu4vr4xnSDxMaL"
  })
});
```

### 2. Intelligent Decision Making
```javascript
fetch("http://localhost:3333/arena/run", {
  method: "POST",
  body: JSON.stringify({
    task: "Analyze customer intent",
    goal: userInput,
    context: sessionHistory,
    preferred_provider: "anthropic"
  })
});
```

## VPS Deployment

### Quick Deploy

```bash
# Auf VPS
mkdir -p /opt/call-supervisor
cd /opt/call-supervisor

# Dateien kopieren (vom lokalen Mac)
scp -r supervisor/* root@46.224.147.155:/opt/call-supervisor/

# Auf VPS: Dependencies installieren
ssh root@46.224.147.155
cd /opt/call-supervisor
npm install

# Starten
npm start
```

### systemd Service

```bash
cat > /etc/systemd/system/call-supervisor.service <<'EOF'
[Unit]
Description=Call Supervisor
After=network.target

[Service]
Type=simple
User=root
WorkingDirectory=/opt/call-supervisor
ExecStart=/usr/bin/tsx server.ts
Restart=always
RestartSec=10
StandardOutput=syslog
StandardError=syslog
SyslogIdentifier=call-supervisor

[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reload
systemctl enable call-supervisor
systemctl start call-supervisor
```

## Ports

- **8080**: Call Supervisor (sipgate Webhooks)
- **3333**: Mini-Arena (TTS + Multi-Model)

Beide Services parallel auf dem VPS!

## sipgate Configuration

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

## Customization

### Neue Szenarien hinzufügen

In `scenarios.ts`:

```typescript
export const scenarios: Record<string, ConversationScenario> = {
  custom: {
    name: "Mein Custom Szenario",
    triggers: ["keyword1", "keyword2"],
    flow: ["greeting", "intent_detection", "response", "closing"],
    arenaConfig: {
      provider: "openai",
      mode: "mixed"
    },
    responses: {
      greeting: ["Hallo!"],
      // ...
    }
  }
};
```

### Decision Logic anpassen

In `conversationSupervisor.ts` - editiere Handler-Funktionen:
- `handleGreeting()`
- `handleIntentDetection()`
- `handleProcessing()`
- `handleResponse()`
- `handleClosing()`

## Monitoring

```bash
# Logs
journalctl -u call-supervisor -f

# Active Sessions
curl http://localhost:8080/health
curl http://localhost:8080/sessions/<callId>
```

## Troubleshooting

**Session nicht gefunden:**
- Sessions werden nach 30 Min gelöscht
- Check Memory/Redis Connection

**Arena nicht erreichbar:**
```bash
curl http://localhost:3333/health
```

**TTS schlägt fehl:**
- Check ElevenLabs API Key in Mini-Arena .env
- Check Mini-Arena läuft

**sipgate Webhook kommt nicht an:**
- Firewall Port 8080 offen?
- Webhook URL korrekt konfiguriert?

## Next Steps

- [ ] Redis für Session Storage (Production)
- [ ] WebSocket für Real-Time Monitoring
- [ ] Spracherkennung (Speech-to-Text) integrieren
- [ ] Analytics Dashboard
- [ ] A/B Testing für Responses
- [ ] Multi-Language Support
