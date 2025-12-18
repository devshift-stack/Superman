/**
 * Agent Coordinator - Koordiniert Tasks mit passenden Agenten
 */

const OpenAIClient = require('./integrations/OpenAIClient');
const ClaudeClient = require('./integrations/ClaudeClient');
const GrokClient = require('./integrations/GrokClient');
const GeminiClient = require('./integrations/GeminiClient');

class AgentCoordinator {
  constructor(supervisor) {
    this.supervisor = supervisor;
    this.apiClients = {
      openai: new OpenAIClient(),
      claude: new ClaudeClient(),
      grok: new GrokClient(),
      gemini: new GeminiClient()
    };
  }

  /**
   * Koordiniert eine Task mit dem passenden Agent
   */
  async coordinateTask(task) {
    console.log(`🎯 Koordiniere Task: ${task.type}`);

    // Bestimme passenden Agent basierend auf Task-Typ
    const agent = this.selectAgent(task);

    if (!agent) {
      throw new Error(`Kein passender Agent für Task-Typ: ${task.type}`);
    }

    // Führe Task aus
    return await this.executeTask(agent, task);
  }

  /**
   * Wählt den passenden Agent für eine Task
   */
  selectAgent(task) {
    const agents = this.supervisor.agentRegistry.getAllAgents();

    // Suche nach passendem Agent basierend auf Task-Typ
    for (const agent of agents) {
      if (this.canHandleTask(agent, task)) {
        return agent;
      }
    }

    // Fallback: Verwende Standard-Agent basierend auf Task-Typ
    return this.getDefaultAgent(task.type);
  }

  /**
   * Prüft ob ein Agent eine Task bearbeiten kann
   */
  canHandleTask(agent, task) {
    const agentType = this.supervisor.agentRegistry.agentTypes.get(agent.type);
    if (!agentType) return false;

    return agentType.capabilities && agentType.capabilities.includes(task.type);
  }

  /**
   * Gibt Standard-Agent für Task-Typ zurück
   */
  getDefaultAgent(taskType) {
    // Mapping von Task-Typen zu Agent-Typen
    const taskTypeMapping = {
      'generate-ui': 'ui-agent',
      'write-docs': 'doc-agent',
      'create-guides': 'user-guide-agent',
      'help': 'coach-agent',
      'answer-question': 'coach-agent'
    };

    const agentType = taskTypeMapping[taskType] || 'coach-agent';
    return {
      type: agentType,
      name: agentType
    };
  }

  /**
   * Führt eine Task mit einem Agent aus
   */
  async executeTask(agent, task) {
    console.log(`🤖 Führe Task aus mit Agent: ${agent.type}`);

    // Bestimme API-Client basierend auf Agent-Konfiguration
    const apiClient = this.getApiClient(agent);

    // Führe Task aus
    switch (task.type) {
      case 'generate-ui':
        return await this.handleUIGeneration(apiClient, task);
      case 'write-docs':
        return await this.handleDocGeneration(apiClient, task);
      case 'create-guides':
        return await this.handleGuideCreation(apiClient, task);
      case 'help':
      case 'answer-question':
        return await this.handleHelp(apiClient, task);
      default:
        return await this.handleGenericTask(apiClient, task);
    }
  }

  /**
   * Gibt passenden API-Client zurück
   */
  getApiClient(agent) {
    // Standard: Claude für komplexe Tasks
    const defaultClient = this.apiClients.claude;

    // Agent-spezifische API-Auswahl
    if (agent.config && agent.config.apiClient) {
      return this.apiClients[agent.config.apiClient] || defaultClient;
    }

    return defaultClient;
  }

  /**
   * Behandelt UI-Generierung
   */
  async handleUIGeneration(apiClient, task) {
    // TODO: Implementiere UI-Generierung mit Shadcn UI
    return {
      success: true,
      message: 'UI-Generierung wird implementiert',
      task: task.type
    };
  }

  /**
   * Behandelt Dokumentations-Generierung
   */
  async handleDocGeneration(apiClient, task) {
    const prompt = `Erstelle professionelle technische Dokumentation für: ${task.data.topic || 'unbekannt'}`;
    const response = await apiClient.generate(prompt);
    
    return {
      success: true,
      documentation: response,
      task: task.type
    };
  }

  /**
   * Behandelt Guide-Erstellung
   */
  async handleGuideCreation(apiClient, task) {
    const prompt = `Erstelle eine einfache, visuelle Benutzeranleitung für: ${task.data.topic || 'unbekannt'}`;
    const response = await apiClient.generate(prompt);
    
    return {
      success: true,
      guide: response,
      task: task.type
    };
  }

  /**
   * Behandelt Hilfe-Anfragen
   */
  async handleHelp(apiClient, task) {
    const prompt = task.data.question || task.data.message || 'Wie kann ich helfen?';
    const response = await apiClient.generate(prompt);
    
    return {
      success: true,
      answer: response,
      task: task.type
    };
  }

  /**
   * Behandelt generische Tasks
   */
  async handleGenericTask(apiClient, task) {
    const prompt = task.data.prompt || JSON.stringify(task.data);
    const response = await apiClient.generate(prompt);
    
    return {
      success: true,
      result: response,
      task: task.type
    };
  }
}

module.exports = AgentCoordinator;

