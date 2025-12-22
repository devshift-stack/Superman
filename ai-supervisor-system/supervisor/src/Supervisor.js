/**
 * AI Supervisor - Haupt-Koordinations-System
 * Koordiniert alle AI-Agenten und verwaltet Tasks
 */

const AgentRegistry = require('./AgentRegistry');
const TaskQueue = require('./TaskQueue');
const SessionManager = require('./SessionManager');
const AgentCoordinator = require('./AgentCoordinator');
const BetaFinalSystem = require('./knowledge-base/BetaFinalSystem');

class Supervisor {
  constructor(config = {}) {
    this.config = {
      redisUrl: config.redisUrl || process.env.REDIS_URL || 'redis://localhost:6379',
      dbPath: config.dbPath || process.env.DB_PATH || './data/sessions.db',
      ...config
    };

    // Core Components
    this.agentRegistry = new AgentRegistry();
    this.taskQueue = new TaskQueue(this.config.redisUrl);
    this.sessionManager = new SessionManager(this.config.dbPath);
    this.coordinator = new AgentCoordinator(this);
    this.knowledgeBase = new BetaFinalSystem();

    // State
    this.isInitialized = false;
    this.activeTasks = new Map();
  }

  /**
   * Initialisiert den Supervisor
   */
  async initialize() {
    if (this.isInitialized) {
      return;
    }

    try {
      console.log('🚀 Initialisiere Supervisor...');

      // Initialisiere alle Komponenten
      await this.sessionManager.initialize();
      await this.taskQueue.initialize();
      await this.agentRegistry.initialize();
      await this.knowledgeBase.initialize();

      // Starte Task-Queue Worker
      await this.taskQueue.startWorker(this.handleTask.bind(this));

      this.isInitialized = true;
      console.log('✅ Supervisor initialisiert');
    } catch (error) {
      console.error('❌ Fehler beim Initialisieren des Supervisors:', error);
      throw error;
    }
  }

  /**
   * Registriert einen neuen Agent
   */
  async registerAgent(agentConfig) {
    return await this.agentRegistry.register(agentConfig);
  }

  /**
   * Fügt eine neue Task zur Queue hinzu
   */
  async addTask(task) {
    const taskId = await this.taskQueue.add(task);
    this.activeTasks.set(taskId, task);
    return taskId;
  }

  /**
   * Behandelt eine Task (wird vom Task-Queue Worker aufgerufen)
   */
  async handleTask(task) {
    try {
      console.log(`📋 Bearbeite Task: ${task.id} - ${task.type}`);

      // Koordiniere Task mit passendem Agent
      const result = await this.coordinator.coordinateTask(task);

      // Speichere Ergebnis in Session
      if (task.sessionId) {
        await this.sessionManager.updateSession(task.sessionId, {
          lastTask: task.id,
          lastResult: result,
          updatedAt: new Date().toISOString()
        });
      }

      return result;
    } catch (error) {
      console.error(`❌ Fehler bei Task ${task.id}:`, error);
      throw error;
    }
  }

  /**
   * Erstellt oder lädt eine Session
   */
  async getSession(sessionId) {
    return await this.sessionManager.getSession(sessionId);
  }

  /**
   * Erstellt eine neue Session
   */
  async createSession(userId, metadata = {}) {
    return await this.sessionManager.createSession(userId, metadata);
  }

  /**
   * Sucht in Knowledge Base
   */
  async searchKnowledge(query, options = {}) {
    return await this.knowledgeBase.search(query, options);
  }

  /**
   * Speichert Recherche in Knowledge Base (Beta)
   */
  async storeResearch(text, source, metadata = {}) {
    return await this.knowledgeBase.storeResearch(text, source, metadata);
  }

  /**
   * Verifiziert Information (Beta → Final)
   */
  async verifyKnowledge(id, notes = '') {
    return await this.knowledgeBase.verify(id, notes);
  }

  /**
   * Gibt Status des Supervisors zurück
   */
  async getStatus() {
    const kbStats = await this.knowledgeBase.getStats();
    return {
      initialized: this.isInitialized,
      activeTasks: this.activeTasks.size,
      registeredAgents: this.agentRegistry.getAgentCount(),
      queueStatus: await this.taskQueue.getStatus(),
      sessions: await this.sessionManager.getSessionCount(),
      knowledgeBase: kbStats
    };
  }

  /**
   * Beendet den Supervisor
   */
  async shutdown() {
    console.log('🛑 Beende Supervisor...');
    await this.taskQueue.shutdown();
    await this.sessionManager.close();
    this.isInitialized = false;
    console.log('✅ Supervisor beendet');
  }
}

module.exports = Supervisor;

