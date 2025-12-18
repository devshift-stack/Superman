require('dotenv').config();
const express = require('express');
const cors = require('cors');
const Supervisor = require('./supervisor/src/Supervisor');

const app = express();
const PORT = process.env.PORT || 3000;

app.use(cors());
app.use(express.json());

// Supervisor Instanz
const supervisor = new Supervisor({
  redisUrl: process.env.REDIS_URL,
  dbPath: process.env.DB_PATH || './data/sessions.db'
});

// Initialisiere Supervisor beim Start
supervisor.initialize().catch(err => {
  console.error('❌ Fehler beim Initialisieren des Supervisors:', err);
});

// Health Check Endpoint
app.get('/', async (req, res) => {
  try {
    const status = await supervisor.getStatus();
    res.json({
      status: 'ok',
      message: 'AI Supervisor System',
      supervisor: status,
      timestamp: new Date().toISOString()
    });
  } catch (error) {
    res.json({
      status: 'ok',
      message: 'AI Supervisor System - Initialisierung läuft...',
      timestamp: new Date().toISOString()
    });
  }
});

// Health Check für Railway
app.get('/health', (req, res) => {
  res.json({ status: 'healthy' });
});

// Supervisor API Endpoints
app.get('/api/supervisor/status', async (req, res) => {
  try {
    const status = await supervisor.getStatus();
    res.json(status);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

app.post('/api/supervisor/tasks', async (req, res) => {
  try {
    const task = req.body;
    const taskId = await supervisor.addTask(task);
    res.json({ taskId, status: 'queued' });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

app.post('/api/supervisor/agents', async (req, res) => {
  try {
    const agent = await supervisor.registerAgent(req.body);
    res.json(agent);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

app.get('/api/supervisor/agents', async (req, res) => {
  try {
    const agents = supervisor.agentRegistry.getAllAgents();
    res.json(agents);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

app.post('/api/supervisor/sessions', async (req, res) => {
  try {
    const { userId, metadata } = req.body;
    const session = await supervisor.createSession(userId, metadata);
    res.json(session);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

app.get('/api/supervisor/sessions/:sessionId', async (req, res) => {
  try {
    const session = await supervisor.getSession(req.params.sessionId);
    if (!session) {
      return res.status(404).json({ error: 'Session nicht gefunden' });
    }
    res.json(session);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

app.listen(PORT, () => {
  console.log(`🚀 Server läuft auf Port ${PORT}`);
  console.log(`📊 Supervisor-System aktiv`);
  console.log(`🔗 API verfügbar unter: http://localhost:${PORT}/api/supervisor`);
});

