/**
 * Gemini API Client
 */

const { GoogleGenerativeAI } = require('@google/generative-ai');

class GeminiClient {
  constructor() {
    this.apiKey = process.env.GEMINI_API_KEY;
    this.genAI = null;
    this.isConfigured = !!this.apiKey;
    
    if (this.isConfigured) {
      try {
        this.genAI = new GoogleGenerativeAI(this.apiKey);
      } catch (error) {
        console.warn('⚠️ Gemini Client konnte nicht initialisiert werden:', error.message);
        this.isConfigured = false;
      }
    } else {
      console.warn('⚠️ GEMINI_API_KEY nicht gesetzt - Gemini Client deaktiviert');
    }
  }

  /**
   * Generiert Text mit Gemini
   */
  async generate(prompt, options = {}) {
    if (!this.isConfigured || !this.genAI) {
      throw new Error('Gemini API nicht konfiguriert. Bitte GEMINI_API_KEY setzen.');
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

