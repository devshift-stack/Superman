import type { ArenaRequest, Decision, Provider } from "./types.js";
import { detectPolicyViolations } from "./policy.js";

function estimateComplexity(task: string): number {
  // tiny heuristic: longer + code words => higher complexity
  const t = task.toLowerCase();
  let score = Math.min(10, Math.floor(task.length / 120));
  const codeWords = ["refactor", "typescript", "node", "sql", "schema", "api", "docker", "kubernetes", "frontend", "backend"];
  if (codeWords.some(w => t.includes(w))) score += 3;
  if (t.includes("many files") || t.includes("multi")) score += 2;
  return Math.min(10, score);
}

function chooseProvider(req: ArenaRequest): Provider {
  if (req.preferred_provider) return req.preferred_provider;

  const t = (req.task + " " + (req.goal ?? "")).toLowerCase();
  const complexity = estimateComplexity(req.task);

  // Heuristic:
  // - Claude: big refactors / large code generation
  // - OpenAI: verification, policy/consistency, structured checks
  if (req.mode === "verify") return "openai";
  if (t.includes("refactor") || t.includes("rewrite") || complexity >= 6) return "anthropic";
  if (t.includes("audit") || t.includes("verify") || t.includes("check")) return "openai";
  return "openai";
}

export function supervisorRoute(req: ArenaRequest): Decision {
  const text = `${req.task}\n${req.goal ?? ""}\n${req.context ?? ""}`;
  const violations = detectPolicyViolations(text);
  if (violations.length) {
    return {
      decision: "STOP_REQUIRED",
      reason: "Policy violation detected (pricing/legal not allowed).",
      stop_reasons: violations,
    };
  }

  // Evidence rule (soft-stop): if user claims something big but no artefacts provided, stop.
  const claims = (req.claims ?? []).join(" ").toLowerCase();
  const bigClaim = ["scraped", "10", "hundreds", "deployed", "production", "live"].some(k => claims.includes(k));
  if (bigClaim && (!req.artefacts || req.artefacts.length === 0)) {
    return {
      decision: "STOP_REQUIRED",
      reason: "Claims provided but no artefacts/evidence paths were included.",
      stop_reasons: ["UNPROVEN_CLAIM_NO_ARTEFACTS"],
    };
  }

  const provider = chooseProvider(req);
  return {
    decision: "ROUTE",
    provider,
    reason: `Routed by supervisor heuristic (mode=${req.mode ?? "mixed"}).`,
    stop_reasons: [],
  };
}
