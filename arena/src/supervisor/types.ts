export type Provider = "openai" | "anthropic";

export type Decision =
  | { decision: "STOP_REQUIRED"; reason: string; stop_reasons: string[] }
  | { decision: "ROUTE"; provider: Provider; reason: string; stop_reasons: string[] };

export type ArenaRequest = {
  task: string;
  goal?: string;
  context?: string;
  artefacts?: string[];   // optional evidence paths
  claims?: string[];      // optional explicit claims
  preferred_provider?: Provider; // optional hint
  mode?: "build" | "verify" | "mixed";
};

export type ArenaResponse = {
  ok: boolean;
  supervisor: {
    decision: "STOP_REQUIRED" | "ROUTE";
    provider?: Provider;
    reason: string;
    stop_reasons: string[];
  };
  provider_output?: any;
  verification?: any;
};
