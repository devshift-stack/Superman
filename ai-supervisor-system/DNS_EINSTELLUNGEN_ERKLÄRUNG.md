# 🔗 DNS-Einstellungen für Railway - Was du brauchst

**Erstellt:** 18. Dezember 2024

---

## ⚠️ WICHTIG: Railway zeigt dir die Werte!

**Du musst die Domain ZUERST in Railway hinzufügen, dann zeigt Railway dir die DNS-Einstellungen!**

---

## 📋 Was Railway dir zeigt

### **Schritt 1: Domain in Railway hinzufügen**

1. Railway Dashboard → Service → Settings → Networking
2. "Add Custom Domain" klicken
3. Domain eingeben (z.B. `supervisor.deinedomain.com`)
4. Railway zeigt dir **automatisch** die DNS-Einstellungen an

---

## 🔗 Zwei Möglichkeiten

### **Option 1: CNAME (Meistens - für Subdomains)**

**Railway zeigt dir:**
```
Type: CNAME
Name: supervisor
Value: xxxxx.up.railway.app
```

**Bei deinem Domain-Provider:**
- Type: **CNAME**
- Name: **supervisor** (oder was Railway dir sagt)
- Value: **xxxxx.up.railway.app** (Railway zeigt dir den genauen Wert)
- TTL: 3600 (oder Auto)

**Beispiel:**
- Domain: `supervisor.meinedomain.com`
- CNAME: `supervisor` → `abc123.up.railway.app`

---

### **Option 2: A-Record (Für Root-Domain)**

**Falls Railway einen A-Record verlangt:**
```
Type: A
Name: @ (oder leer)
Value: [IP-Adresse - Railway zeigt dir diese]
TTL: 3600
```

**WICHTIG:** Railway zeigt dir die **genaue IP-Adresse** an, wenn du die Domain hinzufügst!

---

## 🎯 Was du tun musst

### **1. Domain in Railway hinzufügen**
- Railway Dashboard → Service → Settings → Networking
- "Add Custom Domain"
- Domain eingeben
- **Railway zeigt dir die DNS-Einstellungen!**

### **2. DNS-Einstellungen kopieren**
Railway zeigt dir:
- ✅ **Type** (CNAME oder A)
- ✅ **Name** (z.B. `supervisor` oder `@`)
- ✅ **Value** (z.B. `xxxxx.up.railway.app` oder IP-Adresse)

### **3. Bei Domain-Provider setzen**
- Gehe zu deinem Domain-Provider (Namecheap, GoDaddy, Cloudflare, etc.)
- Öffne DNS-Einstellungen
- Füge neuen Record hinzu
- **Kopiere genau die Werte von Railway!**

---

## 📝 Beispiel-Screenshots (Was Railway zeigt)

**Railway zeigt dir so etwas:**

```
Custom Domain: supervisor.meinedomain.com

DNS Configuration:
Type: CNAME
Name: supervisor
Value: abc123def456.up.railway.app
```

**ODER:**

```
Custom Domain: meinedomain.com

DNS Configuration:
Type: A
Name: @
Value: 35.123.45.67
```

---

## ⚠️ WICHTIG

**Du kannst die IP-Adresse NICHT vorher wissen!**
- Railway vergibt sie dynamisch
- Railway zeigt sie dir, wenn du die Domain hinzufügst
- Jeder Service bekommt eine andere IP/CNAME

**Lösung:**
1. Domain ZUERST in Railway hinzufügen
2. Railway zeigt dir die DNS-Einstellungen
3. Diese Werte bei deinem Domain-Provider setzen

---

## 🔍 Häufige Fragen

### **Frage: Welche IP-Adresse brauche ich?**
**Antwort:** Railway zeigt dir die IP-Adresse (oder CNAME), wenn du die Domain hinzufügst. Du kannst sie nicht vorher wissen.

### **Frage: Kann ich eine IP-Adresse vorher herausfinden?**
**Antwort:** Nein, Railway vergibt sie dynamisch. Du musst die Domain zuerst in Railway hinzufügen.

### **Frage: Ist es immer CNAME oder A-Record?**
**Antwort:** 
- **Subdomain** (z.B. `supervisor.deinedomain.com`) → Meistens **CNAME**
- **Root-Domain** (z.B. `deinedomain.com`) → Meistens **A-Record** oder **CNAME**

Railway zeigt dir, was du brauchst!

---

## ✅ Checkliste

**Vorbereitung:**
- [ ] Domain gekauft/registriert
- [ ] Zugriff auf DNS-Einstellungen bei Domain-Provider
- [ ] Railway Service läuft

**DNS-Konfiguration:**
- [ ] Domain in Railway hinzugefügt
- [ ] **DNS-Einstellungen von Railway kopiert** (Type, Name, Value)
- [ ] DNS-Einstellungen bei Domain-Provider gesetzt
- [ ] Warten auf DNS-Propagation (5-60 Min)

**Verifizierung:**
- [ ] Railway zeigt "Active" Status
- [ ] Domain funktioniert im Browser

---

## 🆘 Falls Railway keine DNS-Einstellungen zeigt

**Prüfe:**
1. Ist die Domain korrekt eingegeben?
2. Ist der Service aktiv?
3. Warte ein paar Sekunden - Railway braucht manchmal Zeit

**Falls immer noch nichts:**
- Railway Support kontaktieren
- Oder: Prüfe Railway Logs für Fehler

---

**Letzte Aktualisierung:** 18. Dezember 2024

