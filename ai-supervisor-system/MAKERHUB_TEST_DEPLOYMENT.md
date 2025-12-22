# 🧪 MakerHub App - Test-Deployment & Testfragen

## 🌐 Test-URLs

### Lokal (Development)
- **URL:** http://localhost:3003
- **Health Check:** http://localhost:3003/api/health
- **API Base:** http://localhost:3003/api/v1

### Staging (Railway/Test)
- **URL:** https://makerhub-test.railway.app
- **Health Check:** https://makerhub-test.railway.app/api/health
- **API Base:** https://makerhub-test.railway.app/api/v1

### Production (Railway)
- **URL:** https://makerhub.railway.app
- **Health Check:** https://makerhub.railway.app/api/health
- **API Base:** https://makerhub.railway.app/api/v1

---

## ✅ Testfragen-Checkliste

### 1. Basis-Funktionalität

- [ ] **Health Check funktioniert?**
  ```bash
  curl http://localhost:3003/api/health
  ```
  Erwartet: `{"status":"ok","version":"1.0.0"}`

- [ ] **App startet ohne Fehler?**
  - Server läuft auf Port 3003
  - Keine Crashes in Logs
  - Alle Dependencies installiert

- [ ] **API-Endpunkte erreichbar?**
  - `/api/health` → OK
  - `/api/v1/projects` → OK
  - `/api/v1/bike` → OK
  - `/api/v1/gaming` → OK
  - `/api/v1/community` → OK

### 2. Projekt-Features (Basteln/Schrauben)

- [ ] **Projekt-Bibliothek lädt?**
  ```bash
  curl http://localhost:3003/api/v1/projects
  ```
  Erwartet: Liste von Bastel-/Schraub-Projekten

- [ ] **Projekt starten?**
  ```bash
  curl -X POST http://localhost:3003/api/v1/projects/start \
    -H "Content-Type: application/json" \
    -d '{"projectId":"wood-001","userId":"test-user"}'
  ```

- [ ] **Schritt-für-Schritt Anleitung?**
  ```bash
  curl http://localhost:3003/api/v1/projects/wood-001/steps
  ```
  Erwartet: Detaillierte Anleitung mit Bildern/Videos

- [ ] **Material-Liste?**
  ```bash
  curl http://localhost:3003/api/v1/projects/wood-001/materials
  ```
  Erwartet: Liste mit Links zum Kauf

- [ ] **Projekt-Fortschritt speichern?**
  ```bash
  curl -X POST http://localhost:3003/api/v1/projects/progress \
    -H "Content-Type: application/json" \
    -d '{"userId":"test-user","projectId":"wood-001","step":3,"completed":true}'
  ```

### 3. Fahrrad-Features

- [ ] **Fahrrad-Reparatur-Tutorials?**
  ```bash
  curl http://localhost:3003/api/v1/bike/tutorials
  ```
  Erwartet: Liste von Reparatur-Anleitungen

- [ ] **Route-Planer?**
  ```bash
  curl -X POST http://localhost:3003/api/v1/bike/routes \
    -H "Content-Type: application/json" \
    -d '{"start":"Berlin","end":"Potsdam","distance":30}'
  ```

- [ ] **Fitness-Tracking?**
  ```bash
  curl -X POST http://localhost:3003/api/v1/bike/track \
    -H "Content-Type: application/json" \
    -d '{"userId":"test-user","distance":15.5,"duration":3600}'
  ```

- [ ] **Wartungs-Erinnerungen?**
  ```bash
  curl http://localhost:3003/api/v1/bike/maintenance?userId=test-user
  ```

### 4. Gaming & Coding

- [ ] **Coding-Tutorials?**
  ```bash
  curl http://localhost:3003/api/v1/gaming/coding
  ```
  Erwartet: Programmieren-lernen Tutorials

- [ ] **Game-Design-Tutorials?**
  ```bash
  curl http://localhost:3003/api/v1/gaming/design
  ```

- [ ] **Modding-Anleitungen?**
  ```bash
  curl http://localhost:3003/api/v1/gaming/modding
  ```

- [ ] **Code-Projekte teilen?**
  ```bash
  curl -X POST http://localhost:3003/api/v1/gaming/share \
    -H "Content-Type: application/json" \
    -d '{"userId":"test-user","projectName":"My Game","code":"..."}'
  ```

### 5. TikTok & Social Features

- [ ] **Projekt-Video erstellen?**
  ```bash
  curl -X POST http://localhost:3003/api/v1/community/video \
    -H "Content-Type: application/json" \
    -d '{"userId":"test-user","projectId":"wood-001","videoUrl":"..."}'
  ```

- [ ] **Community-Feed?**
  ```bash
  curl http://localhost:3003/api/v1/community/feed
  ```
  Erwartet: Feed mit Projekten anderer User

- [ ] **Projekte liken/kommentieren?**
  ```bash
  curl -X POST http://localhost:3003/api/v1/community/like \
    -H "Content-Type: application/json" \
    -d '{"userId":"test-user","projectId":"wood-001"}'
  ```

- [ ] **TikTok-Integration?**
  - Video direkt zu TikTok teilen
  - TikTok-Link in Projekt einbetten

### 6. Gamification

- [ ] **XP-System?**
  ```bash
  curl http://localhost:3003/api/v1/gamification/xp?userId=test-user
  ```
  Erwartet: Aktuelle XP-Punkte

- [ ] **Badges freischalten?**
  ```bash
  curl http://localhost:3003/api/v1/gamification/badges?userId=test-user
  ```
  Erwartet: Liste von freigeschalteten Badges

- [ ] **Challenges?**
  ```bash
  curl http://localhost:3003/api/v1/gamification/challenges
  ```
  Erwartet: Aktuelle Challenges

- [ ] **Leaderboard?**
  ```bash
  curl http://localhost:3003/api/v1/gamification/leaderboard
  ```

### 7. KI-Features

- [ ] **KI-Assistent für Projekte?**
  ```bash
  curl -X POST http://localhost:3003/api/v1/ai/chat \
    -H "Content-Type: application/json" \
    -d '{"message":"Wie repariere ich einen platten Reifen?","userId":"test-user"}'
  ```
  Erwartet: Praktische Anleitung

- [ ] **Projekt-Vorschläge?**
  ```bash
  curl http://localhost:3003/api/v1/ai/recommendations?userId=test-user
  ```
  Erwartet: Personalisierte Projekt-Empfehlungen

- [ ] **Problemlösung-Hilfe?**
  ```bash
  curl -X POST http://localhost:3003/api/v1/ai/help \
    -H "Content-Type: application/json" \
    -d '{"userId":"test-user","projectId":"wood-001","problem":"Schraube passt nicht"}'
  ```

### 8. Mobile App (React Native)

- [ ] **App installiert?**
  - iOS: TestFlight oder App Store
  - Android: APK oder Play Store

- [ ] **Navigation funktioniert?**
  - Home Screen lädt
  - Projekte öffnen
  - Community-Feed anzeigen
  - Profil anzeigen

- [ ] **Offline-Modus?**
  - Projekte funktionieren offline
  - Anleitungen werden gecacht
  - Fortschritt wird synchronisiert

- [ ] **Kamera-Integration?**
  - Fotos von Projekten machen
  - Videos aufnehmen
  - QR-Codes scannen

### 9. Performance

- [ ] **Ladezeiten akzeptabel?**
  - < 3 Sekunden für Projekte
  - < 2 Sekunden für API-Calls
  - Videos laden schnell

- [ ] **Keine Memory-Leaks?**
  - App läuft stabil über längere Zeit
  - Keine Crashes

### 10. Sicherheit

- [ ] **API-Keys geschützt?**
  - Keine Keys im Frontend
  - Environment Variables gesetzt

- [ ] **Daten verschlüsselt?**
  - HTTPS aktiv (Production)
  - Sensible Daten verschlüsselt

- [ ] **Altersgerechte Inhalte?**
  - 14+ Filter aktiv
  - Keine unangemessenen Inhalte

---

## 🚀 Quick Test Script

```bash
#!/bin/bash
# makerhub_test.sh

BASE_URL="${1:-http://localhost:3003}"

echo "🧪 Teste MakerHub App auf: $BASE_URL"
echo ""

# 1. Health Check
echo "1. Health Check..."
curl -s ${BASE_URL}/api/health | python3 -m json.tool
echo ""

# 2. Projekte laden
echo "2. Projekte laden..."
curl -s ${BASE_URL}/api/v1/projects | python3 -m json.tool | head -20
echo ""

# 3. Fahrrad-Tutorials
echo "3. Fahrrad-Tutorials..."
curl -s ${BASE_URL}/api/v1/bike/tutorials | python3 -m json.tool | head -20
echo ""

# 4. Gaming-Tutorials
echo "4. Gaming-Tutorials..."
curl -s ${BASE_URL}/api/v1/gaming/coding | python3 -m json.tool | head -20
echo ""

# 5. Test-User erstellen
echo "5. Test-User erstellen..."
USER_RESPONSE=$(curl -s -X POST ${BASE_URL}/api/v1/users \
  -H "Content-Type: application/json" \
  -d '{"name":"Test User","age":14,"interests":["bike","gaming","building"]}')
echo "$USER_RESPONSE" | python3 -m json.tool
USER_ID=$(echo "$USER_RESPONSE" | python3 -c "import sys, json; print(json.load(sys.stdin).get('userId', ''))" 2>/dev/null)
echo ""

# 6. Projekt starten
if [ -n "$USER_ID" ]; then
  echo "6. Projekt starten..."
  curl -s -X POST ${BASE_URL}/api/v1/projects/start \
    -H "Content-Type: application/json" \
    -d "{\"projectId\":\"wood-001\",\"userId\":\"$USER_ID\"}" | python3 -m json.tool
  echo ""
  
  # 7. KI-Empfehlungen
  echo "7. KI-Empfehlungen..."
  curl -s "${BASE_URL}/api/v1/ai/recommendations?userId=$USER_ID" | python3 -m json.tool | head -20
  echo ""
fi

# 8. Community-Feed
echo "8. Community-Feed..."
curl -s ${BASE_URL}/api/v1/community/feed | python3 -m json.tool | head -20
echo ""

# 9. Gamification
echo "9. Gamification (XP, Badges)..."
curl -s "${BASE_URL}/api/v1/gamification/xp?userId=$USER_ID" | python3 -m json.tool
curl -s "${BASE_URL}/api/v1/gamification/badges?userId=$USER_ID" | python3 -m json.tool | head -10
echo ""

echo "✅ Tests abgeschlossen!"
```

**Verwendung:**
```bash
# Lokal testen
bash makerhub_test.sh

# Staging testen
bash makerhub_test.sh https://makerhub-test.railway.app

# Production testen
bash makerhub_test.sh https://makerhub.railway.app
```

---

## 📝 Test-Szenarien

### Szenario 1: Neues Projekt starten
1. App öffnen
2. Projekt-Bibliothek durchsuchen
3. Projekt auswählen (z.B. "Holzregal bauen")
4. Material-Liste ansehen
5. Schritt-für-Schritt Anleitung folgen
6. Fortschritt dokumentieren (Fotos)

**Erwartet:** Alles funktioniert, XP wird vergeben

### Szenario 2: Fahrrad-Reparatur
1. App öffnen
2. Fahrrad-Tutorials durchsuchen
3. "Platten Reifen reparieren" auswählen
4. Anleitung folgen
5. KI-Assistent fragen bei Problemen
6. Route für Testfahrt planen

**Erwartet:** Anleitung klar, KI hilft, Route wird erstellt

### Szenario 3: Gaming & Coding
1. App öffnen
2. Coding-Tutorial starten
3. Erstes Spiel programmieren
4. Code teilen in Community
5. Feedback erhalten
6. Badge freischalten

**Erwartet:** Tutorial funktioniert, Sharing klappt, Badge wird freigeschaltet

### Szenario 4: TikTok-Integration
1. Projekt fertigstellen
2. Video erstellen
3. Zu TikTok teilen
4. Link in Community posten
5. Likes/Kommentare erhalten

**Erwartet:** Video wird geteilt, Community-Interaktion funktioniert

### Szenario 5: Challenge
1. Wöchentliche Challenge ansehen
2. Challenge akzeptieren
3. Projekt abschließen
4. Einreichen
5. Leaderboard prüfen

**Erwartet:** Challenge funktioniert, Leaderboard aktualisiert

---

## 🐛 Bekannte Probleme / Notizen

- [ ] Problem 1: ...
- [ ] Problem 2: ...
- [ ] Feature Request: ...

---

**Letzte Aktualisierung:** $(date)

