/**
 * Pinecone Knowledge Base Service
 * Verwaltet Beta/Final System für verifizierte vs. unverifizierte Informationen
 */

const { Pinecone } = require('@pinecone-database/pinecone');
const { v4: uuidv4 } = require('uuid');

class PineconeService {
  constructor() {
    this.apiKey = process.env.PINECONE_API_KEY;
    this.indexName = process.env.PINECONE_INDEX_NAME || 'knowledge-base';
    this.client = null;
    this.index = null;
    this.isInitialized = false;
  }

  /**
   * Initialisiert Pinecone Connection
   */
  async initialize() {
    if (this.isInitialized) {
      return;
    }

    if (!this.apiKey) {
      throw new Error('PINECONE_API_KEY ist nicht gesetzt');
    }

    try {
      this.client = new Pinecone({
        apiKey: this.apiKey,
      });

      // Prüfe ob Index existiert, erstelle falls nicht
      const indexList = await this.client.listIndexes();
      const indexExists = indexList.indexes?.some(idx => idx.name === this.indexName);

      if (!indexExists) {
        console.log(`📦 Erstelle Pinecone Index: ${this.indexName}`);
        await this.client.createIndex({
          name: this.indexName,
          dimension: 1536, // OpenAI ada-002 embedding dimension
          metric: 'cosine',
          spec: {
            serverless: {
              cloud: 'aws',
              region: 'us-east-1',
            },
          },
        });
        // Warte bis Index bereit ist
        await this.waitForIndex();
      }

      this.index = this.client.index(this.indexName);
      this.isInitialized = true;
      console.log(`✅ Pinecone Service initialisiert: ${this.indexName}`);
    } catch (error) {
      console.error('❌ Fehler beim Initialisieren von Pinecone:', error);
      throw error;
    }
  }

  /**
   * Wartet bis Index bereit ist
   */
  async waitForIndex(maxWait = 60000) {
    const startTime = Date.now();
    while (Date.now() - startTime < maxWait) {
      const indexList = await this.client.listIndexes();
      const index = indexList.indexes?.find(idx => idx.name === this.indexName);
      if (index && index.status?.ready) {
        return;
      }
      await new Promise(resolve => setTimeout(resolve, 2000));
    }
    throw new Error('Index wurde nicht rechtzeitig bereit');
  }

  /**
   * Speichert Information in Knowledge Base
   * @param {string} text - Der Text der gespeichert werden soll
   * @param {object} metadata - Zusätzliche Metadaten
   * @param {string} status - "beta" oder "final"
   * @param {Array<number>} embedding - Optional: Vorgefertigtes Embedding
   */
  async store(text, metadata = {}, status = 'beta', embedding = null) {
    if (!this.isInitialized) {
      await this.initialize();
    }

    try {
      const id = uuidv4();
      const vector = embedding || await this.createEmbedding(text);

      const record = {
        id,
        values: vector,
        metadata: {
          text,
          status, // "beta" oder "final"
          createdAt: new Date().toISOString(),
          ...metadata,
        },
      };

      await this.index.upsert([record]);
      console.log(`💾 Gespeichert in Knowledge Base (${status}): ${id.substring(0, 8)}...`);
      return id;
    } catch (error) {
      console.error('❌ Fehler beim Speichern in Knowledge Base:', error);
      throw error;
    }
  }

  /**
   * Sucht in Knowledge Base
   * @param {string} query - Suchtext
   * @param {object} options - Suchoptionen
   * @returns {Array} Suchergebnisse
   */
  async search(query, options = {}) {
    if (!this.isInitialized) {
      await this.initialize();
    }

    const {
      topK = 5,
      status = null, // null = beide, "final" = nur final, "beta" = nur beta
      minScore = 0.7,
      includeMetadata = true,
    } = options;

    try {
      const queryEmbedding = await this.createEmbedding(query);

      const filter = status ? { status: { $eq: status } } : undefined;

      const results = await this.index.query({
        vector: queryEmbedding,
        topK,
        includeMetadata,
        filter,
      });

      // Filtere nach minScore und formatiere Ergebnisse
      const matches = results.matches
        .filter(match => match.score >= minScore)
        .map(match => ({
          id: match.id,
          score: match.score,
          text: match.metadata?.text || '',
          status: match.metadata?.status || 'beta',
          metadata: match.metadata || {},
        }));

      return matches;
    } catch (error) {
      console.error('❌ Fehler bei Knowledge Base Suche:', error);
      throw error;
    }
  }

  /**
   * Sucht primär in Final, falls nichts gefunden in Beta (mit Warnung)
   */
  async searchWithFallback(query, options = {}) {
    // Zuerst in Final suchen
    const finalResults = await this.search(query, { ...options, status: 'final' });

    if (finalResults.length > 0) {
      return {
        results: finalResults,
        source: 'final',
        warning: null,
      };
    }

    // Falls nichts in Final, suche in Beta
    const betaResults = await this.search(query, { ...options, status: 'beta' });

    return {
      results: betaResults,
      source: 'beta',
      warning: betaResults.length > 0
        ? '⚠️ Diese Informationen sind noch nicht verifiziert (Beta-Status)'
        : null,
    };
  }

  /**
   * Verschiebt Information von Beta zu Final (nach Verifizierung)
   */
  async verify(id) {
    if (!this.isInitialized) {
      await this.initialize();
    }

    try {
      // Hole aktuellen Record
      const fetchResult = await this.index.fetch([id]);
      const record = fetchResult.records[id];

      if (!record) {
        throw new Error(`Record ${id} nicht gefunden`);
      }

      // Update Status zu "final"
      await this.index.update({
        id,
        metadata: {
          ...record.metadata,
          status: 'final',
          verifiedAt: new Date().toISOString(),
        },
      });

      console.log(`✅ Verifiziert: ${id.substring(0, 8)}... (Beta → Final)`);
      return true;
    } catch (error) {
      console.error('❌ Fehler beim Verifizieren:', error);
      throw error;
    }
  }

  /**
   * Löscht Information aus Knowledge Base
   */
  async delete(id) {
    if (!this.isInitialized) {
      await this.initialize();
    }

    try {
      await this.index.delete1([id]);
      console.log(`🗑️ Gelöscht: ${id.substring(0, 8)}...`);
      return true;
    } catch (error) {
      console.error('❌ Fehler beim Löschen:', error);
      throw error;
    }
  }

  /**
   * Erstellt Embedding für Text (nutzt OpenAI)
   */
  async createEmbedding(text) {
    const OpenAIClient = require('../integrations/OpenAIClient');
    const openaiClient = new OpenAIClient();
    return await openaiClient.createEmbedding(text);
  }

  /**
   * Gibt Statistiken zurück
   */
  async getStats() {
    if (!this.isInitialized) {
      await this.initialize();
    }

    try {
      // Hole alle Records (mit Limit für Stats)
      const stats = {
        total: 0,
        beta: 0,
        final: 0,
      };

      // Pinecone hat keine direkte count API, daher approximativ
      // In Production würde man hier einen separaten Counter nutzen
      const sample = await this.index.query({
        vector: new Array(1536).fill(0), // Dummy vector
        topK: 1000,
        includeMetadata: true,
      });

      sample.matches.forEach(match => {
        stats.total++;
        if (match.metadata?.status === 'final') {
          stats.final++;
        } else {
          stats.beta++;
        }
      });

      return stats;
    } catch (error) {
      console.error('❌ Fehler beim Abrufen der Stats:', error);
      return { total: 0, beta: 0, final: 0 };
    }
  }
}

module.exports = PineconeService;

