/**
 * Claude API Client
 */

const Anthropic = require('@anthropic-ai/sdk');

class ClaudeClient {
  constructor() {
    this.client = new Anthropic({
      apiKey: process.env.CLAUDE_API_KEY
    });
  }

  /**
   * Generiert Text mit Claude
   */
  async generate(prompt, options = {}) {
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

