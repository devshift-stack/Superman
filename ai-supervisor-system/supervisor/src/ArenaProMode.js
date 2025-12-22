/**
 * Arena Pro+ Modus
 * Kollaborative Agent-Arbeit: Aufgaben werden in Teilaufgaben aufgeteilt,
 * Modelle arbeiten als Team zusammen und kombinieren die besten Teile
 */

const OpenAIClient = require('./integrations/OpenAIClient');
const ClaudeClient = require('./integrations/ClaudeClient');
const GrokClient = require('./integrations/GrokClient');
const GeminiClient = require('./integrations/GeminiClient');

class ArenaProMode {
  constructor(supervisor) {
    this.supervisor = supervisor;
    this.apiClients = {
      openai: new OpenAIClient(),
      claude: new ClaudeClient(),
      grok: new GrokClient(),
      gemini: new GeminiClient()
    };
    this.activeCollaborations = new Map(); // taskId -> collaboration data
  }

  /**
   * Startet Arena Pro+ Modus für eine Task
   * @param {object} task - Die Haupt-Task
   * @returns {Promise<object>} Kollaboratives Ergebnis
   */
  async startCollaboration(task) {
    const collaborationId = `collab-${Date.now()}-${Math.random().toString(36).substr(2, 9)}`;
    
    console.log(`🚀 Arena Pro+ gestartet: ${collaborationId}`);
    
    // 1. Task in Teilaufgaben aufteilen
    const subtasks = await this.breakDownTask(task);
    
    // 2. Agenten-Team zusammenstellen
    const team = this.selectTeam(task.type, subtasks.length);
    
    // 3. Kollaboration initialisieren
    this.activeCollaborations.set(collaborationId, {
      id: collaborationId,
      mainTask: task,
      subtasks,
      team,
      results: {},
      status: 'in_progress',
      createdAt: new Date().toISOString()
    });
    
    // 4. Parallele Bearbeitung der Teilaufgaben
    const subtaskResults = await this.processSubtasksInParallel(collaborationId, subtasks, team);
    
    // 5. Agenten diskutieren und kombinieren
    const discussion = await this.facilitateDiscussion(collaborationId, subtaskResults, team);
    
    // 6. Beste Teile kombinieren
    const finalResult = await this.combineBestParts(collaborationId, subtaskResults, discussion);
    
    // 7. Finale Optimierung
    const optimizedResult = await this.optimizeResult(collaborationId, finalResult, team);
    
    // 8. Kollaboration abschließen
    const collaboration = this.activeCollaborations.get(collaborationId);
    collaboration.status = 'completed';
    collaboration.finalResult = optimizedResult;
    collaboration.completedAt = new Date().toISOString();
    
    console.log(`✅ Arena Pro+ abgeschlossen: ${collaborationId}`);
    
    return {
      collaborationId,
      result: optimizedResult,
      process: {
        subtasks,
        team,
        discussion,
        combination: finalResult
      }
    };
  }

  /**
   * Teilt eine Task in Teilaufgaben auf
   */
  async breakDownTask(task) {
    const prompt = `Du bist ein Task-Analyst. Teile diese Aufgabe in logische Teilaufgaben auf:

Aufgabe: ${task.type}
Daten: ${JSON.stringify(task.data, null, 2)}

Erstelle 3-5 Teilaufgaben, die:
1. Logisch aufeinander aufbauen
2. Unabhängig bearbeitet werden können
3. Zusammen das beste Ergebnis ergeben

Antworte NUR mit einem JSON-Array:
[
  {"id": "subtask-1", "title": "Titel", "description": "Beschreibung", "focus": "Fokus"},
  ...
]`;

    // Nutze Claude für intelligente Aufteilung
    const response = await this.apiClients.claude.generate(prompt, {
      systemPrompt: 'Du bist ein Experte für Task-Analyse und Projektplanung. Antworte nur mit gültigem JSON.',
      maxTokens: 2000
    });

    try {
      // Extrahiere JSON aus Antwort
      const jsonMatch = response.match(/\[[\s\S]*\]/);
      if (jsonMatch) {
        return JSON.parse(jsonMatch[0]);
      }
    } catch (e) {
      console.warn('⚠️ JSON-Parsing fehlgeschlagen, verwende Standard-Aufteilung');
    }

    // Fallback: Standard-Aufteilung
    return [
      { id: 'subtask-1', title: 'Analyse & Recherche', description: 'Grundlagen recherchieren', focus: 'research' },
      { id: 'subtask-2', title: 'Struktur & Planung', description: 'Struktur entwickeln', focus: 'structure' },
      { id: 'subtask-3', title: 'Umsetzung', description: 'Hauptinhalt erstellen', focus: 'implementation' },
      { id: 'subtask-4', title: 'Optimierung', description: 'Feinschliff & Verbesserungen', focus: 'optimization' }
    ];
  }

  /**
   * Wählt ein Team von Agenten basierend auf Task-Typ
   */
  selectTeam(taskType, subtaskCount) {
    // Standard-Team: Claude (Struktur), OpenAI (Kreativität), Grok (Recherche)
    const team = [
      { model: 'claude', role: 'Struktur & Planung', strength: 'logical-thinking' },
      { model: 'openai', role: 'Kreativität & Innovation', strength: 'creativity' },
      { model: 'grok', role: 'Recherche & Fakten', strength: 'research' }
    ];

    // Gemini als Backup/Alternative
    if (subtaskCount > 3) {
      team.push({ model: 'gemini', role: 'Alternative Perspektive', strength: 'diversity' });
    }

    return team;
  }

  /**
   * Bearbeitet Teilaufgaben parallel mit verschiedenen Agenten
   */
  async processSubtasksInParallel(collaborationId, subtasks, team) {
    console.log(`🔄 Bearbeite ${subtasks.length} Teilaufgaben parallel...`);

    const results = {};
    const promises = subtasks.map(async (subtask, index) => {
      const agent = team[index % team.length];
      const client = this.apiClients[agent.model];

      const prompt = this.getSubtaskPrompt(subtask, agent);
      
      try {
        const result = await client.generate(prompt, {
          systemPrompt: this.getAgentSystemPrompt(agent, subtask),
          maxTokens: 3000
        });

        results[subtask.id] = {
          subtask,
          agent: agent.model,
          result,
          quality: 'pending', // Wird später bewertet
          timestamp: new Date().toISOString()
        };

        // Emit Chat-Nachricht
        this.emitChatMessage(collaborationId, {
          type: 'subtask_completed',
          agent: agent.model,
          subtask: subtask.title,
          message: `✅ Teilaufgabe "${subtask.title}" abgeschlossen`
        });

        return results[subtask.id];
      } catch (error) {
        console.error(`❌ Fehler bei Teilaufgabe ${subtask.id}:`, error);
        results[subtask.id] = {
          subtask,
          agent: agent.model,
          error: error.message,
          timestamp: new Date().toISOString()
        };
        return results[subtask.id];
      }
    });

    await Promise.all(promises);
    return results;
  }

  /**
   * Erstellt Prompt für Teilaufgabe
   */
  getSubtaskPrompt(subtask, agent) {
    return `Du arbeitest als Teil eines Teams an dieser Teilaufgabe:

**Teilaufgabe:** ${subtask.title}
**Beschreibung:** ${subtask.description}
**Fokus:** ${subtask.focus}

**Deine Rolle:** ${agent.role}
**Deine Stärke:** ${agent.strength}

Erstelle eine qualitativ hochwertige Lösung für diese Teilaufgabe.
Denke daran, dass dein Ergebnis später mit anderen Teammitgliedern kombiniert wird.
`;
  }

  /**
   * System-Prompt für Agenten
   */
  getAgentSystemPrompt(agent, subtask) {
    const prompts = {
      claude: `Du bist Claude, ein Experte für logisches Denken und Struktur. Du arbeitest in einem Team und erstellst präzise, gut strukturierte Lösungen. Du denkst analytisch und sorgfältig.`,
      openai: `Du bist GPT-4, ein kreativer Innovator. Du bringst neue Ideen und innovative Ansätze ein. Du denkst außerhalb der Box und findest kreative Lösungen.`,
      grok: `Du bist Grok, ein Recherche-Experte mit Internet-Zugang. Du lieferst aktuelle, faktenbasierte Informationen und recherchierst gründlich.`,
      gemini: `Du bist Gemini, ein vielseitiger Denker. Du bringst alternative Perspektiven und vielfältige Ansätze ein. Du siehst Dinge aus verschiedenen Blickwinkeln.`
    };

    return prompts[agent.model] || 'Du bist ein hilfreicher Assistent.';
  }

  /**
   * Erleichtert Diskussion zwischen Agenten
   */
  async facilitateDiscussion(collaborationId, subtaskResults, team) {
    console.log(`💬 Starte Team-Diskussion...`);

    const resultsSummary = Object.values(subtaskResults).map(r => ({
      subtask: r.subtask.title,
      agent: r.agent,
      result: r.result?.substring(0, 500) || 'Fehler',
      quality: r.quality
    }));

    const discussionPrompt = `Du moderierst eine Team-Diskussion. Hier sind die Ergebnisse der Teammitglieder:

${JSON.stringify(resultsSummary, null, 2)}

**Aufgabe:** Lass die Agenten diskutieren:
1. Was sind die Stärken jedes Ergebnisses?
2. Was kann verbessert werden?
3. Wie können die besten Teile kombiniert werden?
4. Welche Synergien gibt es?

Erstelle eine strukturierte Diskussion mit konkreten Vorschlägen zur Kombination.`;

    const discussion = await this.apiClients.claude.generate(discussionPrompt, {
      systemPrompt: 'Du bist ein erfahrener Moderator für Team-Kollaborationen. Du hilfst Teams, die besten Ideen zu kombinieren.',
      maxTokens: 2000
    });

    // Emit Chat-Nachricht
    this.emitChatMessage(collaborationId, {
      type: 'discussion',
      message: '💬 Team-Diskussion abgeschlossen',
      discussion: discussion.substring(0, 200) + '...'
    });

    return discussion;
  }

  /**
   * Kombiniert die besten Teile aller Ergebnisse
   */
  async combineBestParts(collaborationId, subtaskResults, discussion) {
    console.log(`🔗 Kombiniere beste Teile...`);

    const combinationPrompt = `Kombiniere die besten Teile aller Teammitglieder-Ergebnisse:

**Teilergebnisse:**
${Object.values(subtaskResults).map(r => `
**${r.subtask.title}** (von ${r.agent}):
${r.result?.substring(0, 1000) || 'Fehler'}
`).join('\n---\n')}

**Diskussion:**
${discussion}

**Aufgabe:** Erstelle ein kombiniertes Ergebnis, das:
1. Die besten Teile jedes Ergebnisses nutzt
2. Synergien zwischen den Ergebnissen schafft
3. Konsistent und hochwertig ist
4. Besser ist als jedes einzelne Ergebnis

Erstelle das finale, kombinierte Ergebnis.`;

    const combined = await this.apiClients.claude.generate(combinationPrompt, {
      systemPrompt: 'Du bist ein Experte für die Kombination von Ideen. Du erstellst bessere Ergebnisse durch intelligente Kombination.',
      maxTokens: 4000
    });

    // Emit Chat-Nachricht
    this.emitChatMessage(collaborationId, {
      type: 'combination',
      message: '🔗 Beste Teile kombiniert',
      preview: combined.substring(0, 200) + '...'
    });

    return combined;
  }

  /**
   * Optimiert das finale Ergebnis
   */
  async optimizeResult(collaborationId, result, team) {
    console.log(`✨ Optimiere Ergebnis...`);

    const optimizationPrompt = `Optimiere dieses Ergebnis durch Team-Feedback:

**Aktuelles Ergebnis:**
${result.substring(0, 3000)}

**Team-Perspektiven:**
- Claude (Struktur): Prüfe auf Logik und Konsistenz
- OpenAI (Kreativität): Prüfe auf Innovation und Einzigartigkeit
- Grok (Fakten): Prüfe auf Aktualität und Richtigkeit

**Aufgabe:** Optimiere das Ergebnis basierend auf allen Perspektiven.
Erstelle die finale, optimierte Version.`;

    const optimized = await this.apiClients.claude.generate(optimizationPrompt, {
      systemPrompt: 'Du bist ein Qualitätsexperte. Du optimierst Ergebnisse durch Multi-Perspektiven-Analyse.',
      maxTokens: 4000
    });

    // Emit Chat-Nachricht
    this.emitChatMessage(collaborationId, {
      type: 'optimization',
      message: '✨ Finale Optimierung abgeschlossen',
      preview: optimized.substring(0, 200) + '...'
    });

    return {
      result: optimized,
      quality: 'optimized',
      collaborationId,
      team: team.map(a => a.model),
      timestamp: new Date().toISOString()
    };
  }

  /**
   * Sendet Chat-Nachricht (wird von WebSocket verwendet)
   */
  emitChatMessage(collaborationId, message) {
    // Wird von WebSocket-Server verwendet
    if (this.supervisor.io) {
      this.supervisor.io.emit('chat', {
        collaborationId,
        ...message,
        timestamp: new Date().toISOString()
      });
    }
  }

  /**
   * Gibt Status einer Kollaboration zurück
   */
  getCollaborationStatus(collaborationId) {
    return this.activeCollaborations.get(collaborationId) || null;
  }
}

module.exports = ArenaProMode;

