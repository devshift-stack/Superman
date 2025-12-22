# 📤 Upload-Keys Exportieren - READY TO USE

## ✅ Status

- ✅ Java installiert (Version 21)
- ✅ PEPK Tool heruntergeladen
- ⏳ **Du musst noch:**
  1. Encryption Key von Google Play Console holen
  2. Keystore-Dateien erstellen (falls noch nicht geschehen)
  3. Export-Befehle ausführen

---

## 🚀 Schnellstart

### 1. Encryption Key holen

Gehe zu Google Play Console → Setup → App-Signatur → App-Signaturschlüssel exportieren

Lade `encryption_public_key.pem` herunter und speichere im Projekt-Verzeichnis.

### 2. Keystores erstellen (falls nötig)

```bash
# Lianko
keytool -genkey -v -keystore lianko-upload-key.jks -keyalg RSA -keysize 2048 -validity 10000 -alias lianko-upload

# Parent  
keytool -genkey -v -keystore parent-upload-key.jks -keyalg RSA -keysize 2048 -validity 10000 -alias parent-upload

# Li Ki Train
keytool -genkey -v -keystore likitrain-upload-key.jks -keyalg RSA -keysize 2048 -validity 10000 -alias likitrain-upload
```

### 3. Export ausführen

```bash
# Lianko
java -jar pepk.jar --keystore=lianko-upload-key.jks --alias=lianko-upload --output=lianko-upload-key.zip --include-cert --rsa-aes-encryption --encryption-key-path=encryption_public_key.pem

# Parent
java -jar pepk.jar --keystore=parent-upload-key.jks --alias=parent-upload --output=parent-upload-key.zip --include-cert --rsa-aes-encryption --encryption-key-path=encryption_public_key.pem

# Li Ki Train
java -jar pepk.jar --keystore=likitrain-upload-key.jks --alias=likitrain-upload --output=likitrain-upload-key.zip --include-cert --rsa-aes-encryption --encryption-key-path=encryption_public_key.pem
```

### 4. ZIP-Dateien hochladen

Die erstellten ZIP-Dateien in Google Play Console hochladen:
- `lianko-upload-key.zip`
- `parent-upload-key.zip`
- `likitrain-upload-key.zip`

---

## 📁 Dateien die du brauchst:

- ✅ `pepk.jar` - Bereit
- ⏳ `encryption_public_key.pem` - Von Google Play Console
- ⏳ `lianko-upload-key.jks` - Erstellen mit keytool
- ⏳ `parent-upload-key.jks` - Erstellen mit keytool
- ⏳ `likitrain-upload-key.jks` - Erstellen mit keytool

---

## 🎯 Ergebnis

Nach erfolgreichem Export hast du:
- ✅ `lianko-upload-key.zip` - Zum Hochladen
- ✅ `parent-upload-key.zip` - Zum Hochladen
- ✅ `likitrain-upload-key.zip` - Zum Hochladen

Diese ZIP-Dateien lädst du in Google Play Console hoch, dann hat Google den Key und kann deine Apps signieren!

