# 🚀 Upload-Keys Exportieren - Schritt für Schritt

## ⚠️ Was du brauchst:

1. ✅ **pepk.jar** - PEPK Tool von Google
2. ✅ **encryption_public_key.pem** - Von Google Play Console
3. ✅ **Keystore-Dateien** (.jks) - Die Upload-Keys die du erstellt hast

---

## 📥 Schritt 1: PEPK Tool herunterladen

```bash
cd "/Users/dsselmanovic/cursor project/kids-ai-all-in"

# PEPK Tool herunterladen
wget https://github.com/google/play-app-signing/releases/latest/download/pepk.jar

# ODER manuell:
# Gehe zu: https://github.com/google/play-app-signing/releases
# Lade pepk.jar herunter
```

---

## 📥 Schritt 2: Encryption Key von Google Play Console

1. Gehe zu Google Play Console
2. Wähle deine App (Lianko/Parent/Li Ki Train)
3. **Setup** → **App-Signatur**
4. Klicke auf **"App-Signaturschlüssel exportieren"**
5. Lade `encryption_public_key.pem` herunter
6. Speichere im Projekt-Verzeichnis

---

## 🔑 Schritt 3: Upload-Keys erstellen (falls noch nicht geschehen)

```bash
# Lianko
keytool -genkey -v -keystore lianko-upload-key.jks -keyalg RSA -keysize 2048 -validity 10000 -alias lianko-upload

# Parent
keytool -genkey -v -keystore parent-upload-key.jks -keyalg RSA -keysize 2048 -validity 10000 -alias parent-upload

# Li Ki Train
keytool -genkey -v -keystore likitrain-upload-key.jks -keyalg RSA -keysize 2048 -validity 10000 -alias likitrain-upload
```

**Wichtig:** Speichere die Passwörter sicher!

---

## 🚀 Schritt 4: Keys exportieren

### Lianko:

```bash
java -jar pepk.jar \
  --keystore=lianko-upload-key.jks \
  --alias=lianko-upload \
  --output=lianko-upload-key.zip \
  --include-cert \
  --rsa-aes-encryption \
  --encryption-key-path=encryption_public_key.pem
```

**Du wirst nach dem Passwort gefragt - gib das Keystore-Passwort ein!**

### Parent:

```bash
java -jar pepk.jar \
  --keystore=parent-upload-key.jks \
  --alias=parent-upload \
  --output=parent-upload-key.zip \
  --include-cert \
  --rsa-aes-encryption \
  --encryption-key-path=encryption_public_key.pem
```

### Li Ki Train:

```bash
java -jar pepk.jar \
  --keystore=likitrain-upload-key.jks \
  --alias=likitrain-upload \
  --output=likitrain-upload-key.zip \
  --include-cert \
  --rsa-aes-encryption \
  --encryption-key-path=encryption_public_key.pem
```

---

## 📤 Schritt 5: ZIP-Dateien hochladen

Die erstellten ZIP-Dateien:
- ✅ `lianko-upload-key.zip`
- ✅ `parent-upload-key.zip`
- ✅ `likitrain-upload-key.zip`

**In Google Play Console hochladen:**
1. Gehe zu Google Play Console
2. Wähle die App
3. **Setup** → **App-Signatur** → **App-Signaturschlüssel hochladen**
4. Lade die entsprechende `.zip` Datei hoch

---

## ✅ Fertig!

Nach dem Hochladen hast du:
- ✅ Upload-Keys an Google übergeben
- ✅ Google Play kann jetzt deine Apps signieren
- ✅ Du kannst neue App Bundles hochladen

---

**Nächste Schritte:**
1. Apps signieren: `./sign-apps.sh`
2. App Bundles in Google Play Console hochladen

