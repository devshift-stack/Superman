# 📞 Call-Test Anleitung - Premium Sales Agents

## 🎯 Was wird benötigt?

### ✅ Erforderlich

1. **GEMINI_API_KEY** (für AI-Chat)
   ```bash
   export GEMINI_API_KEY="dein-gemini-api-key"
   ```

2. **Server läuft**
   ```bash
   cd apps/callcenter-ai/backend
   npm start
   ```

### 🔧 Optional (für Voice/TTS)

3. **Google Cloud TTS Credentials** (für Audio-Ausgabe)
   ```bash
   export GOOGLE_APPLICATION_CREDENTIALS="/path/to/credentials.json"
   # ODER
   export GOOGLE_CLOUD_CREDENTIALS='{"type":"service_account",...}'
   ```

---

## 🚀 Quick Test

### Automatischer Call-Test

```bash
cd apps/callcenter-ai/backend
bash test_call.sh
```

**Testet:**
- ✅ Server-Verbindung
- ✅ Session-Erstellung
- ✅ Chat-Funktionalität
- ✅ Voice/TTS (falls konfiguriert)
- ✅ Audio-Ausgabe

---

## 📋 Manueller Test

### 1. Session erstellen

```bash
curl -X POST http://localhost:3000/api/v1/premium/sessions \
  -H "Content-Type: application/json" \
  -d '{
    "productCategory": "solar",
    "language": "german"
  }'
```

**Antwort:**
```json
{
  "sessionId": "uuid",
  "greeting": "Hallo! Ich bin Lisa...",
  "agentName": "Lisa",
  "productCategory": "solar"
}
```

### 2. Chat mit Voice testen

```bash
SESSION_ID="deine-session-id"

curl -X POST http://localhost:3000/api/v1/premium/sessions/${SESSION_ID}/chat \
  -H "Content-Type: application/json" \
  -d '{
    "message": "Hallo, ich interessiere mich für Solarmodule"
  }'
```

**Antwort mit Audio:**
```json
{
  "sessionId": "uuid",
  "response": "Natürliche Antwort vom Agent...",
  "agentName": "Lisa",
  "audioContent": "base64-encoded-mp3",
  "voiceConfig": {
    "voiceName": "de-DE-Neural2-C",
    "languageCode": "de-DE"
  }
}
```

### 3. Audio abspielen

```bash
# Audio aus Base64 extrahieren
echo "BASE64_STRING" | base64 -d > call_audio.mp3

# Abspielen (macOS)
open call_audio.mp3

# Abspielen (Linux)
mpv call_audio.mp3
# oder
ffplay call_audio.mp3
```

---

## 🎤 Vollständiger Call-Flow

### Schritt 1: Begrüßung

```bash
# Session erstellen → Erhält Begrüßung
SESSION=$(curl -s -X POST http://localhost:3000/api/v1/premium/sessions \
  -H "Content-Type: application/json" \
  -d '{"productCategory":"solar","language":"german"}' \
  | python3 -c "import sys, json; print(json.load(sys.stdin)['sessionId'])")

echo "Session: $SESSION"
```

### Schritt 2: Kunden-Frage

```bash
# Kunde stellt Frage
RESPONSE=$(curl -s -X POST http://localhost:3000/api/v1/premium/sessions/${SESSION}/chat \
  -H "Content-Type: application/json" \
  -d '{"message":"Hallo, ich interessiere mich für Solar"}')

# Antwort anzeigen
echo "$RESPONSE" | python3 -c "import sys, json; print(json.load(sys.stdin)['response'])"
```

### Schritt 3: Audio generieren & abspielen

```bash
# Audio extrahieren und speichern
echo "$RESPONSE" | python3 -c "import sys, json; audio=json.load(sys.stdin).get('audioContent'); print(audio if audio else '')" | base64 -d > response.mp3

# Abspielen
open response.mp3  # macOS
```

### Schritt 4: Weiteres Gespräch

```bash
# Weitere Fragen
curl -X POST http://localhost:3000/api/v1/premium/sessions/${SESSION}/chat \
  -H "Content-Type: application/json" \
  -d '{"message":"Wie viel kostet das?"}'

curl -X POST http://localhost:3000/api/v1/premium/sessions/${SESSION}/chat \
  -H "Content-Type: application/json" \
  -d '{"message":"Gibt es Förderungen?"}'
```

---

## 🔧 Setup für Voice/TTS

### Google Cloud TTS einrichten

1. **Google Cloud Projekt erstellen**
   - Gehe zu: https://console.cloud.google.com
   - Erstelle neues Projekt
   - Aktiviere "Cloud Text-to-Speech API"

2. **Service Account erstellen**
   - IAM & Admin → Service Accounts
   - Neuen Service Account erstellen
   - Rolle: "Cloud Text-to-Speech API User"
   - JSON-Key herunterladen

3. **Credentials setzen**

```bash
# Option A: Datei
export GOOGLE_APPLICATION_CREDENTIALS="/path/to/service-account-key.json"

# Option B: Environment Variable
export GOOGLE_CLOUD_CREDENTIALS='{"type":"service_account","project_id":"..."}'
```

4. **Server neu starten**

```bash
cd apps/callcenter-ai/backend
npm start
```

---

## 🧪 Test-Szenarien

### Szenario 1: Solar-Verkauf

```bash
# 1. Session
SESSION=$(curl -s -X POST http://localhost:3000/api/v1/premium/sessions \
  -H "Content-Type: application/json" \
  -d '{"productCategory":"solar","language":"german"}' \
  | python3 -c "import sys, json; print(json.load(sys.stdin)['sessionId'])")

# 2. Interesse zeigen
curl -X POST http://localhost:3000/api/v1/premium/sessions/${SESSION}/chat \
  -H "Content-Type: application/json" \
  -d '{"message":"Ich interessiere mich für Solarmodule"}'

# 3. Kosten erfragen
curl -X POST http://localhost:3000/api/v1/premium/sessions/${SESSION}/chat \
  -H "Content-Type: application/json" \
  -d '{"message":"Wie viel kostet das?"}'

# 4. Förderungen
curl -X POST http://localhost:3000/api/v1/premium/sessions/${SESSION}/chat \
  -H "Content-Type: application/json" \
  -d '{"message":"Gibt es staatliche Förderungen?"}'
```

### Szenario 2: Strom-Wechsel

```bash
SESSION=$(curl -s -X POST http://localhost:3000/api/v1/premium/sessions \
  -H "Content-Type: application/json" \
  -d '{"productCategory":"strom","language":"german"}' \
  | python3 -c "import sys, json; print(json.load(sys.stdin)['sessionId'])")

curl -X POST http://localhost:3000/api/v1/premium/sessions/${SESSION}/chat \
  -H "Content-Type: application/json" \
  -d '{"message":"Ich möchte meinen Stromanbieter wechseln"}'
```

---

## 📊 Monitoring

### Statistiken anzeigen

```bash
curl http://localhost:3000/api/v1/stats | python3 -m json.tool
```

**Zeigt:**
- Aktive Sessions
- Gesamt-Nachrichten
- Sprach-Verteilung
- Produkt-Verteilung

---

## ✅ Checkliste

- [ ] GEMINI_API_KEY gesetzt
- [ ] Server läuft (Port 3000)
- [ ] Session kann erstellt werden
- [ ] Chat funktioniert
- [ ] (Optional) Google Cloud TTS Credentials gesetzt
- [ ] (Optional) Audio wird generiert
- [ ] (Optional) Audio kann abgespielt werden

---

## 🐛 Troubleshooting

### Kein Audio generiert

**Ursache:** Google Cloud TTS nicht konfiguriert

**Lösung:**
1. Prüfe Credentials: `echo $GOOGLE_APPLICATION_CREDENTIALS`
2. Setze Credentials (siehe oben)
3. Server neu starten

### Chat-Fehler

**Ursache:** GEMINI_API_KEY ungültig

**Lösung:**
1. Prüfe API-Key: `echo $GEMINI_API_KEY`
2. Setze gültigen Key
3. Server neu starten

---

**Viel Erfolg beim Call-Test! 📞🚀**

