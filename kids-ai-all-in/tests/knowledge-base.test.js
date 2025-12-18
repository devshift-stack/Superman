/**
 * Tests für Knowledge Base System
 */

const BetaFinalSystem = require('../supervisor/src/knowledge-base/BetaFinalSystem');

describe('Knowledge Base System', () => {
  let kb;

  beforeAll(async () => {
    kb = new BetaFinalSystem();
    // Nur initialisieren wenn API-Keys vorhanden
    if (process.env.PINECONE_API_KEY) {
      await kb.initialize();
    }
  });

  test('Knowledge Base kann initialisiert werden', async () => {
    if (process.env.PINECONE_API_KEY) {
      expect(kb.isInitialized).toBe(true);
    } else {
      console.log('⚠️ PINECONE_API_KEY nicht gesetzt, überspringe Test');
    }
  });

  test('Recherche kann in Beta gespeichert werden', async () => {
    if (process.env.PINECONE_API_KEY && process.env.OPENAI_API_KEY) {
      const id = await kb.storeResearch(
        'Test Information',
        'test-source',
        { test: true }
      );
      expect(id).toBeDefined();
    } else {
      console.log('⚠️ API-Keys nicht gesetzt, überspringe Test');
    }
  });

  test('Statistiken können abgerufen werden', async () => {
    if (process.env.PINECONE_API_KEY) {
      const stats = await kb.getStats();
      expect(stats).toBeDefined();
      expect(stats.total).toBeGreaterThanOrEqual(0);
    } else {
      console.log('⚠️ PINECONE_API_KEY nicht gesetzt, überspringe Test');
    }
  });
});

