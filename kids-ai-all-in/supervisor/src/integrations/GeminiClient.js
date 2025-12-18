/**
 * Gemini API Client
 */

const { GoogleGenerativeAI } = require('@google/generative-ai');

class GeminiClient {
  constructor() {
    const apiKey = process.env.GEMINI_API_KEY;
    if (!apiKey) {
      console.warn('⚠️ GEMINI_API_KEY nicht gesetzt');
    }
    this.genAI = apiKey ? new GoogleGenerativeAI(apiKey) : null;
  }

  /**
   * Generiert Text mit Gemini
   */
  async generate(prompt, options = {}) {
    if (!this.genAI) {
      throw new Error('Gemini API Key nicht gesetzt');
    }

    try {
      const model = this.genAI.getGenerativeModel({
        model: options.model || 'gemini-pro'
      });

      const result = await model.generateContent(prompt);
      const response = await result.response;
      
      return response.text();
    } catch (error) {
      console.error('❌ Gemini API Fehler:', error);
      throw error;
    }
  }
}

module.exports = GeminiClient;

