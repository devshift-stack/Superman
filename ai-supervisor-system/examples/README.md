# Beispiele: Server-Nutzung

Dieses Verzeichnis enthält praktische Code-Beispiele für die Nutzung der Agenten und ArenaProPlus im Server-Kontext.

## Dateien

- **`server-usage-example.js`** - Vollständiges Express-Server-Beispiel mit 8 funktionsfähigen Endpunkten

## Schnellstart

```bash
# 1. Environment-Variablen setzen
export REDIS_URL=redis://localhost:6379
export DB_PATH=./data/sessions.db
export OPENAI_API_KEY=sk-...
export ANTHROPIC_API_KEY=sk-ant-...

# 2. Beispiel-Server starten
node examples/server-usage-example.js

# 3. Server läuft auf http://localhost:3000
```

## Verfügbare Endpunkte

### Normale Agenten

- `POST /api/example/simple-question` - Einfache Frage
- `POST /api/example/create-docs` - Dokumentation erstellen
- `POST /api/example/task-with-session` - Task mit Session

### ArenaProPlus

- `POST /api/example/arena-complex-analysis` - Komplexe Analyse
- `GET /api/example/arena-status/:collaborationId` - Status abrufen

### Monitoring

- `GET /api/example/status` - Supervisor-Status
- `GET /api/example/task-result/:taskId` - Task-Ergebnis abrufen
- `POST /api/example/compare` - Vergleich Normal vs. ArenaProPlus

## Beispiel-Requests

### Einfache Frage

```bash
curl -X POST http://localhost:3000/api/example/simple-question \
  -H "Content-Type: application/json" \
  -d '{"question": "Wie funktioniert das System?"}'
```

### ArenaProPlus

```bash
curl -X POST http://localhost:3000/api/example/arena-complex-analysis \
  -H "Content-Type: application/json" \
  -d '{
    "topic": "KI-Trends 2024",
    "requirements": "Vollständige Analyse"
  }'
```

## Weitere Dokumentation

- `../SERVER_AGENTEN_NUTZUNG.md` - Vollständige Anleitung
- `../AGENTEN_VERGLEICH.md` - Vergleich Normal vs. ArenaProPlus


