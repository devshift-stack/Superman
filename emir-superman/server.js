/**
 * Express Server für AI Supervisor System
 * REST API für Supervisor, Agents, Tasks, Knowledge Base
 */

require('dotenv').config();
const express = require('express');
const cors = require('cors');
const Supervisor = require('./supervisor/src/Supervisor');

const app = express();
const PORT = process.env.PORT || 3000;

// Middleware
app.use(cors());
app.use(express.json());

/**
 * Request Validation Middleware
 * Prüft Content-Type für POST/PUT/PATCH Requests
 */
const validateRequest = (req, res, next) => {
  // Prüfe Content-Type für POST/PUT/PATCH
  if (['POST', 'PUT', 'PATCH'].includes(req.method)) {
    if (req.get('Content-Type') && !req.is('application/json')) {
      return res.status(400).json({
        error: 'Ungültiger Content-Type',
        message: 'Content-Type muss application/json sein'
      });
    }
  }
  next();
};

app.use(validateRequest);

// Supervisor Instance
let supervisor = null;

/**
 * Initialisiert Supervisor
 */
async function initializeSupervisor() {
  try {
    supervisor = new Supervisor({
      redisUrl: process.env.REDIS_URL || 'redis://localhost:6379',
      dbPath: process.env.DB_PATH || './data/sessions.db',
    });
    await supervisor.initialize();
    console.log('✅ Supervisor initialisiert');
  } catch (error) {
    console.error('⚠️ Supervisor konnte nicht initialisiert werden:', error.message);
    console.warn('⚠️ Server läuft im eingeschränkten Modus (nur Health Check)');
    supervisor = null;
  }
}

// Health Check
app.get('/', (req, res) => {
  res.json({
    status: 'ok',
    message: 'AI Supervisor System',
    timestamp: new Date().toISOString(),
    version: '1.0.0'
  });
});

app.get('/health', (req, res) => {
  res.json({ status: 'healthy' });
});

// Supervisor Status
app.get('/api/status', async (req, res) => {
  try {
    if (!supervisor) {
      return res.status(503).json({ error: 'Supervisor nicht initialisiert' });
    }
    const status = await supervisor.getStatus();
    res.json(status);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// Agent Management
app.post('/api/agents/register', async (req, res) => {
  try {
    if (!supervisor) {
      return res.status(503).json({ error: 'Supervisor nicht initialisiert' });
    }
    const agent = await supervisor.registerAgent(req.body);
    res.json(agent);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

app.get('/api/agents', async (req, res) => {
  try {
    if (!supervisor) {
      return res.status(503).json({ error: 'Supervisor nicht initialisiert' });
    }
    const agents = supervisor.agentRegistry.getAllAgents();
    res.json(agents);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// Task Management
app.post('/api/tasks', async (req, res) => {
  try {
    if (!supervisor) {
      return res.status(503).json({ error: 'Supervisor nicht initialisiert' });
    }
    const taskId = await supervisor.addTask(req.body);
    res.json({ taskId, status: 'queued' });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

app.get('/api/tasks/:taskId', async (req, res) => {
  try {
    if (!supervisor) {
      return res.status(503).json({ error: 'Supervisor nicht initialisiert' });
    }
    const task = supervisor.activeTasks.get(req.params.taskId);
    if (!task) {
      return res.status(404).json({ error: 'Task nicht gefunden' });
    }
    res.json(task);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// Session Management
app.post('/api/sessions', async (req, res) => {
  try {
    if (!supervisor) {
      return res.status(503).json({ error: 'Supervisor nicht initialisiert' });
    }
    const { userId, metadata } = req.body;
    const session = await supervisor.createSession(userId, metadata);
    res.json(session);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

app.get('/api/sessions/:sessionId', async (req, res) => {
  try {
    if (!supervisor) {
      return res.status(503).json({ error: 'Supervisor nicht initialisiert' });
    }
    const session = await supervisor.getSession(req.params.sessionId);
    if (!session) {
      return res.status(404).json({ error: 'Session nicht gefunden' });
    }
    res.json(session);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// Knowledge Base
app.post('/api/knowledge/search', async (req, res) => {
  try {
    if (!supervisor) {
      return res.status(503).json({ error: 'Supervisor nicht initialisiert' });
    }
    const { query, options = {} } = req.body;
    const results = await supervisor.searchKnowledge(query, options);
    res.json(results);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

app.post('/api/knowledge/store', async (req, res) => {
  try {
    if (!supervisor) {
      return res.status(503).json({ error: 'Supervisor nicht initialisiert' });
    }
    const { text, source, metadata = {} } = req.body;
    const id = await supervisor.storeResearch(text, source, metadata);
    res.json({ id, status: 'stored' });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

app.post('/api/knowledge/verify/:id', async (req, res) => {
  try {
    if (!supervisor) {
      return res.status(503).json({ error: 'Supervisor nicht initialisiert' });
    }
    const { notes = '' } = req.body;
    const verified = await supervisor.verifyKnowledge(req.params.id, notes);
    res.json({ verified, id: req.params.id });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

app.get('/api/knowledge/stats', async (req, res) => {
  try {
    if (!supervisor) {
      return res.status(503).json({ error: 'Supervisor nicht initialisiert' });
    }
    const stats = await supervisor.knowledgeBase.getStats();
    res.json(stats);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// ============================================
// ERROR HANDLING
// ============================================

/**
 * JSON Parse Error Handler
 */
app.use((err, req, res, next) => {
  if (err instanceof SyntaxError && err.status === 400 && 'body' in err) {
    return res.status(400).json({
      error: 'Ungültiges JSON',
      message: 'Die Anfrage enthält kein gültiges JSON-Format',
      details: err.message
    });
  }
  next(err);
});


/**
 * 404 Handler - Route nicht gefunden
 */
app.use((req, res) => {
  res.status(404).json({
    error: 'Route nicht gefunden',
    message: `Die Route ${req.method} ${req.path} existiert nicht`,
    path: req.path,
    method: req.method,
    timestamp: new Date().toISOString()
  });
});

/**
 * Globaler Error Handler
 */
app.use((err, req, res, next) => {
  // Log Error mit Details
  console.error('❌ Server Fehler:', {
    message: err.message,
    stack: err.stack,
    path: req.path,
    method: req.method,
    ip: req.ip,
    timestamp: new Date().toISOString()
  });

  // Bestimme Status Code
  const statusCode = err.statusCode || err.status || 500;

  // Strukturierte Error Response
  const errorResponse = {
    error: err.name || 'Interner Serverfehler',
    message: err.message || 'Ein unerwarteter Fehler ist aufgetreten',
    timestamp: new Date().toISOString(),
    path: req.path,
    method: req.method
  };

  // In Development: Stack Trace hinzufügen
  if (process.env.NODE_ENV === 'development') {
    errorResponse.stack = err.stack;
  }

  res.status(statusCode).json(errorResponse);
});

/**
 * Unhandled Promise Rejection Handler
 */
process.on('unhandledRejection', (reason, promise) => {
  console.error('❌ Unhandled Promise Rejection:', {
    reason: reason instanceof Error ? reason.message : reason,
    stack: reason instanceof Error ? reason.stack : undefined,
    timestamp: new Date().toISOString()
  });
  
  // In Production: Server nicht abstürzen lassen
  if (process.env.NODE_ENV === 'production') {
    console.warn('⚠️ Server läuft weiter trotz unhandled rejection');
  } else {
    // In Development: Prozess beenden für besseres Debugging
    process.exit(1);
  }
});

/**
 * Uncaught Exception Handler
 */
process.on('uncaughtException', (error) => {
  console.error('❌ Uncaught Exception:', {
    message: error.message,
    stack: error.stack,
    timestamp: new Date().toISOString()
  });
  
  // Graceful Shutdown
  if (supervisor) {
    supervisor.shutdown().then(() => {
      process.exit(1);
    }).catch(() => {
      process.exit(1);
    });
  } else {
    process.exit(1);
  }
});

// Start Server
async function start() {
  // Initialisiere Supervisor (non-blocking - Server startet auch ohne)
  await initializeSupervisor();
  
  app.listen(PORT, () => {
    console.log(`🚀 Server läuft auf Port ${PORT}`);
    console.log(`📊 API verfügbar unter: http://localhost:${PORT}/api`);
    console.log(`💚 Health Check: http://localhost:${PORT}/health`);
    if (!supervisor) {
      console.warn('⚠️ Supervisor nicht verfügbar - einige Endpoints funktionieren nicht');
    }
  });
}

// Graceful Shutdown
process.on('SIGTERM', async () => {
  console.log('🛑 SIGTERM empfangen, beende Server...');
  if (supervisor) {
    await supervisor.shutdown();
  }
  process.exit(0);
});

process.on('SIGINT', async () => {
  console.log('🛑 SIGINT empfangen, beende Server...');
  if (supervisor) {
    await supervisor.shutdown();
  }
  process.exit(0);
});

// Start
start();
