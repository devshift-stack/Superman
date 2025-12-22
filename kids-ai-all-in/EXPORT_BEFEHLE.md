# 🔐 Export-Befehle - Kopiere und führe aus!

## ⚠️ WICHTIG: Zuerst diese Dateien besorgen:

1. **pepk.jar** - Lade manuell herunter:
   - Gehe zu: https://github.com/google/play-app-signing/releases
   - Lade die neueste `pepk.jar` Datei herunter
   - Speichere im Projekt-Verzeichnis

2. **encryption_public_key.pem** - Von Google Play Console:
   - Google Play Console → Setup → App-Signatur
   - "App-Signaturschlüssel exportieren"
   - Lade `encryption_public_key.pem` herunter

3. **Keystore-Dateien** (.jks) - Falls noch nicht erstellt:
   ```bash
   keytool -genkey -v -keystore lianko-upload-key.jks -keyalg RSA -keysize 2048 -validity 10000 -alias lianko-upload
   keytool -genkey -v -keystore parent-upload-key.jks -keyalg RSA -keysize 2048 -validity 10000 -alias parent-upload
   keytool -genkey -v -keystore likitrain-upload-key.jks -keyalg RSA -keysize 2048 -validity 10000 -alias likitrain-upload
   ```

---

## 🚀 EXPORT-BEFEHLE (Kopiere und führe aus):

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

**Ergebnis:** `lianko-upload-key.zip` ✅

---

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

**Ergebnis:** `parent-upload-key.zip` ✅

---

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

**Ergebnis:** `likitrain-upload-key.zip` ✅

---

## 📤 Hochladen in Google Play Console:

1. Gehe zu Google Play Console
2. Wähle die App (Lianko/Parent/Li Ki Train)
3. **Setup** → **App-Signatur** → **App-Signaturschlüssel hochladen**
4. Lade die entsprechende ZIP-Datei hoch:
   - `lianko-upload-key.zip`
   - `parent-upload-key.zip`
   - `likitrain-upload-key.zip`

---

## ✅ Nach dem Hochladen:

- ✅ Google hat jetzt deinen Upload-Key
- ✅ Google kann deine Apps signieren
- ✅ Du kannst neue App Bundles hochladen
- ✅ Der Fehler in Google Play Console sollte verschwinden

---

**Viel Erfolg! 🚀**

