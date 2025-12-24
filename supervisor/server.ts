import express from "express";
import { createSession, getSession, updateSessionState, endSession } from "./sessionManager.js";
import { makeSupervisorDecision } from "./conversationSupervisor.js";

const app = express();
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

// Health check
app.get("/health", (_req, res) => {
  res.json({ ok: true, service: "call-supervisor", ts: new Date().toISOString() });
});

// sipgate Webhook Handler
app.post("/webhooks/sipgate", async (req, res) => {
  const { event, callId, from, to, user, direction } = req.body;

  console.log(`[sipgate] Event: ${event}, CallID: ${callId}, From: ${from}`);

  switch (event) {
    case "newCall":
      return handleNewCall(req, res, callId, from, to);

    case "answer":
      return handleAnswer(req, res, callId);

    case "hangup":
      return handleHangup(req, res, callId);

    default:
      return res.status(200).send("OK");
  }
});

// Neue Anruf-Handler
async function handleNewCall(req: any, res: any, callId: string, from: string, to: string) {
  // Session erstellen
  const session = createSession(callId, from, to);
  updateSessionState(callId, "active");

  console.log(`[Supervisor] New call from ${from}`);

  // Initiale Entscheidung: Begrüßung
  const decision = await makeSupervisorDecision(callId, "", "greeting");

  // TTS für Begrüßung generieren (Mini-Arena aufrufen)
  let audioUrl = "";
  if (decision.response?.text) {
    try {
      // Rufe Mini-Arena TTS auf (localhost:3333)
      const ttsResponse = await fetch("http://localhost:3333/tts", {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({
          text: decision.response.text,
          voice_id: "EXAVITQu4vr4xnSDxMaL", // Bella
        }),
      });

      if (ttsResponse.ok) {
        // Audio speichern und URL zurückgeben
        // TODO: Audio zu statischem Server hochladen
        audioUrl = `https://yourserver.com/audio/${callId}-greeting.mp3`;
      }
    } catch (e) {
      console.error("[Supervisor] TTS Error:", e);
    }
  }

  // sipgate XML Response
  res.set("Content-Type", "application/xml");
  res.send(`<?xml version="1.0" encoding="UTF-8"?>
<Response>
  <Answer/>
  ${audioUrl ? `<Play>${audioUrl}</Play>` : ""}
  <Gather onData="http://yourserver.com/webhooks/sipgate/dtmf" timeout="5">
    <Say voice="de-DE">${decision.response?.text || "Willkommen"}</Say>
  </Gather>
</Response>`);
}

async function handleAnswer(req: any, res: any, callId: string) {
  console.log(`[Supervisor] Call ${callId} answered`);
  updateSessionState(callId, "active");
  res.status(200).send("OK");
}

async function handleHangup(req: any, res: any, callId: string) {
  console.log(`[Supervisor] Call ${callId} ended`);
  endSession(callId);
  res.status(200).send("OK");
}

// DTMF Handler (Tasteneingabe)
app.post("/webhooks/sipgate/dtmf", async (req, res) => {
  const { callId, dtmf } = req.body;
  const session = getSession(callId);

  if (!session) {
    return res.status(404).send("Session not found");
  }

  console.log(`[Supervisor] DTMF ${dtmf} received for call ${callId}`);

  // DTMF als User Input verarbeiten
  const dtmfMap: Record<string, string> = {
    "1": "Vertrieb",
    "2": "Support",
    "3": "Allgemeine Anfrage",
    "0": "Mitarbeiter",
  };

  const userInput = dtmfMap[dtmf] || "Unbekannte Eingabe";
  const decision = await makeSupervisorDecision(callId, userInput, session.phase);

  // Response basierend auf Decision
  if (decision.action === "transfer" && decision.transferTarget) {
    res.set("Content-Type", "application/xml");
    return res.send(`<?xml version="1.0" encoding="UTF-8"?>
<Response>
  <Dial>${decision.transferTarget}</Dial>
</Response>`);
  }

  if (decision.action === "end") {
    res.set("Content-Type", "application/xml");
    return res.send(`<?xml version="1.0" encoding="UTF-8"?>
<Response>
  <Say voice="de-DE">${decision.response?.text || "Auf Wiederhören"}</Say>
  <Hangup/>
</Response>`);
  }

  // Continue conversation
  res.set("Content-Type", "application/xml");
  res.send(`<?xml version="1.0" encoding="UTF-8"?>
<Response>
  <Gather onData="http://yourserver.com/webhooks/sipgate/dtmf" timeout="5">
    <Say voice="de-DE">${decision.response?.text || "Wie kann ich helfen?"}</Say>
  </Gather>
</Response>`);
});

// Session Info Endpoint (für Debugging)
app.get("/sessions/:callId", (req, res) => {
  const session = getSession(req.params.callId);
  if (!session) {
    return res.status(404).json({ error: "Session not found" });
  }
  res.json(session);
});

const PORT = process.env.PORT || 8080;
const HOST = "0.0.0.0";

app.listen(PORT, HOST, () => {
  console.log(`Call Supervisor running on http://${HOST}:${PORT}`);
  console.log(`sipgate Webhook: http://${HOST}:${PORT}/webhooks/sipgate`);
});
