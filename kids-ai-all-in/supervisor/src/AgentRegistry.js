/**
 * Agent Registry - Verwaltet alle registrierten Agenten
 */

class AgentRegistry {
  constructor() {
    this.agents = new Map();
    this.agentTypes = new Map();
  }

  /**
   * Initialisiert die Registry
   */
  async initialize() {
    console.log('📋 Initialisiere Agent Registry...');
    // Hier können Standard-Agenten registriert werden
    this.registerAgentType('ui-agent', {
      name: 'UI Agent',
      description: 'Generiert UI-Komponenten mit Shadcn UI',
      capabilities: ['generate-ui', 'create-components']
    });

    this.registerAgentType('doc-agent', {
      name: 'Documentation Agent',
      description: 'Erstellt technische Dokumentation',
      capabilities: ['write-docs', 'api-docs', 'code-docs']
    });

    this.registerAgentType('user-guide-agent', {
      name: 'User Guide Agent',
      description: 'Erstellt einfache Benutzeranleitungen',
      capabilities: ['create-guides', 'visual-guides']
    });

    this.registerAgentType('coach-agent', {
      name: 'Coach Agent',
      description: 'Interaktive Hilfe und Unterstützung',
      capabilities: ['help', 'guide', 'answer-questions']
    });
  }

  /**
   * Registriert einen Agent-Typ
   */
  registerAgentType(type, config) {
    this.agentTypes.set(type, config);
    console.log(`✅ Agent-Typ registriert: ${type}`);
  }

  /**
   * Registriert einen neuen Agent
   */
  async register(agentConfig) {
    const agentId = agentConfig.id || `agent-${Date.now()}-${Math.random().toString(36).substr(2, 9)}`;
    
    const agent = {
      id: agentId,
      type: agentConfig.type,
      name: agentConfig.name || agentConfig.type,
      config: agentConfig.config || {},
      status: 'active',
      registeredAt: new Date().toISOString(),
      ...agentConfig
    };

    this.agents.set(agentId, agent);
    console.log(`✅ Agent registriert: ${agentId} (${agent.type})`);
    
    return agent;
  }

  /**
   * Gibt einen Agent zurück
   */
  getAgent(agentId) {
    return this.agents.get(agentId);
  }

  /**
   * Gibt alle Agenten eines Typs zurück
   */
  getAgentsByType(type) {
    return Array.from(this.agents.values()).filter(agent => agent.type === type);
  }

  /**
   * Gibt alle registrierten Agenten zurück
   */
  getAllAgents() {
    return Array.from(this.agents.values());
  }

  /**
   * Gibt die Anzahl der registrierten Agenten zurück
   */
  getAgentCount() {
    return this.agents.size;
  }

  /**
   * Entfernt einen Agent
   */
  async unregister(agentId) {
    const agent = this.agents.get(agentId);
    if (agent) {
      this.agents.delete(agentId);
      console.log(`🗑️ Agent entfernt: ${agentId}`);
      return true;
    }
    return false;
  }
}

module.exports = AgentRegistry;

