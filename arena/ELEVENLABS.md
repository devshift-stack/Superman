# ElevenLabs TTS Integration

Die Mini-Arena bietet jetzt vollständige ElevenLabs Text-to-Speech Integration.

## Setup

1. ElevenLabs API Key besorgen:
   - Gehe zu https://elevenlabs.io/
   - Erstelle Account oder logge dich ein
   - API Key von https://elevenlabs.io/app/settings/api-keys

2. API Key in `.env` eintragen:
```bash
ELEVENLABS_API_KEY=your_api_key_here
ELEVENLABS_VOICE_ID=21m00Tcm4TlvDq8ikWAM  # Optional: Rachel (default)
```

## Verfügbare Endpoints

### 1. Text-to-Speech (Buffered)

Generiert komplettes Audio und gibt es zurück.

```bash
curl -X POST http://localhost:3333/tts \
  -H "Content-Type: application/json" \
  -d '{"text": "Hallo, ich bin dein KI-Assistent"}' \
  --output audio.mp3
```

Mit custom Voice:
```bash
curl -X POST http://localhost:3333/tts \
  -H "Content-Type: application/json" \
  -d '{"text": "Custom voice test", "voice_id": "EXAVITQu4vr4xnSDxMaL"}' \
  --output audio.mp3
```

### 2. Text-to-Speech (Streaming)

Streamt Audio chunks für geringere Latenz.

```bash
curl -X POST http://localhost:3333/tts/stream \
  -H "Content-Type: application/json" \
  -d '{"text": "Streaming TTS für schnelle Wiedergabe"}' \
  --output audio.mp3
```

### 3. Verfügbare Stimmen abrufen

```bash
curl http://localhost:3333/voices | jq .
```

Response:
```json
{
  "ok": true,
  "voices": [
    {
      "voice_id": "21m00Tcm4TlvDq8ikWAM",
      "name": "Rachel",
      "category": "premade",
      "labels": {
        "accent": "american",
        "age": "young",
        "gender": "female"
      }
    },
    ...
  ]
}
```

## Integration mit sipgate

Für Telefonie-Integration:

```javascript
// Beispiel: Generiere Begrüßungsansage
const response = await fetch('http://localhost:3333/tts', {
  method: 'POST',
  headers: { 'Content-Type': 'application/json' },
  body: JSON.stringify({
    text: 'Willkommen bei unserem Service. Bitte bleiben Sie dran.',
    voice_id: '21m00Tcm4TlvDq8ikWAM'
  })
});

const audioBuffer = await response.arrayBuffer();
// Audio über SIP/RTP streamen
```

## Beliebte Deutsche Stimmen

| Voice ID | Name | Beschreibung |
|----------|------|--------------|
| `pNInz6obpgDQGcFmaJgB` | Adam | Männlich, tief |
| `21m00Tcm4TlvDq8ikWAM` | Rachel | Weiblich, klar |
| `EXAVITQu4vr4xnSDxMaL` | Bella | Weiblich, freundlich |
| `ErXwobaYiN019PkySvjV` | Antoni | Männlich, warm |

## Kosten

ElevenLabs berechnet nach Zeichen:
- Free Tier: 10.000 Zeichen/Monat
- Starter: $5/Monat für 30.000 Zeichen
- Creator: $22/Monat für 100.000 Zeichen

## Fehlerbehandlung

```javascript
try {
  const response = await fetch('http://localhost:3333/tts', {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({ text: 'Test' })
  });

  if (!response.ok) {
    const error = await response.json();
    console.error('TTS Error:', error);
  }
} catch (e) {
  console.error('Network Error:', e);
}
```

## Tipps für beste Qualität

1. **Pausen**: Nutze Kommas und Punkte für natürliche Pausen
2. **SSML**: ElevenLabs unterstützt SSML für erweiterte Kontrolle
3. **Streaming**: Nutze `/tts/stream` für geringe Latenz bei langen Texten
4. **Caching**: Cache häufige Ansagen lokal (z.B. Begrüßungen)

## Modelle

Die Integration nutzt `eleven_multilingual_v2`:
- Unterstützt 29 Sprachen
- Hochwertige Stimmen
- Natürliche Intonation
- Geringe Latenz
