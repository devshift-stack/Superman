# 📚 API Dokumentation - AI Supervisor System

## Base URL
```
http://localhost:3000/api
```

## Endpoints

### Health Check
```
GET /health
GET /
```

### Supervisor Status
```
GET /api/status
```
Gibt Status des Supervisors zurück:
- `initialized`: Boolean
- `activeTasks`: Number
- `registeredAgents`: Number
- `queueStatus`: Object
- `sessions`: Number
- `knowledgeBase`: Object (total, beta, final)

---

### Agent Management

#### Agent registrieren
```
POST /api/agents/register
Body: {
  type: "ui-agent" | "doc-agent" | "user-guide-agent" | "coach-agent",
  name: string,
  config: object
}
```

#### Alle Agenten abrufen
```
GET /api/agents
```

---

### Task Management

#### Task hinzufügen
```
POST /api/tasks
Body: {
  type: string,
  data: object,
  sessionId?: string,
  priority?: number
}
```

#### Task Status abrufen
```
GET /api/tasks/:taskId
```

---

### Session Management

#### Session erstellen
```
POST /api/sessions
Body: {
  userId: string,
  metadata?: object
}
```

#### Session abrufen
```
GET /api/sessions/:sessionId
```

---

### Knowledge Base

#### Wissen suchen
```
POST /api/knowledge/search
Body: {
  query: string,
  options?: {
    topK?: number,
    status?: "beta" | "final" | null,
    minScore?: number
  }
}
```

#### Recherche speichern (Beta)
```
POST /api/knowledge/store
Body: {
  text: string,
  source: string,
  metadata?: object
}
```

#### Wissen verifizieren (Beta → Final)
```
POST /api/knowledge/verify/:id
Body: {
  notes?: string
}
```

#### Statistiken abrufen
```
GET /api/knowledge/stats
```

---

## Beispiel-Requests

### Agent registrieren
```bash
curl -X POST http://localhost:3000/api/agents/register \
  -H "Content-Type: application/json" \
  -d '{
    "type": "ui-agent",
    "name": "UI Generator",
    "config": {}
  }'
```

### Task hinzufügen
```bash
curl -X POST http://localhost:3000/api/tasks \
  -H "Content-Type: application/json" \
  -d '{
    "type": "generate-ui",
    "data": {
      "component": "Button",
      "style": "modern"
    }
  }'
```

### Wissen suchen
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

