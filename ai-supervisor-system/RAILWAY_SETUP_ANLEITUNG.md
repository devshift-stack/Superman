# 🚂 Railway Setup - Schritt-für-Schritt Anleitung

## 📋 Was du jetzt machen musst

### **Schritt 1: Railway Account erstellen**

1. Gehe zu: **https://railway.app/**
2. Klicke auf **"Start a New Project"** oder **"Login"**
3. **Account erstellen:**
   - **Option A:** "Login with GitHub" (empfohlen - einfachste Verbindung)
   - **Option B:** E-Mail + Passwort
4. **Account bestätigen** (falls E-Mail - Check dein E-Mail-Postfach)

**URL:** https://railway.app/

**Dauer:** 2-3 Minuten

---

### **Schritt 2: Neues Projekt erstellen**

1. Nach Login: Klicke auf **"New Project"** (oben rechts)
2. Wähle **"Deploy from GitHub repo"**
3. **GitHub erlauben:**
   - Railway fragt: "Darf Railway auf deine GitHub Repositories zugreifen?"
   - Klicke: **"Authorize Railway"**
   - Wähle Repository-Zugriff (nur ausgewählte Repos oder alle)
4. **Repository auswählen:**
   - Railway zeigt alle deine GitHub Repositories
   - Wähle: `kids-ai-all-in` (oder dein Projekt)
   - Klicke auf Repository

**Dauer:** 2-3 Minuten

---

### **Schritt 3: Region wählen (Frankfurt)**

1. In Railway Projekt: Klicke auf **"Settings"** (oben)
2. Scrolle zu **"Region"**
3. Wähle: **"Frankfurt"** (oder London/Amsterdam)
4. **Speichern**

**Warum Frankfurt:**
- ✅ Näher zu dir (weniger Latenz)
- ✅ DSGVO-konform (Datenschutz)
- ✅ Schnell (10-20ms)

**Dauer:** 1 Minute

---

### **Schritt 4: Environment Variables setzen (API-Keys)**

**🎯 WICHTIG: Diese API-Keys müssen in Railway gesetzt werden!**

#### **So machst du es Schritt für Schritt:**

1. **In Railway Projekt öffnen:**
   - Gehe zu: https://railway.app/
   - Klicke auf dein Projekt (oder erstelle eines, falls noch nicht gemacht)

2. **"Variables" Tab öffnen:**
   - Oben in der Navigation: Klicke auf **"Variables"** (oder "Environment Variables")
   - Du siehst eine Liste (wahrscheinlich noch leer)

3. **Erste Variable hinzufügen:**
   - Klicke auf **"New Variable"** (oder "+" Button)
   - **Name:** `OPENAI_API_KEY` (genau so, ohne Leerzeichen)
   - **Value:** `DEIN_OPENAI_API_KEY_HIER` (siehe FRAGEN_ANTWORTEN.md → Frage 50 für alle Keys)
   - Klicke **"Add"** oder **"Save"**

4. **Weitere Variablen hinzufügen (wiederhole für jeden):**
   
   **Variable 2:**
   - Klicke **"New Variable"**
   - **Name:** `GROK_API_KEY`
   - **Value:** `DEIN_GROK_API_KEY_HIER` (siehe FRAGEN_ANTWORTEN.md → Frage 50 für alle Keys)
   - Klicke **"Add"**

   **Variable 3:**
   - Klicke **"New Variable"**
   - **Name:** `GEMINI_API_KEY`
   - **Value:** `DEIN_GEMINI_API_KEY_HIER` (siehe FRAGEN_ANTWORTEN.md → Frage 50 für alle Keys)
   - Klicke **"Add"**

   **Variable 4:**
   - Klicke **"New Variable"**
   - **Name:** `CLAUDE_API_KEY`
   - **Value:** `DEIN_CLAUDE_API_KEY_HIER` (siehe FRAGEN_ANTWORTEN.md → Frage 50 für alle Keys)
   - Klicke **"Add"**

   **Variable 5:**
   - Klicke **"New Variable"**
   - **Name:** `PINECONE_API_KEY`
   - **Value:** `DEIN_PINECONE_API_KEY_HIER` (siehe FRAGEN_ANTWORTEN.md → Frage 50 für alle Keys)
   - Klicke **"Add"**

5. **Prüfen:**
   - Du solltest jetzt 5 Variablen sehen:
     - ✅ `OPENAI_API_KEY`
     - ✅ `GROK_API_KEY`
     - ✅ `GEMINI_API_KEY`
     - ✅ `CLAUDE_API_KEY`
     - ✅ `PINECONE_API_KEY`

6. **Fertig!**
   - Railway speichert automatisch
   - Railway startet automatisch neu (falls Server läuft)
   - Keine weitere Aktion nötig

**⚠️ WICHTIG:**
- **Namen müssen GENAU so sein** (Groß-/Kleinschreibung beachten!)
- **Keine Leerzeichen** in Namen oder Werten
- **Komplette Keys kopieren** (von Anfang bis Ende)
- **Jeder Key einzeln hinzufügen** (nicht alle auf einmal)

**Dauer:** 5-10 Minuten

---

### **Schritt 5: Services hinzufügen (PostgreSQL, Redis)**

**Railway fügt automatisch hinzu, aber du kannst manuell hinzufügen:**

1. In Railway Projekt: Klicke auf **"New"** (oben)
2. Wähle **"Database"** → **"PostgreSQL"**
3. Railway erstellt automatisch PostgreSQL
4. Wiederhole für **"Redis"** (falls nötig)

**Oder:** Railway erkennt automatisch, was du brauchst (aus package.json)

**Dauer:** 2-3 Minuten

---

### **Schritt 6: Deployment prüfen**

1. Railway deployed automatisch von GitHub
2. Prüfe **"Deployments"** Tab
3. Sollte zeigen: "Deployed successfully" ✅

**Falls Fehler:**
- Prüfe **"Logs"** Tab
- Prüfe Environment Variables (sind alle gesetzt?)
- Prüfe package.json (ist `start` Script vorhanden?)

**Dauer:** 1-2 Minuten (automatisch)

---

## ✅ Fertig!

**Was Railway jetzt macht:**
- ✅ Code von GitHub pullen
- ✅ Dependencies installieren (`npm install`)
- ✅ Server starten (`npm start`)
- ✅ 24/7 laufen lassen

**Du musst nichts mehr machen!**

---

## 🔧 Nächste Schritte (nach Setup)

**Was ich dann mache:**
1. Code für Railway vorbereiten (package.json, railway.json)
2. Deployment-Konfiguration erstellen
3. Alles auf Railway deployen
4. Supervisor/Assistent läuft 24/7

**Du sagst mir einfach:**
- "Railway ist fertig, du kannst deployen"
- Oder: "Ich habe Probleme bei Schritt X"

---

## 📝 Checkliste

- [ ] Railway Account erstellt
- [ ] GitHub Repository verbunden
- [ ] Region gewählt (Frankfurt)
- [ ] Environment Variables gesetzt (alle API-Keys)
- [ ] Services hinzugefügt (PostgreSQL, Redis)
- [ ] Deployment erfolgreich

---

## 🆘 Hilfe

**Falls Probleme:**
- Railway Docs: https://docs.railway.app/
- Railway Support: support@railway.app
- Oder: Sag mir, was nicht funktioniert

---

**Letzte Aktualisierung:** 18. Dezember 2024

