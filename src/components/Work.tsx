import "./styles/Work.css";
import ProjectGallery from "./ProjectGallery";
import gsap from "gsap";
import { ScrollTrigger } from "gsap/ScrollTrigger";
import { useGSAP } from "@gsap/react";
import { projects } from "../data/projects";

gsap.registerPlugin(useGSAP);

const DESKTOP_BREAKPOINT = 1024;

const Work = () => {
  useGSAP(() => {
    // Mobile gets a plain stacked-vertical layout (see Work.css) — no pin,
    // no horizontal rail. Trying to reuse the desktop pin/translate rig at
    // narrow widths was the root cause of "I mostly just see Relive on
    // mobile": the horizontal geometry doesn't translate to a column layout
    // at all.
    if (window.innerWidth <= DESKTOP_BREAKPOINT) return;

    let trigger: ScrollTrigger | undefined;
    let timeline: gsap.core.Timeline | undefined;

    // Three-phase choreography: (1) an entrance "dwell" where scrolling is
    // consumed but nothing moves — so project 1 (already fully visible the
    // instant the pin engages, since each .work-box is sized to fit inside
    // the pinned viewport) gets real reading time instead of starting to
    // slide away on the very first wheel tick; (2) the horizontal journey
    // through each project, itself broken into move/dwell segments so every
    // stop gets a readable rest, not just a snapshot mid-slide; (3) an exit
    // dwell once the final project fully arrives, before the pin releases.
    // Dwell/move budgets are in "px" units that map 1:1 to real scroll
    // pixels — see the `end` calculation below, which sums the exact same
    // numbers, so GSAP's scrub stretches the whole timeline across exactly
    // that many scrolled pixels.
    function buildTimeline() {
      trigger?.kill();
      timeline?.kill();

      const boxes = document.querySelectorAll<HTMLElement>(".work-box");
      if (!boxes.length) return;

      const container = document.querySelector(".work-container");
      if (!container) return;

      const rectLeft = container.getBoundingClientRect().left;
      const rect = boxes[0].getBoundingClientRect();
      const parentWidth = boxes[0].parentElement!.getBoundingClientRect().width;
      const padding = parseInt(window.getComputedStyle(boxes[0]).padding) / 2;
      const translateX =
        rect.width * boxes.length - (rectLeft + parentWidth) + padding;
      const stepCount = boxes.length - 1;
      const stepDistance = stepCount > 0 ? translateX / stepCount : 0;

      const vh = window.innerHeight;
      const entranceDwellPx = Math.round(vh * 0.55);
      const movePx = Math.round(vh * 0.55);
      const interDwellPx = Math.round(vh * 0.5);
      const exitDwellPx = Math.round(vh * 0.6);

      const totalPx =
        entranceDwellPx +
        movePx * stepCount +
        interDwellPx * Math.max(0, stepCount - 1) +
        exitDwellPx;

      // Snap to the boundary between every dwell/move segment — releasing
      // mid-move always completes (or reverts) that step instead of leaving
      // a project half-slid-in; releasing inside a dwell zone is already
      // resting, so the snap is a no-op there.
      const snapPoints: number[] = [0];
      let cursor = entranceDwellPx;
      snapPoints.push(cursor / totalPx);
      for (let i = 0; i < stepCount; i++) {
        cursor += movePx;
        snapPoints.push(cursor / totalPx);
        if (i < stepCount - 1) {
          cursor += interDwellPx;
          snapPoints.push(cursor / totalPx);
        }
      }
      snapPoints.push(1);

      timeline = gsap.timeline({
        scrollTrigger: {
          trigger: ".work-section",
          start: "top top",
          end: `+=${totalPx}`,
          scrub: true,
          pin: true,
          id: "work",
          snap: {
            snapTo: snapPoints,
            duration: { min: 0.2, max: 0.6 },
            ease: "power1.inOut",
          },
        },
      });
      trigger = timeline.scrollTrigger!;

      timeline.to({}, { duration: entranceDwellPx });
      for (let i = 1; i <= stepCount; i++) {
        timeline.to(".work-flex", {
          x: -stepDistance * i,
          duration: movePx,
          ease: "none",
        });
        if (i < stepCount) {
          timeline.to({}, { duration: interDwellPx });
        }
      }
      timeline.to({}, { duration: exitDwellPx });
    }

    buildTimeline();

    let resizeTimeout: ReturnType<typeof setTimeout>;
    const onResize = () => {
      clearTimeout(resizeTimeout);
      resizeTimeout = setTimeout(() => {
        // Crossing the desktop/mobile breakpoint mid-session is a rare
        // enough edge case (device rotation on a tablet at the boundary)
        // that a full reload-quality rebuild isn't worth the complexity —
        // only rebuild while still on the desktop side.
        if (window.innerWidth > DESKTOP_BREAKPOINT) buildTimeline();
      }, 200);
    };
    window.addEventListener("resize", onResize);

    // Gallery screenshots load asynchronously; refreshing once they're in
    // (and once webfonts settle) catches any late layout shift — this
    // affects where the trigger's "top" starts (page content above it
    // reflowing), not the pixel budgets above, which stay valid across a
    // refresh since `end` is relative to `start`.
    const images = Array.from(
      document.querySelectorAll<HTMLImageElement>(".work-flex img")
    );
    Promise.all([
      document.fonts?.ready ?? Promise.resolve(),
      ...images.map((img) =>
        img.complete
          ? Promise.resolve()
          : new Promise<void>((resolve) => {
              img.addEventListener("load", () => resolve(), { once: true });
              img.addEventListener("error", () => resolve(), { once: true });
            })
      ),
    ]).then(() => ScrollTrigger.refresh());

    return () => {
      window.removeEventListener("resize", onResize);
      timeline?.kill();
      trigger?.kill();
    };
  }, []);
  return (
    <div className="work-section" id="work">
      <div className="work-container section-container">
        <h2>
          My <span>Work</span>
        </h2>
        <div className="work-flex">
          {projects.map((project, index) => (
            <div className="work-box" key={project.id}>
              <div className="work-info">
                <div className="work-title">
                  <h3>0{index + 1}</h3>

                  <div>
                    {project.system && (
                      <span className="work-system">{project.system}</span>
                    )}
                    <h4>{project.name}</h4>
                    <p>{project.category}</p>
                  </div>
                </div>
                <h4>Tools and features</h4>
                <p>{project.tools}</p>
                <h4>The hard part</h4>
                <p>{project.insight}</p>
              </div>
              {project.media && project.media.length > 0 ? (
                <ProjectGallery
                  groups={project.media}
                  projectName={project.name}
                  link={project.link}
                />
              ) : (
                <div className="work-textcard">
                  <span className="work-textcard-mark">{project.name}</span>
                  <p className="work-textcard-tagline">{project.category}</p>
                  {project.link && (
                    <a
                      className="work-textcard-link"
                      href={project.link}
                      target="_blank"
                      rel="noreferrer"
                      data-cursor="disable"
                    >
                      Visit live product ↗
                    </a>
                  )}
                </div>
              )}
            </div>
          ))}
        </div>
      </div>
    </div>
  );
};

export default Work;
