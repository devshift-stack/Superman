# 🔑 API-Keys in Railway hinzufügen - SOFORT FIX

**Problem:** Server crasht weil API-Keys fehlen!
**Fehler:** `OpenAIError: Missing credentials. Please pass an apiKey, or set the OPENAI_API_KEY environment variable.`

---

## ⚠️ PROBLEM GEFUNDEN

**Der Server crasht weil:**
- ❌ API-Keys fehlen in Railway Environment Variables
- ❌ Server versucht OpenAI zu initialisieren, aber kein API-Key vorhanden

---

## ✅ LÖSUNG: API-Keys in Railway hinzufügen

### **Schritt 1: Railway Dashboard öffnen**

1. Gehe zu: https://railway.app/dashboard
2. Wähle dein Projekt aus
3. Wähle deinen Service aus (z.B. "Supervisor")

### **Schritt 2: Environment Variables öffnen**

1. Klicke auf **"Variables"** Tab (oder "Settings" → "Variables")
2. Du siehst eine Liste von Environment Variables

### **Schritt 3: API-Keys hinzufügen**

**Füge diese Environment Variables hinzu:**

| Variable Name | Wert | Beschreibung |
|--------------|------|--------------|
| `OPENAI_API_KEY` | `sk-proj-...` | OpenAI API Key |
| `CLAUDE_API_KEY` | `sk-ant-api03-...` | Claude API Key |
| `GROK_API_KEY` | `xai-...` | Grok API Key |
| `GEMINI_API_KEY` | `AIzaSy...` | Gemini API Key |
| `PINECONE_API_KEY` | `pcsk_...` | Pinecone API Key |
| `PINECONE_ENVIRONMENT` | `gcp-starter` (oder dein Environment) | Pinecone Environment |
| `REDIS_URL` | `redis://...` | Redis URL (Railway zeigt dir diese) |

---

## 🔧 Schritt-für-Schritt

### **1. "Variables" Tab öffnen**
- Railway Dashboard → Service → **"Variables"** Tab

### **2. "New Variable" klicken**
- Klicke auf **"New Variable"** Button

### **3. Variable hinzufügen**
- **Name:** `OPENAI_API_KEY`
- **Value:** Dein OpenAI API Key (aus `.env` Datei)
- **Klicke "Add"**

### **4. Wiederhole für alle Keys**
Füge alle API-Keys hinzu:
- `OPENAI_API_KEY`
- `CLAUDE_API_KEY`
- `GROK_API_KEY`
- `GEMINI_API_KEY`
- `PINECONE_API_KEY`
- `PINECONE_ENVIRONMENT`

### **5. Redis URL (falls nötig)**
- Railway → Service → **"Data"** Tab
- Klicke auf **"Add Redis"** (falls noch nicht vorhanden)
- Railway zeigt dir die `REDIS_URL`
- Kopiere diese und füge sie als Environment Variable hinzu

---

## 📋 Alle benötigten Environment Variables

**API-Keys:**
```
OPENAI_API_KEY=sk-proj-...
CLAUDE_API_KEY=sk-ant-api03-...
GROK_API_KEY=xai-...
GEMINI_API_KEY=AIzaSy...
PINECONE_API_KEY=pcsk_...
PINECONE_ENVIRONMENT=gcp-starter
```

**Redis (falls verwendet):**
```
REDIS_URL=redis://default:password@host:port
```

**Optional:**
```
DB_PATH=./data/sessions.db
PORT=3000
```

---

## ⚠️ WICHTIG

**1. Genau so benennen:**
- ✅ `OPENAI_API_KEY` (nicht `OPENAI_KEY` oder `OPENAI_API`)
- ✅ `CLAUDE_API_KEY` (nicht `CLAUDE_KEY`)
- ✅ Groß-/Kleinschreibung beachten!

**2. Keine Leerzeichen:**
- ❌ `OPENAI_API_KEY = sk-...` (falsch)
- ✅ `OPENAI_API_KEY=sk-...` (richtig)

**3. Nach dem Hinzufügen:**
- Railway deployt automatisch neu
- Server startet mit API-Keys
- Sollte jetzt funktionieren!

---

## ✅ Checkliste

**API-Keys hinzufügen:**
- [ ] `OPENAI_API_KEY` hinzugefügt
- [ ] `CLAUDE_API_KEY` hinzugefügt
- [ ] `GROK_API_KEY` hinzugefügt
- [ ] `GEMINI_API_KEY` hinzugefügt
- [ ] `PINECONE_API_KEY` hinzugefügt
- [ ] `PINECONE_ENVIRONMENT` hinzugefügt
- [ ] `REDIS_URL` hinzugefügt (falls nötig)

**Verifizierung:**
- [ ] Railway deployt neu (automatisch)
- [ ] Server startet ohne Fehler
- [ ] Logs zeigen keine "Missing credentials" Fehler mehr

---

## 🆘 Falls immer noch Fehler

**Prüfe:**
1. Sind alle API-Keys korrekt kopiert? (keine Leerzeichen, vollständig)
2. Sind die Variablennamen genau richtig? (Groß-/Kleinschreibung!)
3. Warte 1-2 Minuten → Railway deployt neu
4. Prüfe Railway Logs → Gibt es noch andere Fehler?

---

## 📝 Wo finde ich meine API-Keys?

**Lokal (auf deinem Mac):**
- Datei: `/Users/dsselmanovic/cursor project/emir-superman/.env`
- Oder: Railway Setup Anleitung → Dort sind Platzhalter

**Falls du die Keys nicht hast:**
- Siehe: `emir-superman/API_KEY_SETUP.md`
- Oder: Erstelle neue Keys bei den jeweiligen Anbietern

---

**Letzte Aktualisierung:** 18. Dezember 2024

