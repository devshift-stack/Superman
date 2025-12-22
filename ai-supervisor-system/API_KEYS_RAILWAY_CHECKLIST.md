# ⚠️ API-Keys fehlen in Railway - SOFORT FIX!

**Problem:** Server crasht weil API-Keys fehlen!
**Fehler:** `OpenAIError: Missing credentials. Please pass an apiKey, or set the OPENAI_API_KEY environment variable.`

---

## 🔍 Problem gefunden

**Der Server crasht weil:**
- ❌ API-Keys fehlen in Railway Environment Variables
- ❌ Server versucht OpenAI zu initialisieren, aber kein API-Key vorhanden

---

## ✅ LÖSUNG: API-Keys in Railway hinzufügen

### **Schritt 1: Railway Dashboard öffnen**

1. Gehe zu: https://railway.app/dashboard
2. Wähle dein Projekt aus
3. Wähle deinen Service aus (z.B. "Supervisor" oder "emir")

### **Schritt 2: Variables Tab öffnen**

1. Klicke auf **"Variables"** Tab (oben in der Navigation)
2. Du siehst eine Liste von Environment Variables

### **Schritt 3: API-Keys hinzufügen**

**Füge diese Environment Variables hinzu:**

| Variable Name | Wert | Wo finde ich den Wert? |
|--------------|------|------------------------|
| `OPENAI_API_KEY` | `sk-proj-...` | Siehe unten |
| `CLAUDE_API_KEY` | `sk-ant-api03-...` | Siehe unten |
| `GROK_API_KEY` | `xai-...` | Siehe unten |
| `GEMINI_API_KEY` | `AIzaSy...` | Siehe unten |
| `PINECONE_API_KEY` | `pcsk_...` | Siehe unten |
| `PINECONE_ENVIRONMENT` | `gcp-starter` | Siehe unten |

---

## 🔧 Schritt-für-Schritt

### **1. "Variables" Tab öffnen**
- Railway Dashboard → Service → **"Variables"** Tab

### **2. "New Variable" klicken**
- Klicke auf **"New Variable"** Button

### **3. Variable hinzufügen**
- **Name:** `OPENAI_API_KEY` (genau so, Groß-/Kleinschreibung!)
- **Value:** Dein OpenAI API Key
- **Klicke "Add"**

### **4. Wiederhole für alle Keys**
Füge alle API-Keys hinzu:
- `OPENAI_API_KEY`
- `CLAUDE_API_KEY`
- `GROK_API_KEY`
- `GEMINI_API_KEY`
- `PINECONE_API_KEY`
- `PINECONE_ENVIRONMENT`

---

## 📋 Alle benötigten Environment Variables

**API-Keys (aus deiner .env Datei):**

```
OPENAI_API_KEY=DEIN_OPENAI_API_KEY_HIER

CLAUDE_API_KEY=DEIN_CLAUDE_API_KEY_HIER

GROK_API_KEY=DEIN_GROK_API_KEY_HIER

GEMINI_API_KEY=DEIN_GEMINI_API_KEY_HIER

PINECONE_API_KEY=DEIN_PINECONE_API_KEY_HIER

PINECONE_ENVIRONMENT=gcp-starter
```

**⚠️ WICHTIG:** Die echten API-Keys findest du in deiner lokalen `.env` Datei:
- Pfad: `/Users/dsselmanovic/cursor project/emir-superman/.env`
- Oder: Siehe `FRAGEN_ANTWORTEN.md` → Frage 50 (dort sind alle Keys aufgelistet)

**Optional (falls nötig):**
```
REDIS_URL=redis://localhost:6379
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

**Prüfe Railway Logs:**
- Railway Dashboard → Service → "Logs" Tab
- Suche nach "Missing credentials" → Sollte nicht mehr erscheinen!

---

## 📝 Wo finde ich meine API-Keys?

**Lokal (auf deinem Mac):**
- Datei: `/Users/dsselmanovic/cursor project/emir-superman/.env`
- Oder: Siehe oben in dieser Datei (alle Keys sind aufgelistet)

---

**Letzte Aktualisierung:** 18. Dezember 2024

