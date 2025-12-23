import type { ArenaRequest } from "./types.js";

// Minimal claim/evidence verifier. Expand over time.
export function verifyClaims(req: ArenaRequest): { ok: boolean; issues: string[] } {
  const issues: string[] = [];
  const claims = (req.claims ?? []).map(c => c.toLowerCase());
  const artefacts = (req.artefacts ?? []).map(a => a.toLowerCase());

  // If someone claims SQL but no schema/migration file paths referenced -> issue
  const claimsSql = claims.some(c => c.includes("sql") || c.includes("schema") || c.includes("sqlite") || c.includes("postgres"));
  if (claimsSql && !artefacts.some(a => a.includes("schema") || a.includes("migrate") || a.includes(".sql") || a.includes("db"))) {
    issues.push("CLAIM_SQL_WITHOUT_DB_ARTEFACTS");
  }

  // If claims mention number of sources > 1 but no url list artefact path
  const claimsManySources = claims.some(c => c.match(/\b\d+\b/) && (c.includes("portal") || c.includes("source") || c.includes("url")));
  if (claimsManySources && !artefacts.some(a => a.includes("sources") || a.includes("urls") || a.includes("list"))) {
    issues.push("CLAIM_SOURCES_WITHOUT_SOURCE_LIST_ARTEFACT");
  }

  return { ok: issues.length === 0, issues };
}
