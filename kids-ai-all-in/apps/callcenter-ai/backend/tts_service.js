/**
 * TTS Service für Premium Sales Agents
 * Google Cloud TTS Neural2 Integration
 */

import { TextToSpeechClient } from '@google-cloud/text-to-speech';
import dotenv from 'dotenv';
import fs from 'fs';
import path from 'path';
import { fileURLToPath } from 'url';

dotenv.config();

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

// Google Cloud TTS Client
let ttsClient = null;

// Voice Config laden
const voiceConfig = JSON.parse(
  fs.readFileSync(path.join(__dirname, 'voice_config.json'), 'utf-8')
);

// TTS Client initialisieren
function getTTSClient() {
  if (!ttsClient) {
    const credentials = process.env.GOOGLE_CLOUD_CREDENTIALS;
    if (credentials) {
      ttsClient = new TextToSpeechClient({
        credentials: JSON.parse(credentials)
      });
    } else if (process.env.GOOGLE_APPLICATION_CREDENTIALS) {
      ttsClient = new TextToSpeechClient();
    } else {
      console.warn('⚠️ Google Cloud TTS Credentials nicht gesetzt - TTS deaktiviert');
      return null;
    }
  }
  return ttsClient;
}

/**
 * Synthesisiert Speech mit Agent-Konfiguration
 */
export async function synthesizeAgentSpeech(text, agentName, productCategory) {
  const client = getTTSClient();
  if (!client) {
    return null; // TTS nicht verfügbar
  }

  // Agent-Konfiguration laden
  const agentConfig = voiceConfig.agents[productCategory]?.[agentName];
  if (!agentConfig) {
    console.warn(`⚠️ Keine Voice-Config für ${agentName} (${productCategory})`);
    return null;
  }

  // SSML für natürliche Pausen
  const ssmlText = addNaturalPauses(text, agentConfig.pauses);

  const request = {
    input: { 
      ssml: ssmlText 
    },
    voice: {
      languageCode: voiceConfig.defaults.languageCode,
      name: agentConfig.voice,
      ssmlGender: agentConfig.gender,
    },
    audioConfig: {
      audioEncoding: voiceConfig.defaults.audioEncoding,
      speakingRate: agentConfig.speakingRate,
      pitch: agentConfig.pitch,
      volumeGainDb: agentConfig.volumeGainDb,
      sampleRateHertz: voiceConfig.defaults.sampleRateHertz,
      enableTimePointing: voiceConfig.defaults.enableTimePointing,
    },
  };

  try {
    const [response] = await client.synthesizeSpeech(request);
    return {
      audioContent: response.audioContent,
      audioConfig: request.audioConfig,
      timepoints: response.timepoints || []
    };
  } catch (error) {
    console.error('TTS Error:', error);
    return null;
  }
}

/**
 * Fügt natürliche Pausen zu Text hinzu
 */
function addNaturalPauses(text, pauseConfig) {
  // Ersetze Satzzeichen mit SSML Pausen
  let ssml = text
    .replace(/\. /g, `.<break time="${pauseConfig.medium}s"/> `)
    .replace(/, /g, `,<break time="${pauseConfig.short}s"/> `)
    .replace(/\? /g, `?<break time="${pauseConfig.long}s"/> `)
    .replace(/! /g, `!<break time="${pauseConfig.medium}s"/> `)
    .replace(/\.\.\./g, `<break time="${pauseConfig.long}s"/>`)
    .replace(/Ähm/g, `Ähm<break time="0.2s"/>`)
    .replace(/Also/g, `Also<break time="0.15s"/>`)
    .replace(/Hmm/g, `Hmm<break time="0.3s"/>`);

  return `<speak>${ssml}</speak>`;
}

/**
 * Passt Voice basierend auf Emotion an
 */
export function adjustVoiceForEmotion(agentConfig, emotion) {
  const emotionConfig = voiceConfig.emotions[emotion] || voiceConfig.emotions.professional;
  
  return {
    ...agentConfig,
    speakingRate: Math.max(0.25, Math.min(4.0, agentConfig.speakingRate + emotionConfig.speakingRate)),
    pitch: Math.max(-20.0, Math.min(20.0, agentConfig.pitch + emotionConfig.pitch)),
    volumeGainDb: Math.max(-96.0, Math.min(16.0, agentConfig.volumeGainDb + emotionConfig.volumeGainDb)),
    pauses: {
      short: agentConfig.pauses.short * emotionConfig.pauseMultiplier,
      medium: agentConfig.pauses.medium * emotionConfig.pauseMultiplier,
      long: agentConfig.pauses.long * emotionConfig.pauseMultiplier
    }
  };
}

/**
 * Holt Agent Voice-Konfiguration
 */
export function getAgentVoiceConfig(agentName, productCategory) {
  return voiceConfig.agents[productCategory]?.[agentName] || null;
}

/**
 * Liste aller verfügbaren Stimmen
 */
export function getAvailableVoices() {
  return {
    solar: Object.keys(voiceConfig.agents.solar || {}),
    strom: Object.keys(voiceConfig.agents.strom || {}),
    handy: Object.keys(voiceConfig.agents.handy || {})
  };
}

export { voiceConfig };

