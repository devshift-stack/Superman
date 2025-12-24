import type { ConversationScenario } from "./types.js";

export const scenarios: Record<string, ConversationScenario> = {
  support: {
    name: "Technischer Support",
    triggers: ["hilfe", "problem", "fehler", "funktioniert nicht", "support", "bug"],
    flow: ["greeting", "intent_detection", "processing", "response", "closing"],
    arenaConfig: {
      provider: "anthropic",
      mode: "build",
    },
    responses: {
      greeting: [
        "Willkommen beim technischen Support. Wie kann ich Ihnen helfen?",
        "Guten Tag! Sie haben den Support erreicht. Beschreiben Sie bitte Ihr Problem.",
      ],
      intent_detection: [
        "Verstehe. Können Sie mir mehr Details nennen?",
        "Ich höre zu. Was genau funktioniert nicht?",
      ],
      processing: [
        "Einen Moment bitte, ich prüfe das für Sie.",
        "Lassen Sie mich nachsehen...",
      ],
      response: [
        "Ich habe eine Lösung für Sie gefunden.",
        "Versuchen Sie bitte Folgendes:",
      ],
      escalation: [
        "Ich verbinde Sie mit einem Spezialisten.",
        "Ein Mitarbeiter wird sich um Ihr Anliegen kümmern.",
      ],
      closing: [
        "Konnte ich Ihnen weiterhelfen?",
        "Gibt es noch etwas, womit ich helfen kann?",
      ],
    },
  },

  sales: {
    name: "Vertrieb",
    triggers: ["kaufen", "preis", "angebot", "kosten", "bestellen", "produkt"],
    flow: ["greeting", "intent_detection", "processing", "response", "closing"],
    arenaConfig: {
      provider: "openai",
      mode: "verify",
    },
    responses: {
      greeting: [
        "Herzlich willkommen! Interessieren Sie sich für unsere Produkte?",
        "Guten Tag! Schön, dass Sie anrufen. Wie kann ich Ihnen helfen?",
      ],
      intent_detection: [
        "Welches Produkt interessiert Sie besonders?",
        "Möchten Sie mehr über unsere Angebote erfahren?",
      ],
      processing: [
        "Einen Moment, ich stelle Ihnen die Informationen zusammen.",
        "Lassen Sie mich das für Sie heraussuchen.",
      ],
      response: [
        "Ich kann Ihnen folgendes Angebot machen:",
        "Unser aktuelles Angebot umfasst:",
      ],
      escalation: [
        "Ich verbinde Sie mit unserem Vertriebsteam.",
        "Ein Verkaufsberater wird Ihnen gleich weiterhelfen.",
      ],
      closing: [
        "Möchten Sie das Angebot annehmen?",
        "Haben Sie noch Fragen zum Angebot?",
      ],
    },
  },

  general: {
    name: "Allgemeine Anfrage",
    triggers: ["hallo", "informationen", "frage", "auskunft"],
    flow: ["greeting", "intent_detection", "processing", "response", "closing"],
    arenaConfig: {
      provider: "openai",
      mode: "mixed",
    },
    responses: {
      greeting: [
        "Guten Tag! Wie kann ich Ihnen helfen?",
        "Willkommen! Was kann ich für Sie tun?",
      ],
      intent_detection: [
        "Worum geht es genau?",
        "Erzählen Sie mir mehr darüber.",
      ],
      processing: [
        "Verstanden, einen Moment bitte.",
        "Ich kümmere mich darum.",
      ],
      response: [
        "Hier ist die Information, die Sie brauchen:",
        "Das kann ich Ihnen sagen:",
      ],
      escalation: [
        "Ich verbinde Sie mit einem Mitarbeiter.",
        "Lassen Sie mich jemanden für Sie holen.",
      ],
      closing: [
        "Konnte ich Ihre Frage beantworten?",
        "Brauchen Sie noch weitere Informationen?",
      ],
    },
  },

  emergency: {
    name: "Dringender Fall",
    triggers: ["notfall", "dringend", "sofort", "wichtig", "eilig"],
    flow: ["greeting", "escalation"],
    arenaConfig: {
      provider: "openai",
      mode: "verify",
    },
    responses: {
      greeting: [
        "Ich verstehe, es ist dringend. Ich verbinde Sie sofort.",
      ],
      intent_detection: [],
      processing: [],
      response: [],
      escalation: [
        "Ich stelle Sie durch zu einem verfügbaren Mitarbeiter.",
        "Bleiben Sie dran, ich verbinde Sie unverzüglich.",
      ],
      closing: [],
    },
  },
};

export function detectScenario(input: string): ConversationScenario {
  const lowerInput = input.toLowerCase();

  for (const scenario of Object.values(scenarios)) {
    if (scenario.triggers.some((trigger) => lowerInput.includes(trigger))) {
      return scenario;
    }
  }

  // Fallback: general scenario
  return scenarios.general;
}

export function getResponseForPhase(
  scenario: ConversationScenario,
  phase: ConversationPhase
): string {
  const responses = scenario.responses[phase];
  if (!responses || responses.length === 0) {
    return "Einen Moment bitte.";
  }

  // Random response aus den verfügbaren
  return responses[Math.floor(Math.random() * responses.length)];
}
