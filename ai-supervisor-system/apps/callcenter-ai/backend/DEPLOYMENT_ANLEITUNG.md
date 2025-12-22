# 🚀 Deployment-Anleitung - Premium Sales Agents

## 📋 Übersicht

Deployment des Premium Sales Agents Backends auf Server für sofortiges Testen.

---

## 🎯 Quick Deploy

### Lokales Deployment (Test)

```bash
cd apps/callcenter-ai/backend
bash deploy.sh
```

**Oder manuell:**
```bash
npm install
npm start
```

**Backend läuft auf:** http://localhost:3000

---

## 🌐 Remote Server Deployment

### 1. Environment Variables setzen

```bash
export DEPLOY_HOST="dein-server.com"
export DEPLOY_USER="root"
export DEPLOY_PORT="22"
export DEPLOY_PATH="/opt/callcenter-ai"
```

### 2. Deployen

```bash
cd apps/callcenter-ai/backend
bash deploy.sh
```

### 3. Server-Konfiguration

Das Script:
- ✅ Erstellt Deployment-Package
- ✅ Kopiert auf Server
- ✅ Installiert Node.js (falls nötig)
- ✅ Installiert Dependencies
- ✅ Startet mit PM2
- ✅ Konfiguriert Auto-Start

---

## 🔧 Server-Anforderungen

### Minimum
- **OS:** Ubuntu 20.04+ / Debian 11+
- **RAM:** 2GB
- **CPU:** 2 Cores
- **Disk:** 10GB
- **Node.js:** 18+

### Empfohlen
- **RAM:** 4GB+
- **CPU:** 4 Cores+
- **Disk:** 20GB+

---

## 📦 Dependencies

### Automatisch installiert:
- Node.js 18+
- npm
- PM2 (Process Manager)
- Alle npm Dependencies

### Manuell benötigt:
- Google Cloud TTS Credentials (für Voice)
- Gemini API Key (für AI)

---

## 🔐 Environment Variables auf Server

```bash
# Auf Server setzen
export GEMINI_API_KEY="dein-api-key"
export GOOGLE_CLOUD_CREDENTIALS='{"type":"service_account",...}'
export PORT=3000

# Oder in .env Datei
echo "GEMINI_API_KEY=dein-api-key" > .env
echo "PORT=3000" >> .env
```

---

## 🚀 PM2 Management

### Service starten
```bash
pm2 start server.js --name callcenter-ai
```

### Service stoppen
```bash
pm2 stop callcenter-ai
```

### Service neustarten
```bash
pm2 restart callcenter-ai
```

### Logs anzeigen
```bash
pm2 logs callcenter-ai
```

### Status
```bash
pm2 status
```

### Auto-Start konfigurieren
```bash
pm2 save
pm2 startup
```

---

## 🧪 Testing nach Deployment

### 1. Health Check

```bash
curl http://SERVER:3000/api/v1/health
```

**Erwartete Antwort:**
```json
{
  "status": "ok",
  "activeSessions": 0,
  "timestamp": "2025-12-18T..."
}
```

### 2. Premium Session erstellen

```bash
curl -X POST http://SERVER:3000/api/v1/premium/sessions \
  -H "Content-Type: application/json" \
  -d '{"productCategory":"solar","language":"german"}'
```

### 3. Chat testen

```bash
curl -X POST http://SERVER:3000/api/v1/premium/sessions/SESSION_ID/chat \
  -H "Content-Type: application/json" \
  -d '{"message":"Hallo, ich interessiere mich für Solar"}'
```

---

## 🔥 Firewall & Ports

### Port öffnen

```bash
# UFW (Ubuntu)
sudo ufw allow 3000/tcp

# FirewallD (CentOS)
sudo firewall-cmd --add-port=3000/tcp --permanent
sudo firewall-cmd --reload
```

### Nginx Reverse Proxy (Optional)

```nginx
server {
    listen 80;
    server_name callcenter-api.dein-server.com;

    location / {
        proxy_pass http://localhost:3000;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_cache_bypass $http_upgrade;
    }
}
```

---

## 📊 Monitoring

### PM2 Monitoring

```bash
pm2 monit
```

### Logs

```bash
# Live Logs
pm2 logs callcenter-ai

# Log-Datei
tail -f ~/.pm2/logs/callcenter-ai-out.log
```

### Metriken

```bash
curl http://SERVER:3000/api/v1/stats
```

---

## 🔄 Updates

### Neues Deployment

```bash
# Lokal
cd apps/callcenter-ai/backend
git pull
bash deploy.sh
```

### Rollback

```bash
# Auf Server
cd /opt/callcenter-ai
git checkout PREVIOUS_COMMIT
pm2 restart callcenter-ai
```

---

## 🐛 Troubleshooting

### Port bereits belegt

```bash
# Prüfe was auf Port 3000 läuft
sudo lsof -i :3000

# Stoppe Prozess
pm2 stop callcenter-ai
# oder
kill -9 PID
```

### Dependencies fehlen

```bash
cd /opt/callcenter-ai
npm install
pm2 restart callcenter-ai
```

### API Key nicht gesetzt

```bash
export GEMINI_API_KEY="dein-key"
pm2 restart callcenter-ai
```

---

## ✅ Deployment-Checkliste

- [ ] Server-Zugriff konfiguriert
- [ ] Environment Variables gesetzt
- [ ] Port 3000 geöffnet
- [ ] Dependencies installiert
- [ ] Service gestartet
- [ ] Health Check erfolgreich
- [ ] Test-Session erstellt
- [ ] Chat getestet
- [ ] PM2 Auto-Start konfiguriert
- [ ] Monitoring eingerichtet

---

**Status:** ✅ Deployment-Script bereit

