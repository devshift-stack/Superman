/**
 * Grok API Client (xAI)
 */

const axios = require('axios');

class GrokClient {
  constructor() {
    this.apiKey = process.env.GROK_API_KEY;
    this.baseURL = 'https://api.x.ai/v1';
  }

  /**
   * Generiert Text mit Grok
   */
  async generate(prompt, options = {}) {
    try {
      const response = await axios.post(
        `${this.baseURL}/chat/completions`,
        {
          model: options.model || 'grok-beta',
          messages: [
            { role: 'system', content: options.systemPrompt || 'Du bist ein hilfreicher Assistent mit Internet-Zugang.' },
            { role: 'user', content: prompt }
          ],
          temperature: options.temperature || 0.7,
          max_tokens: options.maxTokens || 2000
        },
        {
          headers: {
            'Authorization': `Bearer ${this.apiKey}`,
            'Content-Type': 'application/json'
          }
        }
      );

      return response.data.choices[0].message.content;
    } catch (error) {
      console.error('❌ Grok API Fehler:', error.response?.data || error.message);
      throw error;
    }
  }

  /**
   * Recherche mit Internet-Zugang
   */
  async research(query) {
    const prompt = `Recherchiere im Internet: ${query}`;
    return await this.generate(prompt, {
      systemPrompt: 'Du bist ein Recherche-Assistent mit Zugang zum Internet. Recherchiere gründlich und gib präzise Informationen.'
    });
  }
}

module.exports = GrokClient;

