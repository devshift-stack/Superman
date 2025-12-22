# 🧪 Alanko App - Test-Deployment & Testfragen

## 🌐 Test-URLs

### Lokal (Development)
- **URL:** http://localhost:3001
- **Health Check:** http://localhost:3001/api/health
- **API Base:** http://localhost:3001/api/v1

### Staging (Railway/Test)
- **URL:** https://alanko-test.railway.app
- **Health Check:** https://alanko-test.railway.app/api/health
- **API Base:** https://alanko-test.railway.app/api/v1

### Production (Railway)
- **URL:** https://alanko.railway.app
- **Health Check:** https://alanko.railway.app/api/health
- **API Base:** https://alanko.railway.app/api/v1

---

## ✅ Testfragen-Checkliste

### 1. Basis-Funktionalität

- [ ] **Health Check funktioniert?**
  ```bash
  curl http://localhost:3001/api/health
  ```
  Erwartet: `{"status":"ok","version":"1.0.0"}`

- [ ] **App startet ohne Fehler?**
  - Server läuft auf Port 3001
  - Keine Crashes in Logs
  - Alle Dependencies installiert

- [ ] **API-Endpunkte erreichbar?**
  - `/api/health` → OK
  - `/api/v1/lessons` → OK
  - `/api/v1/progress` → OK

### 2. Lern-Features (7-jähriger)

- [ ] **Lektionen laden?**
  ```bash
  curl http://localhost:3001/api/v1/lessons
  ```
  Erwartet: Liste von Lektionen mit Altersgruppe 7+

- [ ] **Lektion starten?**
  ```bash
  curl -X POST http://localhost:3001/api/v1/lessons/start \
    -H "Content-Type: application/json" \
    -d '{"lessonId":"math-001","userId":"test-user"}'
  ```

- [ ] **Fortschritt speichern?**
  ```bash
  curl -X POST http://localhost:3001/api/v1/progress \
    -H "Content-Type: application/json" \
    -d '{"userId":"test-user","lessonId":"math-001","completed":true}'
  ```

- [ ] **Gamification funktioniert?**
  - XP-Punkte werden vergeben
  - Badges werden freigeschaltet
  - Level steigt an

### 3. KI-Features

- [ ] **KI-Assistent antwortet?**
  ```bash
  curl -X POST http://localhost:3001/api/v1/ai/chat \
    -H "Content-Type: application/json" \
    -d '{"message":"Was ist 2+2?","userId":"test-user"}'
  ```
  Erwartet: Kindgerechte Antwort

- [ ] **Personalisiertes Lernen?**
  - KI passt Schwierigkeit an
  - Empfehlungen basierend auf Fortschritt
  - Altersgerechte Inhalte (7 Jahre)

### 4. Eltern-Dashboard

- [ ] **Fortschritt sichtbar?**
  ```bash
  curl http://localhost:3001/api/v1/parent/progress?userId=test-user
  ```

- [ ] **Sicherheitseinstellungen?**
  - Zeitlimits funktionieren
  - Inhalte altersgerecht gefiltert

### 5. Mobile App (React Native)

- [ ] **App installiert?**
  - iOS: TestFlight oder App Store
  - Android: APK oder Play Store

- [ ] **Navigation funktioniert?**
  - Home Screen lädt
  - Lektionen öffnen
  - Profil anzeigen

- [ ] **Offline-Modus?**
  - Lektionen funktionieren offline
  - Fortschritt wird synchronisiert

### 6. Performance

- [ ] **Ladezeiten akzeptabel?**
  - < 2 Sekunden für Lektionen
  - < 1 Sekunde für API-Calls

- [ ] **Keine Memory-Leaks?**
  - App läuft stabil über längere Zeit
  - Keine Crashes

### 7. Sicherheit

- [ ] **API-Keys geschützt?**
  - Keine Keys im Frontend
  - Environment Variables gesetzt

- [ ] **Daten verschlüsselt?**
  - HTTPS aktiv (Production)
  - Sensible Daten verschlüsselt

---

## 🚀 Quick Test Script

```bash
#!/bin/bash
# alanko_test.sh

BASE_URL="${1:-http://localhost:3001}"

echo "🧪 Teste Alanko App auf: $BASE_URL"
echo ""

# 1. Health Check
echo "1. Health Check..."
curl -s ${BASE_URL}/api/health | python3 -m json.tool
echo ""

# 2. Lektionen laden
echo "2. Lektionen laden..."
curl -s ${BASE_URL}/api/v1/lessons | python3 -m json.tool | head -20
echo ""

# 3. Test-User erstellen
echo "3. Test-User erstellen..."
USER_RESPONSE=$(curl -s -X POST ${BASE_URL}/api/v1/users \
  -H "Content-Type: application/json" \
  -d '{"name":"Test User","age":7}')
echo "$USER_RESPONSE" | python3 -m json.tool
USER_ID=$(echo "$USER_RESPONSE" | python3 -c "import sys, json; print(json.load(sys.stdin).get('userId', ''))" 2>/dev/null)
echo ""

# 4. Lektion starten
if [ -n "$USER_ID" ]; then
  echo "4. Lektion starten..."
  curl -s -X POST ${BASE_URL}/api/v1/lessons/start \
    -H "Content-Type: application/json" \
    -d "{\"lessonId\":\"math-001\",\"userId\":\"$USER_ID\"}" | python3 -m json.tool
  echo ""
fi

echo "✅ Tests abgeschlossen!"
```

**Verwendung:**
```bash
# Lokal testen
bash alanko_test.sh

# Staging testen
bash alanko_test.sh https://alanko-test.railway.app

# Production testen
bash alanko_test.sh https://alanko.railway.app
```

---

## 📝 Test-Szenarien

### Szenario 1: Neuer Benutzer
1. App öffnen
2. Registrierung (Alter: 7)
3. Erste Lektion starten
4. Aufgabe lösen
5. Fortschritt speichern

**Erwartet:** Alles funktioniert, XP wird vergeben

### Szenario 2: Fortgeschrittener Benutzer
1. App öffnen
2. Login
3. Nächste Lektion starten
4. KI-Assistent fragen
5. Badge freischalten

**Erwartet:** Personalisierte Empfehlungen, Badge wird freigeschaltet

### Szenario 3: Eltern-Dashboard
1. Eltern-Login
2. Fortschritt ansehen
3. Zeitlimits prüfen
4. Bericht exportieren

**Erwartet:** Alle Daten sichtbar, Export funktioniert

---

## 🐛 Bekannte Probleme / Notizen

- [ ] Problem 1: ...
- [ ] Problem 2: ...
- [ ] Feature Request: ...

---

**Letzte Aktualisierung:** $(date)

