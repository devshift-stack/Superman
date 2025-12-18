/**
 * OpenAI API Client
 */

const OpenAI = require('openai');

class OpenAIClient {
  constructor() {
    this.client = new OpenAI({
      apiKey: process.env.OPENAI_API_KEY
    });
  }

  /**
   * Generiert Text mit GPT-4
   */
  async generate(prompt, options = {}) {
    try {
      const response = await this.client.chat.completions.create({
        model: options.model || 'gpt-4',
        messages: [
          { role: 'system', content: options.systemPrompt || 'Du bist ein hilfreicher Assistent.' },
          { role: 'user', content: prompt }
        ],
        temperature: options.temperature || 0.7,
        max_tokens: options.maxTokens || 2000
      });

      return response.choices[0].message.content;
    } catch (error) {
      console.error('❌ OpenAI API Fehler:', error);
      throw error;
    }
  }

  /**
   * Erstellt Embeddings
   */
  async createEmbedding(text) {
    try {
      const response = await this.client.embeddings.create({
        model: 'text-embedding-3-small',
        input: text
      });

      return response.data[0].embedding;
    } catch (error) {
      console.error('❌ OpenAI Embedding Fehler:', error);
      throw error;
    }
  }
}

module.exports = OpenAIClient;

