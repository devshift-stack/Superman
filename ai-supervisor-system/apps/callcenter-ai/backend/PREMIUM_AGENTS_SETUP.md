# 🤖 Premium Sales Agents - Setup

## 🎯 Features

- ✅ **10-20 gleichzeitige Sessions** - Multi-User Support
- ✅ **Nicht erkennbar als KI** - Natürliche Sprache, Emotionen, kleine "Fehler"
- ✅ **3 Produktkategorien**: Solar, Strom, Handy
- ✅ **Beste Verkäufer** - Optimierte Prompts für maximale Conversion
- ✅ **Menschliche Stimmen** - Variable Agent-Namen

---

## 🚀 Quick Start

### 1. Backend starten

```bash
cd apps/callcenter-ai/backend
npm install
npm start
```

### 2. Premium Session erstellen

**Solar:**
```bash
curl -X POST http://localhost:3000/api/v1/premium/sessions \
  -H "Content-Type: application/json" \
  -d '{"productCategory":"solar","language":"german"}'
```

**Strom:**
```bash
curl -X POST http://localhost:3000/api/v1/premium/sessions \
  -H "Content-Type: application/json" \
  -d '{"productCategory":"strom","language":"german"}'
```

**Handy:**
```bash
curl -X POST http://localhost:3000/api/v1/premium/sessions \
  -H "Content-Type: application/json" \
  -d '{"productCategory":"handy","language":"german"}'
```

### 3. Chat mit Agent

```bash
curl -X POST http://localhost:3000/api/v1/premium/sessions/SESSION_ID/chat \
  -H "Content-Type: application/json" \
  -d '{"message":"Hallo, ich interessiere mich für Solar"}'
```

---

## 📊 API Endpoints

### POST `/api/v1/premium/sessions`
Erstellt neue Premium Agent Session

**Body:**
```json
{
  "productCategory": "solar|strom|handy",
  "language": "german"
}
```

**Response:**
```json
{
  "sessionId": "uuid",
  "greeting": "Natürliche Begrüßung...",
  "productCategory": "solar",
  "agentName": "Lisa",
  "activeSessions": 5
}
```

### POST `/api/v1/premium/sessions/:sessionId/chat`
Chat mit Premium Agent

**Body:**
```json
{
  "message": "Kunden-Nachricht"
}
```

**Response:**
```json
{
  "sessionId": "uuid",
  "response": "Natürliche Agent-Antwort...",
  "agentName": "Lisa",
  "productCategory": "solar"
}
```

### GET `/api/v1/stats`
Statistiken (Sessions, Messages, Produkte)

---

## 🎭 Agent-Namen

**Solar:** Lisa, Sarah, Anna, Julia, Maria, Sophie, Emma, Laura  
**Strom:** Max, Thomas, Michael, David, Daniel, Stefan, Markus, Christian  
**Handy:** Nicole, Jennifer, Melanie, Stephanie, Nadine, Jessica, Vanessa, Kathrin

---

## 🔧 Konfiguration

**Maximale Sessions:** 20 (konfigurierbar in `server.js`)

**Rate Limiting:** 500 Requests/Minute (für 10-20 Sessions)

**Temperature:** 0.9 (höher für mehr Variation, natürlichere Antworten)

---

## 💡 Warum nicht erkennbar als KI?

1. **Natürliche Sprache** - Umgangssprachlich, nicht perfekt
2. **Emotionen** - Echte Reaktionen auf Kunden
3. **Variation** - Jede Antwort ist unterschiedlich
4. **Kleine "Fehler"** - Selbstkorrekturen, Füllwörter
5. **Persönlichkeit** - Jeder Agent hat eigene Charakterzüge
6. **Pausen** - Natürliche Gesprächsflüsse

---

## 📈 Performance

- **10-20 gleichzeitige Sessions** ✅
- **Schnelle Antworten** (< 2 Sekunden)
- **Skalierbar** - Kann auf Datenbank erweitert werden

---

**Status:** ✅ Produktionsbereit!

