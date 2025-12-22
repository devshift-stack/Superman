# 🔑 API-Key Setup - Premium Sales Agents

## ⚠️ Wichtig

**Für vollständige Funktionalität benötigst du einen gültigen Google Gemini API-Key.**

---

## 🚀 Quick Setup

### 1. Gemini API-Key erhalten

1. Gehe zu: https://aistudio.google.com/apikey
2. Erstelle einen neuen API-Key
3. Kopiere den Key

### 2. API-Key setzen

#### Option A: Environment Variable (Empfohlen)

```bash
export GEMINI_API_KEY="dein-api-key-hier"
```

#### Option B: .env Datei

```bash
cd apps/callcenter-ai/backend
echo "GEMINI_API_KEY=dein-api-key-hier" > .env
```

#### Option C: Beim Server-Start

```bash
cd apps/callcenter-ai/backend
GEMINI_API_KEY="dein-api-key-hier" npm start
```

---

## ✅ Testen

### 1. Prüfe ob API-Key gesetzt ist

```bash
echo $GEMINI_API_KEY
```

### 2. Server neu starten

```bash
cd apps/callcenter-ai/backend
pkill -f "node.*server.js"
npm start
```

### 3. Teste Chat

```bash
# Session erstellen
SESSION=$(curl -s -X POST http://localhost:3000/api/v1/premium/sessions \
  -H "Content-Type: application/json" \
  -d '{"productCategory":"solar","language":"german"}' | python3 -c "import sys, json; print(json.load(sys.stdin)['sessionId'])")

# Chat testen
curl -X POST "http://localhost:3000/api/v1/premium/sessions/${SESSION}/chat" \
  -H "Content-Type: application/json" \
  -d '{"message":"Hallo, ich interessiere mich für Solar"}'
```

---

## 🔍 Fehlerbehebung

### Fehler: "API key not valid"

**Ursache:** API-Key ist ungültig oder fehlt

**Lösung:**
1. Prüfe ob API-Key gesetzt ist: `echo $GEMINI_API_KEY`
2. Stelle sicher, dass der Key korrekt ist (keine Leerzeichen, vollständig)
3. Server neu starten nach dem Setzen des Keys

### Fehler: "Entschuldigung, ähm, ich hab Sie nicht ganz verstanden"

**Ursache:** API-Key-Fehler wird als generischer Fehler angezeigt

**Lösung:**
- Prüfe Server-Logs: `tail -f /tmp/callcenter-server.log`
- Suche nach "API key not valid" oder "API_KEY_INVALID"
- Setze einen gültigen API-Key

---

## 📊 Aktueller Status

**Ohne gültigen API-Key:**
- ✅ Health Check funktioniert
- ✅ Session-Erstellung funktioniert (statische Begrüßung)
- ❌ Chat funktioniert nicht (benötigt API-Key)

**Mit gültigem API-Key:**
- ✅ Health Check funktioniert
- ✅ Session-Erstellung funktioniert
- ✅ Chat funktioniert vollständig
- ✅ Natürliche, menschliche Antworten

---

## 🔐 Sicherheit

**WICHTIG:**
- ❌ Niemals API-Keys in Git committen
- ✅ Verwende `.env` Dateien (in `.gitignore`)
- ✅ Verwende Environment Variables
- ✅ Setze API-Keys nur auf dem Server

---

**Nach dem Setzen des API-Keys funktioniert alles perfekt! 🚀**

