/**
 * Session Manager - Verwaltet Sessions mit SQLite
 */

const sqlite3 = require('sqlite3').verbose();
const { promisify } = require('util');
const path = require('path');
const fs = require('fs');

class SessionManager {
  constructor(dbPath) {
    this.dbPath = dbPath;
    this.db = null;
  }

  /**
   * Initialisiert die Datenbank
   */
  async initialize() {
    console.log('📋 Initialisiere Session Manager...');

    // Erstelle Datenbank-Verzeichnis falls nicht vorhanden
    const dbDir = path.dirname(this.dbPath);
    if (!fs.existsSync(dbDir)) {
      fs.mkdirSync(dbDir, { recursive: true });
    }

    // Öffne Datenbank
    this.db = new sqlite3.Database(this.dbPath, (err) => {
      if (err) {
        console.error('❌ Fehler beim Öffnen der Datenbank:', err);
        throw err;
      }
    });

    // Promisify für async/await
    this.db.run = promisify(this.db.run.bind(this.db));
    this.db.get = promisify(this.db.get.bind(this.db));
    this.db.all = promisify(this.db.all.bind(this.db));

    // Erstelle Tabellen
    await this.createTables();

    console.log('✅ Session Manager initialisiert');
  }

  /**
   * Erstellt die Datenbank-Tabellen
   */
  async createTables() {
    await this.db.run(`
      CREATE TABLE IF NOT EXISTS sessions (
        id TEXT PRIMARY KEY,
        userId TEXT,
        metadata TEXT,
        createdAt TEXT,
        updatedAt TEXT
      )
    `);

    await this.db.run(`
      CREATE TABLE IF NOT EXISTS session_history (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        sessionId TEXT,
        action TEXT,
        data TEXT,
        timestamp TEXT,
        FOREIGN KEY (sessionId) REFERENCES sessions(id)
      )
    `);
  }

  /**
   * Erstellt eine neue Session
   */
  async createSession(userId, metadata = {}) {
    const sessionId = `session-${Date.now()}-${Math.random().toString(36).substr(2, 9)}`;
    const now = new Date().toISOString();

    await this.db.run(
      `INSERT INTO sessions (id, userId, metadata, createdAt, updatedAt) 
       VALUES (?, ?, ?, ?, ?)`,
      [sessionId, userId, JSON.stringify(metadata), now, now]
    );

    console.log(`✅ Session erstellt: ${sessionId}`);
    return await this.getSession(sessionId);
  }

  /**
   * Gibt eine Session zurück
   */
  async getSession(sessionId) {
    const session = await this.db.get(
      'SELECT * FROM sessions WHERE id = ?',
      [sessionId]
    );

    if (session) {
      session.metadata = JSON.parse(session.metadata || '{}');
    }

    return session;
  }

  /**
   * Aktualisiert eine Session
   */
  async updateSession(sessionId, updates) {
    const now = new Date().toISOString();
    const metadata = updates.metadata ? JSON.stringify(updates.metadata) : null;

    await this.db.run(
      `UPDATE sessions 
       SET updatedAt = ?, 
           ${metadata ? 'metadata = ?' : ''}
       WHERE id = ?`,
      metadata ? [now, metadata, sessionId] : [now, sessionId]
    );

    // Speichere in History
    await this.db.run(
      `INSERT INTO session_history (sessionId, action, data, timestamp) 
       VALUES (?, ?, ?, ?)`,
      [sessionId, 'update', JSON.stringify(updates), now]
    );

    return await this.getSession(sessionId);
  }

  /**
   * Gibt alle Sessions eines Users zurück
   */
  async getUserSessions(userId) {
    const sessions = await this.db.all(
      'SELECT * FROM sessions WHERE userId = ? ORDER BY updatedAt DESC',
      [userId]
    );

    return sessions.map(session => ({
      ...session,
      metadata: JSON.parse(session.metadata || '{}')
    }));
  }

  /**
   * Gibt die Anzahl der Sessions zurück
   */
  async getSessionCount() {
    const result = await this.db.get('SELECT COUNT(*) as count FROM sessions');
    return result.count;
  }

  /**
   * Schließt die Datenbank
   */
  async close() {
    if (this.db) {
      await new Promise((resolve, reject) => {
        this.db.close((err) => {
          if (err) reject(err);
          else resolve();
        });
      });
      this.db = null;
    }
  }
}

module.exports = SessionManager;

