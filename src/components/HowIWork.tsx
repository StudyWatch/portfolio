import { lazy, Suspense, useEffect, useRef, useState } from "react";
import "./styles/HowIWork.css";
import { assetPath } from "../utils/assetPath";
import ErrorBoundary from "./ErrorBoundary";

// One shared source file - see HowIWorkAvatar.tsx for how pushups1.glb and
// pushups2.glb were confirmed to be the same asset before consolidating.
const PUSHUPS_GLB = assetPath("models/pushups1.glb");

const HowIWorkAvatar = lazy(() => import("./HowIWorkAvatar"));

interface Trait {
  title: string;
  body: string;
}

// Every line here maps to something checkable in the Work section - no
// trait is listed unless a real project backs it up.
const TRAITS: Trait[] = [
  {
    title: "Ownership",
    body: "I take things from a rough idea through architecture, implementation, and the unglamorous parts - auth, payments, monitoring - that decide whether something survives contact with real users. BaliHofesh and Relive were both built and run by me, end to end.",
  },
  {
    title: "Creative Problem-Solving",
    body: "The obvious implementation is rarely the right one for a hard problem. The AI grading engine never trusts a new rule directly - it proves itself in an isolated shadow store first, because a wrong grade is worse than no grade.",
  },
  {
    title: "Curiosity",
    body: "I want to know why something works, not just that it does. That pull is what took me from calling an LLM API to building the evaluation logic, guardrails, and multi-stage pipelines that make its output trustworthy.",
  },
  {
    title: "Collaboration",
    body: "Before any of this I led intelligence-collection teams under real pressure - small groups, high stakes, no room to assume everyone's aligned. That instinct for clear handoffs and honest feedback carries straight into how I work with other engineers.",
  },
];

const HowIWork = () => {
  const sectionRef = useRef<HTMLDivElement | null>(null);
  // Two separate flags on purpose: `everNear` latches true the first time
  // the section gets close and never resets - that's what decides whether
  // the avatars mount/download at all, so scrolling past once doesn't
  // un-load them. `active` tracks CURRENT proximity and just gates the
  // already-mounted canvases' render loops, toggling freely as the user
  // scrolls back and forth.
  const [everNear, setEverNear] = useState(false);
  const [active, setActive] = useState(false);

  useEffect(() => {
    const node = sectionRef.current;
    if (!node) return;
    const observer = new IntersectionObserver(
      ([entry]) => {
        setActive(entry.isIntersecting);
        if (entry.isIntersecting) {
          setEverNear(true);
        }
      },
      { rootMargin: "400px 0px 400px 0px", threshold: 0 }
    );
    observer.observe(node);
    return () => observer.disconnect();
  }, []);

  return (
    <div className="how-i-work-section" ref={sectionRef}>
      <div className="how-i-work-header">
        <div className="how-i-work-avatar-col how-i-work-avatar-col-left">
          {window.innerWidth > 1024 && everNear && (
            <ErrorBoundary>
              <Suspense fallback={null}>
                <HowIWorkAvatar
                  modelPath={PUSHUPS_GLB}
                  viewAngle="threeQuarter"
                  active={active}
                />
              </Suspense>
            </ErrorBoundary>
          )}
        </div>
        <div className="how-i-work-heading">
          <div className="how-i-work-avatar-col-mobile">
            {window.innerWidth <= 1024 && everNear && (
              <ErrorBoundary>
                <Suspense fallback={null}>
                  <HowIWorkAvatar
                    modelPath={PUSHUPS_GLB}
                    viewAngle="threeQuarter"
                    active={active}
                  />
                </Suspense>
              </ErrorBoundary>
            )}
          </div>
          <h2>
            How I <span>Work</span>
          </h2>
          <p className="how-i-work-tagline">
            Hard work, curiosity, and ownership.
          </p>
        </div>
        <div className="how-i-work-avatar-col how-i-work-avatar-col-right">
          {window.innerWidth > 1024 && everNear && (
            <ErrorBoundary>
              <Suspense fallback={null}>
                <HowIWorkAvatar
                  modelPath={PUSHUPS_GLB}
                  viewAngle="side"
                  active={active}
                />
              </Suspense>
            </ErrorBoundary>
          )}
        </div>
      </div>
      <div className="how-i-work-grid">
        {TRAITS.map((trait, i) => (
          <div className="how-i-work-card" key={trait.title}>
            <span className="how-i-work-index">
              {String(i + 1).padStart(2, "0")}
            </span>
            <h3>{trait.title}</h3>
            <p>{trait.body}</p>
          </div>
        ))}
      </div>
    </div>
  );
};

export default HowIWork;
