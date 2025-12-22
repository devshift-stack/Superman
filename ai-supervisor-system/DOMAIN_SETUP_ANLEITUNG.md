# 🌐 Domain-Setup für Railway - Anleitung

**Erstellt:** 18. Dezember 2024

---

## 📋 Was du vorbereiten musst

### **1. Domain-Informationen**
- ✅ **Domain-Name:** (z.B. `supervisor.deinedomain.com`)
- ✅ **Domain-Provider:** (z.B. Namecheap, GoDaddy, Cloudflare)
- ✅ **Zugriff auf DNS-Einstellungen:** (Benötigt für DNS-Konfiguration)

---

## 🔧 Schritt-für-Schritt Anleitung

### **Schritt 1: Domain in Railway hinzufügen**

1. **Gehe zu Railway Dashboard:**
   - https://railway.app/dashboard
   - Wähle dein Projekt aus

2. **Service auswählen:**
   - Klicke auf deinen Service (z.B. "Supervisor")

3. **Settings öffnen:**
   - Klicke auf "Settings" Tab
   - Scrolle zu "Networking"

4. **Custom Domain hinzufügen:**
   - Klicke auf "Add Custom Domain"
   - Gib deine Domain ein (z.B. `supervisor.deinedomain.com`)
   - Railway zeigt dir die **DNS-Einstellungen** an

---

## 🔗 DNS-Einstellungen

### **Option 1: CNAME (Empfohlen für Subdomains)**

**Beispiel:**
```
Type: CNAME
Name: supervisor (oder @ für Root-Domain)
Value: [Railway zeigt dir den Wert]
TTL: 3600 (oder Auto)
```

**Für Root-Domain (@):**
- Railway zeigt dir einen **A-Record** oder **CNAME**
- Verwende den Wert, den Railway dir gibt

### **Option 2: A-Record (Für Root-Domain)**

**Falls Railway einen A-Record verlangt:**
```
Type: A
Name: @ (oder leer für Root-Domain)
Value: [IP-Adresse von Railway]
TTL: 3600
```

---

## 📝 Was Railway dir zeigt

Nach dem Hinzufügen der Domain zeigt Railway:

1. **DNS-Einstellungen:**
   - Type (CNAME oder A)
   - Name (z.B. `supervisor`)
   - Value (z.B. `xxxxx.railway.app`)

2. **Status:**
   - ⏳ "Pending" - Warte auf DNS-Propagation
   - ✅ "Active" - Domain ist aktiv

---

## ⏱️ DNS-Propagation

**Wie lange dauert es?**
- ⏱️ **Normal:** 5-60 Minuten
- ⏱️ **Manchmal:** Bis zu 24 Stunden
- ✅ **Prüfen:** Railway zeigt Status an

**DNS-Propagation prüfen:**
```bash
# Terminal-Befehl
dig supervisor.deinedomain.com
# oder
nslookup supervisor.deinedomain.com
```

---

## 🔒 SSL-Zertifikat

**Automatisch von Railway:**
- ✅ Railway erstellt automatisch SSL-Zertifikat (Let's Encrypt)
- ✅ HTTPS funktioniert automatisch
- ✅ Keine manuelle Konfiguration nötig

**Status prüfen:**
- Railway Dashboard → Service → Settings → Networking
- Zeigt SSL-Status an

---

## ✅ Checkliste

**Vorbereitung:**
- [ ] Domain gekauft/registriert
- [ ] Zugriff auf DNS-Einstellungen (Domain-Provider)
- [ ] Railway Account erstellt
- [ ] Service auf Railway deployed

**DNS-Konfiguration:**
- [ ] Domain in Railway hinzugefügt
- [ ] DNS-Einstellungen von Railway kopiert
- [ ] DNS-Einstellungen bei Domain-Provider gesetzt
- [ ] DNS-Propagation abgewartet (5-60 Min)

**Verifizierung:**
- [ ] Railway zeigt "Active" Status
- [ ] Domain funktioniert im Browser
- [ ] HTTPS funktioniert (SSL-Zertifikat aktiv)

---

## 🆘 Troubleshooting

### **Problem: Domain zeigt "Pending"**
**Lösung:**
- Prüfe DNS-Einstellungen bei Domain-Provider
- Warte auf DNS-Propagation (bis zu 24h)
- Prüfe mit `dig` oder `nslookup`

### **Problem: SSL-Zertifikat wird nicht erstellt**
**Lösung:**
- Warte bis DNS-Propagation abgeschlossen ist
- Railway erstellt SSL automatisch nach DNS-Propagation
- Prüfe Railway Dashboard für Status

### **Problem: Domain funktioniert nicht**
**Lösung:**
- Prüfe DNS-Einstellungen (Type, Name, Value)
- Prüfe ob Railway Service läuft
- Prüfe Railway Logs für Fehler

---

## 📚 Weitere Informationen

**Railway Dokumentation:**
- https://docs.railway.app/guides/custom-domains

**DNS-Provider Anleitungen:**
- **Cloudflare:** https://developers.cloudflare.com/dns/manage-dns-records/
- **Namecheap:** https://www.namecheap.com/support/knowledgebase/article.aspx/767/10/
- **GoDaddy:** https://www.godaddy.com/help/add-a-cname-record-19236

---

**Letzte Aktualisierung:** 18. Dezember 2024

