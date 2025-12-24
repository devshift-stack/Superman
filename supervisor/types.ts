import type { ArenaRequest } from "../arena/supervisor/types.js";

export type CallState = "idle" | "ringing" | "active" | "holding" | "ended";
export type ConversationPhase = "greeting" | "intent_detection" | "processing" | "response" | "escalation" | "closing";

export interface CallSession {
  callId: string;
  from: string;
  to: string;
  state: CallState;
  phase: ConversationPhase;
  startedAt: Date;
  history: ConversationTurn[];
  context: Record<string, any>;
  metadata: {
    userIntent?: string;
    confidence?: number;
    escalationReason?: string;
    sentiment?: "positive" | "neutral" | "negative";
  };
}

export interface ConversationTurn {
  timestamp: Date;
  speaker: "user" | "assistant" | "system";
  type: "speech" | "dtmf" | "system_event";
  content: string;
  metadata?: {
    duration?: number;
    confidence?: number;
    provider?: string;
  };
}

export interface SupervisorDecision {
  action: "continue" | "escalate" | "transfer" | "end";
  reason: string;
  nextPhase?: ConversationPhase;
  response?: {
    text: string;
    voiceId?: string;
    urgent?: boolean;
  };
  arenaRequest?: ArenaRequest;
  transferTarget?: string;
}

export interface ConversationScenario {
  name: string;
  triggers: string[];
  flow: ConversationPhase[];
  arenaConfig?: {
    provider?: "openai" | "anthropic";
    mode?: "build" | "verify" | "mixed";
  };
  responses: Record<ConversationPhase, string[]>;
}
