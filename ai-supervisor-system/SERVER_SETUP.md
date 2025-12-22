# 🚀 Hetzner Server Setup - Schritt für Schritt

**Server IP:** 49.13.158.176

---

## Schritt 1: SSH-Verbindung

```bash
ssh root@49.13.158.176
```

---

## Schritt 2: Deployment-Script ausführen

**Option A: Script hochladen und ausführen**

```bash
# Auf deinem Mac: Script hochladen
scp deploy.sh root@49.13.158.176:/root/

# Auf Server: Script ausführen
ssh root@49.13.158.176
chmod +x deploy.sh
./deploy.sh
```

**Option B: Manuell installieren**

Siehe unten "Manuelle Installation"

---

## Schritt 3: Code auf Server deployen

```bash
# Auf Server
cd /root
git clone https://github.com/devshift-stack/Superman.git
cd Superman/emir-superman
npm install
```

---

## Schritt 4: Environment Variables setzen

```bash
# Auf Server
cd /root/Superman/emir-superman
cp .env.example .env
nano .env  # Oder vi .env
```

**Füge deine API-Keys ein:**
```
OPENAI_API_KEY=dein-key
CLAUDE_API_KEY=dein-key
GROK_API_KEY=dein-key
GEMINI_API_KEY=dein-key
PINECONE_API_KEY=dein-key
PINECONE_ENVIRONMENT=gcp-starter
REDIS_URL=redis://localhost:6379
DB_PATH=./data/sessions.db
PORT=3000
```

---

## Schritt 5: Server starten

```bash
# Mit PM2 (empfohlen)
pm2 start server.js --name supervisor
pm2 save
pm2 startup  # Für Auto-Start nach Reboot

# Oder direkt
node server.js
```

---

## Schritt 6: Testen

```bash
# Health Check
curl http://localhost:3000/health

# Status
curl http://localhost:3000/api/status
```

---

## Manuelle Installation (falls Script nicht funktioniert)

### Node.js (CentOS)
```bash
curl -fsSL https://rpm.nodesource.com/setup_20.x | bash -
yum install -y nodejs
```

### Redis (CentOS)
```bash
yum install -y redis
systemctl start redis
systemctl enable redis
redis-cli ping  # Sollte "PONG" zurückgeben
```

### Git (CentOS)
```bash
yum install -y git
```

### PM2
```bash
npm install -g pm2
```

---

## Firewall (falls nötig)

```bash
# Firewall-Regeln prüfen
firewall-cmd --list-all

# Ports öffnen (falls Firewall aktiv)
firewall-cmd --permanent --add-port=3000/tcp
firewall-cmd --permanent --add-port=443/tcp
firewall-cmd --reload
```

---

## Troubleshooting

**Redis läuft nicht:**
```bash
systemctl status redis
systemctl start redis
```

**Node.js nicht gefunden:**
```bash
which node
export PATH=$PATH:/usr/bin
```

**Port bereits belegt:**
```bash
netstat -tulpn | grep 3000
# Oder
lsof -i :3000
```

---

**Fertig!** 🎉

