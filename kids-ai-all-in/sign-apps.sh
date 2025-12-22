#!/bin/bash

# App-Signing Script für Lianko, Parent und Li Ki Train
# Erstellt korrekt signierte App Bundles für Google Play Console

set -e  # Exit on error

echo "🔐 App-Signing Script"
echo "===================="
echo ""

# Prüfe ob wir im richtigen Verzeichnis sind
if [ ! -d "apps" ]; then
    echo "❌ Fehler: 'apps' Verzeichnis nicht gefunden!"
    echo "   Bitte führe das Script aus dem Projekt-Root aus."
    exit 1
fi

# Prüfe ob Keystores existieren
check_keystore() {
    local app_name=$1
    local keystore_path=$2
    
    if [ ! -f "$keystore_path" ]; then
        echo "⚠️  Warnung: Keystore für $app_name nicht gefunden: $keystore_path"
        echo "   Erstelle zuerst den Keystore mit:"
        echo "   keytool -genkey -v -keystore $keystore_path -keyalg RSA -keysize 2048 -validity 10000 -alias ${app_name}-upload"
        return 1
    fi
    return 0
}

# Signiere eine App
sign_app() {
    local app_name=$1
    local keystore_path=$2
    local keystore_password=$3
    local key_alias=$4
    local key_password=$5
    
    echo ""
    echo "📱 Signiere $app_name App..."
    echo "   Keystore: $keystore_path"
    
    # Prüfe Keystore
    if ! check_keystore "$app_name" "$keystore_path"; then
        echo "   ⏭️  Überspringe $app_name"
        return 1
    fi
    
    # Wechsle ins App-Verzeichnis
    if [ ! -d "apps/$app_name/android" ]; then
        echo "   ❌ Android-Verzeichnis nicht gefunden: apps/$app_name/android"
        return 1
    fi
    
    cd "apps/$app_name/android"
    
    # Setze Environment Variables für Gradle
    export KEYSTORE_PATH="../../$keystore_path"
    export KEYSTORE_PASSWORD="$keystore_password"
    export KEY_ALIAS="$key_alias"
    export KEY_PASSWORD="$key_password"
    
    # Erstelle Bundle
    echo "   🔨 Erstelle App Bundle..."
    if ./gradlew bundleRelease; then
        # Verschiebe Bundle
        if [ -f "app/build/outputs/bundle/release/app-release.aab" ]; then
            mv app/build/outputs/bundle/release/app-release.aab "../../../${app_name}-release.aab"
            echo "   ✅ Bundle erstellt: ${app_name}-release.aab"
            
            # Prüfe Signatur
            echo "   🔍 Prüfe Signatur..."
            if jarsigner -verify -verbose -certs "../../../${app_name}-release.aab" > /dev/null 2>&1; then
                echo "   ✅ Signatur gültig"
            else
                echo "   ⚠️  Signatur-Prüfung fehlgeschlagen"
            fi
        else
            echo "   ❌ Bundle nicht gefunden!"
            cd ../../..
            return 1
        fi
    else
        echo "   ❌ Gradle-Build fehlgeschlagen!"
        cd ../../..
        return 1
    fi
    
    cd ../../..
    return 0
}

# Haupt-Script
echo "Prüfe Keystores..."
echo ""

# Lade Passwörter (falls vorhanden)
if [ -f "keystore-passwords.txt" ]; then
    echo "📝 Lade Passwörter aus keystore-passwords.txt..."
    source keystore-passwords.txt
else
    echo "⚠️  Warnung: keystore-passwords.txt nicht gefunden!"
    echo "   Erstelle die Datei mit den Keystore-Passwörtern."
    echo ""
    echo "   Beispiel:"
    echo "   export LIANKO_KEYSTORE_PATH=./lianko-upload-key.jks"
    echo "   export LIANKO_KEYSTORE_PASSWORD=dein-passwort"
    echo "   export LIANKO_KEY_ALIAS=lianko-upload"
    echo "   export LIANKO_KEY_PASSWORD=dein-passwort"
    echo ""
    read -p "Möchtest du trotzdem fortfahren? (j/n): " continue
    if [ "$continue" != "j" ]; then
        exit 1
    fi
fi

# Signiere Apps
LIANKO_SIGNED=false
PARENT_SIGNED=false
LIKITRAIN_SIGNED=false

# Lianko
if [ -n "$LIANKO_KEYSTORE_PATH" ] && [ -n "$LIANKO_KEYSTORE_PASSWORD" ]; then
    if sign_app "lianko" "$LIANKO_KEYSTORE_PATH" "$LIANKO_KEYSTORE_PASSWORD" "$LIANKO_KEY_ALIAS" "$LIANKO_KEY_PASSWORD"; then
        LIANKO_SIGNED=true
    fi
else
    echo "⚠️  Lianko: Keystore-Parameter nicht gesetzt"
fi

# Parent
if [ -n "$PARENT_KEYSTORE_PATH" ] && [ -n "$PARENT_KEYSTORE_PASSWORD" ]; then
    if sign_app "parent" "$PARENT_KEYSTORE_PATH" "$PARENT_KEYSTORE_PASSWORD" "$PARENT_KEY_ALIAS" "$PARENT_KEY_PASSWORD"; then
        PARENT_SIGNED=true
    fi
else
    echo "⚠️  Parent: Keystore-Parameter nicht gesetzt"
fi

# Li Ki Train
if [ -n "$LIKITRAIN_KEYSTORE_PATH" ] && [ -n "$LIKITRAIN_KEYSTORE_PASSWORD" ]; then
    if sign_app "likitrain" "$LIKITRAIN_KEYSTORE_PATH" "$LIKITRAIN_KEYSTORE_PASSWORD" "$LIKITRAIN_KEY_ALIAS" "$LIKITRAIN_KEY_PASSWORD"; then
        LIKITRAIN_SIGNED=true
    fi
else
    echo "⚠️  Li Ki Train: Keystore-Parameter nicht gesetzt"
fi

# Zusammenfassung
echo ""
echo "===================="
echo "📊 Zusammenfassung"
echo "===================="
echo ""

if [ "$LIANKO_SIGNED" = true ]; then
    echo "✅ Lianko: lianko-release.aab"
else
    echo "❌ Lianko: Nicht signiert"
fi

if [ "$PARENT_SIGNED" = true ]; then
    echo "✅ Parent: parent-release.aab"
else
    echo "❌ Parent: Nicht signiert"
fi

if [ "$LIKITRAIN_SIGNED" = true ]; then
    echo "✅ Li Ki Train: likitrain-release.aab"
else
    echo "❌ Li Ki Train: Nicht signiert"
fi

echo ""
echo "📦 Erstellte Bundles:"
ls -lh *-release.aab 2>/dev/null || echo "   Keine Bundles gefunden"

echo ""
echo "✅ Fertig!"
echo ""
echo "📤 Nächste Schritte:"
echo "   1. Lade die .aab Dateien in Google Play Console hoch"
echo "   2. Stelle sicher, dass alte Bundles gelöscht sind"
echo "   3. Prüfe ob der Fehler behoben ist"

