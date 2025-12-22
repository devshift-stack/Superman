#!/bin/bash

# Google Play App Signing - Upload-Keys exportieren
# Verwendet pepk.jar um Upload-Keys für Google Play zu exportieren

set -e

echo "🔐 Google Play App Signing - Upload-Keys Export"
echo "================================================"
echo ""

# Prüfe ob pepk.jar existiert
if [ ! -f "pepk.jar" ]; then
    echo "❌ pepk.jar nicht gefunden!"
    echo ""
    echo "   Lade es herunter von:"
    echo "   https://github.com/google/play-app-signing/releases"
    echo ""
    echo "   Oder direkt:"
    echo "   wget https://github.com/google/play-app-signing/releases/latest/download/pepk.jar"
    exit 1
fi

# Prüfe ob encryption_public_key.pem existiert
if [ ! -f "encryption_public_key.pem" ]; then
    echo "❌ encryption_public_key.pem nicht gefunden!"
    echo ""
    echo "   Lade es von Google Play Console herunter:"
    echo "   1. Gehe zu Google Play Console"
    echo "   2. Wähle deine App"
    echo "   3. Setup → App-Signatur"
    echo "   4. App-Signaturschlüssel exportieren"
    echo "   5. Lade encryption_public_key.pem herunter"
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
    
    echo "   🔐 Bitte Keystore-Passwort eingeben..."
    
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
    echo "📝 Lade Passwörter aus keystore-passwords.txt..."
    source keystore-passwords.txt
fi

# Exportiere alle Keys
echo "Exportiere Upload-Keys..."
echo ""

LIANKO_EXPORTED=false
PARENT_EXPORTED=false
LIKITRAIN_EXPORTED=false

# Lianko
if [ -n "$LIANKO_KEYSTORE_PATH" ]; then
    if export_key "lianko" "$LIANKO_KEYSTORE_PATH" "$LIANKO_KEY_ALIAS"; then
        LIANKO_EXPORTED=true
    fi
else
    if [ -f "lianko-upload-key.jks" ]; then
        if export_key "lianko" "lianko-upload-key.jks" "lianko-upload"; then
            LIANKO_EXPORTED=true
        fi
    else
        echo "⚠️  Lianko Keystore nicht gefunden"
    fi
fi

# Parent
if [ -n "$PARENT_KEYSTORE_PATH" ]; then
    if export_key "parent" "$PARENT_KEYSTORE_PATH" "$PARENT_KEY_ALIAS"; then
        PARENT_EXPORTED=true
    fi
else
    if [ -f "parent-upload-key.jks" ]; then
        if export_key "parent" "parent-upload-key.jks" "parent-upload"; then
            PARENT_EXPORTED=true
        fi
    else
        echo "⚠️  Parent Keystore nicht gefunden"
    fi
fi

# Li Ki Train
if [ -n "$LIKITRAIN_KEYSTORE_PATH" ]; then
    if export_key "likitrain" "$LIKITRAIN_KEYSTORE_PATH" "$LIKITRAIN_KEY_ALIAS"; then
        LIKITRAIN_EXPORTED=true
    fi
else
    if [ -f "likitrain-upload-key.jks" ]; then
        if export_key "likitrain" "likitrain-upload-key.jks" "likitrain-upload"; then
            LIKITRAIN_EXPORTED=true
        fi
    else
        echo "⚠️  Li Ki Train Keystore nicht gefunden"
    fi
fi

# Zusammenfassung
echo ""
echo "================================================"
echo "📊 Zusammenfassung"
echo "================================================"
echo ""

if [ "$LIANKO_EXPORTED" = true ]; then
    echo "✅ Lianko: lianko-upload-key.zip"
else
    echo "❌ Lianko: Nicht exportiert"
fi

if [ "$PARENT_EXPORTED" = true ]; then
    echo "✅ Parent: parent-upload-key.zip"
else
    echo "❌ Parent: Nicht exportiert"
fi

if [ "$LIKITRAIN_EXPORTED" = true ]; then
    echo "✅ Li Ki Train: likitrain-upload-key.zip"
else
    echo "❌ Li Ki Train: Nicht exportiert"
fi

echo ""
echo "📦 Exportierte ZIP-Dateien:"
ls -lh *-upload-key.zip 2>/dev/null || echo "   Keine ZIP-Dateien gefunden"

echo ""
echo "✅ Fertig!"
echo ""
echo "📤 Nächste Schritte:"
echo "   1. Gehe zu Google Play Console"
echo "   2. Wähle die App (Lianko/Parent/Li Ki Train)"
echo "   3. Setup → App-Signatur → App-Signaturschlüssel hochladen"
echo "   4. Lade die entsprechende .zip Datei hoch:"
echo ""
if [ "$LIANKO_EXPORTED" = true ]; then
    echo "      - Lianko: lianko-upload-key.zip"
fi
if [ "$PARENT_EXPORTED" = true ]; then
    echo "      - Parent: parent-upload-key.zip"
fi
if [ "$LIKITRAIN_EXPORTED" = true ]; then
    echo "      - Li Ki Train: likitrain-upload-key.zip"
fi
echo ""

