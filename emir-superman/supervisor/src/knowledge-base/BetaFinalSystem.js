/**
 * Beta/Final System für Knowledge Base
 * Verwaltet Verifizierungs-Workflow
 */

const PineconeService = require('./PineconeService');

class BetaFinalSystem {
  constructor() {
    this.pinecone = new PineconeService();
    this.isInitialized = false;
  }

  /**
   * Initialisiert das System
   */
  async initialize() {
    if (this.isInitialized) {
      return;
    }

    await this.pinecone.initialize();
    this.isInitialized = this.pinecone.isInitialized;
    if (this.isInitialized) {
      console.log('✅ Beta/Final System initialisiert');
    } else {
      console.warn('⚠️ Beta/Final System deaktiviert (Pinecone nicht konfiguriert)');
    }
  }

  /**
   * Speichert Recherche-Ergebnis in Beta
   */
  async storeResearch(text, source, metadata = {}) {
    await this.initialize();

    return await this.pinecone.store(text, {
      source,
      type: 'research',
      ...metadata,
    }, 'beta');
  }

  /**
   * Verifiziert Information (Beta → Final)
   */
  async verify(id, verificationNotes = '') {
    await this.initialize();

    // Hole aktuellen Record
    const fetchResult = await this.pinecone.client.index(this.pinecone.indexName).fetch([id]);
    const record = fetchResult.records[id];

    if (!record) {
      throw new Error(`Record ${id} nicht gefunden`);
    }

    if (record.metadata?.status === 'final') {
      console.log(`ℹ️ Record ${id.substring(0, 8)}... ist bereits verifiziert`);
      return false;
    }

    // Verifiziere
    await this.pinecone.verify(id);

    // Füge Verifizierungs-Notizen hinzu
    await this.pinecone.client.index(this.pinecone.indexName).update({
      id,
      metadata: {
        ...record.metadata,
        verificationNotes,
        verifiedAt: new Date().toISOString(),
      },
    });

    return true;
  }

  /**
   * Sucht Information (primär Final, Fallback Beta)
   */
  async search(query, options = {}) {
    await this.initialize();
    return await this.pinecone.searchWithFallback(query, options);
  }

  /**
   * Batch-Verifizierung mehrerer Records
   */
  async verifyBatch(ids, verificationNotes = '') {
    await this.initialize();

    const results = [];
    for (const id of ids) {
      try {
        const verified = await this.verify(id, verificationNotes);
        results.push({ id, verified, error: null });
      } catch (error) {
        results.push({ id, verified: false, error: error.message });
      }
    }

    return results;
  }

  /**
   * Gibt alle Beta-Records zurück (für Verifizierungs-Queue)
   */
  async getBetaRecords(limit = 100) {
    await this.initialize();

    // Suche mit Dummy-Query, filtere nach Beta
    const results = await this.pinecone.search('', {
      topK: limit,
      status: 'beta',
      minScore: 0, // Niedrige Schwelle für alle Beta-Records
    });

    return results;
  }

  /**
   * Gibt Statistiken zurück
   */
  async getStats() {
    await this.initialize();
    return await this.pinecone.getStats();
  }
}

module.exports = BetaFinalSystem;

