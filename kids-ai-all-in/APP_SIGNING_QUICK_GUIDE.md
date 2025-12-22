# 🔐 App-Signing Quick Guide - Lianko, Parent, Li Ki Train

**Erstellt:** 19. Dezember 2024  
**Für:** Google Play Console Upload

---

## ⚠️ Problem

Google Play Console Fehler:
> "Du hast ein APK oder Android App Bundle hochgeladen, das mit einem Schlüssel signiert wurde, der auch zum Signieren von APKs verwendet wird..."

**Lösung:** Neue Upload-Keys erstellen und Apps neu signieren.

---

## 🚀 Schnellstart (3 Schritte)

### Schritt 1: Upload-Keys erstellen

```bash
# Lianko
keytool -genkey -v -keystore lianko-upload-key.jks -keyalg RSA -keysize 2048 -validity 10000 -alias lianko-upload

# Parent
keytool -genkey -v -keystore parent-upload-key.jks -keyalg RSA -keysize 2048 -validity 10000 -alias parent-upload

# Li Ki Train
keytool -genkey -v -keystore likitrain-upload-key.jks -keyalg RSA -keysize 2048 -validity 10000 -alias likitrain-upload
```

**Wichtig:** Passwörter sicher speichern!

---

### Schritt 2: Passwörter konfigurieren

Erstelle `keystore-passwords.txt`:

```bash
export LIANKO_KEYSTORE_PATH=./lianko-upload-key.jks
export LIANKO_KEYSTORE_PASSWORD=DEIN_PASSWORT
export LIANKO_KEY_ALIAS=lianko-upload
export LIANKO_KEY_PASSWORD=DEIN_PASSWORT

export PARENT_KEYSTORE_PATH=./parent-upload-key.jks
export PARENT_KEYSTORE_PASSWORD=DEIN_PASSWORT
export PARENT_KEY_ALIAS=parent-upload
export PARENT_KEY_PASSWORD=DEIN_PASSWORT

export LIKITRAIN_KEYSTORE_PATH=./likitrain-upload-key.jks
export LIKITRAIN_KEYSTORE_PASSWORD=DEIN_PASSWORT
export LIKITRAIN_KEY_ALIAS=likitrain-upload
export LIKITRAIN_KEY_PASSWORD=DEIN_PASSWORT
```

---

### Schritt 3: Apps signieren

```bash
# Script ausführen
./sign-apps.sh

# ODER manuell für jede App:
cd apps/lianko/android && ./gradlew bundleRelease
cd apps/parent/android && ./gradlew bundleRelease
cd apps/likitrain/android && ./gradlew bundleRelease
```

**Ergebnis:** 
- `lianko-release.aab`
- `parent-release.aab`
- `likitrain-release.aab`

---

## 📤 Google Play Console Upload

1. Gehe zu Google Play Console
2. Wähle App (Lianko/Parent/Li Ki Train)
3. "Testen und veröffentlichen" → "Geschlossener Test"
4. "Neues Release erstellen"
5. **Altes Bundle löschen** (falls vorhanden)
6. Neues `.aab` File hochladen
7. Speichern

---

## ✅ Checkliste

- [ ] Upload-Keys erstellt (3x)
- [ ] Passwörter gespeichert
- [ ] `keystore-passwords.txt` erstellt
- [ ] Apps signiert (3x `.aab` Files)
- [ ] Signatur geprüft
- [ ] Alte Bundles in Google Play gelöscht
- [ ] Neue Bundles hochgeladen

---

## 🛡️ Sicherheit

**NIEMALS in Git committen:**
- `*.jks` (Keystore-Dateien)
- `keystore-passwords.txt`
- `*.aab` (App Bundles)

**`.gitignore` Einträge:**
```
*.jks
*.keystore
keystore-passwords.txt
*.aab
*.apk
```

---

## 🐛 Troubleshooting

**Fehler: "Keystore nicht gefunden"**
- Prüfe Pfad in `keystore-passwords.txt`
- Nutze absoluten Pfad

**Fehler: "Passwort falsch"**
- Prüfe Passwort (keine Leerzeichen)
- Prüfe ob korrekt kopiert

**Fehler in Google Play bleibt**
- Lösche altes Bundle komplett
- Lade neues Bundle hoch
- Prüfe ob neuer Key verwendet wurde

---

## 📞 Hilfe

- **Google Play App Signing:** https://support.google.com/googleplay/android-developer/answer/9842756
- **Android Signing:** https://developer.android.com/studio/publish/app-signing

---

**Viel Erfolg! 🚀**

