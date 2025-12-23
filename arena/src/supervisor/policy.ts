function envBool(name: string, def: boolean) {
  const v = process.env[name];
  if (v == null) return def;
  return v === "true" || v === "1";
}

export const policy = {
  allowPricing: envBool("ALLOW_PRICING", false),
  allowLegal: envBool("ALLOW_LEGAL", false),
};

export function detectPolicyViolations(text: string): string[] {
  const t = text.toLowerCase();
  const reasons: string[] = [];

  const pricingHints = ["preis", "pricing", "€", "$", "cost", "kosten", "angebot", "paket", "subscription"];
  const legalHints = ["recht", "legal", "haft", "gdpr", "dsgvo", "compliance", "vertrag", "terms", "datenschutz"];

  if (!policy.allowPricing && pricingHints.some(k => t.includes(k))) reasons.push("PRICING_NOT_ALLOWED");
  if (!policy.allowLegal && legalHints.some(k => t.includes(k))) reasons.push("LEGAL_NOT_ALLOWED");

  return reasons;
}
