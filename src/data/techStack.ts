import { assetPath } from "../utils/assetPath";

// Every DISTINCT technology here is backed by real, checkable evidence from
// Timor's actual projects (BaliHofesh's 50+ Supabase edge functions,
// Stripe/Bit/Hyp webhook handlers, cron-driven notification jobs, Sentry
// monitoring, Playwright suites, Zod-validated schemas, a 20-stage agentic
// exam-authoring pipeline; Relive's realtime moderation/upload pipeline; a
// Python/WeasyPrint booklet generator) - not a trend list. Nothing here
// should appear unless Timor can talk through how he actually used it.
//
// Some of the strongest/most recognizable logos below appear a second time
// (id suffixed "-2") - same real technology, same evidence, just repeated
// for cluster density. The original Moncy reference TechStack read as rich
// because it had many spheres pulling from a smaller set of recognizable
// logo textures, not because every sphere was a unique claim. These
// duplicates are that same decorative visual rhythm, not additional skill
// claims - see TechStack.tsx, which renders TECH_ITEMS 1:1 with no random
// selection, so which logo lands on which sphere is fully deterministic.

export type TechTier = "core" | "primary" | "supporting" | "aiTool";
export type TechKind = "logo" | "badge";

export interface TechItem {
  id: string;
  label: string;
  tier: TechTier;
  kind: TechKind;
  /** Image path, for kind: "logo" only. */
  image?: string;
  /** Badge background gradient (kind: "badge") or tint color (kind: "logo"). */
  color: string;
  colorAlt?: string;
  /** Short line shown on hover - what it was actually used for. */
  descriptor: string;
}

export const TECH_ITEMS: TechItem[] = [
  // --- Core: the technologies most of Timor's real work sits on ---
  {
    id: "react",
    label: "React",
    tier: "core",
    kind: "logo",
    image: assetPath("images/tech/react.webp"),
    color: "#61dafb",
    descriptor: "Production product interfaces",
  },
  {
    id: "typescript",
    label: "TypeScript",
    tier: "core",
    kind: "logo",
    image: assetPath("images/tech/typescript.webp"),
    color: "#3178c6",
    descriptor: "Typed, maintainable codebases",
  },
  {
    id: "supabase",
    label: "Supabase",
    tier: "core",
    kind: "logo",
    image: assetPath("images/tech/supabase.svg"),
    color: "#3ecf8e",
    descriptor: "Auth · Postgres · Edge Functions · Realtime",
  },
  {
    id: "postgresql",
    label: "PostgreSQL",
    tier: "core",
    kind: "logo",
    image: assetPath("images/tech/postgresql.svg"),
    color: "#4a90b8",
    descriptor: "Schema design · RLS-backed data · migrations",
  },
  {
    id: "openai",
    label: "OpenAI",
    tier: "core",
    kind: "logo",
    image: assetPath("images/tech/openai.svg"),
    color: "#c9d6d6",
    descriptor: "Structured outputs · evaluation pipelines",
  },

  // --- Primary: strong, regularly-used skills ---
  {
    id: "python",
    label: "Python",
    tier: "primary",
    kind: "logo",
    image: assetPath("images/tech/python.svg"),
    color: "#3776ab",
    colorAlt: "#2b5b82",
    descriptor: "Document/PDF generation tooling",
  },
  {
    id: "nodejs",
    label: "Node.js",
    tier: "primary",
    kind: "logo",
    image: assetPath("images/tech/nodejs.webp"),
    color: "#3c873a",
    descriptor: "Scripts, tooling, server runtimes",
  },
  {
    id: "vite",
    label: "Vite",
    tier: "primary",
    kind: "logo",
    image: assetPath("images/tech/vite.svg"),
    color: "#646cff",
    descriptor: "Fast dev & build tooling",
  },
  {
    id: "tailwind",
    label: "Tailwind",
    tier: "primary",
    kind: "logo",
    image: assetPath("images/tech/tailwind.svg"),
    color: "#38bdf8",
    descriptor: "Responsive design systems",
  },
  {
    id: "github",
    label: "GitHub",
    tier: "primary",
    kind: "logo",
    image: assetPath("images/tech/github.svg"),
    color: "#3a3f47",
    colorAlt: "#181b20",
    descriptor: "Version control & collaboration",
  },
  {
    id: "vercel",
    label: "Vercel",
    tier: "primary",
    kind: "logo",
    image: assetPath("images/tech/vercel.svg"),
    color: "#2a2a2a",
    colorAlt: "#050505",
    descriptor: "Production deployment",
  },
  {
    id: "stripe",
    label: "Stripe",
    tier: "primary",
    kind: "logo",
    image: assetPath("images/tech/stripe.svg"),
    color: "#635bff",
    colorAlt: "#4b3fd6",
    descriptor: "Payments, webhooks & checkout",
  },

  // --- Supporting: real engineering concepts, proven in production ---
  {
    id: "rls",
    label: "RLS",
    tier: "supporting",
    kind: "badge",
    color: "#4a90b8",
    colorAlt: "#2d5f7a",
    descriptor: "Row-level security policies",
  },
  {
    id: "webhooks",
    label: "Webhooks",
    tier: "supporting",
    kind: "badge",
    color: "#e0954f",
    colorAlt: "#b56a2c",
    descriptor: "Stripe, Bit/Hyp & Supabase events",
  },
  {
    id: "realtime",
    label: "Realtime",
    tier: "supporting",
    kind: "badge",
    color: "#3ecf8e",
    colorAlt: "#1f8f5f",
    descriptor: "Live sync across BaliHofesh & Relive",
  },
  {
    id: "edge-functions",
    label: "Edge Functions",
    tier: "supporting",
    kind: "badge",
    color: "#7fae94",
    colorAlt: "#4f7a63",
    descriptor: "50+ Deno functions in production",
  },
  {
    id: "cron",
    label: "Scheduled Jobs",
    tier: "supporting",
    kind: "badge",
    color: "#9c8cd6",
    colorAlt: "#6a5aa8",
    descriptor: "Cron-driven digests & notifications",
  },
  {
    id: "structured-outputs",
    label: "Structured JSON",
    tier: "supporting",
    kind: "badge",
    color: "#c9d6d6",
    colorAlt: "#8fa3a3",
    descriptor: "Canonical schemas for LLM output",
  },
  {
    id: "zod",
    label: "Validation",
    tier: "supporting",
    kind: "badge",
    color: "#3178c6",
    colorAlt: "#1e4e85",
    descriptor: "Zod-validated data boundaries",
  },
  {
    id: "playwright",
    label: "Playwright",
    tier: "supporting",
    kind: "logo",
    image: assetPath("images/tech/playwright.svg"),
    color: "#7ea0c9",
    colorAlt: "#4d6f96",
    descriptor: "End-to-end test coverage",
  },
  {
    id: "sentry",
    label: "Sentry",
    tier: "supporting",
    kind: "logo",
    image: assetPath("images/tech/sentry.svg"),
    color: "#e0954f",
    colorAlt: "#a8622a",
    descriptor: "Production error monitoring",
  },
  {
    id: "agentic",
    label: "Agentic Workflows",
    tier: "supporting",
    kind: "badge",
    color: "#c9a15a",
    colorAlt: "#8f6f34",
    descriptor: "Multi-stage AI pipeline orchestration",
  },

  // --- AI dev tools: how Timor builds, kept visually distinct from the
  // engineering technologies above - a workflow, not a technology ---
  {
    id: "claude-code",
    label: "Claude Code",
    tier: "aiTool",
    kind: "badge",
    color: "#d97757",
    colorAlt: "#a8563a",
    descriptor: "Agentic development workflow",
  },
  {
    id: "codex",
    label: "Codex",
    tier: "aiTool",
    kind: "badge",
    color: "#6b7280",
    colorAlt: "#3f434a",
    descriptor: "AI-assisted engineering workflow",
  },

  // --- Repeated logos: cluster density, not new claims (see file header) -
  // same id/tier/scale as the original, just a second sphere so these read
  // visually distance-recognizable ---
  {
    id: "react-2",
    label: "React",
    tier: "core",
    kind: "logo",
    image: assetPath("images/tech/react.webp"),
    color: "#61dafb",
    descriptor: "Production product interfaces",
  },
  {
    id: "typescript-2",
    label: "TypeScript",
    tier: "core",
    kind: "logo",
    image: assetPath("images/tech/typescript.webp"),
    color: "#3178c6",
    descriptor: "Typed, maintainable codebases",
  },
  {
    id: "supabase-2",
    label: "Supabase",
    tier: "core",
    kind: "logo",
    image: assetPath("images/tech/supabase.svg"),
    color: "#3ecf8e",
    descriptor: "Auth · Postgres · Edge Functions · Realtime",
  },
  {
    id: "postgresql-2",
    label: "PostgreSQL",
    tier: "core",
    kind: "logo",
    image: assetPath("images/tech/postgresql.svg"),
    color: "#4a90b8",
    descriptor: "Schema design · RLS-backed data · migrations",
  },
  {
    id: "openai-2",
    label: "OpenAI",
    tier: "core",
    kind: "logo",
    image: assetPath("images/tech/openai.svg"),
    color: "#c9d6d6",
    descriptor: "Structured outputs · evaluation pipelines",
  },
  {
    id: "python-2",
    label: "Python",
    tier: "primary",
    kind: "logo",
    image: assetPath("images/tech/python.svg"),
    color: "#3776ab",
    colorAlt: "#2b5b82",
    descriptor: "Document/PDF generation tooling",
  },
  {
    id: "nodejs-2",
    label: "Node.js",
    tier: "primary",
    kind: "logo",
    image: assetPath("images/tech/nodejs.webp"),
    color: "#3c873a",
    descriptor: "Scripts, tooling, server runtimes",
  },
  {
    id: "vite-2",
    label: "Vite",
    tier: "primary",
    kind: "logo",
    image: assetPath("images/tech/vite.svg"),
    color: "#646cff",
    descriptor: "Fast dev & build tooling",
  },
  {
    id: "tailwind-2",
    label: "Tailwind",
    tier: "primary",
    kind: "logo",
    image: assetPath("images/tech/tailwind.svg"),
    color: "#38bdf8",
    descriptor: "Responsive design systems",
  },
  {
    id: "github-2",
    label: "GitHub",
    tier: "primary",
    kind: "logo",
    image: assetPath("images/tech/github.svg"),
    color: "#3a3f47",
    colorAlt: "#181b20",
    descriptor: "Version control & collaboration",
  },
];
