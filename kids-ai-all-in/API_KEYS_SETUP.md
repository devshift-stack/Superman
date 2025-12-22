# 🔑 API-Keys Setup - Alle APIs

## ⚠️ WICHTIG: Sicherheit

**NIEMALS API-Keys in Git committen!**
- Nutze `.env` Dateien (in `.gitignore`)
- Nutze Environment Variables in Railway
- Nutze Secrets Management

---

## 📋 Benötigte API-Keys

### 1. OpenAI API
**URL:** https://platform.openai.com/api-keys

**Key-Format:**
```
sk-proj-XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
```

**Umgebung:**
```bash
OPENAI_API_KEY=sk-proj-XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
```

**Verwendung:**
- GPT-4 für KI-Assistenten
- Text-Generierung
- Code-Generierung

---

### 2. Claude API (Anthropic)
**URL:** https://console.anthropic.com/settings/keys

**Key-Format:**
```
sk-ant-api03-XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
```

**Umgebung:**
```bash
CLAUDE_API_KEY=sk-ant-api03-XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
```

**Verwendung:**
- Supervisor/Assistent
- Komplexe Aufgaben
- Dokumentation

---

### 3. Grok API (xAI)
**URL:** https://console.x.ai/keys

**Key-Format:**
```
xai-XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
```

**Umgebung:**
```bash
GROK_API_KEY=xai-XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
```

**Verwendung:**
- Aktuelle Informationen
- Recherche (Internet-Zugang)
- Real-time Daten

---

### 4. Gemini API (Google)
**URL:** https://makersuite.google.com/app/apikey

**Key-Format:**
```
AIzaSyXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
```

**Umgebung:**
```bash
GEMINI_API_KEY=AIzaSyXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
```

**Verwendung:**
- Backup-Modell
- Kostenlos (mit Limits)
- Multimodal (Text, Bilder)

---

### 5. Pinecone API (Vector Database)
**URL:** https://app.pinecone.io/

**Key-Format:**
```
xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx
```

**Umgebung:**
```bash
PINECONE_API_KEY=xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx
PINECONE_ENVIRONMENT=us-east-1
PINECONE_INDEX_NAME=kids-ai-knowledge-base
```

**Verwendung:**
- Knowledge Base
- Langzeit-Memory
- Vektor-Suche

---

## 🔧 Setup-Anleitung

### Lokal (.env Datei)

Erstelle eine `.env` Datei im Projekt-Root:

```bash
# .env
OPENAI_API_KEY=dein-openai-key-hier
CLAUDE_API_KEY=dein-claude-key-hier
GROK_API_KEY=dein-grok-key-hier
GEMINI_API_KEY=dein-gemini-key-hier
PINECONE_API_KEY=dein-pinecone-key-hier
PINECONE_ENVIRONMENT=us-east-1
PINECONE_INDEX_NAME=kids-ai-knowledge-base

# Optional
NODE_ENV=development
PORT=3000
```

**Lade in Node.js:**
```javascript
require('dotenv').config();
const openaiKey = process.env.OPENAI_API_KEY;
```

---

### Railway (Environment Variables)

1. Gehe zu Railway Dashboard
2. Wähle dein Projekt
3. Klicke auf "Variables" Tab
4. Füge jede Variable hinzu:

```
OPENAI_API_KEY = sk-proj-...
CLAUDE_API_KEY = sk-ant-api03-...
GROK_API_KEY = xai-...
GEMINI_API_KEY = AIzaSy...
PINECONE_API_KEY = xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx
PINECONE_ENVIRONMENT = us-east-1
PINECONE_INDEX_NAME = kids-ai-knowledge-base
```

---

### .gitignore

Stelle sicher, dass `.env` in `.gitignore` ist:

```gitignore
# Environment variables
.env
.env.local
.env.production
.env.*.local

# API Keys
*.key
*.pem
secrets/
```

---

## 📝 API-Keys Checkliste

- [ ] OpenAI API Key erstellt
- [ ] Claude API Key erstellt
- [ ] Grok API Key erstellt
- [ ] Gemini API Key erstellt
- [ ] Pinecone API Key erstellt
- [ ] `.env` Datei erstellt (lokal)
- [ ] Environment Variables in Railway gesetzt
- [ ] `.gitignore` prüft `.env` Dateien
- [ ] Keys getestet (API-Call funktioniert)

---

## 🧪 Test der API-Keys

### OpenAI Test
```bash
curl https://api.openai.com/v1/models \
  -H "Authorization: Bearer $OPENAI_API_KEY"
```

### Claude Test
```bash
curl https://api.anthropic.com/v1/messages \
  -H "x-api-key: $CLAUDE_API_KEY" \
  -H "anthropic-version: 2023-06-01" \
  -H "Content-Type: application/json" \
  -d '{"model":"claude-3-opus-20240229","max_tokens":1024,"messages":[{"role":"user","content":"Hello"}]}'
```

### Gemini Test
```bash
curl "https://generativelanguage.googleapis.com/v1beta/models/gemini-pro:generateContent?key=$GEMINI_API_KEY" \
  -H 'Content-Type: application/json' \
  -d '{"contents":[{"parts":[{"text":"Hello"}]}]}'
```

---

## 💰 Kosten-Übersicht (ca.)

| API | Kosten | Limits |
|-----|--------|--------|
| OpenAI GPT-4 | ~$0.03/1K tokens | Pay-as-you-go |
| Claude Opus | ~$0.015/1K tokens | Pay-as-you-go |
| Grok | ~$0.01/1K tokens | Pay-as-you-go |
| Gemini | Kostenlos | 60 requests/min |
| Pinecone | Kostenlos (Starter) | 1 Index, 100K vectors |

---

## 🔐 Sicherheits-Best Practices

1. **Nie in Code committen**
   - Nutze Environment Variables
   - Nutze `.env` Dateien (in `.gitignore`)

2. **Rotation**
   - Regelmäßig Keys rotieren
   - Alte Keys sofort löschen

3. **Berechtigungen**
   - Minimal notwendige Berechtigungen
   - Separate Keys für Dev/Prod

4. **Monitoring**
   - API-Usage überwachen
   - Ungewöhnliche Aktivitäten alarmieren

5. **Backup**
   - Keys sicher speichern (Password Manager)
   - Nicht in Klartext

---

## 📞 Support & Hilfe

### API-Dokumentationen:
- **OpenAI:** https://platform.openai.com/docs
- **Claude:** https://docs.anthropic.com
- **Grok:** https://docs.x.ai
- **Gemini:** https://ai.google.dev/docs
- **Pinecone:** https://docs.pinecone.io

### Probleme?
- Prüfe API-Key Format
- Prüfe Berechtigungen
- Prüfe Rate Limits
- Prüfe Billing/Quota

---

**WICHTIG:** Ersetze alle Platzhalter (`XXX...`) mit deinen echten API-Keys!

**Letzte Aktualisierung:** 19. Dezember 2024

