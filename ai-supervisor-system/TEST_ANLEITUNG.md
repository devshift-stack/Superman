# 🧪 Test-Anleitung - Premium Sales Agents

## ✅ Server Status

**Backend läuft auf:** http://localhost:3000

---

## 🚀 Quick Test

### 1. Health Check

```bash
curl http://localhost:3000/api/v1/health
```

**Erwartete Antwort:**
```json
{
  "status": "ok",
  "activeSessions": 0,
  "timestamp": "2025-12-18T..."
}
```

---

### 2. Premium Session erstellen

#### Solar (Deutsch)

```bash
curl -X POST http://localhost:3000/api/v1/premium/sessions \
  -H "Content-Type: application/json" \
  -d '{
    "productCategory": "solar",
    "language": "german"
  }'
```

#### Strom (Deutsch)

```bash
curl -X POST http://localhost:3000/api/v1/premium/sessions \
  -H "Content-Type: application/json" \
  -d '{
    "productCategory": "strom",
    "language": "german"
  }'
```

#### Handy (Deutsch)

```bash
curl -X POST http://localhost:3000/api/v1/premium/sessions \
  -H "Content-Type: application/json" \
  -d '{
    "productCategory": "handy",
    "language": "german"
  }'
```

**Antwort enthält:**
- `sessionId` - Für weitere Chat-Nachrichten
- `greeting` - Begrüßung vom Agent
- `agentName` - Name des Agents

---

### 3. Chat testen

**Ersetze `SESSION_ID` mit der Session-ID aus Schritt 2:**

```bash
curl -X POST http://localhost:3000/api/v1/premium/sessions/SESSION_ID/chat \
  -H "Content-Type: application/json" \
  -d '{
    "message": "Hallo, ich interessiere mich für Solar"
  }'
```

**Weitere Test-Nachrichten:**

```bash
# Frage stellen
curl -X POST http://localhost:3000/api/v1/premium/sessions/SESSION_ID/chat \
  -H "Content-Type: application/json" \
  -d '{"message": "Wie viel kostet das?"}'

# Bedenken äußern
curl -X POST http://localhost:3000/api/v1/premium/sessions/SESSION_ID/chat \
  -H "Content-Type: application/json" \
  -d '{"message": "Ich bin mir nicht sicher, ob das für mich passt"}'

# Interesse zeigen
curl -X POST http://localhost:3000/api/v1/premium/sessions/SESSION_ID/chat \
  -H "Content-Type: application/json" \
  -d '{"message": "Das klingt interessant, erzählen Sie mir mehr"}'
```

---

### 4. Statistiken anzeigen

```bash
curl http://localhost:3000/api/v1/stats
```

**Zeigt:**
- Aktive Sessions
- Gesamt-Nachrichten
- Sprach-Verteilung
- Produkt-Verteilung

---

## 🌐 Browser-Test

### Postman / Insomnia

1. **Health Check:**
   - GET: `http://localhost:3000/api/v1/health`

2. **Session erstellen:**
   - POST: `http://localhost:3000/api/v1/premium/sessions`
   - Body (JSON):
     ```json
     {
       "productCategory": "solar",
       "language": "german"
     }
     ```

3. **Chat:**
   - POST: `http://localhost:3000/api/v1/premium/sessions/{sessionId}/chat`
   - Body (JSON):
     ```json
     {
       "message": "Hallo, ich interessiere mich für Solar"
     }
     ```

---

## 🧪 Automatischer Test

```bash
cd apps/callcenter-ai/backend
bash test_deployment.sh
```

**Testet automatisch:**
- ✅ Health Check
- ✅ Session-Erstellung
- ✅ Chat-Funktionalität
- ✅ Statistiken

---

## 📊 Test-Szenarien

### Szenario 1: Solar-Verkauf

1. Session erstellen: `productCategory: "solar"`
2. Nachricht: "Ich interessiere mich für Solarmodule"
3. Nachricht: "Wie viel kostet das?"
4. Nachricht: "Gibt es Förderungen?"

### Szenario 2: Strom-Wechsel

1. Session erstellen: `productCategory: "strom"`
2. Nachricht: "Ich möchte meinen Stromanbieter wechseln"
3. Nachricht: "Was sind die Vorteile?"
4. Nachricht: "Wie läuft der Wechsel ab?"

### Szenario 3: Handy-Vertrag

1. Session erstellen: `productCategory: "handy"`
2. Nachricht: "Ich suche einen neuen Handyvertrag"
3. Nachricht: "Welche Tarife gibt es?"
4. Nachricht: "Wie viel Datenvolumen?"

---

## 🔍 Debugging

### Server-Logs anzeigen

```bash
tail -f /tmp/callcenter-server.log
```

### Server-Status prüfen

```bash
lsof -i :3000
```

### Server neu starten

```bash
kill $(cat /tmp/callcenter-server.pid)
cd apps/callcenter-ai/backend
npm start
```

---

## ✅ Erfolgreiche Tests

Wenn alles funktioniert, solltest du sehen:

- ✅ Health Check gibt `"status": "ok"` zurück
- ✅ Session wird erstellt mit `sessionId` und `greeting`
- ✅ Chat gibt natürliche, menschliche Antworten zurück
- ✅ Agent klingt nicht wie KI (mit kleinen "Fehlern", Emotionen)
- ✅ Statistiken zeigen aktive Sessions

---

**Viel Erfolg beim Testen! 🚀**

