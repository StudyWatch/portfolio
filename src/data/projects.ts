import { assetPath } from "../utils/assetPath";

export type MediaType = "image" | "video";

export interface MediaItem {
  type: MediaType;
  src: string;
  alt: string;
  /** Video only - a still frame shown before playback/while loading. */
  poster?: string;
}

/**
 * A named cluster of media within one project - e.g. BaliHofesh's "Degree
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
  /** The umbrella system this project belongs to, shown as a small kicker above the name - e.g. "BaliHofesh". Omitted for standalone products. */
  system?: string;
  name: string;
  category: string;
  tools: string;
  /** The hard part + outcome, one crisp sentence - not a full case study. */
  insight: string;
  /** Omitted (or empty) renders a text-only card instead of ProjectGallery - for projects with no curated screenshots yet, rather than inventing media. */
  media?: MediaGroup[];
  link?: string;
}

// Five featured moments, not five separate companies - BaliHofesh is one
// real system, but the Degree Planner and the Exam/AI Grading Engine are
// each substantial enough to earn their own full presentation stop in the
// Work journey rather than being buried as tabs inside one card. The
// `system` field carries that relationship in the copy ("BaliHofesh -
// Featured System - Degree Planner") without pretending they're separate
// products. The former standalone "AI Grading Engine" card is folded into
// the Exam System moment here - same real system (BaliHofesh's AI-checked
// exam bank), same architecture diagram, just presented as one moment
// instead of two.
//
// Order is deliberate, not chronological: BaliHofesh first (largest, most
// substantial), then Relive second so the first three featured moments
// don't all read as the same product - variety before circling back to the
// deeper BaliHofesh engineering systems, then closing on StudyWatch.
//
// Every media item below is a real screenshot Timor captured himself from
// the live products (see PROJECTS_DIR) - not a stock/placeholder image and
// not fabricated. adminsettingbalihofesh.png was deliberately excluded: it
// exposes a live WhatsApp support number in plaintext, which fails the
// "sanitize personal/private data" bar this pass is held to. StudyWatch has
// no curated screenshots available, so it renders as a text card (see
// ProjectGallery's fallback) rather than an invented gallery - its copy is
// the same accurate description already used for it in Other Work, not new
// claims.
const PROJECTS_DIR = assetPath("images/projects");

export const projects: Project[] = [
  {
    id: "balihofesh-platform",
    system: "BaliHofesh",
    name: "BaliHofesh",
    category: "Featured System - Platform Overview",
    tools:
      "React, TypeScript, Supabase, PostgreSQL, 51 edge functions, Stripe + Bit/Hyp",
    insight:
      "Solo-built: auth/RLS, two payment rails, a tutor marketplace and double-opt-in study-partner matching - real backend breadth, not CRUD.",
    media: [
      {
        label: "Platform",
        items: [
          {
            type: "image",
            src: `${PROJECTS_DIR}/balihofeshhome.png`,
            alt: "BaliHofesh homepage - semester planning, study groups, deals and events in one place",
          },
          {
            type: "image",
            src: `${PROJECTS_DIR}/admindashboardbalihofesh.png`,
            alt: "BaliHofesh admin control center - 30+ platform management modules",
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
            alt: "Relive landing page - every guest's moment, on one screen and in everyone's pocket",
          },
          {
            type: "image",
            src: `${PROJECTS_DIR}/relivemobile.png`,
            alt: "Guest upload experience on mobile - polaroid-style gallery and one-tap upload",
          },
          {
            type: "image",
            src: `${PROJECTS_DIR}/relive2.png`,
            alt: "Live photo wall - a real-time slideshow designed for the venue's big screen",
          },
          {
            type: "image",
            src: `${PROJECTS_DIR}/relive3.png`,
            alt: "Event customization - backgrounds, themes and branding for the live wall",
          },
          {
            type: "image",
            src: `${PROJECTS_DIR}/relive4.png`,
            alt: "Custom QR table-card designs generated per event",
          },
          {
            type: "image",
            src: `${PROJECTS_DIR}/relive5.png`,
            alt: "Platform management - AI moderation, media review, and event analytics toggles",
          },
          {
            type: "image",
            src: `${PROJECTS_DIR}/reliveadminforcouple.png`,
            alt: "Couple-facing event editor - live wall styling and background selection",
          },
        ],
      },
    ],
  },
  {
    id: "balihofesh-degree-planner",
    system: "BaliHofesh",
    name: "BaliHofesh",
    category: "Featured System - Degree Planner",
    tools: "React, TypeScript, Supabase, constraint-based scheduling",
    insight:
      "A smart course-placement bank fits real degree requirements around each student's own constraints - pacing, summer semesters, credits already earned - not a static checklist.",
    media: [
      {
        label: "Degree Planner",
        items: [
          {
            type: "image",
            src: `${PROJECTS_DIR}/degreebuilder1.png`,
            alt: "Degree Planner onboarding - starting from existing progress or a fresh plan",
          },
          {
            type: "image",
            src: `${PROJECTS_DIR}/degreebuilder2.png`,
            alt: "Choosing a degree program, with credit requirements per track",
          },
          {
            type: "image",
            src: `${PROJECTS_DIR}/degreebuilder4.png`,
            alt: "Configuring program constraints - duration, summer semesters, pacing",
          },
          {
            type: "image",
            src: `${PROJECTS_DIR}/degreebuilder3.png`,
            alt: "The resulting semester-by-semester study plan with a smart course-placement bank",
          },
        ],
      },
    ],
  },
  {
    id: "balihofesh-exam-system",
    system: "BaliHofesh",
    name: "BaliHofesh",
    category: "Featured System - Exam / AI Exam Engine",
    tools:
      "OpenAI, Supabase, shadow-mode calibration, canonical schema pipeline",
    insight:
      "An AI-checked exam bank backed by a fail-closed grading engine - new grading logic proves itself in an isolated shadow store before it ever touches a real grade. Never fabricates a score.",
    media: [
      {
        label: "Exam Bank",
        items: [
          {
            type: "image",
            src: `${PROJECTS_DIR}/examengine1.png`,
            alt: "AI-powered exam bank - real past exams and drills, organized per course",
          },
          {
            type: "image",
            src: `${PROJECTS_DIR}/examengine2.png`,
            alt: "Course exam list with automatic AI answer-checking",
          },
        ],
      },
      {
        label: "Grading Architecture",
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
    id: "studywatch",
    name: "StudyWatch",
    category: "Language-learning platform",
    tools: "React, Node.js, PostgreSQL, AI word extraction",
    insight:
      "Extracts vocabulary from real TV episodes and turns it into quizzes and games - earlier full-stack work, built solo end to end.",
    link: "https://studywatch-swart.vercel.app/",
  },
];
