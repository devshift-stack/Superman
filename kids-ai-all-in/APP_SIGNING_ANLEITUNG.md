# 🔐 App-Signing Anleitung - Google Play Console

## ⚠️ Problem

Google Play Console zeigt Fehler:
> "Du hast ein APK oder Android App Bundle hochgeladen, das mit einem Schlüssel signiert wurde, der auch zum Signieren von APKs verwendet wird, die an den Nutzer geliefert werden."

**Lösung:** Apps müssen mit einem neuen Upload-Key signiert werden (nicht mit dem ursprünglichen Signing-Key).

---

## 📱 Apps die signiert werden müssen

1. **Lianko** - App für 4-jährigen Sohn (Hörbehinderung)
2. **Parent** - Eltern-Dashboard App
3. **Li Ki Train** - Training-App

---

## 🔑 Schritt 1: Neuen Upload-Key erstellen

### Für jede App einen separaten Upload-Key erstellen:

```bash
# Lianko App Key
keytool -genkey -v -keystore lianko-upload-key.jks -keyalg RSA -keysize 2048 -validity 10000 -alias lianko-upload

# Parent App Key
keytool -genkey -v -keystore parent-upload-key.jks -keyalg RSA -keysize 2048 -validity 10000 -alias parent-upload

# Li Ki Train App Key
keytool -genkey -v -keystore likitrain-upload-key.jks -keyalg RSA -keysize 2048 -validity 10000 -alias likitrain-upload
```

**Wichtig:**
- Speichere die Passwörter sicher!
- Jede App bekommt einen eigenen Key
- Keys niemals in Git committen!

---

## 📝 Schritt 2: Key-Informationen speichern

Erstelle eine `keystore-passwords.txt` Datei (NICHT in Git!):

```bash
# Lianko
LIANKO_KEYSTORE_PATH=./lianko-upload-key.jks
LIANKO_KEYSTORE_PASSWORD=dein-passwort-hier
LIANKO_KEY_ALIAS=lianko-upload
LIANKO_KEY_PASSWORD=dein-passwort-hier

# Parent
PARENT_KEYSTORE_PATH=./parent-upload-key.jks
PARENT_KEYSTORE_PASSWORD=dein-passwort-hier
PARENT_KEY_ALIAS=parent-upload
PARENT_KEY_PASSWORD=dein-passwort-hier

# Li Ki Train
LIKITRAIN_KEYSTORE_PATH=./likitrain-upload-key.jks
LIKITRAIN_KEYSTORE_PASSWORD=dein-passwort-hier
LIKITRAIN_KEY_ALIAS=likitrain-upload
LIKITRAIN_KEY_PASSWORD=dein-passwort-hier
```

**WICHTIG:** Diese Datei in `.gitignore` aufnehmen!

---

## 🏗️ Schritt 3: Gradle konfigurieren

### Für jede App: `android/app/build.gradle` anpassen

#### Lianko App:

```gradle
android {
    ...
    signingConfigs {
        release {
            if (project.hasProperty('LIANKO_KEYSTORE_PATH')) {
                storeFile file(LIANKO_KEYSTORE_PATH)
                storePassword LIANKO_KEYSTORE_PASSWORD
                keyAlias LIANKO_KEY_ALIAS
                keyPassword LIANKO_KEY_PASSWORD
            }
        }
    }
    buildTypes {
        release {
            signingConfig signingConfigs.release
            ...
        }
    }
}
```

#### Parent App:

```gradle
android {
    ...
    signingConfigs {
        release {
            if (project.hasProperty('PARENT_KEYSTORE_PATH')) {
                storeFile file(PARENT_KEYSTORE_PATH)
                storePassword PARENT_KEYSTORE_PASSWORD
                keyAlias PARENT_KEY_ALIAS
                keyPassword PARENT_KEY_PASSWORD
            }
        }
    }
    buildTypes {
        release {
            signingConfig signingConfigs.release
            ...
        }
    }
}
```

#### Li Ki Train App:

```gradle
android {
    ...
    signingConfigs {
        release {
            if (project.hasProperty('LIKITRAIN_KEYSTORE_PATH')) {
                storeFile file(LIKITRAIN_KEYSTORE_PATH)
                storePassword LIKITRAIN_KEYSTORE_PASSWORD
                keyAlias LIKITRAIN_KEY_ALIAS
                keyPassword LIKITRAIN_KEY_PASSWORD
            }
        }
    }
    buildTypes {
        release {
            signingConfig signingConfigs.release
            ...
        }
    }
}
```

---

## 🔧 Schritt 4: gradle.properties konfigurieren

Füge in `android/gradle.properties` hinzu (oder erstelle `.env` und lade in Gradle):

```properties
# Lianko
LIANKO_KEYSTORE_PATH=../lianko-upload-key.jks
LIANKO_KEYSTORE_PASSWORD=dein-passwort
LIANKO_KEY_ALIAS=lianko-upload
LIANKO_KEY_PASSWORD=dein-passwort

# Parent
PARENT_KEYSTORE_PATH=../parent-upload-key.jks
PARENT_KEYSTORE_PASSWORD=dein-passwort
PARENT_KEY_ALIAS=parent-upload
PARENT_KEY_PASSWORD=dein-passwort

# Li Ki Train
LIKITRAIN_KEYSTORE_PATH=../likitrain-upload-key.jks
LIKITRAIN_KEYSTORE_PASSWORD=dein-passwort
LIKITRAIN_KEY_ALIAS=likitrain-upload
LIKITRAIN_KEY_PASSWORD=dein-passwort
```

**ODER** nutze Environment Variables:

```bash
export LIANKO_KEYSTORE_PATH=./lianko-upload-key.jks
export LIANKO_KEYSTORE_PASSWORD=dein-passwort
export LIANKO_KEY_ALIAS=lianko-upload
export LIANKO_KEY_PASSWORD=dein-passwort
```

---

## 📦 Schritt 5: App Bundles erstellen

### Lianko App:

```bash
cd apps/lianko/android
./gradlew bundleRelease

# Bundle liegt in: app/build/outputs/bundle/release/app-release.aab
# Umbenennen zu: lianko-release.aab
mv app/build/outputs/bundle/release/app-release.aab ../../../lianko-release.aab
```

### Parent App:

```bash
cd apps/parent/android
./gradlew bundleRelease

# Bundle liegt in: app/build/outputs/bundle/release/app-release.aab
# Umbenennen zu: parent-release.aab
mv app/build/outputs/bundle/release/app-release.aab ../../../parent-release.aab
```

### Li Ki Train App:

```bash
cd apps/likitrain/android
./gradlew bundleRelease

# Bundle liegt in: app/build/outputs/bundle/release/app-release.aab
# Umbenennen zu: likitrain-release.aab
mv app/build/outputs/bundle/release/app-release.aab ../../../likitrain-release.aab
```

---

## ✅ Schritt 6: Signatur prüfen

Prüfe ob die Apps korrekt signiert sind:

```bash
# Lianko
jarsigner -verify -verbose -certs lianko-release.aab

# Parent
jarsigner -verify -verbose -certs parent-release.aab

# Li Ki Train
jarsigner -verify -verbose -certs likitrain-release.aab
```

**Erwartete Ausgabe:**
```
jar verified.
```

---

## 🚀 Schritt 7: In Google Play Console hochladen

1. Gehe zu Google Play Console
2. Wähle die App (Lianko, Parent oder Li Ki Train)
3. Gehe zu "Testen und veröffentlichen" → "Geschlossener Test"
4. Klicke auf "Neues Release erstellen"
5. Lade das neue `.aab` File hoch
6. **Wichtig:** Das alte Bundle löschen (falls vorhanden)
7. Release speichern

---

## 🔄 Automatisches Signing-Script

Erstelle `sign-apps.sh`:

```bash
#!/bin/bash

# Lade Passwörter (aus sicherer Quelle)
source keystore-passwords.txt

# Lianko
echo "📱 Signiere Lianko App..."
cd apps/lianko/android
./gradlew bundleRelease
mv app/build/outputs/bundle/release/app-release.aab ../../../lianko-release.aab
cd ../../..

# Parent
echo "📱 Signiere Parent App..."
cd apps/parent/android
./gradlew bundleRelease
mv app/build/outputs/bundle/release/app-release.aab ../../../parent-release.aab
cd ../../..

# Li Ki Train
echo "📱 Signiere Li Ki Train App..."
cd apps/likitrain/android
./gradlew bundleRelease
mv app/build/outputs/bundle/release/app-release.aab ../../../likitrain-release.aab
cd ../../..

echo "✅ Alle Apps signiert!"
echo ""
echo "📦 Erstellte Bundles:"
echo "  - lianko-release.aab"
echo "  - parent-release.aab"
echo "  - likitrain-release.aab"
```

**Ausführbar machen:**
```bash
chmod +x sign-apps.sh
```

**Ausführen:**
```bash
./sign-apps.sh
```

---

## 🛡️ Sicherheit

### .gitignore Einträge:

```gitignore
# Keystores
*.jks
*.keystore
*.key

# Passwort-Dateien
keystore-passwords.txt
*.passwords
*.secrets

# App Bundles (optional - nur wenn nicht in Git)
*.aab
*.apk
```

---

## 📋 Checkliste

- [ ] Neuen Upload-Key für Lianko erstellt
- [ ] Neuen Upload-Key für Parent erstellt
- [ ] Neuen Upload-Key für Li Ki Train erstellt
- [ ] Passwörter sicher gespeichert
- [ ] Gradle konfiguriert (build.gradle)
- [ ] gradle.properties konfiguriert
- [ ] App Bundles erstellt
- [ ] Signatur geprüft
- [ ] In Google Play Console hochgeladen
- [ ] Alte Bundles gelöscht

---

## 🐛 Troubleshooting

### Fehler: "Keystore wurde nicht gefunden"
- Prüfe Pfad in `gradle.properties`
- Prüfe ob Key-Datei existiert
- Nutze absoluten Pfad

### Fehler: "Passwort falsch"
- Prüfe Passwort in `gradle.properties`
- Prüfe ob Passwort korrekt kopiert wurde (keine Leerzeichen)

### Fehler: "Key-Alias nicht gefunden"
- Prüfe Alias-Name in `gradle.properties`
- Prüfe ob Alias beim Key-Erstellen korrekt war

### Fehler in Google Play Console bleibt
- Stelle sicher, dass der neue Key verwendet wurde
- Lösche das alte Bundle komplett
- Lade neues Bundle hoch

---

## 📞 Hilfe

**Google Play App Signing:**
- Dokumentation: https://support.google.com/googleplay/android-developer/answer/9842756

**Android App Signing:**
- Dokumentation: https://developer.android.com/studio/publish/app-signing

---

**Letzte Aktualisierung:** 19. Dezember 2024

