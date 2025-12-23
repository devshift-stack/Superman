import "dotenv/config";
import express from "express";
import { runArena, runDualArena } from "./supervisor/arenaSupervisor.js";
import { textToSpeech, streamTextToSpeech, getVoices } from "./services/elevenlabs.js";

const app = express();
app.use(express.json({ limit: "2mb" }));

app.get("/health", (_req, res) => {
  res.json({ ok: true, service: "mini-arena", ts: new Date().toISOString() });
});

app.post("/arena/run", async (req, res) => {
  try {
    const out = await runArena(req.body);
    res.json(out);
  } catch (e: any) {
    res.status(500).json({ ok: false, error: e?.message ?? String(e) });
  }
});

app.post("/arena/run-dual", async (req, res) => {
  try {
    const out = await runDualArena(req.body);
    res.json(out);
  } catch (e: any) {
    res.status(500).json({ ok: false, error: e?.message ?? String(e) });
  }
});

// ElevenLabs TTS endpoints
app.post("/tts", async (req, res) => {
  try {
    const { text, voice_id } = req.body;
    if (!text) {
      return res.status(400).json({ ok: false, error: "Missing 'text' parameter" });
    }
    const audio = await textToSpeech(text, voice_id);
    res.set("Content-Type", "audio/mpeg");
    res.send(audio);
  } catch (e: any) {
    res.status(500).json({ ok: false, error: e?.message ?? String(e) });
  }
});

app.post("/tts/stream", async (req, res) => {
  try {
    const { text, voice_id } = req.body;
    if (!text) {
      return res.status(400).json({ ok: false, error: "Missing 'text' parameter" });
    }
    res.set("Content-Type", "audio/mpeg");
    res.set("Transfer-Encoding", "chunked");

    const stream = await streamTextToSpeech(text, voice_id);
    for await (const chunk of stream) {
      res.write(chunk);
    }
    res.end();
  } catch (e: any) {
    if (!res.headersSent) {
      res.status(500).json({ ok: false, error: e?.message ?? String(e) });
    }
  }
});

app.get("/voices", async (_req, res) => {
  try {
    const voices = await getVoices();
    res.json({ ok: true, voices });
  } catch (e: any) {
    res.status(500).json({ ok: false, error: e?.message ?? String(e) });
  }
});

const port = Number(process.env.PORT ?? 3333);
app.listen(port, () => console.log(`mini-arena listening on :${port}`));
