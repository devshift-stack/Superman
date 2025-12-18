/**
 * Task Queue - Verwaltet Tasks mit BullMQ
 */

const { Queue, Worker } = require('bullmq');
const Redis = require('ioredis');

class TaskQueue {
  constructor(redisUrl) {
    this.redisUrl = redisUrl;
    this.redis = null;
    this.queue = null;
    this.worker = null;
  }

  /**
   * Initialisiert die Task Queue
   */
  async initialize() {
    console.log('📋 Initialisiere Task Queue...');

    // Redis Connection
    this.redis = new Redis(this.redisUrl, {
      maxRetriesPerRequest: null,
      enableReadyCheck: false
    });

    // BullMQ Queue
    this.queue = new Queue('supervisor-tasks', {
      connection: this.redis
    });

    console.log('✅ Task Queue initialisiert');
  }

  /**
   * Startet den Worker
   */
  async startWorker(handler) {
    if (this.worker) {
      return;
    }

    this.worker = new Worker(
      'supervisor-tasks',
      async (job) => {
        console.log(`🔄 Verarbeite Job: ${job.id} - ${job.data.type}`);
        return await handler(job.data);
      },
      {
        connection: this.redis,
        concurrency: 5 // Max 5 gleichzeitige Tasks
      }
    );

    this.worker.on('completed', (job) => {
      console.log(`✅ Job abgeschlossen: ${job.id}`);
    });

    this.worker.on('failed', (job, err) => {
      console.error(`❌ Job fehlgeschlagen: ${job.id}`, err);
    });

    console.log('✅ Task Queue Worker gestartet');
  }

  /**
   * Fügt eine Task zur Queue hinzu
   */
  async add(task) {
    const job = await this.queue.add('task', {
      id: task.id || `task-${Date.now()}-${Math.random().toString(36).substr(2, 9)}`,
      type: task.type,
      data: task.data || {},
      sessionId: task.sessionId,
      priority: task.priority || 0,
      createdAt: new Date().toISOString()
    });

    return job.id;
  }

  /**
   * Gibt den Status der Queue zurück
   */
  async getStatus() {
    const waiting = await this.queue.getWaitingCount();
    const active = await this.queue.getActiveCount();
    const completed = await this.queue.getCompletedCount();
    const failed = await this.queue.getFailedCount();

    return {
      waiting,
      active,
      completed,
      failed,
      total: waiting + active + completed + failed
    };
  }

  /**
   * Beendet die Task Queue
   */
  async shutdown() {
    if (this.worker) {
      await this.worker.close();
      this.worker = null;
    }
    if (this.queue) {
      await this.queue.close();
      this.queue = null;
    }
    if (this.redis) {
      await this.redis.quit();
      this.redis = null;
    }
    console.log('✅ Task Queue beendet');
  }
}

module.exports = TaskQueue;

