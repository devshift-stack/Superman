import type { ArenaRequest } from "../supervisor/types.js";

export async function callAnthropic(req: ArenaRequest) {
  const apiKey = process.env.ANTHROPIC_API_KEY;
  if (!apiKey) throw new Error("ANTHROPIC_API_KEY missing");
  const model = process.env.ANTHROPIC_MODEL ?? "claude-sonnet-4-5-20250929";
  const version = process.env.ANTHROPIC_VERSION ?? "2023-06-01";

  const system = "You are a code-focused senior engineer. Output clear steps and concrete code changes. Do not invent results; if unsure say UNKNOWN.";
  const messages = [
    { role: "user", content: `TASK:\n${req.task}\n\nGOAL:\n${req.goal ?? ""}\n\nCONTEXT:\n${req.context ?? ""}\n\nARTEFACTS:\n${(req.artefacts ?? []).join("\n")}\n\nCLAIMS:\n${(req.claims ?? []).join("\n")}` }
  ];

  const body = {
    model,
    max_tokens: 1200,
    system,
    messages,
  };

  const r = await fetch("https://api.anthropic.com/v1/messages", {
    method: "POST",
    headers: {
      "Content-Type": "application/json",
      "x-api-key": apiKey,
      "anthropic-version": version,
    },
    body: JSON.stringify(body),
  });

  if (!r.ok) {
    const txt = await r.text();
    throw new Error(`Anthropic error ${r.status}: ${txt}`);
  }
  return await r.json();
}
