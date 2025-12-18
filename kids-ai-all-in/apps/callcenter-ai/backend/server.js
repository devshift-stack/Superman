import express from 'express';
import cors from 'cors';
import dotenv from 'dotenv';
import { GoogleGenerativeAI } from '@google/generative-ai';
import { v4 as uuidv4 } from 'uuid';
import rateLimit from 'express-rate-limit';
import { getSystemPrompt } from './language_prompts.js';
import { PremiumAgentFactory } from './premium_agents.js';
import { synthesizeAgentSpeech, getAgentVoiceConfig } from './tts_service.js';

dotenv.config();

const app = express();
const PORT = process.env.PORT || 3000;

// Middleware
app.use(cors());
app.use(express.json());

// Rate Limiting für API-Schutz - Erhöht für 10-20 gleichzeitige Sessions
const apiLimiter = rateLimit({
  windowMs: 1 * 60 * 1000, // 1 Minute
  max: 500, // 500 Requests pro Minute (für 10-20 Sessions)
  message: 'Zu viele Anfragen, bitte später erneut versuchen.'
});

app.use('/api/', apiLimiter);

// Gemini API Setup
const GEMINI_API_KEY = process.env.GEMINI_API_KEY || '';
if (!GEMINI_API_KEY) {
  console.error('⚠️ GEMINI_API_KEY nicht gesetzt!');
  process.exit(1);
}

const genAI = new GoogleGenerativeAI(GEMINI_API_KEY);

// Factory-Funktion für Model mit Sprache
function createModel(language = 'german') {
  return genAI.getGenerativeModel({ 
    model: 'gemini-2.5-flash', // Verfügbares Modell für diese API-Version
    generationConfig: {
      temperature: 0.8,
      topK: 40,
      topP: 0.95,
      maxOutputTokens: 512,
    },
    systemInstruction: getSystemPrompt(language),
  });
}

// Session Storage (In-Memory - für Production: Datenbank verwenden)
const sessions = new Map();

// System-Prompts sind jetzt in language_prompts.js

// API Routes

// Health Check
app.get('/api/v1/health', (req, res) => {
  res.json({ 
    status: 'ok', 
    activeSessions: sessions.size,
    timestamp: new Date().toISOString()
  });
});

// Neue Session erstellen
app.post('/api/v1/sessions', (req, res) => {
  const { language = 'german' } = req.body;
  const sessionId = uuidv4();
  const modelInstance = createModel(language);
  const chat = modelInstance.startChat();
  
  const session = {
    id: sessionId,
    chat: chat,
    language: language,
    messages: [],
    createdAt: new Date().toISOString(),
    lastActivity: new Date().toISOString(),
  };
  
  sessions.set(sessionId, session);
  
  // Begrüßung von Lisa (sprachabhängig)
  const greetings = {
    german: 'Hallo! Ich bin Lisa, Ihre Verkaufsberaterin. Schön, dass ich Sie erreiche! Wie geht es Ihnen heute? Ich rufe an, um über Solarmodule zu sprechen – haben Sie sich schon einmal Gedanken über Solarstrom gemacht?',
    bosnian: 'Zdravo! Ja sam Lisa, vaša prodajna savjetnica. Drago mi je što vas mogu kontaktirati! Kako ste danas? Zovem vas da razgovorimo o solarnim panelima – da li ste ikada razmišljali o solarnoj energiji?',
    serbian: 'Zdravo! Ja sam Lisa, vaša prodajna savetnica. Drago mi je što vas mogu kontaktirati! Kako ste danas? Zovem vas da razgovorimo o solarnim panelima – da li ste ikada razmišljali o solarnoj energiji?',
  };
  
  const greeting = greetings[language] || greetings.german;
  
  session.messages.push({
    role: 'assistant',
    text: greeting,
    timestamp: new Date().toISOString(),
  });
  
  res.json({
    sessionId: sessionId,
    greeting: greeting,
    language: language,
    createdAt: session.createdAt,
  });
});

// Nachricht an Session senden
app.post('/api/v1/sessions/:sessionId/chat', async (req, res) => {
  const { sessionId } = req.params;
  const { message } = req.body;
  
  if (!message || typeof message !== 'string') {
    return res.status(400).json({ error: 'Message ist erforderlich' });
  }
  
  const session = sessions.get(sessionId);
  if (!session) {
    return res.status(404).json({ error: 'Session nicht gefunden' });
  }
  
  try {
    // User-Nachricht speichern
    session.messages.push({
      role: 'user',
      text: message,
      timestamp: new Date().toISOString(),
    });
    
    // Gemini API aufrufen
    const result = await session.chat.sendMessage(message);
    const response = result.response.text();
    
    // Assistant-Antwort speichern
    session.messages.push({
      role: 'assistant',
      text: response,
      timestamp: new Date().toISOString(),
    });
    
    session.lastActivity = new Date().toISOString();
    
    res.json({
      sessionId: sessionId,
      response: response,
      timestamp: new Date().toISOString(),
    });
  } catch (error) {
    console.error('Gemini API Error:', error);
    
    let errorMessage = 'Entschuldigung, es ist ein Fehler aufgetreten. Können Sie Ihre Frage bitte wiederholen?';
    
    if (error.message?.includes('quota') || error.message?.includes('429')) {
      errorMessage = 'Entschuldigung, ich habe momentan zu viele Anfragen. Bitte versuchen Sie es in ein paar Minuten erneut.';
    }
    
    res.status(500).json({
      error: errorMessage,
      sessionId: sessionId,
    });
  }
});

// Session-Status abrufen
app.get('/api/v1/sessions/:sessionId', (req, res) => {
  const { sessionId } = req.params;
  const session = sessions.get(sessionId);
  
  if (!session) {
    return res.status(404).json({ error: 'Session nicht gefunden' });
  }
  
  res.json({
    sessionId: session.id,
    messageCount: session.messages.length,
    createdAt: session.createdAt,
    lastActivity: session.lastActivity,
    messages: session.messages,
  });
});

// Session beenden
app.delete('/api/v1/sessions/:sessionId', (req, res) => {
  const { sessionId } = req.params;
  const deleted = sessions.delete(sessionId);
  
  if (!deleted) {
    return res.status(404).json({ error: 'Session nicht gefunden' });
  }
  
  res.json({ 
    success: true,
    message: 'Session beendet'
  });
});

// Alle aktiven Sessions (Admin)
app.get('/api/v1/sessions', (req, res) => {
  const sessionList = Array.from(sessions.values()).map(session => ({
    sessionId: session.id,
    language: session.language || 'german',
    messageCount: session.messages.length,
    createdAt: session.createdAt,
    lastActivity: session.lastActivity,
  }));
  
  res.json({
    total: sessionList.length,
    sessions: sessionList,
  });
});

// Premium Agent Session erstellen (10-20 gleichzeitig)
app.post('/api/v1/premium/sessions', (req, res) => {
  const { 
    productCategory = 'solar', // solar, strom, handy
    language = 'german' 
  } = req.body;
  
  // Prüfe ob Maximum erreicht (20 Sessions)
  if (sessions.size >= 20) {
    return res.status(429).json({ 
      error: 'Maximum von 20 gleichzeitigen Sessions erreicht',
      activeSessions: sessions.size
    });
  }
  
  const sessionId = uuidv4();
  
  try {
    // Erstelle Premium Agent
    let agent;
    if (productCategory === 'solar') {
      agent = PremiumAgentFactory.createSolarAgent(language);
    } else if (productCategory === 'strom') {
      agent = PremiumAgentFactory.createStromAgent(language);
    } else if (productCategory === 'handy') {
      agent = PremiumAgentFactory.createHandyAgent(language);
    } else {
      return res.status(400).json({ error: `Unbekannte Produktkategorie: ${productCategory}` });
    }
    
    const chat = agent.startChat();
    
    const session = {
      id: sessionId,
      agent: agent,
      chat: chat,
      productCategory: productCategory,
      language: language,
      agentName: agent.name,
      messages: [],
      createdAt: new Date().toISOString(),
      lastActivity: new Date().toISOString(),
    };
    
    sessions.set(sessionId, session);
    
    // Natürliche Begrüßung basierend auf Produkt
    const greeting = getPremiumGreeting(productCategory, language, agent.name);
    
    session.messages.push({
      role: 'assistant',
      text: greeting,
      timestamp: new Date().toISOString(),
    });
    
    res.json({
      sessionId: sessionId,
      greeting: greeting,
      productCategory: productCategory,
      language: language,
      agentName: agent.name,
      createdAt: session.createdAt,
      activeSessions: sessions.size,
    });
  } catch (error) {
    console.error('Premium Agent Error:', error);
    res.status(500).json({ error: 'Fehler beim Erstellen des Premium Agents' });
  }
});

// Premium Agent Begrüßungen (natürlich, nicht perfekt)
function getPremiumGreeting(productCategory, language, agentName) {
  const greetings = {
    solar: {
      german: [
        `Hallo! Ähm, ich bin ${agentName} von der Solarberatung. Schön, dass ich Sie erreiche! Wie geht's Ihnen denn heute?`,
        `Hallo! Ich bin ${agentName}. Also, ich rufe an, weil wir gerade super Angebote für Solarmodule haben. Haben Sie sich schon mal Gedanken über Solar gemacht?`,
        `Hi! Ich bin ${agentName}. Schön, dass ich Sie erreiche! Ich rufe wegen Solarmodulen an – haben Sie sich da schon mal informiert?`
      ]
    },
    strom: {
      german: [
        `Hallo! Ich bin ${agentName} vom Stromanbieter. Ich rufe an, weil wir gerade echt gute Tarife haben. Wie hoch sind denn aktuell Ihre Stromkosten?`,
        `Hallo! ${agentName} hier. Also, wir haben gerade super Angebote für Stromverträge. Haben Sie schon mal über einen Wechsel nachgedacht?`,
        `Hi! Ich bin ${agentName}. Ich rufe an, weil wir Ihnen bei den Stromkosten helfen können. Wie viel zahlen Sie denn aktuell?`
      ]
    },
    handy: {
      german: [
        `Hallo! Ich bin ${agentName} von der Handyberatung. Schön, dass ich Sie erreiche! Welches Gerät nutzen Sie denn aktuell?`,
        `Hallo! ${agentName} hier. Also, wir haben gerade echt gute Angebote für Handyverträge. Sind Sie zufrieden mit Ihrem aktuellen?`,
        `Hi! Ich bin ${agentName}. Ich rufe an, weil wir super Handyverträge haben. Welches Gerät haben Sie denn gerade?`
      ]
    }
  };
  
  const categoryGreetings = greetings[productCategory]?.[language] || greetings.solar.german;
  return categoryGreetings[Math.floor(Math.random() * categoryGreetings.length)];
}

// Premium Agent Chat
app.post('/api/v1/premium/sessions/:sessionId/chat', async (req, res) => {
  const { sessionId } = req.params;
  const { message } = req.body;
  
  if (!message || typeof message !== 'string') {
    return res.status(400).json({ error: 'Message ist erforderlich' });
  }
  
  const session = sessions.get(sessionId);
  if (!session) {
    return res.status(404).json({ error: 'Session nicht gefunden' });
  }
  
  if (!session.agent) {
    return res.status(400).json({ error: 'Keine Premium Agent Session' });
  }
  
  try {
    // User-Nachricht speichern
    session.messages.push({
      role: 'user',
      text: message,
      timestamp: new Date().toISOString(),
    });
    
    // Premium Agent verwenden
    const response = await session.agent.sendMessage(message);
    
    // Assistant-Antwort speichern
    session.messages.push({
      role: 'assistant',
      text: response,
      timestamp: new Date().toISOString(),
    });
    
    session.lastActivity = new Date().toISOString();
    
    // TTS generieren (optional)
    let audioContent = null;
    try {
      const ttsResult = await synthesizeAgentSpeech(
        response,
        session.agentName,
        session.productCategory
      );
      if (ttsResult) {
        audioContent = ttsResult.audioContent.toString('base64');
      }
    } catch (error) {
      console.warn('TTS generation failed:', error.message);
    }

    res.json({
      sessionId: sessionId,
      response: response,
      agentName: session.agentName,
      productCategory: session.productCategory,
      timestamp: new Date().toISOString(),
      audioContent: audioContent, // Base64 encoded MP3
      voiceConfig: getAgentVoiceConfig(session.agentName, session.productCategory)
    });
  } catch (error) {
    console.error('Premium Agent Error:', error);
    
    let errorMessage = 'Entschuldigung, ähm, ich hab Sie nicht ganz verstanden. Können Sie das nochmal sagen?';
    let statusCode = 500;
    
    // API-Key Fehler
    if (error.message?.includes('API key not valid') || error.message?.includes('API_KEY_INVALID')) {
      errorMessage = 'Entschuldigung, ich habe gerade technische Probleme. Bitte versuchen Sie es später erneut.';
      console.error('❌ GEMINI_API_KEY ist ungültig oder fehlt!');
      statusCode = 503; // Service Unavailable
    }
    // Quota/Rate Limit Fehler
    else if (error.message?.includes('quota') || error.message?.includes('429')) {
      errorMessage = 'Oh, tut mir leid, ich habe gerade technische Probleme. Können Sie es in ein paar Minuten nochmal versuchen?';
      statusCode = 429;
    }
    
    res.status(statusCode).json({
      error: errorMessage,
      sessionId: sessionId,
    });
  }
});

// Monitoring & Statistiken
app.get('/api/v1/stats', (req, res) => {
  const now = new Date();
  const todayStart = new Date(now.getFullYear(), now.getMonth(), now.getDate());
  
  let totalMessages = 0;
  let messagesToday = 0;
  const languageStats = {};
  const productStats = {};
  
  for (const session of sessions.values()) {
    totalMessages += session.messages.length;
    
    const sessionMessages = session.messages.filter(msg => {
      const msgDate = new Date(msg.timestamp);
      return msgDate >= todayStart;
    });
    messagesToday += sessionMessages.length;
    
    const lang = session.language || 'german';
    languageStats[lang] = (languageStats[lang] || 0) + 1;
    
    const product = session.productCategory || 'solar';
    productStats[product] = (productStats[product] || 0) + 1;
  }
  
  res.json({
    activeSessions: sessions.size,
    maxSessions: 20,
    totalMessages: totalMessages,
    messagesToday: messagesToday,
    languageDistribution: languageStats,
    productDistribution: productStats,
    timestamp: now.toISOString(),
  });
});

// Server starten
app.listen(PORT, () => {
  console.log(`🚀 Callcenter AI Backend läuft auf Port ${PORT}`);
  console.log(`📊 Health Check: http://localhost:${PORT}/api/v1/health`);
  console.log(`🔑 Gemini API Key: ${GEMINI_API_KEY.substring(0, 10)}...`);
});

// Cleanup: Alte Sessions nach 1 Stunde Inaktivität löschen
setInterval(() => {
  const oneHourAgo = new Date(Date.now() - 60 * 60 * 1000);
  
  for (const [sessionId, session] of sessions.entries()) {
    if (new Date(session.lastActivity) < oneHourAgo) {
      sessions.delete(sessionId);
      console.log(`🧹 Session ${sessionId} gelöscht (inaktiv)`);
    }
  }
}, 5 * 60 * 1000); // Alle 5 Minuten prüfen

