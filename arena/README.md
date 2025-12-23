# Mini-Arena (OpenAI + Claude) with Cloud Supervisor Router

This service routes tasks to either:
- OpenAI Responses API (recommended for reasoning, verification, structured outputs)
- Anthropic Claude Messages API (recommended for big refactors, code generation)

## Setup
Create `arena/.env` (copy from `.env.example`) and fill:
- OPENAI_API_KEY
- ANTHROPIC_API_KEY

## Run
From repo root:
- npm install
- npm run arena:dev

Service:
- POST http://localhost:3333/arena/run
- POST http://localhost:3333/arena/run-dual (Claude build -> OpenAI verify)
