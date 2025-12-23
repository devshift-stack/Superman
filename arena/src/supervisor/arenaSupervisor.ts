import type { ArenaRequest, ArenaResponse } from "./types.js";
import { supervisorRoute } from "./router.js";
import { verifyClaims } from "./verify.js";
import { callOpenAI } from "../providers/openai.js";
import { callAnthropic } from "../providers/anthropic.js";

export async function runArena(req: ArenaRequest): Promise<ArenaResponse> {
  const decision = supervisorRoute(req);

  if (decision.decision === "STOP_REQUIRED") {
    return {
      ok: false,
      supervisor: { decision: "STOP_REQUIRED", reason: decision.reason, stop_reasons: decision.stop_reasons },
    };
  }

  // Pre-verify any explicit claims
  const pre = verifyClaims(req);
  if (!pre.ok) {
    return {
      ok: false,
      supervisor: { decision: "STOP_REQUIRED", reason: "Claim verification failed (pre-check).", stop_reasons: pre.issues },
      verification: pre,
    };
  }

  const provider = decision.provider!;
  const out = provider === "openai" ? await callOpenAI(req) : await callAnthropic(req);

  return {
    ok: true,
    supervisor: { decision: "ROUTE", provider, reason: decision.reason, stop_reasons: decision.stop_reasons },
    provider_output: out,
    verification: pre,
  };
}

// Dual mode: Claude builds (code-heavy), OpenAI verifies (strict)
export async function runDualArena(req: ArenaRequest): Promise<ArenaResponse> {
  // First pass: force Claude
  const buildReq: ArenaRequest = { ...req, mode: "build", preferred_provider: "anthropic" };
  const build = await runArena(buildReq);
  if (!build.ok) return build;

  // Second pass: verify with OpenAI using the Claude output as context
  const verifyReq: ArenaRequest = {
    task: "Verify the produced work for completeness, evidence, and policy violations. If anything is unproven, return STOP_REQUIRED with explicit missing artefacts.",
    goal: req.goal,
    context: `ORIGINAL_TASK:\n${req.task}\n\nCLAUDE_OUTPUT(JSON):\n${JSON.stringify(build.provider_output).slice(0, 12000)}`,
    artefacts: req.artefacts ?? [],
    claims: req.claims ?? [],
    mode: "verify",
    preferred_provider: "openai",
  };

  const verify = await runArena(verifyReq);
  return {
    ok: verify.ok,
    supervisor: verify.supervisor,
    provider_output: { build: build.provider_output, verify: verify.provider_output },
    verification: { precheck: build.verification, verification: verify.verification },
  };
}
