# 🎤 Komplette Voice & TTS Dokumentation

## 📋 Inhaltsverzeichnis

1. [Stimmen-Konfiguration](#stimmen-konfiguration)
2. [Geschwindigkeit](#geschwindigkeit)
3. [Tonhöhe](#tonhöhe)
4. [Pausen](#pausen)
5. [Emotionen](#emotionen)
6. [Technische Details](#technische-details)
7. [Implementierung](#implementierung)

---

## 🎭 Stimmen-Konfiguration

### Google Cloud TTS Neural2 Stimmen (Deutsch)

#### Weibliche Stimmen

| Stimme | Code | Beschreibung | Verwendung |
|--------|------|--------------|------------|
| **Neural2-A** | `de-DE-Neural2-A` | Warm, freundlich | Solar-Agenten |
| **Neural2-B** | `de-DE-Neural2-B` | Professionell, klar | Strom-Agenten |
| **Neural2-C** | `de-DE-Neural2-C` | Begeistert, modern | Handy-Agenten |
| **Neural2-D** | `de-DE-Neural2-D` | Empathisch, verständnisvoll | Solar-Agenten |
| **Neural2-E** | `de-DE-Neural2-E` | Kompetent, technisch | Handy-Agenten |
| **Neural2-F** | `de-DE-Neural2-F` | Professionell, sachlich | Strom-Agenten |

#### Männliche Stimmen

| Stimme | Code | Beschreibung | Verwendung |
|--------|------|--------------|------------|
| **Neural2-A** | `de-DE-Neural2-A` | Kompetent, autoritär | Strom-Agenten |
| **Neural2-B** | `de-DE-Neural2-B` | Professionell, beratend | Strom-Agenten |
| **Neural2-C** | `de-DE-Neural2-C` | Freundlich, modern | Strom-Agenten |

---

## ⚡ Geschwindigkeit (Speaking Rate)

### Detaillierte Werte

| Wert | WPM* | Beschreibung | Verwendung | Beispiel |
|------|------|--------------|------------|----------|
| **0.75x** | ~120 | Sehr langsam | Ältere Kunden, komplexe Themen | "Ich erkläre Ihnen das ganz langsam..." |
| **0.85x** | ~136 | Langsam | Wichtige Informationen | "Das ist wirklich wichtig..." |
| **0.90x** | ~144 | Etwas langsam | Empathische Gespräche | "Ich verstehe Ihre Situation..." |
| **0.95x** | ~152 | Leicht langsam | Vertrauensvolle Gespräche | "Lassen Sie mich Ihnen helfen..." |
| **1.0x** | ~160 | Normal | Standard-Geschwindigkeit | "Hallo! Wie kann ich Ihnen helfen?" |
| **1.05x** | ~168 | Etwas schnell | Begeisterte Gespräche | "Das ist ein super Angebot!" |
| **1.10x** | ~176 | Schnell | Technische Themen | "Das Gerät hat 5G-Unterstützung..." |
| **1.15x** | ~184 | Sehr schnell | Nicht empfohlen | Zu schnell, unverständlich |

*WPM = Words Per Minute (ca. 160 WPM = Standard)

### Produktspezifische Geschwindigkeiten

**Solar:**
- Standard: 0.95x - 1.0x (vertrauenswürdig, nicht aufdringlich)
- Empathisch: 0.90x - 0.95x (bei Problemen)
- Begeistert: 1.0x - 1.05x (bei Interesse)

**Strom:**
- Standard: 0.96x - 1.0x (professionell, kompetent)
- Beratend: 0.95x - 0.98x (bei Fragen)
- Überzeugend: 1.0x - 1.02x (bei Vorteilen)

**Handy:**
- Standard: 1.0x - 1.05x (modern, dynamisch)
- Technisch: 1.05x - 1.10x (bei Features)
- Begeistert: 1.08x - 1.12x (bei Angeboten)

---

## 🎵 Tonhöhe (Pitch)

### Detaillierte Werte

| Wert | Semitöne | Beschreibung | Verwendung |
|------|----------|--------------|------------|
| **-0.3** | -3 | Sehr tief | Autoritär, männlich |
| **-0.2** | -2 | Tief | Männlich, Standard |
| **-0.15** | -1.5 | Etwas tief | Männlich, professionell |
| **-0.1** | -1 | Leicht tief | Männlich, freundlich |
| **0.0** | 0 | Normal | Standard |
| **+0.1** | +1 | Leicht höher | Weiblich, Standard |
| **+0.15** | +1.5 | Etwas höher | Weiblich, freundlich |
| **+0.2** | +2 | Höher | Weiblich, begeistert |
| **+0.3** | +3 | Sehr hoch | Nicht empfohlen (unnatürlich) |

### Geschlechtsspezifisch

**Männlich (Strom-Agenten):**
- Standard: -0.1 bis -0.15
- Autoritär: -0.2 bis -0.25
- Freundlich: -0.08 bis -0.12

**Weiblich (Solar/Handy-Agenten):**
- Standard: +0.1 bis +0.15
- Begeistert: +0.2 bis +0.25
- Empathisch: +0.08 bis +0.12

---

## ⏸️ Pausen (Natural Pauses)

### Pausen-Typen

| Typ | Dauer | SSML | Verwendung |
|-----|-------|------|------------|
| **Mikro-Pause** | 0.1-0.2s | `<break time="0.15s"/>` | Nach kurzen Wörtern |
| **Kurze Pause** | 0.2-0.3s | `<break time="0.3s"/>` | Nach Kommas, natürliche Atempausen |
| **Mittlere Pause** | 0.4-0.6s | `<break time="0.5s"/>` | Nach Sätzen, für Betonung |
| **Lange Pause** | 0.8-1.2s | `<break time="1.0s"/>` | Für wichtige Informationen, nach Fragen |
| **Emotionale Pause** | 0.5-0.8s | `<break time="0.7s"/>` | Bei emotionalen Momenten |
| **Dramatische Pause** | 1.5-2.0s | `<break time="1.8s"/>` | Für wichtige Ankündigungen |

### Pausen-Platzierung

**Nach Kommas:**
```xml
Das ist wirklich interessant,<break time="0.3s"/> und könnte Ihnen viel Geld sparen.
```

**Nach Sätzen:**
```xml
Haben Sie sich schon mal Gedanken über Solar gemacht?<break time="0.5s"/> 
Wir haben gerade super Angebote.
```

**Für Betonung:**
```xml
Das Beste ist:<break time="0.8s"/> Sie sparen bis zu 500 Euro pro Jahr.
```

**Emotionale Pausen:**
```xml
Oh, das verstehe ich total.<break time="0.6s"/> 
Viele Kunden haben die gleichen Bedenken.
```

**Füllwörter:**
```xml
Ähm<break time="0.2s"/>, lassen Sie mich das erklären.
Also<break time="0.15s"/>, das ist wirklich einfach.
Hmm<break time="0.3s"/>, das ist eine gute Frage.
```

---

## 😊 Emotionen

### Emotionale Konfigurationen

#### Freude/Begeisterung
```javascript
{
  speakingRate: +0.05,  // Etwas schneller
  pitch: +0.1,          // Etwas höher
  volumeGainDb: +1.0,   // Etwas lauter
  pauseMultiplier: 0.9  // Kürzere Pausen
}
```

**Verwendung:** Bei positiven Reaktionen, Angeboten, Erfolgen

#### Empathie/Verständnis
```javascript
{
  speakingRate: -0.05,  // Etwas langsamer
  pitch: -0.05,         // Etwas tiefer
  volumeGainDb: -1.0,   // Etwas leiser
  pauseMultiplier: 1.2  // Längere Pausen
}
```

**Verwendung:** Bei Problemen, Bedenken, Ablehnung

#### Kompetenz/Professionell
```javascript
{
  speakingRate: 0.0,    // Standard
  pitch: 0.0,           // Standard
  volumeGainDb: 0.0,    // Standard
  pauseMultiplier: 1.0  // Standard
}
```

**Verwendung:** Bei Fakten, Zahlen, technischen Details

#### Vertrauen/Vertraulich
```javascript
{
  speakingRate: -0.03,  // Etwas langsamer
  pitch: 0.0,           // Standard
  volumeGainDb: -2.0,   // Leiser
  pauseMultiplier: 1.3  // Längere Pausen
}
```

**Verwendung:** Bei persönlichen Informationen, Vertraulichkeit

#### Überzeugung/Enthusiasmus
```javascript
{
  speakingRate: +0.03,  // Etwas schneller
  pitch: +0.08,         // Etwas höher
  volumeGainDb: +1.5,   // Lauter
  pauseMultiplier: 0.95 // Etwas kürzere Pausen
}
```

**Verwendung:** Bei Verkaufsargumenten, Vorteilen

---

## 🔧 Technische Details

### Audio-Formate

| Format | Encoding | Bitrate | Qualität | Größe | Verwendung |
|--------|----------|---------|----------|-------|------------|
| **MP3** | MP3 | 64 kbps | Gut | Klein | Standard, Web |
| **OGG_OPUS** | OGG | 48 kbps | Sehr gut | Sehr klein | Mobile, Streaming |
| **LINEAR16** | PCM | 1536 kbps | Perfekt | Groß | Professionell |
| **MULAW** | μ-law | 64 kbps | Gut | Klein | Telefonie |

**Empfehlung:** MP3 (64 kbps) für Web, OGG_OPUS für Mobile

### Sample Rates

| Rate | Qualität | Verwendung |
|------|----------|------------|
| **16000 Hz** | Telefon-Qualität | Telefonie |
| **22050 Hz** | Radio-Qualität | Streaming |
| **24000 Hz** | Standard | Web, Mobile |
| **32000 Hz** | Gut | High-Quality |
| **44100 Hz** | CD-Qualität | Professionell |
| **48000 Hz** | Studio-Qualität | Premium |

**Empfehlung:** 24000 Hz (Balance Qualität/Größe)

### Latenz-Optimierung

| Methode | Latenz | Qualität | Kosten |
|---------|--------|----------|--------|
| **Streaming** | < 200ms | Gut | Mittel |
| **Caching** | < 50ms | Gut | Niedrig |
| **Pre-Generation** | 0ms | Gut | Hoch |
| **On-Demand** | 300-500ms | Sehr gut | Niedrig |

**Empfehlung:** Caching + Streaming für beste Performance

---

## 💻 Implementierung

### TTS Service Integration

```javascript
import { synthesizeAgentSpeech } from './tts_service.js';

// In Chat-Route
const ttsResult = await synthesizeAgentSpeech(
  response,
  session.agentName,
  session.productCategory
);

if (ttsResult) {
  // Audio als Base64 zurückgeben
  res.json({
    response: response,
    audioContent: ttsResult.audioContent.toString('base64'),
    audioFormat: 'mp3',
    voiceConfig: getAgentVoiceConfig(session.agentName, session.productCategory)
  });
}
```

### Emotionale Anpassung

```javascript
import { adjustVoiceForEmotion } from './tts_service.js';

// Basierend auf Kundenreaktion
const customerEmotion = detectEmotion(customerMessage); // 'happy', 'sad', 'angry'
const adjustedConfig = adjustVoiceForEmotion(agentConfig, customerEmotion);

// Mit angepasster Konfiguration synthetisieren
const ttsResult = await synthesizeWithConfig(text, adjustedConfig);
```

### Caching-Strategie

```javascript
// Häufige Phrasen cachen
const cache = new Map();

async function getCachedOrSynthesize(text, agentConfig) {
  const cacheKey = `${text}_${agentConfig.voice}_${agentConfig.speakingRate}`;
  
  if (cache.has(cacheKey)) {
    return cache.get(cacheKey);
  }
  
  const audio = await synthesizeAgentSpeech(text, agentConfig);
  cache.set(cacheKey, audio);
  
  // Cache nach 24h löschen
  setTimeout(() => cache.delete(cacheKey), 24 * 60 * 60 * 1000);
  
  return audio;
}
```

---

## 📊 Monitoring & Analytics

### Metriken tracken

```javascript
{
  agentName: "Lisa",
  productCategory: "solar",
  voice: "de-DE-Neural2-C",
  speakingRate: 0.98,
  pitch: 0.2,
  textLength: 120,
  audioLength: 3500, // ms
  latency: 450, // ms (TTS-Generierung)
  cacheHit: false,
  emotion: "warm",
  customerReaction: "positive"
}
```

### Performance-Metriken

- **Latenz:** Ziel < 500ms
- **Cache-Hit-Rate:** Ziel > 60%
- **Audio-Qualität:** Subjektive Bewertung
- **Variation:** Unterschiede zwischen Antworten

---

## 🎯 Best Practices

### 1. Natürliche Variation
- Geschwindigkeit: ±0.02x pro Antwort
- Pausen: 0.2-0.4s (variabel)
- Tonhöhe: ±0.05 für Emotionen

### 2. Produktspezifisch
- **Solar:** Langsamer, vertrauenswürdig
- **Strom:** Professionell, sachlich
- **Handy:** Schneller, modern

### 3. Emotionale Anpassung
- Reagiere auf Kundenemotionen
- Passe Voice dynamisch an
- Zeige echte Empathie

### 4. Nicht erkennbar als KI
- Variation in jeder Antwort
- Natürliche, unregelmäßige Pausen
- Echte emotionale Reaktionen
- Kleine "Versprecher" sind okay

---

## 📝 Konfigurationsdatei

Siehe `voice_config.json` für vollständige Konfiguration aller Agenten.

---

**Status:** ✅ Vollständig dokumentiert mit allen Details

