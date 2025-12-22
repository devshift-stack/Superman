# 🔐 Google Play App Signing - PEPK Tool Anleitung

**Für:** Lianko, Parent, Li Ki Train Apps

---

## 📋 Was ist PEPK?

`pepk.jar` ist ein Tool von Google, um den Upload-Key an Google Play App Signing zu übergeben.

**Wichtig:** Wenn du Google Play App Signing aktiviert hast, musst du den Upload-Key an Google übergeben.

---

## 🔑 Schritt 1: PEPK Tool herunterladen

```bash
# PEPK Tool von Google herunterladen
# URL: https://github.com/google/play-app-signing/releases
# Oder direkt:
wget https://github.com/google/play-app-signing/releases/latest/download/pepk.jar
```

**ODER** manuell:
1. Gehe zu: https://github.com/google/play-app-signing/releases
2. Lade `pepk.jar` herunter
3. Speichere im Projekt-Verzeichnis

---

## 🔐 Schritt 2: Encryption Key von Google Play Console holen

1. Gehe zu Google Play Console
2. Wähle deine App (Lianko/Parent/Li Ki Train)
3. Gehe zu: **"Setup" → "App-Signatur"**
4. Klicke auf: **"App-Signaturschlüssel exportieren"**
5. Lade den **Encryption Public Key** herunter
   - Datei: `encryption_public_key.pem`
6. Speichere die Datei im Projekt-Verzeichnis

---

## 🚀 Schritt 3: Upload-Key exportieren

### Für jede App separat:

#### Lianko App:

```bash
java -jar pepk.jar \
  --keystore=lianko-upload-key.jks \
  --alias=lianko-upload \
  --output=lianko-upload-key.zip \
  --include-cert \
  --rsa-aes-encryption \
  --encryption-key-path=encryption_public_key.pem
```

**Du wirst nach dem Keystore-Passwort gefragt:**
```
Enter keystore password: [DEIN_PASSWORT]
```

**Ergebnis:** `lianko-upload-key.zip`

---

#### Parent App:

```bash
java -jar pepk.jar \
  --keystore=parent-upload-key.jks \
  --alias=parent-upload \
  --output=parent-upload-key.zip \
  --include-cert \
  --rsa-aes-encryption \
  --encryption-key-path=encryption_public_key.pem
```

**Ergebnis:** `parent-upload-key.zip`

---

#### Li Ki Train App:

```bash
java -jar pepk.jar \
  --keystore=likitrain-upload-key.jks \
  --alias=likitrain-upload \
  --output=likitrain-upload-key.zip \
  --include-cert \
  --rsa-aes-encryption \
  --encryption-key-path=encryption_public_key.pem
```

**Ergebnis:** `likitrain-upload-key.zip`

---

## 📤 Schritt 4: Upload-Key in Google Play Console hochladen

### Für jede App:

1. Gehe zu Google Play Console
2. Wähle die App (Lianko/Parent/Li Ki Train)
3. Gehe zu: **"Setup" → "App-Signatur"**
4. Klicke auf: **"App-Signaturschlüssel hochladen"**
5. Wähle die entsprechende `.zip` Datei:
   - Lianko: `lianko-upload-key.zip`
   - Parent: `parent-upload-key.zip`
   - Li Ki Train: `likitrain-upload-key.zip`
6. Hochladen und bestätigen

---

## 🤖 Automatisches Script

Erstelle `export-upload-keys.sh`:

```bash
#!/bin/bash

# Google Play App Signing - Upload-Keys exportieren

set -e

echo "🔐 Google Play App Signing - Upload-Keys Export"
echo "================================================"
echo ""

# Prüfe ob pepk.jar existiert
if [ ! -f "pepk.jar" ]; then
    echo "❌ pepk.jar nicht gefunden!"
    echo "   Lade es herunter von: https://github.com/google/play-app-signing/releases"
    exit 1
fi

# Prüfe ob encryption_public_key.pem existiert
if [ ! -f "encryption_public_key.pem" ]; then
    echo "❌ encryption_public_key.pem nicht gefunden!"
    echo "   Lade es von Google Play Console herunter:"
    echo "   Setup → App-Signatur → App-Signaturschlüssel exportieren"
    exit 1
fi

# Funktion zum Exportieren eines Keys
export_key() {
    local app_name=$1
    local keystore=$2
    local alias=$3
    local output="${app_name}-upload-key.zip"
    
    echo ""
    echo "📦 Exportiere $app_name Upload-Key..."
    echo "   Keystore: $keystore"
    echo "   Alias: $alias"
    echo "   Output: $output"
    
    if [ ! -f "$keystore" ]; then
        echo "   ⚠️  Keystore nicht gefunden: $keystore"
        echo "   ⏭️  Überspringe $app_name"
        return 1
    fi
    
    java -jar pepk.jar \
        --keystore="$keystore" \
        --alias="$alias" \
        --output="$output" \
        --include-cert \
        --rsa-aes-encryption \
        --encryption-key-path=encryption_public_key.pem
    
    if [ -f "$output" ]; then
        echo "   ✅ Export erfolgreich: $output"
        return 0
    else
        echo "   ❌ Export fehlgeschlagen"
        return 1
    fi
}

# Lade Passwörter (falls vorhanden)
if [ -f "keystore-passwords.txt" ]; then
    source keystore-passwords.txt
fi

# Exportiere alle Keys
echo "Exportiere Upload-Keys..."
echo ""

# Lianko
if [ -n "$LIANKO_KEYSTORE_PATH" ]; then
    export_key "lianko" "$LIANKO_KEYSTORE_PATH" "$LIANKO_KEY_ALIAS"
else
    export_key "lianko" "lianko-upload-key.jks" "lianko-upload"
fi

# Parent
if [ -n "$PARENT_KEYSTORE_PATH" ]; then
    export_key "parent" "$PARENT_KEYSTORE_PATH" "$PARENT_KEY_ALIAS"
else
    export_key "parent" "parent-upload-key.jks" "parent-upload"
fi

# Li Ki Train
if [ -n "$LIKITRAIN_KEYSTORE_PATH" ]; then
    export_key "likitrain" "$LIKITRAIN_KEYSTORE_PATH" "$LIKITRAIN_KEY_ALIAS"
else
    export_key "likitrain" "likitrain-upload-key.jks" "likitrain-upload"
fi

# Zusammenfassung
echo ""
echo "================================================"
echo "📊 Zusammenfassung"
echo "================================================"
echo ""

echo "📦 Exportierte ZIP-Dateien:"
ls -lh *-upload-key.zip 2>/dev/null || echo "   Keine ZIP-Dateien gefunden"

echo ""
echo "✅ Fertig!"
echo ""
echo "📤 Nächste Schritte:"
echo "   1. Gehe zu Google Play Console"
echo "   2. Setup → App-Signatur → App-Signaturschlüssel hochladen"
echo "   3. Lade die entsprechenden .zip Dateien hoch"
echo ""
echo "   - Lianko: lianko-upload-key.zip"
echo "   - Parent: parent-upload-key.zip"
echo "   - Li Ki Train: likitrain-upload-key.zip"
```

**Ausführbar machen:**
```bash
chmod +x export-upload-keys.sh
```

**Ausführen:**
```bash
./export-upload-keys.sh
```

---

## 📋 Vollständiger Workflow

### 1. Upload-Keys erstellen
```bash
keytool -genkey -v -keystore lianko-upload-key.jks -keyalg RSA -keysize 2048 -validity 10000 -alias lianko-upload
keytool -genkey -v -keystore parent-upload-key.jks -keyalg RSA -keysize 2048 -validity 10000 -alias parent-upload
keytool -genkey -v -keystore likitrain-upload-key.jks -keyalg RSA -keysize 2048 -validity 10000 -alias likitrain-upload
```

### 2. Encryption Key von Google Play Console herunterladen
- `encryption_public_key.pem`

### 3. PEPK Tool herunterladen
- `pepk.jar`

### 4. Upload-Keys exportieren
```bash
./export-upload-keys.sh
```

### 5. ZIP-Dateien in Google Play Console hochladen
- Für jede App die entsprechende `.zip` Datei hochladen

### 6. Apps signieren und hochladen
```bash
./sign-apps.sh
```

### 7. App Bundles in Google Play Console hochladen
- `lianko-release.aab`
- `parent-release.aab`
- `likitrain-release.aab`

---

## ✅ Checkliste

- [ ] PEPK Tool heruntergeladen (`pepk.jar`)
- [ ] Encryption Key von Google Play Console heruntergeladen (`encryption_public_key.pem`)
- [ ] Upload-Keys erstellt (3x `.jks` Dateien)
- [ ] Upload-Keys exportiert (3x `.zip` Dateien)
- [ ] ZIP-Dateien in Google Play Console hochgeladen
- [ ] Apps signiert (3x `.aab` Dateien)
- [ ] App Bundles in Google Play Console hochgeladen

---

## 🐛 Troubleshooting

### Fehler: "pepk.jar nicht gefunden"
- Lade PEPK Tool herunter: https://github.com/google/play-app-signing/releases
- Stelle sicher, dass `pepk.jar` im Projekt-Verzeichnis ist

### Fehler: "encryption_public_key.pem nicht gefunden"
- Lade Encryption Key von Google Play Console herunter
- Setup → App-Signatur → App-Signaturschlüssel exportieren

### Fehler: "Keystore-Passwort falsch"
- Prüfe Passwort
- Stelle sicher, dass kein Leerzeichen am Ende ist

### Fehler: "Keystore nicht gefunden"
- Prüfe Pfad zum Keystore
- Nutze absoluten Pfad falls nötig

---

## 📞 Hilfe & Links

- **PEPK Tool:** https://github.com/google/play-app-signing
- **Google Play App Signing:** https://support.google.com/googleplay/android-developer/answer/9842756
- **Android App Signing:** https://developer.android.com/studio/publish/app-signing

---

**Letzte Aktualisierung:** 19. Dezember 2024

