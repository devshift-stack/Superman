/**
 * Claude API Client
 */

const Anthropic = require('@anthropic-ai/sdk');

class ClaudeClient {
  constructor() {
    this.apiKey = process.env.CLAUDE_API_KEY;
    this.client = null;
    this.isConfigured = !!this.apiKey;
    
    if (this.isConfigured) {
      try {
        this.client = new Anthropic({ apiKey: this.apiKey });
      } catch (error) {
        console.warn('⚠️ Claude Client konnte nicht initialisiert werden:', error.message);
        this.isConfigured = false;
      }
    } else {
      console.warn('⚠️ CLAUDE_API_KEY nicht gesetzt - Claude Client deaktiviert');
    }
  }

  /**
   * Generiert Text mit Claude
   */
  async generate(prompt, options = {}) {
    if (!this.isConfigured || !this.client) {
      throw new Error('Claude API nicht konfiguriert. Bitte CLAUDE_API_KEY setzen.');
    }
    
    try {
      const response = await this.client.messages.create({
        model: options.model || 'claude-3-5-sonnet-20241022',
        max_tokens: options.maxTokens || 2000,
        temperature: options.temperature || 0.7,
        system: options.systemPrompt || 'Du bist ein hilfreicher Assistent.',
        messages: [
          { role: 'user', content: prompt }
        ]
      });

      return response.content[0].text;
    } catch (error) {
      console.error('❌ Claude API Fehler:', error);
      throw error;
    }
  }
}

module.exports = ClaudeClient;

