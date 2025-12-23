import "dotenv/config";
import express from "express";
import { runArena, runDualArena } from "./supervisor/arenaSupervisor.js";

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

const port = Number(process.env.PORT ?? 3333);
app.listen(port, () => console.log(`mini-arena listening on :${port}`));
