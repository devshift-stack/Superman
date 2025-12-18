# 🎤 Google Cloud TTS Setup

## 🔑 API-Key / Credentials

Der bereitgestellte Key: `AQ.Ab8RN6KXmY_nDijMhxPbzU82hCIfuPDXTFip9iXbep0N8h8DFg`

---

## 📋 Setup-Optionen

### Option 1: Service Account JSON (Empfohlen)

1. **Service Account Key herunterladen** von Google Cloud Console
2. **Als JSON speichern** (z.B. `google-tts-credentials.json`)
3. **Environment Variable setzen:**

```bash
export GOOGLE_APPLICATION_CREDENTIALS="/path/to/google-tts-credentials.json"
```

### Option 2: Environment Variable (JSON String)

```bash
export GOOGLE_CLOUD_CREDENTIALS='{
  "type": "service_account",
  "project_id": "dein-project-id",
  "private_key_id": "AQ.Ab8RN6KXmY_nDijMhxPbzU82hCIfuPDXTFip9iXbep0N8h8DFg",
  "private_key": "-----BEGIN PRIVATE KEY-----\n...\n-----END PRIVATE KEY-----\n",
  "client_email": "service-account@project.iam.gserviceaccount.com",
  "client_id": "...",
  "auth_uri": "https://accounts.google.com/o/oauth2/auth",
  "token_uri": "https://oauth2.googleapis.com/token",
  "auth_provider_x509_cert_url": "https://www.googleapis.com/oauth2/v1/certs",
  "client_x509_cert_url": "..."
}'
```

---

## ✅ Testen

### 1. Server mit TTS starten

```bash
cd apps/callcenter-ai/backend
export GOOGLE_APPLICATION_CREDENTIALS="/path/to/credentials.json"
# ODER
export GOOGLE_CLOUD_CREDENTIALS='{...}'
npm start
```

### 2. Session mit Audio testen

```bash
# Session erstellen
SESSION=$(curl -s -X POST http://localhost:3000/api/v1/premium/sessions \
  -H "Content-Type: application/json" \
  -d '{"productCategory":"solar","language":"german"}' \
  | python3 -c "import sys, json; print(json.load(sys.stdin)['sessionId'])")

# Chat mit Audio
RESPONSE=$(curl -s -X POST "http://localhost:3000/api/v1/premium/sessions/${SESSION}/chat" \
  -H "Content-Type: application/json" \
  -d '{"message":"Hallo, ich interessiere mich für Solar"}')

# Audio extrahieren
AUDIO=$(echo "$RESPONSE" | python3 -c "import sys, json; print(json.load(sys.stdin).get('audioContent', ''))" 2>/dev/null)

if [ -n "$AUDIO" ] && [ "$AUDIO" != "null" ]; then
    echo "✅ Audio generiert!"
    echo "$AUDIO" | base64 -d > test_audio.mp3
    open test_audio.mp3  # macOS
else
    echo "⚠️ Kein Audio generiert - prüfe TTS Credentials"
fi
```

---

## 🔍 Troubleshooting

### Fehler: "TTS Credentials nicht gesetzt"

**Lösung:**
- Prüfe Environment Variables: `echo $GOOGLE_APPLICATION_CREDENTIALS`
- Stelle sicher, dass der Pfad korrekt ist
- Prüfe Dateiberechtigungen

### Fehler: "Permission denied"

**Lösung:**
- Service Account benötigt Rolle: "Cloud Text-to-Speech API User"
- Aktiviere "Cloud Text-to-Speech API" im Google Cloud Projekt

### Kein Audio in Response

**Prüfe:**
1. TTS Credentials gesetzt?
2. Cloud Text-to-Speech API aktiviert?
3. Service Account hat Berechtigung?
4. Server-Logs: `tail -f /tmp/callcenter-server.log`

---

## 📚 Weitere Informationen

- **Google Cloud Console:** https://console.cloud.google.com
- **TTS API Dokumentation:** https://cloud.google.com/text-to-speech/docs
- **Service Accounts:** https://console.cloud.google.com/iam-admin/serviceaccounts

---

**Nach dem Setup funktioniert Voice/TTS vollständig! 🎤**

