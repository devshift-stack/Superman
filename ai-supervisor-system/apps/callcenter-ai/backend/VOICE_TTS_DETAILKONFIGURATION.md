# 🎤 Voice & TTS - Detaillierte Konfiguration

## 📋 Übersicht

Detaillierte Konfiguration für Text-to-Speech (TTS) Systeme für Premium Sales Agents.
Alle Parameter für Stimmen, Geschwindigkeit, Tonhöhe, Emotionen, etc.

---

## 🎭 Agent-Stimmen Konfiguration

### Solar-Agenten (weiblich)

| Agent-Name | Stimme | Geschwindigkeit | Tonhöhe | Emotion | Pausen |
|------------|--------|-----------------|---------|---------|--------|
| **Lisa** | de-DE-Neural2-C | 1.0x (normal) | +0.2 (etwas höher) | Warm, freundlich | 0.3s |
| **Sarah** | de-DE-Neural2-D | 0.95x (etwas langsamer) | +0.1 | Empathisch | 0.4s |
| **Anna** | de-DE-Neural2-E | 1.05x (etwas schneller) | +0.15 | Begeistert | 0.25s |
| **Julia** | de-DE-Neural2-F | 1.0x | +0.1 | Professionell | 0.35s |
| **Maria** | de-DE-Neural2-A | 0.98x | +0.2 | Herzlich | 0.3s |
| **Sophie** | de-DE-Neural2-B | 1.02x | +0.12 | Freundlich | 0.28s |
| **Emma** | de-DE-Neural2-C | 0.97x | +0.18 | Warm | 0.32s |
| **Laura** | de-DE-Neural2-D | 1.0x | +0.15 | Empathisch | 0.3s |

### Strom-Agenten (männlich)

| Agent-Name | Stimme | Geschwindigkeit | Tonhöhe | Emotion | Pausen |
|------------|--------|-----------------|---------|---------|--------|
| **Max** | de-DE-Neural2-A | 1.0x | -0.1 (etwas tiefer) | Kompetent | 0.3s |
| **Thomas** | de-DE-Neural2-B | 0.96x | -0.15 | Professionell | 0.35s |
| **Michael** | de-DE-Neural2-C | 1.03x | -0.08 | Freundlich | 0.28s |
| **David** | de-DE-Neural2-D | 0.99x | -0.12 | Beratend | 0.32s |
| **Daniel** | de-DE-Neural2-E | 1.01x | -0.1 | Kompetent | 0.3s |
| **Stefan** | de-DE-Neural2-F | 0.97x | -0.13 | Professionell | 0.33s |
| **Markus** | de-DE-Neural2-A | 1.0x | -0.11 | Freundlich | 0.3s |
| **Christian** | de-DE-Neural2-B | 0.98x | -0.14 | Beratend | 0.31s |

### Handy-Agenten (weiblich)

| Agent-Name | Stimme | Geschwindigkeit | Tonhöhe | Emotion | Pausen |
|------------|--------|-----------------|---------|---------|--------|
| **Nicole** | de-DE-Neural2-C | 1.05x (schneller) | +0.2 | Technisch begeistert | 0.25s |
| **Jennifer** | de-DE-Neural2-D | 1.0x | +0.15 | Freundlich | 0.3s |
| **Melanie** | de-DE-Neural2-E | 0.98x | +0.18 | Kompetent | 0.32s |
| **Stephanie** | de-DE-Neural2-F | 1.02x | +0.16 | Begeistert | 0.28s |
| **Nadine** | de-DE-Neural2-A | 0.99x | +0.19 | Freundlich | 0.3s |
| **Jessica** | de-DE-Neural2-B | 1.03x | +0.17 | Technisch | 0.27s |
| **Vanessa** | de-DE-Neural2-C | 1.0x | +0.2 | Warm | 0.3s |
| **Kathrin** | de-DE-Neural2-D | 0.97x | +0.15 | Professionell | 0.31s |

---

## ⚙️ Detaillierte TTS-Parameter

### Google Cloud TTS Neural2 (Premium)

```javascript
{
  // Stimme
  voice: {
    languageCode: 'de-DE',
    name: 'de-DE-Neural2-C', // Variiert je nach Agent
    ssmlGender: 'FEMALE' | 'MALE',
  },
  
  // Audio-Konfiguration
  audioConfig: {
    audioEncoding: 'MP3', // Oder 'OGG_OPUS' für bessere Qualität
    speakingRate: 1.0,    // 0.25 - 4.0 (1.0 = normal)
    pitch: 0.0,           // -20.0 bis +20.0 Semitöne
    volumeGainDb: 0.0,    // -96.0 bis +16.0 dB
    sampleRateHertz: 24000, // 16000, 22050, 24000, 32000, 44100, 48000
  },
  
  // SSML für natürlichere Sprache
  enableTimePointing: true, // Für Pausen-Markierungen
}
```

### Geschwindigkeit (Speaking Rate)

| Wert | Beschreibung | Verwendung |
|------|--------------|------------|
| **0.85x** | Sehr langsam | Für wichtige Informationen, ältere Kunden |
| **0.90x** | Langsam | Für komplexe Themen |
| **0.95x** | Etwas langsam | Standard für empathische Gespräche |
| **1.0x** | Normal | Standard-Geschwindigkeit |
| **1.05x** | Etwas schnell | Für begeisterte Agenten |
| **1.10x** | Schnell | Für technische Themen (Handy) |
| **1.15x** | Sehr schnell | Nicht empfohlen (unverständlich) |

**Empfehlung:** 0.95x - 1.05x für natürliche Gespräche

### Tonhöhe (Pitch)

| Wert | Beschreibung | Verwendung |
|------|--------------|------------|
| **-0.2** | Sehr tief | Männliche Stimmen, autoritär |
| **-0.1** | Tief | Männliche Stimmen, Standard |
| **0.0** | Normal | Standard |
| **+0.1** | Etwas höher | Weibliche Stimmen, Standard |
| **+0.2** | Höher | Weibliche Stimmen, freundlich |
| **+0.3** | Sehr hoch | Nicht empfohlen (unnatürlich) |

**Empfehlung:** 
- Männlich: -0.1 bis -0.15
- Weiblich: +0.1 bis +0.2

### Lautstärke (Volume Gain)

| Wert | Beschreibung | Verwendung |
|------|--------------|------------|
| **-3.0 dB** | Leiser | Für ruhige, vertrauensvolle Gespräche |
| **0.0 dB** | Normal | Standard |
| **+2.0 dB** | Lauter | Für begeisterte Gespräche |
| **+4.0 dB** | Sehr laut | Nicht empfohlen (unangenehm) |

**Empfehlung:** 0.0 dB (Standard)

### Pausen (Natural Pauses)

| Pausen-Typ | Dauer | Verwendung |
|------------|-------|------------|
| **Kurze Pause** | 0.2-0.3s | Nach Kommas, natürliche Atempausen |
| **Mittlere Pause** | 0.4-0.6s | Nach Sätzen, für Betonung |
| **Lange Pause** | 0.8-1.2s | Für wichtige Informationen, nach Fragen |
| **Emotionale Pause** | 0.5-0.8s | Bei emotionalen Momenten |

**SSML für Pausen:**
```xml
<break time="0.3s"/>  <!-- Kurze Pause -->
<break time="0.5s"/>  <!-- Mittlere Pause -->
<break time="1.0s"/>  <!-- Lange Pause -->
```

---

## 🎯 Produktspezifische Konfiguration

### Solar-Agenten

**Stimme:** Warm, empathisch, vertrauenswürdig
- **Geschwindigkeit:** 0.95x - 1.0x (etwas langsamer für Vertrauen)
- **Tonhöhe:** +0.1 bis +0.2 (freundlich, weiblich)
- **Pausen:** 0.3-0.4s (für wichtige Informationen)
- **Emotion:** Warm, verständnisvoll, nicht aufdringlich

**Beispiel-Konfiguration (Lisa):**
```javascript
{
  voice: 'de-DE-Neural2-C',
  speakingRate: 0.98,
  pitch: +0.2,
  volumeGainDb: 0.0,
  pauses: {
    short: 0.3,
    medium: 0.5,
    long: 0.8
  }
}
```

### Strom-Agenten

**Stimme:** Kompetent, professionell, beratend
- **Geschwindigkeit:** 0.96x - 1.0x (professionell)
- **Tonhöhe:** -0.1 bis -0.15 (männlich, autoritär)
- **Pausen:** 0.3-0.35s (für Zahlen, Fakten)
- **Emotion:** Kompetent, hilfsbereit, sachlich

**Beispiel-Konfiguration (Max):**
```javascript
{
  voice: 'de-DE-Neural2-A',
  speakingRate: 1.0,
  pitch: -0.1,
  volumeGainDb: 0.0,
  pauses: {
    short: 0.3,
    medium: 0.4,
    long: 0.7
  }
}
```

### Handy-Agenten

**Stimme:** Technisch kompetent, begeistert, modern
- **Geschwindigkeit:** 1.0x - 1.05x (etwas schneller, modern)
- **Tonhöhe:** +0.15 bis +0.2 (weiblich, begeistert)
- **Pausen:** 0.25-0.3s (kürzer, dynamischer)
- **Emotion:** Technisch begeistert, hilfsbereit, modern

**Beispiel-Konfiguration (Nicole):**
```javascript
{
  voice: 'de-DE-Neural2-C',
  speakingRate: 1.05,
  pitch: +0.2,
  volumeGainDb: +1.0, // Etwas lauter für Begeisterung
  pauses: {
    short: 0.25,
    medium: 0.35,
    long: 0.6
  }
}
```

---

## 🎨 Emotionale Variationen

### Freude/Begeisterung
- **Geschwindigkeit:** +0.05x (etwas schneller)
- **Tonhöhe:** +0.1 (etwas höher)
- **Lautstärke:** +1.0 dB
- **Pausen:** Kürzer (0.2-0.3s)

### Empathie/Verständnis
- **Geschwindigkeit:** -0.05x (etwas langsamer)
- **Tonhöhe:** Standard
- **Lautstärke:** -1.0 dB (etwas leiser)
- **Pausen:** Länger (0.4-0.6s)

### Kompetenz/Professionell
- **Geschwindigkeit:** Standard (1.0x)
- **Tonhöhe:** Standard
- **Lautstärke:** Standard
- **Pausen:** Standard (0.3-0.4s)

### Vertrauen/Vertraulich
- **Geschwindigkeit:** -0.03x (etwas langsamer)
- **Tonhöhe:** Standard
- **Lautstärke:** -2.0 dB (leiser, vertraulich)
- **Pausen:** Länger (0.5-0.7s)

---

## 🔧 Technische Implementierung

### Google Cloud TTS Integration

```javascript
import { TextToSpeechClient } from '@google-cloud/text-to-speech';

const client = new TextToSpeechClient();

async function synthesizeSpeech(text, agentConfig) {
  const request = {
    input: { text: text },
    voice: {
      languageCode: 'de-DE',
      name: agentConfig.voice,
      ssmlGender: agentConfig.gender,
    },
    audioConfig: {
      audioEncoding: 'MP3',
      speakingRate: agentConfig.speakingRate,
      pitch: agentConfig.pitch,
      volumeGainDb: agentConfig.volumeGainDb,
      sampleRateHertz: 24000,
    },
  };

  const [response] = await client.synthesizeSpeech(request);
  return response.audioContent;
}
```

### SSML für natürliche Sprache

```xml
<speak>
  Hallo! 
  <break time="0.3s"/>
  Ähm, ich bin ${agentName} von der Solarberatung.
  <break time="0.4s"/>
  Schön, dass ich Sie erreiche!
  <prosody rate="0.98" pitch="+0.2st">
    Wie geht's Ihnen denn heute?
  </prosody>
</speak>
```

**SSML Tags:**
- `<break time="0.3s"/>` - Pause
- `<prosody rate="0.98" pitch="+0.2st">` - Geschwindigkeit & Tonhöhe
- `<emphasis level="moderate">` - Betonung
- `<say-as interpret-as="telephone">` - Telefonnummern

---

## 📊 Performance-Optimierungen

### Caching
- **Stimmen-Cache:** Häufige Phrasen cachen
- **Audio-Cache:** Generierte Audio-Dateien cachen
- **TTL:** 24 Stunden für Standard-Phrasen

### Latenz
- **Ziel:** < 500ms für TTS-Generierung
- **Optimierung:** Streaming für lange Texte
- **Fallback:** Lokale TTS wenn API langsam

### Qualität
- **Sample Rate:** 24000 Hz (Balance Qualität/Größe)
- **Encoding:** MP3 (komprimiert) oder OGG_OPUS (besser)
- **Bitrate:** 64 kbps (MP3) oder 48 kbps (OGG)

---

## 🎯 Best Practices

### 1. Natürliche Variation
- **Geschwindigkeit variieren:** ±0.02x pro Antwort
- **Pausen variieren:** 0.2-0.4s (nicht immer gleich)
- **Tonhöhe variieren:** ±0.05 für Emotionen

### 2. Emotionale Anpassung
- **Freude:** Schneller, höher, lauter
- **Empathie:** Langsamer, leiser, längere Pausen
- **Kompetenz:** Standard, klar, präzise

### 3. Produktspezifisch
- **Solar:** Langsamer, vertrauenswürdig
- **Strom:** Professionell, sachlich
- **Handy:** Schneller, modern, begeistert

### 4. Nicht erkennbar als KI
- **Variation:** Jede Antwort leicht unterschiedlich
- **Pausen:** Natürliche, unregelmäßige Pausen
- **Emotionen:** Echte emotionale Reaktionen
- **Fehler:** Kleine "Versprecher" sind okay

---

## 📝 Konfigurationsdatei

### `voice_config.json`

```json
{
  "agents": {
    "solar": {
      "Lisa": {
        "voice": "de-DE-Neural2-C",
        "gender": "FEMALE",
        "speakingRate": 0.98,
        "pitch": 0.2,
        "volumeGainDb": 0.0,
        "pauses": {
          "short": 0.3,
          "medium": 0.5,
          "long": 0.8
        },
        "emotion": "warm"
      }
    },
    "strom": {
      "Max": {
        "voice": "de-DE-Neural2-A",
        "gender": "MALE",
        "speakingRate": 1.0,
        "pitch": -0.1,
        "volumeGainDb": 0.0,
        "pauses": {
          "short": 0.3,
          "medium": 0.4,
          "long": 0.7
        },
        "emotion": "professional"
      }
    },
    "handy": {
      "Nicole": {
        "voice": "de-DE-Neural2-C",
        "gender": "FEMALE",
        "speakingRate": 1.05,
        "pitch": 0.2,
        "volumeGainDb": 1.0,
        "pauses": {
          "short": 0.25,
          "medium": 0.35,
          "long": 0.6
        },
        "emotion": "enthusiastic"
      }
    }
  },
  "defaults": {
    "audioEncoding": "MP3",
    "sampleRateHertz": 24000,
    "enableTimePointing": true
  }
}
```

---

## 🔄 Dynamische Anpassung

### Basierend auf Kundenreaktion

```javascript
function adjustVoiceForEmotion(agentConfig, customerEmotion) {
  switch(customerEmotion) {
    case 'happy':
      return {
        ...agentConfig,
        speakingRate: agentConfig.speakingRate + 0.02,
        pitch: agentConfig.pitch + 0.05,
        volumeGainDb: agentConfig.volumeGainDb + 0.5
      };
    case 'sad':
      return {
        ...agentConfig,
        speakingRate: agentConfig.speakingRate - 0.03,
        pitch: agentConfig.pitch - 0.05,
        volumeGainDb: agentConfig.volumeGainDb - 1.0
      };
    case 'angry':
      return {
        ...agentConfig,
        speakingRate: agentConfig.speakingRate - 0.05,
        pitch: agentConfig.pitch - 0.1,
        volumeGainDb: agentConfig.volumeGainDb - 2.0
      };
    default:
      return agentConfig;
  }
}
```

---

## 📈 Monitoring

### Metriken tracken
- **Latenz:** TTS-Generierungszeit
- **Qualität:** Audio-Qualität (subjektiv)
- **Variation:** Unterschiede zwischen Antworten
- **Emotionen:** Korrekte emotionale Anpassung

### Logging
```javascript
{
  agentName: "Lisa",
  productCategory: "solar",
  voice: "de-DE-Neural2-C",
  speakingRate: 0.98,
  pitch: 0.2,
  latency: 450, // ms
  textLength: 120,
  audioLength: 3500 // ms
}
```

---

**Status:** ✅ Vollständig dokumentiert

**Nächster Schritt:** TTS-Integration in Backend implementieren

