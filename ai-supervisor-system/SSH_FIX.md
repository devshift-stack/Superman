# 🔑 SSH-Verbindung zum Server einrichten

**Server:** 49.13.158.176

---

## Problem

SSH-Verbindung funktioniert nicht - "Permission denied (publickey)".

---

## Lösung: SSH-Key auf Server hinzufügen

### **Option 1: Key manuell auf Server kopieren**

**1. Öffne Hetzner Dashboard:**
- Gehe zu deinem Server
- Klicke auf "SSH-Keys"
- Klicke auf "+ SSH-Key hinzufügen"

**2. Öffne deinen SSH-Key:**
```bash
# Auf deinem Mac
cat ~/.ssh/id_ed25519.pub
```

**3. Kopiere den gesamten Key** (beginnt mit `ssh-ed25519` oder `ssh-rsa`)

**4. Füge ihn in Hetzner ein:**
- Name: z.B. "Mac-DS8877"
- Key: Den kopierten Key einfügen
- Speichern

**5. Teste Verbindung:**
```bash
ssh root@49.13.158.176
```

---

### **Option 2: Neuen SSH-Key generieren**

```bash
# Neuen Key generieren
ssh-keygen -t ed25519 -f ~/.ssh/superman_server -C "superman-server"

# Öffentlichen Key anzeigen
cat ~/.ssh/superman_server.pub
```

**Dann:**
1. Key in Hetzner Dashboard hinzufügen (siehe Option 1, Schritt 2-4)
2. Verbinden mit:
```bash
ssh -i ~/.ssh/superman_server root@49.13.158.176
```

---

### **Option 3: Passwort-Login aktivieren (temporär)**

**Falls du das Root-Passwort hast:**
```bash
ssh root@49.13.158.176
# Passwort eingeben
```

**Dann Key hinzufügen:**
```bash
# Auf Server
mkdir -p ~/.ssh
chmod 700 ~/.ssh

# Auf deinem Mac: Key kopieren
cat ~/.ssh/id_ed25519.pub | ssh root@49.13.158.176 "cat >> ~/.ssh/authorized_keys"
```

---

## Welcher Key ist auf dem Server?

**Prüfe in Hetzner Dashboard:**
- Server → "SSH-Keys" Tab
- Welche Keys sind dort aufgelistet?
- Welcher Name passt zu deinen Keys?

**Mögliche Keys:**
- `hetzner_46`
- `server46`
- `id_ed25519`
- Oder ein anderer Name

---

## Nach erfolgreicher Verbindung

**Dann kann ich automatisch deployen:**
```bash
./deploy-local.sh
```

---

**Sag mir, welcher Key auf dem Server ist, dann kann ich die Verbindung einrichten!**

