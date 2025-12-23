# Mini-Arena (OpenAI + Claude) with Cloud Supervisor Router + ElevenLabs TTS

This service routes tasks to either:
- **OpenAI Responses API** (recommended for reasoning, verification, structured outputs)
- **Anthropic Claude Messages API** (recommended for big refactors, code generation)
- **ElevenLabs TTS** (high-quality text-to-speech, 29 languages)

## Features

- Multi-model routing with intelligent supervisor
- Policy enforcement (pricing/legal checks)
- Evidence-based claim verification
- Dual-mode execution (build + verify)
- Text-to-Speech with streaming support
- Voice management API

## Setup

Create `arena/.env` (copy from `.env.example`) and configure:
```bash
OPENAI_API_KEY=your_openai_key
ANTHROPIC_API_KEY=your_anthropic_key
ELEVENLABS_API_KEY=your_elevenlabs_key  # Optional for TTS
```

## Local Development

```bash
# From repo root
npm install
npm run arena:dev
```

## VPS Deployment

```bash
# Deploy to VPS
./arena/deploy-vps.sh 46.224.147.155 root
```

## Endpoints

### Multi-Model Arena
- `POST /arena/run` - Auto-route to best model
- `POST /arena/run-dual` - Claude builds → OpenAI verifies

### Text-to-Speech
- `POST /tts` - Generate audio from text
- `POST /tts/stream` - Stream audio (low latency)
- `GET /voices` - List available voices

### Health
- `GET /health` - Service status

## Documentation

- [ElevenLabs Integration Guide](./ELEVENLABS.md) - TTS setup and usage
