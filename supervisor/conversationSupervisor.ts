import type { CallSession, SupervisorDecision, ConversationPhase } from "./types.js";
import type { ArenaRequest } from "../arena/supervisor/types.js";
import { detectScenario, getResponseForPhase } from "./scenarios.js";
import {
  getSession,
  updateSessionPhase,
  updateSessionMetadata,
  addConversationTurn,
} from "./sessionManager.js";

export async function makeSupervisorDecision(
  callId: string,
  userInput: string,
  currentPhase: ConversationPhase
): Promise<SupervisorDecision> {
  const session = getSession(callId);
  if (!session) {
    return {
      action: "end",
      reason: "Session not found",
    };
  }

  // User input zu History hinzufügen
  addConversationTurn(callId, {
    speaker: "user",
    type: "speech",
    content: userInput,
  });

  // Szenario erkennen (beim ersten Mal oder bei Änderung)
  const scenario = detectScenario(userInput);
  updateSessionMetadata(callId, { userIntent: scenario.name });

  // Sentiment-Analyse (vereinfacht)
  const sentiment = analyzeSentiment(userInput);
  updateSessionMetadata(callId, { sentiment });

  // Entscheidungslogik basierend auf Phase
  switch (currentPhase) {
    case "greeting":
      return handleGreeting(session, scenario, userInput);

    case "intent_detection":
      return handleIntentDetection(session, scenario, userInput);

    case "processing":
      return handleProcessing(session, scenario, userInput);

    case "response":
      return handleResponse(session, scenario, userInput);

    case "escalation":
      return handleEscalation(session, scenario);

    case "closing":
      return handleClosing(session, scenario, userInput);

    default:
      return {
        action: "continue",
        reason: "Unknown phase, continuing",
        response: {
          text: "Einen Moment bitte.",
        },
      };
  }
}

function handleGreeting(
  session: CallSession,
  scenario: any,
  userInput: string
): SupervisorDecision {
  const response = getResponseForPhase(scenario, "greeting");

  // Bei Notfällen direkt eskalieren
  if (scenario.name === "Dringender Fall") {
    return {
      action: "escalate",
      reason: "Emergency detected",
      nextPhase: "escalation",
      response: {
        text: response,
        urgent: true,
      },
    };
  }

  return {
    action: "continue",
    reason: "Greeting completed",
    nextPhase: "intent_detection",
    response: {
      text: response,
    },
  };
}

function handleIntentDetection(
  session: CallSession,
  scenario: any,
  userInput: string
): SupervisorDecision {
  // Komplexe Anfragen an Arena weiterleiten
  const needsArena = userInput.length > 50 || hasComplexKeywords(userInput);

  if (needsArena) {
    const arenaRequest: ArenaRequest = {
      task: `Analyze customer intent and provide appropriate response`,
      goal: `Understand what the customer needs: ${userInput}`,
      context: JSON.stringify({
        scenario: scenario.name,
        callId: session.callId,
        history: session.history.slice(-3),
      }),
      mode: scenario.arenaConfig?.mode ?? "mixed",
      preferred_provider: scenario.arenaConfig?.provider,
    };

    return {
      action: "continue",
      reason: "Complex intent, using Arena",
      nextPhase: "processing",
      arenaRequest,
      response: {
        text: "Einen Moment, ich analysiere Ihre Anfrage.",
      },
    };
  }

  // Einfache Anfragen direkt beantworten
  const response = getResponseForPhase(scenario, "intent_detection");
  return {
    action: "continue",
    reason: "Intent detected, proceeding",
    nextPhase: "processing",
    response: {
      text: response,
    },
  };
}

function handleProcessing(
  session: CallSession,
  scenario: any,
  userInput: string
): SupervisorDecision {
  // Nach Processing → Response
  const response = getResponseForPhase(scenario, "response");

  return {
    action: "continue",
    reason: "Processing complete",
    nextPhase: "response",
    response: {
      text: response,
    },
  };
}

function handleResponse(
  session: CallSession,
  scenario: any,
  userInput: string
): SupervisorDecision {
  // Check ob User zufrieden ist
  const satisfactionKeywords = ["danke", "super", "perfekt", "gut", "ja"];
  const dissatisfactionKeywords = ["nein", "nicht", "falsch", "problem"];

  const isSatisfied = satisfactionKeywords.some((kw) =>
    userInput.toLowerCase().includes(kw)
  );
  const isDissatisfied = dissatisfactionKeywords.some((kw) =>
    userInput.toLowerCase().includes(kw)
  );

  if (isDissatisfied) {
    return {
      action: "escalate",
      reason: "Customer not satisfied",
      nextPhase: "escalation",
      response: {
        text: "Ich verstehe. Lassen Sie mich einen Mitarbeiter für Sie holen.",
      },
    };
  }

  if (isSatisfied) {
    const response = getResponseForPhase(scenario, "closing");
    return {
      action: "continue",
      reason: "Moving to closing",
      nextPhase: "closing",
      response: {
        text: response,
      },
    };
  }

  // Weitere Fragen
  return {
    action: "continue",
    reason: "Continuing conversation",
    nextPhase: "intent_detection",
    response: {
      text: "Gibt es noch etwas, womit ich helfen kann?",
    },
  };
}

function handleEscalation(
  session: CallSession,
  scenario: any
): SupervisorDecision {
  const response = getResponseForPhase(scenario, "escalation");

  return {
    action: "transfer",
    reason: "Escalating to human agent",
    transferTarget: "+49301234567", // Beispiel-Nummer
    response: {
      text: response,
      urgent: true,
    },
  };
}

function handleClosing(
  session: CallSession,
  scenario: any,
  userInput: string
): SupervisorDecision {
  const goodbyeKeywords = ["tschüss", "danke", "bye", "auf wiedersehen", "nein"];

  if (goodbyeKeywords.some((kw) => userInput.toLowerCase().includes(kw))) {
    return {
      action: "end",
      reason: "Conversation completed",
      response: {
        text: "Vielen Dank für Ihren Anruf. Auf Wiederhören!",
      },
    };
  }

  // Zurück zu intent detection
  return {
    action: "continue",
    reason: "Customer has more questions",
    nextPhase: "intent_detection",
    response: {
      text: "Natürlich, was möchten Sie noch wissen?",
    },
  };
}

// Hilfsfunktionen
function analyzeSentiment(text: string): "positive" | "neutral" | "negative" {
  const positive = ["danke", "super", "toll", "gut", "perfekt", "ja"];
  const negative = ["problem", "schlecht", "nicht", "nein", "fehler"];

  const lowerText = text.toLowerCase();
  const positiveCount = positive.filter((w) => lowerText.includes(w)).length;
  const negativeCount = negative.filter((w) => lowerText.includes(w)).length;

  if (positiveCount > negativeCount) return "positive";
  if (negativeCount > positiveCount) return "negative";
  return "neutral";
}

function hasComplexKeywords(text: string): boolean {
  const complex = [
    "warum",
    "wieso",
    "wie genau",
    "erklären",
    "verstehe nicht",
    "kompliziert",
  ];
  const lowerText = text.toLowerCase();
  return complex.some((kw) => lowerText.includes(kw));
}
