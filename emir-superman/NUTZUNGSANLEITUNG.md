# 🚀 Supervisor System - Nutzungsanleitung

**Erstellt:** 19. Dezember 2024

---

## 📍 Server-Informationen

- **Server-IP:** `49.13.158.176`
- **Port:** `3000`
- **Base URL:** `http://49.13.158.176:3000`

---

## ✅ Schnellstart

### **1. Health Check**

Prüfe ob der Server läuft:

```bash
curl http://49.13.158.176:3000/health
```

**Antwort:**
```json
{"status":"healthy"}
```

---

### **2. System-Status abrufen**

```bash
curl http://49.13.158.176:3000/api/status
```

**Antwort:**
```json
{
  "initialized": true,
  "activeTasks": 0,
  "registeredAgents": 0,
  "queueStatus": {
    "waiting": 0,
    "active": 0,
    "completed": 0,
    "failed": 0,
    "total": 0
  },
  "sessions": 0,
  "knowledgeBase": {
    "message": "Knowledge Base nicht initialisiert (PINECONE_API_KEY fehlt)",
    "total": 0,
    "beta": 0,
    "final": 0
  }
}
```

---

## 🤖 Agent Management

### **Agent registrieren**

```bash
curl -X POST http://49.13.158.176:3000/api/agents/register \
  -H "Content-Type: application/json" \
  -d '{
    "type": "doc-agent",
    "name": "Dokumentations-Agent",
    "config": {
      "apiClient": "claude"
    }
  }'
```

**Antwort:**
```json
{
  "id": "agent-123...",
  "type": "doc-agent",
  "name": "Dokumentations-Agent",
  "status": "idle",
  "lastActivity": "2024-12-19T04:10:00.000Z"
}
```

---

### **Alle Agenten auflisten**

```bash
curl http://49.13.158.176:3000/api/agents
```

---

## 📋 Task Management

### **Task erstellen**

```bash
curl -X POST http://49.13.158.176:3000/api/tasks \
  -H "Content-Type: application/json" \
  -d '{
    "type": "write-docs",
    "data": {
      "topic": "API-Dokumentation",
      "language": "de"
    },
    "priority": 1
  }'
```

**Antwort:**
```json
{
  "taskId": "task-123...",
  "status": "queued"
}
```

---

### **Task-Status abrufen**

```bash
curl http://49.13.158.176:3000/api/tasks/TASK_ID_HIER
```

---

## 💬 Session Management

### **Session erstellen**

```bash
curl -X POST http://49.13.158.176:3000/api/sessions \
  -H "Content-Type: application/json" \
  -d '{
    "userId": "user-123",
    "metadata": {
      "project": "Superman",
      "language": "de"
    }
  }'
```

**Antwort:**
```json
{
  "id": "session-123...",
  "userId": "user-123",
  "metadata": {
    "project": "Superman",
    "language": "de"
  },
  "createdAt": "2024-12-19T04:10:00.000Z",
  "updatedAt": "2024-12-19T04:10:00.000Z"
}
```

---

### **Session abrufen**

```bash
curl http://49.13.158.176:3000/api/sessions/SESSION_ID_HIER
```

---

## 📚 Knowledge Base

### **Information speichern (Beta)**

```bash
curl -X POST http://49.13.158.176:3000/api/knowledge/store \
  -H "Content-Type: application/json" \
  -d '{
    "text": "Node.js ist eine JavaScript-Runtime",
    "source": "Wikipedia",
    "metadata": {
      "category": "technology",
      "language": "de"
    }
  }'
```

**Antwort:**
```json
{
  "id": "kb-123...",
  "status": "stored"
}
```

---

### **Information suchen**

```bash
curl -X POST http://49.13.158.176:3000/api/knowledge/search \
  -H "Content-Type: application/json" \
  -d '{
    "query": "Node.js",
    "options": {
      "topK": 5,
      "minScore": 0.7
    }
  }'
```

---

### **Information verifizieren (Beta → Final)**

```bash
curl -X POST http://49.13.158.176:3000/api/knowledge/verify/KB_ID_HIER \
  -H "Content-Type: application/json" \
  -d '{
    "notes": "Verifiziert durch Benutzer"
  }'
```

---

### **Knowledge Base Statistiken**

```bash
curl http://49.13.158.176:3000/api/knowledge/stats
```

---

## 🌐 Im Browser testen

### **Einfache Endpoints (GET):**

Öffne im Browser:
- `http://49.13.158.176:3000/` - Hauptseite
- `http://49.13.158.176:3000/health` - Health Check
- `http://49.13.158.176:3000/api/status` - System-Status
- `http://49.13.158.176:3000/api/agents` - Alle Agenten

---

## 🛠️ Mit Postman/Insomnia

1. **Neue Request erstellen**
2. **URL:** `http://49.13.158.176:3000/api/status`
3. **Method:** GET
4. **Headers:** `Content-Type: application/json` (bei POST/PUT)
5. **Body:** JSON (bei POST/PUT)

---

## 📝 Beispiel-Workflow

### **1. System-Status prüfen**
```bash
curl http://49.13.158.176:3000/api/status
```

### **2. Agent registrieren**
```bash
curl -X POST http://49.13.158.176:3000/api/agents/register \
  -H "Content-Type: application/json" \
  -d '{"type": "doc-agent", "name": "Mein Agent"}'
```

### **3. Task erstellen**
```bash
curl -X POST http://49.13.158.176:3000/api/tasks \
  -H "Content-Type: application/json" \
  -d '{"type": "write-docs", "data": {"topic": "Test"}}'
```

### **4. Session erstellen**
```bash
curl -X POST http://49.13.158.176:3000/api/sessions \
  -H "Content-Type: application/json" \
  -d '{"userId": "test-user"}'
```

---

## ⚠️ Wichtige Hinweise

### **Content-Type Header**
Bei POST/PUT/PATCH Requests **MUSS** der Header gesetzt sein:
```
Content-Type: application/json
```

### **Error-Handling**
Bei Fehlern gibt der Server strukturierte Fehlermeldungen zurück:
```json
{
  "error": "Route nicht gefunden",
  "message": "Die Route GET /api/unknown existiert nicht",
  "path": "/api/unknown",
  "method": "GET",
  "timestamp": "2024-12-19T04:10:00.000Z"
}
```

### **404 Fehler**
Wenn eine Route nicht existiert:
```json
{
  "error": "Route nicht gefunden",
  "message": "Die Route GET /api/unknown existiert nicht",
  "path": "/api/unknown",
  "method": "GET"
}
```

---

## 🔗 Verfügbare Endpoints

### **Health & Status**
- `GET /` - Hauptseite
- `GET /health` - Health Check
- `GET /api/status` - System-Status

### **Agent Management**
- `POST /api/agents/register` - Agent registrieren
- `GET /api/agents` - Alle Agenten auflisten

### **Task Management**
- `POST /api/tasks` - Task erstellen
- `GET /api/tasks/:taskId` - Task-Status abrufen

### **Session Management**
- `POST /api/sessions` - Session erstellen
- `GET /api/sessions/:sessionId` - Session abrufen

### **Knowledge Base**
- `POST /api/knowledge/search` - Information suchen
- `POST /api/knowledge/store` - Information speichern
- `POST /api/knowledge/verify/:id` - Information verifizieren
- `GET /api/knowledge/stats` - Statistiken abrufen

---

## 📚 Vollständige API-Dokumentation

Siehe: `API_DOCUMENTATION.md`

---

**Letzte Aktualisierung:** 19. Dezember 2024

