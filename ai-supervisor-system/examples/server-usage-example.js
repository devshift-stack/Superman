/**
 * Praktisches Beispiel: Server-Nutzung von Agenten & ArenaProPlus
 * 
 * Diese Datei zeigt konkrete Code-Beispiele für die Nutzung im Server-Kontext.
 */

require('dotenv').config();
const express = require('express');
const Supervisor = require('../supervisor/Supervisor');
const ArenaProPlus = require('../supervisor/ArenaProPlus');

const app = express();
app.use(express.json());

// ============================================
// 1. SUPERVISOR INITIALISIEREN
// ============================================

let supervisor = null;
let arenaPro = null;

async function initializeSupervisor() {
  try {
    console.log('🚀 Initialisiere Supervisor...');
    
    supervisor = new Supervisor({
      redisUrl: process.env.REDIS_URL || 'redis://localhost:6379',
      dbPath: process.env.DB_PATH || './data/sessions.db',
    });
    
    await supervisor.initialize();
    console.log('✅ Supervisor initialisiert');
    
    // ArenaProPlus mit AgentManager initialisieren
    arenaPro = new ArenaProPlus(supervisor.agentManager, {
      maxParallelTasks: 4,
      synthesisModel: 'creative',
      qualityCheckModel: 'coding',
      decomposerModel: 'research'
    });
    console.log('✅ ArenaProPlus initialisiert');
    
  } catch (error) {
    console.error('❌ Fehler bei Initialisierung:', error.message);
    // Server kann im eingeschränkten Modus weiterlaufen
  }
}

// ============================================
// 2. NORMALE AGENTEN NUTZEN
// ============================================

/**
 * Beispiel 1: Einfache Frage an Coach-Agent
 */
app.post('/api/example/simple-question', async (req, res) => {
  try {
    if (!supervisor) {
      return res.status(503).json({ error: 'Supervisor nicht initialisiert' });
    }
    
    const task = await supervisor.createTask({
      type: 'research',
      content: req.body.question || 'Wie funktioniert das Supervisor-System?',
      priority: 'medium',
    });
    
    res.json({
      success: true,
      taskId: task.id,
      assignedAgent: task.assignedAgent,
      routingScore: task.routingScore,
      estimatedTime: task.estimatedTime,
      message: 'Task wurde erstellt und zur Verarbeitung hinzugefügt',
      tip: `Ergebnis abrufen mit: GET /api/tasks/${task.id}/result`
    });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

/**
 * Beispiel 2: Dokumentation erstellen
 */
app.post('/api/example/create-docs', async (req, res) => {
  try {
    if (!supervisor) {
      return res.status(503).json({ error: 'Supervisor nicht initialisiert' });
    }
    
    const task = await supervisor.createTask({
      type: 'creative',
      content: `Erstelle Dokumentation für: ${req.body.topic || 'API-Dokumentation'}\nFormat: ${req.body.format || 'markdown'}\nSections: ${(req.body.sections || ['Übersicht', 'Endpunkte', 'Beispiele']).join(', ')}`,
      priority: 'high',
      metadata: {
        sessionId: req.body.sessionId
      }
    });
    
    res.json({
      success: true,
      taskId: task.id,
      assignedAgent: task.assignedAgent,
      message: 'Dokumentations-Task erstellt',
    });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

/**
 * Beispiel 3: Task mit Session
 */
app.post('/api/example/task-with-session', async (req, res) => {
  try {
    if (!supervisor) {
      return res.status(503).json({ error: 'Supervisor nicht initialisiert' });
    }
    
    // Session erstellen
    const session = await supervisor.createSession(req.body.userId || 'user-123', {
      context: req.body.context || {},
    });
    
    // Task mit Session-ID erstellen
    const task = await supervisor.createTask({
      type: 'general',
      content: req.body.question,
      priority: 'high',
      metadata: {
        sessionId: session.id,
        context: req.body.context
      }
    });
    
    res.json({
      success: true,
      taskId: task.id,
      assignedAgent: task.assignedAgent,
      sessionId: session.id,
      message: 'Task mit Session erstellt',
    });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// ============================================
// 3. ARENAPROPLUS NUTZEN
// ============================================

/**
 * Beispiel 4: ArenaProPlus für komplexe Analyse
 */
app.post('/api/example/arena-complex-analysis', async (req, res) => {
  try {
    if (!arenaPro) {
      return res.status(503).json({ error: 'ArenaProPlus nicht verfügbar' });
    }
    
    const task = {
      content: req.body.content || `${req.body.topic || 'KI-Trends 2024'}: ${req.body.requirements || 'Vollständige Analyse mit Recherche, Strukturierung und kreativen Ideen'}`,
      type: req.body.type || 'general',
      priority: req.body.priority || 'high'
    };
    
    console.log('🏟️ Starte ArenaProPlus Kollaboration...');
    const result = await arenaPro.execute(task);
    
    res.json({
      success: true,
      arenaId: result.arenaId,
      content: result.content,
      phases: result.phases,
      duration: result.duration,
      usage: result.usage,
      message: 'ArenaProPlus Kollaboration abgeschlossen',
    });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

/**
 * Beispiel 5: ArenaProPlus ist synchron - Ergebnis direkt verfügbar
 * (Status-Endpunkt nicht benötigt, da execute() synchron das Ergebnis zurückgibt)
 */

// ============================================
// 4. MONITORING & STATUS
// ============================================

/**
 * Beispiel 6: Supervisor-Status abrufen
 */
app.get('/api/example/status', async (req, res) => {
  try {
    if (!supervisor) {
      return res.status(503).json({ error: 'Supervisor nicht initialisiert' });
    }
    
    const status = await supervisor.getStatus();
    const queueStats = await supervisor.getQueueStats();
    const agents = await supervisor.getAllAgents();
    
    res.json({
      success: true,
      supervisor: {
        initialized: status.initialized,
        activeTasks: status.activeTasks,
        registeredAgents: status.registeredAgents,
        sessions: status.sessions,
      },
      queue: queueStats,
      agents: agents.map(a => ({
        id: a.id,
        name: a.name,
        type: a.type,
        status: a.status,
        primary: a.primary,
        fallback: a.fallback,
      })),
      timestamp: new Date().toISOString(),
    });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

/**
 * Beispiel 7: Task-Ergebnis abrufen
 */
app.get('/api/example/task-result/:taskId', async (req, res) => {
  try {
    if (!supervisor) {
      return res.status(503).json({ error: 'Supervisor nicht initialisiert' });
    }
    
    const taskId = req.params.taskId;
    
    // Task-Objekt abrufen
    const task = await supervisor.getTask(taskId);
    if (!task) {
      return res.status(404).json({ error: 'Task nicht gefunden' });
    }
    
    // Ergebnis abrufen
    const result = await supervisor.getTaskResult(taskId);
    
    res.json({
      taskId,
      task: {
        id: task.id,
        type: task.type,
        status: task.status,
        assignedAgent: task.assignedAgent,
        createdAt: task.createdAt,
        startedAt: task.startedAt,
        completedAt: task.completedAt,
      },
      result: result ? {
        success: result.success,
        content: result.result || result.content,
        usage: result.usage,
        duration: result.duration,
        agent: result.agent,
        provider: result.provider,
      } : null,
    });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// ============================================
// 5. VERGLEICH: NORMAL vs. ARENAPROPLUS
// ============================================

/**
 * Beispiel 8: Vergleich - Normale Agent vs. ArenaProPlus
 */
app.post('/api/example/compare', async (req, res) => {
  try {
    if (!supervisor || !arenaPro) {
      return res.status(503).json({ error: 'Supervisor oder ArenaProPlus nicht verfügbar' });
    }
    
    const question = req.body.question || 'Erkläre die Vorteile von KI-Supervisor-Systemen';
    
    // Normale Agent-Antwort
    const normalTask = await supervisor.createTask({
      type: 'research',
      content: question,
      priority: 'high',
    });
    
    // ArenaProPlus-Antwort
    const arenaTask = {
      content: `${question} - Vollständige, mehrschichtige Antwort`,
      type: 'general',
      priority: 'high'
    };
    const arenaResult = await arenaPro.execute(arenaTask);
    
    // Warte auf normale Antwort (vereinfacht - in Produktion besser mit Polling)
    await new Promise(resolve => setTimeout(resolve, 5000));
    const normalResult = await supervisor.getTaskResult(normalTask.id);
    
    res.json({
      success: true,
      comparison: {
        normal: {
          taskId: normalTask.id,
          assignedAgent: normalTask.assignedAgent,
          approach: 'Einzelner Agent',
          speed: 'Schnell (~5-10s)',
          cost: 'Niedrig',
          result: normalResult?.content?.substring(0, 200) || 'Noch in Bearbeitung',
        },
        arenaProPlus: {
          arenaId: arenaResult.arenaId,
          approach: 'Multi-Agent Kollaboration',
          speed: 'Langsamer (~30-60s)',
          cost: 'Höher',
          quality: 'Sehr hoch',
          phases: arenaResult.phases,
          duration: arenaResult.duration,
          result: arenaResult.content.substring(0, 200),
        },
      },
      tip: 'Normale Agenten für schnelle Antworten, ArenaProPlus für komplexe Aufgaben',
    });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// ============================================
// SERVER STARTEN
// ============================================

const PORT = process.env.PORT || 3000;

async function start() {
  await initializeSupervisor();
  
  app.listen(PORT, () => {
    console.log(`🚀 Beispiel-Server läuft auf Port ${PORT}`);
    console.log(`📚 Beispiele verfügbar unter: http://localhost:${PORT}/api/example/`);
    console.log(`\nVerfügbare Endpunkte:`);
    console.log(`  POST /api/example/simple-question`);
    console.log(`  POST /api/example/create-docs`);
    console.log(`  POST /api/example/task-with-session`);
    console.log(`  POST /api/example/arena-complex-analysis`);
    console.log(`  GET  /api/example/arena-status/:collaborationId`);
    console.log(`  GET  /api/example/status`);
    console.log(`  GET  /api/example/task-result/:taskId`);
    console.log(`  POST /api/example/compare`);
  });
}

// Graceful Shutdown
process.on('SIGTERM', async () => {
  console.log('🛑 Beende Server...');
  if (supervisor) {
    await supervisor.shutdown();
  }
  process.exit(0);
});

process.on('SIGINT', async () => {
  console.log('🛑 Beende Server...');
  if (supervisor) {
    await supervisor.shutdown();
  }
  process.exit(0);
});

// Start
if (require.main === module) {
  start();
}

module.exports = { app, initializeSupervisor };

