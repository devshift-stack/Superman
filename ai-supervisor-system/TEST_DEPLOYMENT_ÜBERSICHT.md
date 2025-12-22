# 🧪 Test-Deployment Übersicht - Alle Apps

## 📱 Apps & URLs

### 1. Alanko App (7-jähriger Sohn)
- **Lokal:** http://localhost:3001
- **Staging:** https://alanko-test.railway.app
- **Production:** https://alanko.railway.app
- **Test-Script:** `bash alanko_test.sh`
- **Dokumentation:** [ALANKO_TEST_DEPLOYMENT.md](ALANKO_TEST_DEPLOYMENT.md)

### 2. Lianko App (4-jähriger Sohn)
- **Lokal:** http://localhost:3002
- **Staging:** https://lianko-test.railway.app
- **Production:** https://lianko.railway.app
- **Test-Script:** `bash lianko_test.sh`
- **Dokumentation:** [LIANKO_TEST_DEPLOYMENT.md](LIANKO_TEST_DEPLOYMENT.md)

### 3. MakerHub App (14-jähriger Sohn)
- **Lokal:** http://localhost:3003
- **Staging:** https://makerhub-test.railway.app
- **Production:** https://makerhub.railway.app
- **Test-Script:** `bash makerhub_test.sh`
- **Dokumentation:** [MAKERHUB_TEST_DEPLOYMENT.md](MAKERHUB_TEST_DEPLOYMENT.md)

---

## 🚀 Quick Test - Alle Apps

### Lokal testen
```bash
# Alanko
bash alanko_test.sh

# Lianko
bash lianko_test.sh

# MakerHub
bash makerhub_test.sh
```

### Staging testen
```bash
# Alanko
bash alanko_test.sh https://alanko-test.railway.app

# Lianko
bash lianko_test.sh https://lianko-test.railway.app

# MakerHub
bash makerhub_test.sh https://makerhub-test.railway.app
```

### Production testen
```bash
# Alanko
bash alanko_test.sh https://alanko.railway.app

# Lianko
bash lianko_test.sh https://lianko.railway.app

# MakerHub
bash makerhub_test.sh https://makerhub.railway.app
```

---

## ✅ Basis-Testfragen (Alle Apps)

### Health Check
```bash
# Alanko
curl http://localhost:3001/api/health

# Lianko
curl http://localhost:3002/api/health

# MakerHub
curl http://localhost:3003/api/health
```

**Erwartet:** `{"status":"ok","version":"1.0.0"}`

---

## 📋 App-spezifische Testfragen

### Alanko (7-jähriger)
- [ ] Lektionen laden?
- [ ] Lektion starten?
- [ ] Fortschritt speichern?
- [ ] Gamification (XP, Badges)?
- [ ] KI-Assistent antwortet?
- [ ] Eltern-Dashboard funktioniert?

**Details:** Siehe [ALANKO_TEST_DEPLOYMENT.md](ALANKO_TEST_DEPLOYMENT.md)

### Lianko (4-jähriger, Hörbehinderung)
- [ ] Visuelle Signale funktionieren?
- [ ] Gebärdensprache-Videos?
- [ ] Text-zu-Gebärde Konvertierung?
- [ ] Vibration/Haptisches Feedback?
- [ ] Visuelle Lerninhalte?
- [ ] Barrierefreiheit?

**Details:** Siehe [LIANKO_TEST_DEPLOYMENT.md](LIANKO_TEST_DEPLOYMENT.md)

### MakerHub (14-jähriger)
- [ ] Projekt-Bibliothek lädt?
- [ ] Fahrrad-Reparatur-Tutorials?
- [ ] Gaming & Coding-Tutorials?
- [ ] TikTok-Integration?
- [ ] Community-Feed?
- [ ] Gamification (XP, Badges, Challenges)?
- [ ] KI-Assistent für Projekte?

**Details:** Siehe [MAKERHUB_TEST_DEPLOYMENT.md](MAKERHUB_TEST_DEPLOYMENT.md)

---

## 🔧 Ports & Konfiguration

| App | Port | API Base | Health Endpoint |
|-----|------|----------|-----------------|
| Alanko | 3001 | `/api/v1` | `/api/health` |
| Lianko | 3002 | `/api/v1` | `/api/health` |
| MakerHub | 3003 | `/api/v1` | `/api/health` |

---

## 📝 Test-Szenarien

### Szenario 1: Alle Apps gleichzeitig testen
```bash
# Terminal 1: Alanko
bash alanko_test.sh http://localhost:3001

# Terminal 2: Lianko
bash lianko_test.sh http://localhost:3002

# Terminal 3: MakerHub
bash makerhub_test.sh http://localhost:3003
```

### Szenario 2: Staging-Deployment testen
```bash
# Alle Apps auf Staging testen
bash alanko_test.sh https://alanko-test.railway.app
bash lianko_test.sh https://lianko-test.railway.app
bash makerhub_test.sh https://makerhub-test.railway.app
```

### Szenario 3: Production-Deployment testen
```bash
# Alle Apps auf Production testen
bash alanko_test.sh https://alanko.railway.app
bash lianko_test.sh https://lianko.railway.app
bash makerhub_test.sh https://makerhub.railway.app
```

---

## 🐛 Troubleshooting

### Port bereits belegt
```bash
# Prüfe was auf Port läuft
lsof -i :3001  # Alanko
lsof -i :3002  # Lianko
lsof -i :3003  # MakerHub
```

### App startet nicht
1. Prüfe Logs
2. Prüfe Environment Variables
3. Prüfe Dependencies (`npm install`)
4. Prüfe Port-Konflikte

### API-Endpunkte nicht erreichbar
1. Prüfe ob Server läuft
2. Prüfe Firewall-Einstellungen
3. Prüfe URL/Port
4. Prüfe CORS-Einstellungen

---

## 📚 Weitere Dokumentation

- **Alanko:** [ALANKO_TEST_DEPLOYMENT.md](ALANKO_TEST_DEPLOYMENT.md)
- **Lianko:** [LIANKO_TEST_DEPLOYMENT.md](LIANKO_TEST_DEPLOYMENT.md)
- **MakerHub:** [MAKERHUB_TEST_DEPLOYMENT.md](MAKERHUB_TEST_DEPLOYMENT.md)
- **Google Play Beschreibungen:**
  - [ALANKO_GOOGLE_PLAY_DESCRIPTION.md](ALANKO_GOOGLE_PLAY_DESCRIPTION.md)
  - [LIANKO_GOOGLE_PLAY_DESCRIPTION.md](LIANKO_GOOGLE_PLAY_DESCRIPTION.md)

---

**Letzte Aktualisierung:** $(date)

