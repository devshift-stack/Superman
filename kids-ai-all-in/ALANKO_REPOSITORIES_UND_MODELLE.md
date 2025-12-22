# 📚 Alanko App - Repositories & Modelle

**Erstellt:** 19. Dezember 2024

---

## 📦 Repositories

### 1. **Superman Repository** (Haupt-Repository)
- **URL:** `https://github.com/devshift-stack/Superman.git`
- **GitHub User:** `devshift-stack`
- **Repository-Name:** `Superman`
- **Pfad:** `/Users/dsselmanovic/cursor project/kids-ai-all-in`
- **Status:** ✅ Aktives Repository
- **Enthält:**
  - Alanko App (geplant/entwickelt)
  - Lianko App
  - Parent App
  - MakerHub App
  - Security-Monitoring
  - API-Dokumentationen

### 2. **emir-superman** (Supervisor-System)
- **Pfad:** `/Users/dsselmanovic/cursor project/emir-superman`
- **Status:** Supervisor/Assistent System
- **Enthält:**
  - Supervisor API
  - Agent Management
  - Task Management
  - Knowledge Base

### 3. **ai-supervisor-system** (AI-System)
- **Pfad:** `/Users/dsselmanovic/cursor project/ai-supervisor-system`
- **Status:** AI-Supervisor System
- **Enthält:**
  - Supervisor-Kern
  - Agent-Orchestrierung
  - Knowledge Base Integration

---

## 🤖 AI-Modelle für Alanko App

### 1. **OpenAI GPT-4**
- **API:** OpenAI API
- **Key:** `OPENAI_API_KEY`
- **URL:** https://platform.openai.com/api-keys
- **Verwendung in Alanko:**
  - KI-Assistent für Kinder (7-jährige)
  - Personalisiertes Lernen
  - Interaktive Gespräche
  - Lerninhalte-Generierung
- **Kosten:** ~$0.03/1K tokens
- **Model:** `gpt-4` oder `gpt-4-turbo`

### 2. **Claude API (Anthropic)**
- **API:** Claude API
- **Key:** `CLAUDE_API_KEY`
- **URL:** https://console.anthropic.com/settings/keys
- **Verwendung in Alanko:**
  - Supervisor/Assistent (Backend)
  - Komplexe Aufgaben
  - Dokumentation
  - Qualitätskontrolle
- **Kosten:** ~$0.015/1K tokens
- **Model:** `claude-3-opus-20240229` oder `claude-3-sonnet`

### 3. **Gemini API (Google)**
- **API:** Google Gemini API
- **Key:** `GEMINI_API_KEY`
- **URL:** https://makersuite.google.com/app/apikey
- **Verwendung in Alanko:**
  - Backup-Modell (falls OpenAI ausfällt)
  - Multimodal (Text + Bilder)
  - Kostenlose Alternative
- **Kosten:** Kostenlos (mit Limits)
- **Model:** `gemini-pro` oder `gemini-pro-vision`

### 4. **Grok API (xAI)** - Optional
- **API:** Grok API
- **Key:** `GROK_API_KEY`
- **URL:** https://console.x.ai/keys
- **Verwendung in Alanko:**
  - Aktuelle Informationen (Recherche)
  - Real-time Daten
  - Internet-Zugang
- **Kosten:** ~$0.01/1K tokens
- **Model:** `grok-beta`

### 5. **Pinecone (Vector Database)**
- **API:** Pinecone API
- **Key:** `PINECONE_API_KEY`
- **URL:** https://app.pinecone.io/
- **Verwendung in Alanko:**
  - Knowledge Base
  - Langzeit-Memory für jeden Benutzer
  - Vektor-Suche für Lerninhalte
  - Personalisierte Empfehlungen
- **Kosten:** Kostenlos (Starter Plan)
- **Index:** `kids-ai-knowledge-base`

---

## 🏗️ Technologie-Stack

### Frontend
- **Framework:** React Native
- **Sprache:** TypeScript/JavaScript
- **Platform:** iOS & Android

### Backend
- **Framework:** Node.js + Express
- **Sprache:** JavaScript/TypeScript
- **Database:** PostgreSQL (Railway)
- **Deployment:** Railway

### AI-Integration
- **Primary:** OpenAI GPT-4
- **Secondary:** Claude API (Supervisor)
- **Backup:** Gemini API
- **Knowledge Base:** Pinecone

---

## 📊 Modelle-Übersicht

| Modell | Provider | Verwendung | Kosten | Status |
|--------|----------|------------|--------|--------|
| GPT-4 | OpenAI | Haupt-KI-Assistent | ~$0.03/1K | ✅ Primär |
| Claude Opus | Anthropic | Supervisor/Backend | ~$0.015/1K | ✅ Aktiv |
| Gemini Pro | Google | Backup-Modell | Kostenlos | ✅ Backup |
| Grok | xAI | Recherche (optional) | ~$0.01/1K | ⏳ Optional |
| Pinecone | Pinecone | Knowledge Base | Kostenlos | ✅ Aktiv |

---

## 🔗 Repository-Struktur

```
cursor project/
├── kids-ai-all-in/              # Haupt-Repository (Superman)
│   ├── apps/
│   │   ├── alanko/             # Alanko App (7-jähriger)
│   │   ├── lianko/             # Lianko App (4-jähriger)
│   │   ├── parent/             # Parent Dashboard
│   │   └── makerhub/           # MakerHub App (14-jähriger)
│   ├── API_DOKUMENTATION.md
│   ├── API_KEYS_SETUP.md
│   └── ...
├── emir-superman/               # Supervisor-System
│   ├── server.js
│   ├── NUTZUNGSANLEITUNG.md
│   └── ...
└── ai-supervisor-system/        # AI-Supervisor
    ├── supervisor/
    ├── agents/
    └── knowledge-base/
```

---

## 📝 API-Endpunkte für Alanko

### AI-Assistant Endpoints:
- `POST /api/v1/ai/chat` - Chat mit KI-Assistenten
- `GET /api/v1/ai/recommendations` - Personalisierte Empfehlungen

### Verwendete Modelle:
- **Chat:** OpenAI GPT-4 (kindgerechte Antworten)
- **Empfehlungen:** GPT-4 + Pinecone (basierend auf Fortschritt)
- **Supervisor:** Claude API (Backend-Koordination)

---

## 🚀 Deployment

### Alanko App:
- **Lokal:** `http://localhost:3001`
- **Staging:** `https://alanko-test.railway.app`
- **Production:** `https://alanko.railway.app`

### Supervisor:
- **URL:** `http://49.13.158.176:3000`
- **Health:** `http://49.13.158.176:3000/health`

---

## ✅ Checkliste

### Repositories:
- [x] Superman Repository (Haupt-Repo)
- [x] emir-superman (Supervisor)
- [x] ai-supervisor-system (AI-System)

### Modelle:
- [ ] OpenAI GPT-4 API Key
- [ ] Claude API Key
- [ ] Gemini API Key
- [ ] Pinecone API Key
- [ ] Grok API Key (optional)

---

**Letzte Aktualisierung:** 19. Dezember 2024

