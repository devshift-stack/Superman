# 🚀 Quick Start Guide - AI Supervisor System

**Version:** 1.0.0  
**Status:** Core-System fertig, bereit zum Start

---

## ✅ Was ist fertig

- ✅ Supervisor-Kern-System (Agent-Registry, Task-Queue, Session-Manager)
- ✅ API-Integrationen (OpenAI, Claude, Grok, Gemini)
- ✅ Knowledge Base (Pinecone mit Beta/Final System)
- ✅ REST API (15+ Endpoints)
- ✅ Tests & CI/CD Pipeline
- ✅ Railway Deployment

---

## 🚀 System starten

### **Option 1: Lokal starten**

```bash
# 1. Dependencies installieren
npm install

# 2. Environment Variables setzen
# Erstelle .env Datei mit:
# OPENAI_API_KEY=...
# CLAUDE_API_KEY=...
# GROK_API_KEY=...
# GEMINI_API_KEY=...
# PINECONE_API_KEY=...
# REDIS_URL=redis://localhost:6379

# 3. Redis starten (falls lokal)
redis-server

# 4. Server starten
npm start
```

**Server läuft auf:** http://localhost:3000

---

### **Option 2: Railway (bereits deployed)**

**Railway URL:** Prüfe Railway Dashboard für die Live-URL

**API verfügbar unter:**
- `https://YOUR_RAILWAY_URL/api/status`
- `https://YOUR_RAILWAY_URL/api/agents`
- `https://YOUR_RAILWAY_URL/api/tasks`
- etc.

---

## 📋 API-Endpoints

### **Health Check**
```bash
GET /health
GET /
```

### **Supervisor Status**
```bash
GET /api/status
```

### **Agent Management**
```bash
POST /api/agents/register
GET /api/agents
```

### **Task Management**
```bash
POST /api/tasks
GET /api/tasks/:taskId
```

### **Session Management**
```bash
POST /api/sessions
GET /api/sessions/:sessionId
```

### **Knowledge Base**
```bash
POST /api/knowledge/search
POST /api/knowledge/store
POST /api/knowledge/verify/:id
GET /api/knowledge/stats
```

**Vollständige Dokumentation:** Siehe `API_DOCUMENTATION.md`

---

## 🧪 Tests ausführen

```bash
# Alle Tests
npm test

# Mit Coverage
npm test -- --coverage
```

---

## 📊 Beispiel-Requests

### **1. Supervisor Status prüfen**
```bash
curl http://localhost:3000/api/status
```

### **2. Agent registrieren**
```bash
curl -X POST http://localhost:3000/api/agents/register \
  -H "Content-Type: application/json" \
  -d '{
    "type": "coach-agent",
    "name": "Coach",
    "config": {}
  }'
```

### **3. Task hinzufügen**
```bash
curl -X POST http://localhost:3000/api/tasks \
  -H "Content-Type: application/json" \
  -d '{
    "type": "help",
    "data": {
      "question": "Wie funktioniert das System?"
    }
  }'
```

### **4. Wissen suchen**
```bash
curl -X POST http://localhost:3000/api/knowledge/search \
  -H "Content-Type: application/json" \
  -d '{
    "query": "Wie funktioniert React?",
    "options": {
      "topK": 5,
      "status": "final"
    }
  }'
```

---

## ⚙️ Environment Variables

**Erforderlich:**
- `OPENAI_API_KEY` - OpenAI API Key
- `CLAUDE_API_KEY` - Claude API Key
- `GROK_API_KEY` - Grok API Key
- `GEMINI_API_KEY` - Gemini API Key
- `PINECONE_API_KEY` - Pinecone API Key

**Optional:**
- `REDIS_URL` - Redis Connection URL (Standard: `redis://localhost:6379`)
- `DB_PATH` - SQLite Database Path (Standard: `./data/sessions.db`)
- `PORT` - Server Port (Standard: `3000`)

---

## 🔧 Troubleshooting

### **Problem: Redis Connection Error**
**Lösung:**
- Prüfe ob Redis läuft: `redis-cli ping`
- Prüfe `REDIS_URL` in `.env`
- Für Railway: Redis Service hinzufügen

### **Problem: API Keys fehlen**
**Lösung:**
- Prüfe `.env` Datei
- Prüfe Railway Variables
- Alle API-Keys müssen gesetzt sein

### **Problem: Port bereits belegt**
**Lösung:**
- Anderen Port setzen: `PORT=3001 npm start`
- Oder: Prozess auf Port 3000 beenden

---

## 📝 Nächste Schritte

**Für nächstes Update geplant:**
- ⏳ Coach-Agent (Fragen beantworten)
- ⏳ User-Guide Agent (Anleitungen erstellen)
- ⏳ UI-Agent (Shadcn UI Integration)
- ⏳ Dashboard (Web-Interface)
- ⏳ Mobile Integration (WhatsApp, Viber)

---

## 🎯 System ist bereit!

**Core-System funktioniert vollständig:**
- ✅ Agent-Registrierung
- ✅ Task-Management
- ✅ Session-Management
- ✅ Knowledge Base
- ✅ REST API

**Starte das System und teste die API-Endpoints!**

---

**Letzte Aktualisierung:** 18. Dezember 2024

