# 🧪 Lianko App - Test-Deployment & Testfragen

## 🌐 Test-URLs

### Lokal (Development)
- **URL:** http://localhost:3002
- **Health Check:** http://localhost:3002/api/health
- **API Base:** http://localhost:3002/api/v1

### Staging (Railway/Test)
- **URL:** https://lianko-test.railway.app
- **Health Check:** https://lianko-test.railway.app/api/health
- **API Base:** https://lianko-test.railway.app/api/v1

### Production (Railway)
- **URL:** https://lianko.railway.app
- **Health Check:** https://lianko.railway.app/api/health
- **API Base:** https://lianko.railway.app/api/v1

---

## ✅ Testfragen-Checkliste

### 1. Basis-Funktionalität

- [ ] **Health Check funktioniert?**
  ```bash
  curl http://localhost:3002/api/health
  ```
  Erwartet: `{"status":"ok","version":"1.0.0"}`

- [ ] **App startet ohne Fehler?**
  - Server läuft auf Port 3002
  - Keine Crashes in Logs
  - Alle Dependencies installiert

- [ ] **API-Endpunkte erreichbar?**
  - `/api/health` → OK
  - `/api/v1/lessons` → OK
  - `/api/v1/progress` → OK
  - `/api/v1/hearing` → OK (speziell für Hörbehinderung)

### 2. Hörbehinderung-Features (4-jähriger)

- [ ] **Visuelle Signale funktionieren?**
  - Farbige Indikatoren
  - Animationen
  - Bildsprache

- [ ] **Gebärdensprache-Videos?**
  ```bash
  curl http://localhost:3002/api/v1/lessons/sign-language
  ```
  Erwartet: Liste von Gebärdensprache-Videos

- [ ] **Text-zu-Gebärde Konvertierung?**
  ```bash
  curl -X POST http://localhost:3002/api/v1/translate/sign \
    -H "Content-Type: application/json" \
    -d '{"text":"Hallo","language":"DGS"}'
  ```

- [ ] **Vibration/Haptisches Feedback?**
  - Vibration bei Aktionen
  - Haptisches Feedback für Interaktionen

### 3. Lern-Features (4-jähriger)

- [ ] **Einfache Lektionen laden?**
  ```bash
  curl http://localhost:3002/api/v1/lessons?age=4
  ```
  Erwartet: Altersgerechte Lektionen (4 Jahre)

- [ ] **Visuelle Lerninhalte?**
  - Große Bilder
  - Einfache Symbole
  - Klare Farben

- [ ] **Interaktive Spiele?**
  - Drag & Drop funktioniert
  - Touch-Gesten erkannt
  - Sofortiges visuelles Feedback

### 4. KI-Features

- [ ] **KI-Assistent mit visueller Unterstützung?**
  ```bash
  curl -X POST http://localhost:3002/api/v1/ai/chat \
    -H "Content-Type: application/json" \
    -d '{"message":"Was ist das?","userId":"test-user","includeVisuals":true}'
  ```
  Erwartet: Antwort + visuelle Unterstützung

- [ ] **Personalisiertes Lernen?**
  - Anpassung an Hörbehinderung
  - Visuelle Lernpräferenzen
  - Altersgerecht (4 Jahre)

### 5. Eltern-Dashboard

- [ ] **Fortschritt sichtbar?**
  ```bash
  curl http://localhost:3002/api/v1/parent/progress?userId=test-user
  ```

- [ ] **Hörbehinderung-Einstellungen?**
  - Grad der Hörbehinderung einstellbar
  - Präferierte Kommunikationsmethode
  - Gebärdensprache-Einstellungen

### 6. Mobile App (React Native)

- [ ] **App installiert?**
  - iOS: TestFlight oder App Store
  - Android: APK oder Play Store

- [ ] **Barrierefreiheit?**
  - Screen Reader Support
  - Große Touch-Targets
  - Hoher Kontrast

- [ ] **Offline-Modus?**
  - Lektionen funktionieren offline
  - Videos werden gecacht

### 7. Performance

- [ ] **Ladezeiten akzeptabel?**
  - < 2 Sekunden für Lektionen
  - < 1 Sekunde für API-Calls
  - Videos laden schnell

- [ ] **Keine Memory-Leaks?**
  - App läuft stabil über längere Zeit
  - Keine Crashes

### 8. Sicherheit

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
# lianko_test.sh

BASE_URL="${1:-http://localhost:3002}"

echo "🧪 Teste Lianko App auf: $BASE_URL"
echo ""

# 1. Health Check
echo "1. Health Check..."
curl -s ${BASE_URL}/api/health | python3 -m json.tool
echo ""

# 2. Lektionen laden (4-jährige)
echo "2. Lektionen laden (Alter 4)..."
curl -s "${BASE_URL}/api/v1/lessons?age=4" | python3 -m json.tool | head -20
echo ""

# 3. Gebärdensprache-Videos
echo "3. Gebärdensprache-Videos..."
curl -s ${BASE_URL}/api/v1/lessons/sign-language | python3 -m json.tool | head -20
echo ""

# 4. Test-User erstellen
echo "4. Test-User erstellen..."
USER_RESPONSE=$(curl -s -X POST ${BASE_URL}/api/v1/users \
  -H "Content-Type: application/json" \
  -d '{"name":"Test User","age":4,"hearingImpairment":true}')
echo "$USER_RESPONSE" | python3 -m json.tool
USER_ID=$(echo "$USER_RESPONSE" | python3 -c "import sys, json; print(json.load(sys.stdin).get('userId', ''))" 2>/dev/null)
echo ""

# 5. Lektion starten
if [ -n "$USER_ID" ]; then
  echo "5. Lektion starten..."
  curl -s -X POST ${BASE_URL}/api/v1/lessons/start \
    -H "Content-Type: application/json" \
    -d "{\"lessonId\":\"visual-001\",\"userId\":\"$USER_ID\"}" | python3 -m json.tool
  echo ""
fi

echo "✅ Tests abgeschlossen!"
```

**Verwendung:**
```bash
# Lokal testen
bash lianko_test.sh

# Staging testen
bash lianko_test.sh https://lianko-test.railway.app

# Production testen
bash lianko_test.sh https://lianko.railway.app
```

---

## 📝 Test-Szenarien

### Szenario 1: Neuer Benutzer mit Hörbehinderung
1. App öffnen
2. Registrierung (Alter: 4, Hörbehinderung: ja)
3. Gebärdensprache-Video ansehen
4. Erste visuelle Lektion starten
5. Interaktives Spiel spielen

**Erwartet:** Alles visuell, keine Audio-Abhängigkeit

### Szenario 2: Visuelles Lernen
1. App öffnen
2. Login
3. Visuelle Lektion starten
4. Drag & Drop Aufgabe lösen
5. Vibration/Haptisches Feedback erhalten

**Erwartet:** Visuelle Signale klar, haptisches Feedback funktioniert

### Szenario 3: Eltern-Dashboard
1. Eltern-Login
2. Fortschritt ansehen
3. Hörbehinderung-Einstellungen prüfen
4. Gebärdensprache-Statistiken ansehen

**Erwartet:** Alle Daten sichtbar, Einstellungen funktionieren

---

## 🐛 Bekannte Probleme / Notizen

- [ ] Problem 1: ...
- [ ] Problem 2: ...
- [ ] Feature Request: ...

---

**Letzte Aktualisierung:** $(date)

