# 🚀 Kids AI All-In - Komplett-System

Alle Kids AI Apps und Systeme in einem Repository.

---

## 📋 Übersicht

### 🎯 Hauptsysteme

1. **📊 Dashboard-System**
   - Repository-Übersicht und Monitoring
   - Entwickler-Statistiken
   - Sicherheitsprüfung
   - Web-Interface: http://localhost:8080/dashboard.html

2. **🤖 Premium Sales Agents**
   - 10-20 gleichzeitige Verkäufer
   - Solar, Strom, Handy (Deutschland)
   - Nicht erkennbar als KI
   - Backend: http://localhost:3000

3. **💬 Callcenter AI**
   - KI-gestützter Verkaufsagent
   - Multi-Session Support
   - Mehrsprachig (Deutsch, Bosnisch, Serbisch)

4. **👶 Kids Apps**
   - Lianko - App für Kinder mit Hörbehinderung
   - Alanko - Lern-App für alle Kinder
   - Parent - Eltern-Dashboard

---

## 🚀 Quick Start

### 1. Repository klonen

```bash
git clone https://github.com/devshift-stack/kids-ai-all-in.git
cd kids-ai-all-in
```

### 2. Dashboard starten

```bash
# Daten generieren
python3 scripts/generate_dashboard_data.py

# Web-Server starten
python3 -m http.server 8080

# Browser: http://localhost:8080/dashboard.html
```

### 3. Premium Sales Agents starten

```bash
cd apps/callcenter-ai/backend
npm install
npm start

# Backend: http://localhost:3000
```

---

## 📚 Dokumentation

### Setup-Anleitungen

- **README_SETUP_COMPLETE.md** - Komplette Setup-Anleitung
- **apps/callcenter-ai/backend/PREMIUM_AGENTS_SETUP.md** - Premium Agents Setup
- **DASHBOARD_URL.txt** - Dashboard-Zugriff

### Feature-Dokumentation

- **PREMIUM_SALES_AGENTS_READY.md** - Premium Sales Agents Features
- **GITHUB_PUSH_ANLEITUNG.md** - GitHub Push & PR
- **PUSH_ERFOLGREICH.md** - Push-Status

### Scripts

- **scripts/generate_dashboard_data.py** - Dashboard-Daten-Generierung
- **scripts/repo_analyzer.py** - Repository-Analyse

---

## 🔧 System-Anforderungen

- **Node.js** 18+ (für Backend)
- **Python 3** (für Dashboard-Scripts)
- **Git** (für Repository-Management)
- **npm** (für Dependencies)

---

## 📦 Installation

### Node.js Dependencies

```bash
cd apps/callcenter-ai/backend
npm install
```

### Python Dependencies

```bash
pip3 install requests
```

---

## 🎯 Features

### Dashboard-System
- ✅ Repository-Status (alle Apps)
- ✅ Entwickler-Statistiken
- ✅ Sicherheitsprüfung
- ✅ Web-Interface
- ✅ Automatische Daten-Generierung

### Premium Sales Agents
- ✅ 10-20 gleichzeitige Sessions
- ✅ 3 Produktkategorien (Solar, Strom, Handy)
- ✅ Nicht erkennbar als KI
- ✅ Optimierte Verkaufs-Prompts
- ✅ Variable Agent-Namen

### Callcenter AI
- ✅ Multi-Session Support
- ✅ Mehrsprachig
- ✅ Voice & Text Support
- ✅ Premium TTS (optional)

---

## 📁 Projektstruktur

```
kids-ai-all-in/
├── apps/
│   ├── callcenter-ai/      # Premium Sales Agents
│   ├── lianko/             # Lianko App
│   ├── alanko/             # Alanko App
│   └── parent/             # Parent Dashboard
├── scripts/
│   ├── generate_dashboard_data.py
│   └── repo_analyzer.py
├── dashboard.html          # Web-Dashboard
├── dashboard_data.json     # Dashboard-Daten
└── README.md              # Diese Datei
```

---

## 🔗 URLs

- **Dashboard:** http://localhost:8080/dashboard.html
- **Premium Agents Backend:** http://localhost:3000
- **GitHub Repository:** https://github.com/devshift-stack/kids-ai-all-in

---

## 🛠️ Entwicklung

### Dashboard aktualisieren

```bash
python3 scripts/generate_dashboard_data.py
```

### Backend starten (Development)

```bash
cd apps/callcenter-ai/backend
npm run dev  # Mit nodemon
```

### Repository analysieren

```bash
python3 scripts/repo_analyzer.py
```

---

## 📝 Beitragen

1. Fork das Repository
2. Erstelle Feature-Branch (`git checkout -b feature/AmazingFeature`)
3. Commit Änderungen (`git commit -m 'feat: Add AmazingFeature'`)
4. Push zu Branch (`git push origin feature/AmazingFeature`)
5. Öffne Pull Request

---

## 📄 Lizenz

Siehe LICENSE Datei für Details.

---

## 👥 Kontakt

- **Repository:** https://github.com/devshift-stack/kids-ai-all-in
- **Issues:** https://github.com/devshift-stack/kids-ai-all-in/issues

---

**Status:** ✅ Produktionsbereit

