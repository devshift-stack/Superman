import type { ArenaRequest } from "../supervisor/types.js";

export async function callOpenAI(req: ArenaRequest) {
  const apiKey = process.env.OPENAI_API_KEY;
  if (!apiKey) throw new Error("OPENAI_API_KEY missing");
  const model = process.env.OPENAI_MODEL ?? "gpt-5";

  // OpenAI Responses API
  // Docs: https://platform.openai.com/docs/api-reference/responses
  const input = [
    { role: "system", content: "You are a strict engineering supervisor assistant. Return concise, verifiable outputs. If unsure say UNKNOWN." },
    { role: "user", content: `TASK:\n${req.task}\n\nGOAL:\n${req.goal ?? ""}\n\nCONTEXT:\n${req.context ?? ""}\n\nARTEFACTS:\n${(req.artefacts ?? []).join("\n")}\n\nCLAIMS:\n${(req.claims ?? []).join("\n")}` },
  ];

  const body = {
    model,
    input,
  };

  const r = await fetch("https://api.openai.com/v1/responses", {
    method: "POST",
    headers: {
      "Authorization": `Bearer ${apiKey}`,
      "Content-Type": "application/json",
    },
    body: JSON.stringify(body),
  });

  if (!r.ok) {
    const txt = await r.text();
    throw new Error(`OpenAI error ${r.status}: ${txt}`);
  }
  const json = await r.json();
  // Many SDKs provide output_text; here we return raw for flexibility.
  return json;
}
