import { assetPath } from "../utils/assetPath";

export type MediaType = "image" | "video";

export interface MediaItem {
  type: MediaType;
  src: string;
  alt: string;
  /** Video only — a still frame shown before playback/while loading. */
  poster?: string;
}

/**
 * A named cluster of media within one project — e.g. BaliHofesh's "Degree
 * Planner" and "Exam System" are two real, distinct subsystems that each
 * deserve their own visual story without splitting into separate project
 * cards. Single-group projects (AI Grading Engine, Relive) just render as
 * one flat gallery with no tab UI.
 */
export interface MediaGroup {
  label: string;
  items: MediaItem[];
}

export interface Project {
  id: string;
  name: string;
  category: string;
  tools: string;
  /** The hard part + outcome, one crisp sentence — not a full case study. */
  insight: string;
  media: MediaGroup[];
  link?: string;
}

// Three flagship products only. Every media item below is a real screenshot
// Timor captured himself from the live products (see PROJECTS_DIR) — not a
// stock/placeholder image and not fabricated. adminsettingbalihofesh.png was
// deliberately excluded: it exposes a live WhatsApp support number in
// plaintext, which fails the "sanitize personal/private data" bar this pass
// is held to.
//
// AI Grading Engine gets its own top-billed entry even though it technically
// lives inside the BaliHofesh repo — it's a distinct Applied AI case study
// (structured outputs, validation, shadow-mode safety), not a full-stack
// CRUD story, so it stays a separate project rather than a BaliHofesh
// sub-section. Its image is a pipeline-architecture diagram
// (public/images/work/grading-engine-architecture.svg), built directly from
// facts already verified elsewhere in this portfolio (techStack.ts,
// Career.tsx, About.tsx, WhatIDo.tsx) — not invented.
const PROJECTS_DIR = assetPath("images/projects");

export const projects: Project[] = [
  {
    id: "balihofesh",
    name: "BaliHofesh",
    category: "AI-powered student platform",
    tools:
      "React, TypeScript, Supabase, PostgreSQL, 51 edge functions, Stripe + Bit/Hyp",
    insight:
      "Solo-built: auth/RLS, two payment rails, a tutor marketplace and double-opt-in study-partner matching — real backend breadth, not CRUD.",
    media: [
      {
        label: "Platform",
        items: [
          {
            type: "image",
            src: `${PROJECTS_DIR}/balihofeshhome.png`,
            alt: "BaliHofesh homepage — semester planning, study groups, deals and events in one place",
          },
          {
            type: "image",
            src: `${PROJECTS_DIR}/admindashboardbalihofesh.png`,
            alt: "BaliHofesh admin control center — 30+ platform management modules",
          },
        ],
      },
      {
        label: "Degree Planner",
        items: [
          {
            type: "image",
            src: `${PROJECTS_DIR}/degreebuilder1.png`,
            alt: "Degree Planner onboarding — starting from existing progress or a fresh plan",
          },
          {
            type: "image",
            src: `${PROJECTS_DIR}/degreebuilder2.png`,
            alt: "Choosing a degree program, with credit requirements per track",
          },
          {
            type: "image",
            src: `${PROJECTS_DIR}/degreebuilder4.png`,
            alt: "Configuring program constraints — duration, summer semesters, pacing",
          },
          {
            type: "image",
            src: `${PROJECTS_DIR}/degreebuilder3.png`,
            alt: "The resulting semester-by-semester study plan with a smart course-placement bank",
          },
        ],
      },
      {
        label: "Exam System",
        items: [
          {
            type: "image",
            src: `${PROJECTS_DIR}/examengine1.png`,
            alt: "AI-powered exam bank — real past exams and drills, organized per course",
          },
          {
            type: "image",
            src: `${PROJECTS_DIR}/examengine2.png`,
            alt: "Course exam list with automatic AI answer-checking",
          },
        ],
      },
    ],
  },
  {
    id: "grading-engine",
    name: "AI Grading Engine",
    category: "Fail-closed LLM exam evaluation",
    tools:
      "OpenAI, shadow-mode calibration, rubric-secure grading, canonical schema pipeline",
    insight:
      "Never fabricates a score — new grading logic runs in an isolated shadow store until proven, before it ever touches a real grade.",
    media: [
      {
        label: "Architecture",
        items: [
          {
            type: "image",
            src: assetPath("images/work/grading-engine-architecture.svg"),
            alt: "AI Grading Engine pipeline: exam input, structured LLM output, Zod validation boundary, course rubric rules, a fail-closed gate, shadow-mode calibration, and final grade + feedback",
          },
        ],
      },
    ],
  },
  {
    id: "relive",
    name: "Relive",
    category: "Realtime multi-tenant event media",
    tools:
      "React, TypeScript, Supabase Realtime & Storage, two-layer AI moderation",
    insight:
      "Shipped for my own wedding, then generalized: signed uploads, server-rehashed content, and culturally-tunable AI moderation.",
    media: [
      {
        label: "Product",
        items: [
          {
            type: "image",
            src: `${PROJECTS_DIR}/Relive1.png`,
            alt: "Relive landing page — every guest's moment, on one screen and in everyone's pocket",
          },
          {
            type: "image",
            src: `${PROJECTS_DIR}/relivemobile.png`,
            alt: "Guest upload experience on mobile — polaroid-style gallery and one-tap upload",
          },
          {
            type: "image",
            src: `${PROJECTS_DIR}/relive2.png`,
            alt: "Live photo wall — a real-time slideshow designed for the venue's big screen",
          },
          {
            type: "image",
            src: `${PROJECTS_DIR}/relive3.png`,
            alt: "Event customization — backgrounds, themes and branding for the live wall",
          },
          {
            type: "image",
            src: `${PROJECTS_DIR}/relive4.png`,
            alt: "Custom QR table-card designs generated per event",
          },
          {
            type: "image",
            src: `${PROJECTS_DIR}/relive5.png`,
            alt: "Platform management — AI moderation, media review, and event analytics toggles",
          },
          {
            type: "image",
            src: `${PROJECTS_DIR}/reliveadminforcouple.png`,
            alt: "Couple-facing event editor — live wall styling and background selection",
          },
        ],
      },
    ],
  },
];
