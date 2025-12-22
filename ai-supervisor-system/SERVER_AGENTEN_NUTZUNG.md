# Server-Nutzung: Agenten & ArenaProPlus

**Anleitung für die praktische Nutzung der normalen Agenten und des ArenaProPlus-Modus im Server/Backend-Kontext.**

> **Quick Start:** Für eine schnelle Übersicht siehe [`QUICK_START_AGENTEN.md`](QUICK_START_AGENTEN.md)

---

## Inhaltsverzeichnis

1. [Supervisor initialisieren](#1-supervisor-initialisieren)
2. [Normale Agenten nutzen](#2-normale-agenten-nutzen)
3. [ArenaProPlus-Modus nutzen](#3-arenaproplu-modus-nutzen)
4. [Konfiguration & Umgebung](#4-konfiguration--umgebung)
5. [Beispiel-Endpunkte](#5-beispiel-endpunkte)
6. [Monitoring & Status](#6-monitoring--status)

---

## 1. Supervisor initialisieren

### Basis-Initialisierung

```javascript
const Supervisor = require('./supervisor/src/Supervisor');

// Supervisor-Instanz erstellen
const supervisor = new Supervisor({
  redisUrl: process.env.REDIS_URL || 'redis://localhost:6379',
  dbPath: process.env.DB_PATH || './data/sessions.db',
});

// Initialisieren (async)
await supervisor.initialize();
```

### Was passiert beim Initialisieren?

Der Supervisor initialisiert automatisch:
- **SessionManager** - SQLite-Datenbank für Sessions
- **TaskQueue** - BullMQ/Redis Queue für Tasks
- **AgentRegistry** - Verwaltung aller registrierten Agenten
- **AgentCoordinator** - Koordination von Tasks mit Agenten
- **Knowledge Base** - Pinecone-basierte Wissensdatenbank

### Fehlerbehandlung

```javascript
try {
  await supervisor.initialize();
  console.log('✅ Supervisor initialisiert');
} catch (error) {
  console.error('❌ Initialisierung fehlgeschlagen:', error.message);
  // Server kann im eingeschränkten Modus weiterlaufen
}
```

---

## 2. Normale Agenten nutzen

### Task erstellen und senden

Ein Task wird automatisch vom `TaskRouter` an den passenden Agenten geroutet:

```javascript
// Task erstellen mit createTask (routet automatisch)
const task = await supervisor.createTask({
  type: 'research',  // Task-Typ: 'research', 'coding', 'creative', 'analysis'
  content: 'Wie funktioniert das Supervisor-System?',
  priority: 'high',  // Optional: 'high', 'medium', 'low'
  metadata: {
    context: 'Benutzer fragt nach Architektur',
    sessionId: 'session-123'  // Optional: Session-ID
  }
});

console.log(`Task erstellt: ${task.id}`);
console.log(`Zugewiesener Agent: ${task.assignedAgent}`);
console.log(`Routing-Score: ${task.routingScore}`);
console.log(`Geschätzte Zeit: ${task.estimatedTime}ms`);
```

**Hinweis:** `createTask()` erstellt den Task, routet ihn automatisch zum passenden Agenten und startet die Verarbeitung asynchron.

### Task-Typen und Agent-Zuordnung

Der `TaskRouter` routet Tasks basierend auf dem `type` und Keywords im Content:

| Task-Typ | Zugewiesener Agent | Beschreibung |
|----------|-------------------|--------------|
| `research` | `research-agent` (Gemini) | Recherche, Fakten, Informationen |
| `coding` | `coding-agent` (Claude) | Code schreiben, technische Lösungen |
| `creative` | `creative-agent` (GPT-4) | Texte, Marketing, kreative Inhalte |
| `analysis` | `analysis-agent` (Grok) | Datenanalyse, Trends, Bewertungen |
| Andere | Automatisches Routing | Basierend auf Keywords im Content |

**Routing-Logik:**
1. **Type-Matching** - Direkte Zuordnung wenn `type` passt
2. **Keyword-Matching** - Analyse des Contents auf Keywords
3. **Load Balancing** - Agent mit geringster Last
4. **Fallback** - Standard-Agent wenn kein Match

### Task-Ergebnis abrufen

```javascript
// Option 1: Über Session (wenn sessionId angegeben)
const session = await supervisor.getSession('session-123');
if (session.metadata && session.metadata.lastTask === taskId) {
  const result = session.metadata.lastResult;
  console.log('Ergebnis:', result);
}

// Option 2: Über Task Queue Status
const jobStatus = await supervisor.taskQueue.getJobStatus(taskId);
if (jobStatus === 'completed') {
  // Ergebnis aus Queue abrufen
  const { Job } = require('bullmq');
  const job = await Job.fromId(supervisor.taskQueue.queue, taskId);
  const result = job.returnvalue;
}
```

### Agent manuell auswählen

Falls du einen spezifischen Agent verwenden möchtest:

```javascript
// Agent direkt aus AgentManager holen
const agent = supervisor.agentManager.getAgent('research-agent');

// Task direkt mit Agent ausführen
const result = await supervisor.agentManager.executeTask({
  id: 'task-123',
  assignedAgent: 'research-agent',
  type: 'research',
  content: 'Recherchiere KI-Trends',
  priority: 'high'
});
```

### Task-Status prüfen

```javascript
// Task-Objekt abrufen
const task = await supervisor.getTask(taskId);
console.log('Status:', task.status);  // 'pending', 'processing', 'completed', 'failed'
console.log('Agent:', task.assignedAgent);
console.log('Erstellt:', task.createdAt);
```

---

## 3. ArenaProPlus-Modus nutzen

### ArenaProPlus initialisieren

```javascript
const ArenaProPlus = require('./supervisor/ArenaProPlus');

// ArenaProPlus mit AgentManager initialisieren
const arenaProPlus = new ArenaProPlus(supervisor.agentManager, {
  maxParallelTasks: 4,
  synthesisModel: 'creative',  // GPT-4
  qualityCheckModel: 'coding',  // Claude
  decomposerModel: 'research'  // Gemini
});
```

### Kollaboration starten

Der ArenaProPlus-Modus teilt eine Aufgabe in Teilaufgaben auf und lässt mehrere Agenten parallel arbeiten:

```javascript
// Task für ArenaProPlus erstellen
const task = {
  content: 'Erstelle eine vollständige Analyse zu KI-Trends 2024 mit Recherche, Strukturierung und kreativen Ideen',
  type: 'general',  // ArenaProPlus zerlegt automatisch
  priority: 'high'
};

// Kollaboration starten mit execute()
const result = await arenaPro.execute(task);

console.log('Arena-ID:', result.arenaId);
console.log('Ergebnis:', result.content);
console.log('Phasen:', result.phases);
console.log('Dauer:', result.duration, 'ms');
console.log('Usage:', result.usage);
```

### Was passiert im ArenaProPlus-Modus?

Der `execute()`-Methode durchläuft 4 Phasen:

1. **PHASE 1: Task Decomposition** - Gemini zerlegt die Aufgabe in 2-5 spezialisierte Teilaufgaben
2. **PHASE 2: Parallel Execution** - Alle Agenten bearbeiten ihre Teilaufgaben parallel:
   - Research Agent (Gemini) - Recherche & Fakten
   - Coding Agent (Claude) - Technische Aspekte
   - Creative Agent (GPT-4) - Kreative Inhalte
   - Analysis Agent (Grok) - Analyse & Bewertung
3. **PHASE 3: Synthesis** - GPT-4 kombiniert alle Ergebnisse zu einem Gesamtergebnis
4. **PHASE 4: Quality Check** - Claude prüft und verbessert das finale Ergebnis

### Ergebnis-Struktur

Das `execute()`-Ergebnis enthält:

```javascript
{
  success: true,
  content: "Finales optimiertes Ergebnis...",
  arenaId: "uuid-arena-id",
  mode: "arena-pro-plus",
  phases: {
    decomposition: "4 Teilaufgaben",
    agents: ["research", "coding", "creative", "analysis"],
    synthesized: true,
    qualityChecked: true
  },
  duration: 45230,  // ms
  usage: {
    total_tokens: 15000,
    input_tokens: 8000,
    output_tokens: 7000,
    by_agent: {
      "research": { input_tokens: 2000, output_tokens: 1500 },
      "coding": { input_tokens: 2000, output_tokens: 2000 },
      "creative": { input_tokens: 2000, output_tokens: 2000 },
      "analysis": { input_tokens: 2000, output_tokens: 1500 }
    }
  }
}
```

### WebSocket-Updates (optional)

ArenaProPlus sendet automatisch WebSocket-Nachrichten während der Kollaboration:

```javascript
// Im Server (server.js)
supervisor.io.on('connection', (socket) => {
  socket.on('chat', (data) => {
    console.log('ArenaProPlus Update:', data);
    // data enthält: type, agent, message, timestamp
  });
});
```

---

## 4. Konfiguration & Umgebung

### Erforderliche Environment-Variablen

```bash
# API Keys (mindestens einer erforderlich)
OPENAI_API_KEY=sk-...  # Für Creative Agent (GPT-4) und Fallbacks
ANTHROPIC_API_KEY=sk-ant-...  # Für Coding Agent (Claude)
XAI_API_KEY=xai-...  # Für Analysis Agent (Grok)
GOOGLE_AI_API_KEY=...  # Für Research Agent (Gemini)

# Infrastructure
REDIS_URL=redis://localhost:6379  # Oder Redis Cloud URL
DB_PATH=./data/sessions.db  # SQLite Datenbank-Pfad

# Optional - Cost Tracking & Caching
DAILY_TOKEN_LIMIT=1000000  # Tägliches Token-Limit
MONTHLY_BUDGET_USD=100  # Monatliches Budget in USD
ENABLE_CACHING=true  # Caching aktivieren
SLACK_WEBHOOK_URL=...  # Für Cost-Alerts

# Optional - Server
PORT=3000
NODE_ENV=production
```

### Agent-Konfiguration (`config/agents.config.js`)

Die Agent-Konfiguration definiert alle 4 spezialisierten Agenten:

```javascript
// config/agents.config.js
module.exports = {
  agents: {
    research: {
      id: 'research-agent',
      primary: { provider: 'google', model: 'gemini-2.0-flash' },
      fallback: { provider: 'openai', model: 'gpt-4o' },
      keywords: ['search', 'find', 'research', 'information'],
      // ... weitere Konfiguration
    },
    coding: {
      id: 'coding-agent',
      primary: { provider: 'anthropic', model: 'claude-sonnet-4-20250514' },
      fallback: { provider: 'openai', model: 'gpt-4o' },
      keywords: ['code', 'function', 'bug', 'debug'],
      // ... weitere Konfiguration
    },
    creative: {
      id: 'creative-agent',
      primary: { provider: 'openai', model: 'gpt-4o' },
      fallback: { provider: 'anthropic', model: 'claude-sonnet-4-20250514' },
      keywords: ['write', 'create', 'blog', 'marketing'],
      // ... weitere Konfiguration
    },
    analysis: {
      id: 'analysis-agent',
      primary: { provider: 'xai', model: 'grok-2' },
      fallback: { provider: 'google', model: 'gemini-2.0-flash' },
      keywords: ['analyze', 'data', 'trend', 'report'],
      // ... weitere Konfiguration
    },
  },
  routing: {
    defaultAgent: 'research',
    matchThreshold: 0.3,
    loadBalancing: 'least-load',
  },
  // ... weitere Konfigurationen
};
```

**Wichtige Konfigurationsoptionen:**

- **Routing:** `defaultAgent`, `matchThreshold`, `loadBalancing`
- **Failover:** Automatisches Failover zwischen Primary und Fallback LLMs
- **Cost Tracking:** Tägliche Token-Limits und Budget-Alerts
- **Caching:** Agent-spezifische Cache-TTLs
- **Performance:** Timeouts, Retries, Max Concurrent Tasks

### Redis-Konfiguration

**Lokal:**
```bash
# Redis installieren und starten
redis-server
```

**Cloud (Railway/Render):**
```bash
# Redis als Service hinzufügen
# URL wird automatisch als REDIS_URL gesetzt
```

### Datenbank-Konfiguration

SQLite wird automatisch erstellt. Stelle sicher, dass das `data/` Verzeichnis existiert:

```javascript
const fs = require('fs');
if (!fs.existsSync('./data')) {
  fs.mkdirSync('./data', { recursive: true });
}
```

---

## 5. Beispiel-Endpunkte

### Express-Server Integration

```javascript
const express = require('express');
const app = express();
app.use(express.json());

// Supervisor-Instanz (global)
let supervisor = null;
let arenaProPlus = null;

// Initialisierung beim Server-Start
async function initializeSupervisor() {
  supervisor = new Supervisor({
    redisUrl: process.env.REDIS_URL,
    dbPath: process.env.DB_PATH,
    enableCaching: true,
    enableCostTracking: true
  });
  await supervisor.initialize();
  
  // ArenaProPlus mit AgentManager initialisieren
  const ArenaProPlus = require('./supervisor/ArenaProPlus');
  arenaProPlus = new ArenaProPlus(supervisor.agentManager, {
    maxParallelTasks: 4,
    synthesisModel: 'creative',  // GPT-4
    qualityCheckModel: 'coding',  // Claude
    decomposerModel: 'research'  // Gemini
  });
}

// ============================================
// NORMALE AGENTEN ENDPUNKTE
// ============================================

// Task erstellen (mit automatischem Routing)
app.post('/api/tasks', async (req, res) => {
  try {
    const task = await supervisor.createTask({
      type: req.body.type || 'general',
      content: req.body.content,
      priority: req.body.priority || 'medium',
      metadata: req.body.metadata || {}
    });
    
    res.json({
      taskId: task.id,
      assignedAgent: task.assignedAgent,
      routingScore: task.routingScore,
      estimatedTime: task.estimatedTime,
      status: task.status
    });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// Task-Status abrufen
app.get('/api/tasks/:taskId', async (req, res) => {
  try {
    const task = await supervisor.getTask(req.params.taskId);
    if (!task) {
      return res.status(404).json({ error: 'Task nicht gefunden' });
    }
    
    res.json({
      id: task.id,
      type: task.type,
      status: task.status,
      assignedAgent: task.assignedAgent,
      routingScore: task.routingScore,
      createdAt: task.createdAt,
      startedAt: task.startedAt,
      completedAt: task.completedAt
    });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// Task-Ergebnis abrufen
app.get('/api/tasks/:taskId/result', async (req, res) => {
  try {
    const result = await supervisor.getTaskResult(req.params.taskId);
    if (!result) {
      return res.status(404).json({ error: 'Ergebnis nicht gefunden' });
    }
    
    res.json({
      taskId: result.taskId,
      success: result.success,
      result: result.result || result.content,
      usage: result.usage,
      duration: result.duration,
      agent: result.agent,
      provider: result.provider,
      completedAt: result.completedAt
    });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// ============================================
// ARENAPROPLUS ENDPUNKTE
// ============================================

// ArenaProPlus starten
app.post('/api/arena-pro/start', async (req, res) => {
  try {
    const task = {
      content: req.body.content,
      type: req.body.type || 'general',
      priority: req.body.priority || 'high'
    };
    
    const result = await arenaProPlus.execute(task);
    res.json(result);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// Server starten
async function start() {
  await initializeSupervisor();
  app.listen(3000, () => {
    console.log('Server läuft auf Port 3000');
  });
}

start();
```

### Beispiel-Requests

**Normale Task:**
```bash
curl -X POST http://localhost:3000/api/tasks \
  -H "Content-Type: application/json" \
  -d '{
    "type": "research",
    "content": "Wie funktioniert das Supervisor-System?",
    "priority": "high"
  }'
```

**ArenaProPlus:**
```bash
curl -X POST http://localhost:3000/api/arena-pro/start \
  -H "Content-Type: application/json" \
  -d '{
    "content": "Erstelle eine vollständige Analyse zu KI-Trends 2024 mit Recherche, Strukturierung und kreativen Ideen",
    "type": "general",
    "priority": "high"
  }'
```

---

## 6. Monitoring & Status

### Supervisor-Status abrufen

```javascript
const status = await supervisor.getStatus();

console.log('Initialisiert:', status.initialized);
console.log('Aktive Tasks:', status.activeTasks);
console.log('Registrierte Agenten:', status.registeredAgents);
console.log('Queue-Status:', status.queueStatus);
console.log('Sessions:', status.sessions);
console.log('Knowledge Base:', status.knowledgeBase);
```

### Task-Queue Statistiken

```javascript
const queueStats = await supervisor.taskQueue.getStatus();

console.log('Wartend:', queueStats.waiting);
console.log('Aktiv:', queueStats.active);
console.log('Abgeschlossen:', queueStats.completed);
console.log('Fehlgeschlagen:', queueStats.failed);
```

### Agent-Manager Status

```javascript
// Alle Agenten abrufen
const agents = await supervisor.getAllAgents();
console.log('Verfügbare Agenten:', agents.length);

agents.forEach(agent => {
  console.log(`- ${agent.id}: ${agent.name}`);
  console.log(`  Type: ${agent.type}`);
  console.log(`  Status: ${agent.status}`);
  console.log(`  Primary: ${agent.primary.provider} (${agent.primary.model})`);
  console.log(`  Fallback: ${agent.fallback.provider} (${agent.fallback.model})`);
});

// Health-Status aller Agenten
const health = await supervisor.getAgentHealth();
console.log('Gesamt-Status:', health.overallStatus);
console.log('Gesund:', health.healthy);
console.log('Degradiert:', health.degraded);
console.log('Ungesund:', health.unhealthy);
```

### Health-Check Endpoint

```javascript
app.get('/api/health', async (req, res) => {
  try {
    const status = await supervisor.getStatus();
    const isHealthy = status.initialized && status.queueStatus;
    
    res.json({
      status: isHealthy ? 'healthy' : 'degraded',
      supervisor: status,
      timestamp: new Date().toISOString()
    });
  } catch (error) {
    res.status(503).json({
      status: 'unhealthy',
      error: error.message
    });
  }
});
```

---

## Unterschiede: Normale Agenten vs. ArenaProPlus

| Aspekt | Normale Agenten | ArenaProPlus |
|--------|----------------|--------------|
| **Anzahl Agenten** | 1 Agent pro Task | 3-4 Agenten parallel |
| **Routing** | Automatisch via `AgentCoordinator` | Manuell via `ArenaProMode` |
| **Prozess** | Direkt → Ergebnis | Zerlegung → Parallel → Diskussion → Kombination → Optimierung |
| **Geschwindigkeit** | Schnell (1 API-Call) | Langsamer (mehrere API-Calls) |
| **Qualität** | Gut (1 Perspektive) | Sehr gut (mehrere Perspektiven kombiniert) |
| **Verwendung** | Standard-Tasks | Komplexe, wichtige Tasks |
| **Kosten** | Niedrig | Höher (mehr API-Calls) |

---

## Best Practices

### Wann normale Agenten verwenden?

- ✅ Einfache, klare Aufgaben
- ✅ Schnelle Antworten benötigt
- ✅ Kostenoptimierung wichtig
- ✅ Standard-Tasks (Fragen, Dokumentation)

### Wann ArenaProPlus verwenden?

- ✅ Komplexe, mehrschichtige Aufgaben
- ✅ Höchste Qualität erforderlich
- ✅ Mehrere Perspektiven gewünscht
- ✅ Wichtige Projekte/Präsentationen

### Fehlerbehandlung

```javascript
try {
  const result = await supervisor.addTask(task);
} catch (error) {
  // Supervisor nicht initialisiert
  if (error.message.includes('not initialized')) {
    // Retry nach Initialisierung
  }
  // Redis nicht verfügbar
  if (error.message.includes('Redis')) {
    // Fallback auf In-Memory Queue
  }
}
```

### Performance-Optimierung

- **Caching**: Nutze Sessions für wiederholte Anfragen
- **Prioritäten**: Setze `priority: 'high'` für wichtige Tasks
- **Batch-Processing**: Mehrere Tasks gleichzeitig senden
- **Connection Pooling**: Redis-Verbindungen wiederverwenden

---

## Zusammenfassung

**Normale Agenten:**
1. Task mit `supervisor.createTask()` erstellen
2. Automatisches Routing via `TaskRouter`
3. Ergebnis über `getTaskResult()` abrufen

**ArenaProPlus:**
1. `ArenaProPlus` mit `AgentManager` initialisieren
2. `execute()` mit Task aufrufen
3. Ergebnis direkt im Return-Objekt verfügbar

**Beide Systeme:**
- Nutzen dieselbe Supervisor-Instanz
- Teilen sich Redis und Datenbank
- Können parallel verwendet werden
- Unterstützen WebSocket-Updates

---

**Weitere Dokumentation:**
- `API_DOCUMENTATION.md` - Vollständige API-Referenz
- `QUICK_START.md` - Schnellstart-Anleitung
- `NUTZUNGSANLEITUNG.md` - Detaillierte Nutzungsanleitung

