/**
 * Tests für Supervisor System
 */

const Supervisor = require('../supervisor/src/Supervisor');

describe('Supervisor System', () => {
  let supervisor;

  beforeAll(async () => {
    supervisor = new Supervisor({
      redisUrl: process.env.REDIS_URL || 'redis://localhost:6379',
      dbPath: './data/test-sessions.db'
    });
  });

  afterAll(async () => {
    if (supervisor) {
      await supervisor.shutdown();
    }
  });

  test('Supervisor initialisiert korrekt', async () => {
    await supervisor.initialize();
    expect(supervisor.isInitialized).toBe(true);
  });

  test('Agent kann registriert werden', async () => {
    const agent = await supervisor.registerAgent({
      type: 'test-agent',
      name: 'Test Agent',
      config: {}
    });
    expect(agent).toBeDefined();
    expect(agent.id).toBeDefined();
  });

  test('Task kann zur Queue hinzugefügt werden', async () => {
    const taskId = await supervisor.addTask({
      type: 'test-task',
      data: { test: true }
    });
    expect(taskId).toBeDefined();
  });

  test('Session kann erstellt werden', async () => {
    const session = await supervisor.createSession('test-user', {
      test: true
    });
    expect(session).toBeDefined();
    expect(session.id).toBeDefined();
  });

  test('Status kann abgerufen werden', async () => {
    const status = await supervisor.getStatus();
    expect(status).toBeDefined();
    expect(status.initialized).toBe(true);
  });
});

