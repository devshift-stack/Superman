# Quick Start: Agenten & ArenaProPlus

**Schnellstart-Anleitung für die praktische Nutzung im Server-Kontext.**

---

## 🚀 In 5 Minuten starten

### 1. Supervisor initialisieren

```javascript
const Supervisor = require('./supervisor/Supervisor');

const supervisor = new Supervisor({
  redisUrl: process.env.REDIS_URL || 'redis://localhost:6379',
  dbPath: process.env.DB_PATH || './data/sessions.db',
});

await supervisor.initialize();
```

### 2. Normale Agenten nutzen

```javascript
// Task erstellen - wird automatisch geroutet
const task = await supervisor.createTask({
  type: 'research',  // 'research', 'coding', 'creative', 'analysis'
  content: 'Wie funktioniert KI?',
  priority: 'high'
});

// Ergebnis abrufen
const result = await supervisor.getTaskResult(task.id);
console.log(result.content);
```

### 3. ArenaProPlus nutzen

```javascript
const ArenaProPlus = require('./supervisor/ArenaProPlus');

const arenaProPlus = new ArenaProPlus(supervisor.agentManager);

const result = await arenaProPlus.execute({
  content: 'Erstelle eine vollständige Analyse zu KI-Trends 2024',
  type: 'general',
  priority: 'high'
});

console.log(result.content);  // Finales optimiertes Ergebnis
```

---

## 📋 Environment-Variablen

```bash
# Mindestens einer erforderlich
OPENAI_API_KEY=sk-...
ANTHROPIC_API_KEY=sk-ant-...
XAI_API_KEY=xai-...
GOOGLE_AI_API_KEY=...

# Infrastructure
REDIS_URL=redis://localhost:6379
DB_PATH=./data/sessions.db
```

---

## 🎯 Wann was verwenden?

| Situation | Lösung |
|-----------|--------|
| Einfache Frage | Normale Agenten (`createTask`) |
| Code schreiben | Normale Agenten (`type: 'coding'`) |
| Komplexe Analyse | ArenaProPlus (`execute`) |
| Wichtige Projekte | ArenaProPlus (höchste Qualität) |

---

## 📚 Vollständige Dokumentation

- **`SERVER_AGENTEN_NUTZUNG.md`** - Vollständige Anleitung
- **`examples/server-usage-example.js`** - Code-Beispiele
- **`AGENTEN_VERGLEICH.md`** - Vergleich Normal vs. ArenaProPlus

---

## 🔗 Schnelle Referenz

### Normale Agenten

```javascript
// Task erstellen
const task = await supervisor.createTask({
  type: 'research',
  content: 'Frage',
  priority: 'high'
});

// Status prüfen
const taskStatus = await supervisor.getTask(task.id);

// Ergebnis abrufen
const result = await supervisor.getTaskResult(task.id);
```

### ArenaProPlus

```javascript
// Kollaboration starten
const result = await arenaProPlus.execute({
  content: 'Komplexe Aufgabe',
  type: 'general',
  priority: 'high'
});

// Ergebnis direkt verfügbar
console.log(result.content);
console.log(result.phases);
console.log(result.duration);
```

---

**Weitere Details:** Siehe `SERVER_AGENTEN_NUTZUNG.md`

