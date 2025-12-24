import type { CallSession, ConversationTurn, CallState, ConversationPhase } from "./types.js";

// In-memory session store (für Production: Redis/DB verwenden)
const sessions = new Map<string, CallSession>();

export function createSession(callId: string, from: string, to: string): CallSession {
  const session: CallSession = {
    callId,
    from,
    to,
    state: "ringing",
    phase: "greeting",
    startedAt: new Date(),
    history: [],
    context: {},
    metadata: {},
  };

  sessions.set(callId, session);
  return session;
}

export function getSession(callId: string): CallSession | undefined {
  return sessions.get(callId);
}

export function updateSessionState(callId: string, state: CallState): void {
  const session = sessions.get(callId);
  if (session) {
    session.state = state;
  }
}

export function updateSessionPhase(callId: string, phase: ConversationPhase): void {
  const session = sessions.get(callId);
  if (session) {
    session.phase = phase;
  }
}

export function addConversationTurn(
  callId: string,
  turn: Omit<ConversationTurn, "timestamp">
): void {
  const session = sessions.get(callId);
  if (session) {
    session.history.push({
      ...turn,
      timestamp: new Date(),
    });
  }
}

export function updateSessionContext(
  callId: string,
  updates: Record<string, any>
): void {
  const session = sessions.get(callId);
  if (session) {
    session.context = { ...session.context, ...updates };
  }
}

export function updateSessionMetadata(
  callId: string,
  updates: Partial<CallSession["metadata"]>
): void {
  const session = sessions.get(callId);
  if (session) {
    session.metadata = { ...session.metadata, ...updates };
  }
}

export function endSession(callId: string): void {
  const session = sessions.get(callId);
  if (session) {
    session.state = "ended";
    // Session für Audit-Log behalten (30 Minuten)
    setTimeout(() => sessions.delete(callId), 30 * 60 * 1000);
  }
}

export function getActiveSessionCount(): number {
  return Array.from(sessions.values()).filter(
    (s) => s.state === "active" || s.state === "holding"
  ).length;
}

export function getSessionHistory(callId: string): ConversationTurn[] {
  const session = sessions.get(callId);
  return session?.history ?? [];
}
