import "./styles/Work.css";
import ProjectGallery from "./ProjectGallery";
import gsap from "gsap";
import { ScrollTrigger } from "gsap/ScrollTrigger";
import { useGSAP } from "@gsap/react";
import { projects } from "../data/projects";

gsap.registerPlugin(useGSAP);

const Work = () => {
  useGSAP(() => {
    let translateX = 0;

    function setTranslateX() {
      const box = document.getElementsByClassName("work-box");
      const rectLeft = document
        .querySelector(".work-container")!
        .getBoundingClientRect().left;
      const rect = box[0].getBoundingClientRect();
      const parentWidth = box[0].parentElement!.getBoundingClientRect().width;
      const padding = parseInt(window.getComputedStyle(box[0]).padding) / 2;
      translateX =
        rect.width * box.length - (rectLeft + parentWidth) + padding;
    }

    // The bug this fixes: translateX was computed exactly once at mount and
    // baked as a plain number into the ScrollTrigger's `end` and the tween's
    // `x`. Any layout change after that first measurement — the browser
    // window resizing, a webfont finishing its swap, gallery images
    // finishing loading — left the pin's reserved scroll distance
    // (pin-spacer height) permanently wrong relative to the real horizontal
    // scroll width. Too little reserved space meant the pin released early,
    // which is exactly what made Other Work start overlapping Work instead
    // of cleanly after it. Function-based `end`/`x` plus `invalidateOnRefresh`
    // re-run this measurement every time ScrollTrigger refreshes (window
    // resize does this automatically), so the geometry self-corrects instead
    // of going stale.
    setTranslateX();
    ScrollTrigger.addEventListener("refreshInit", setTranslateX);

    const timeline = gsap.timeline({
      scrollTrigger: {
        trigger: ".work-section",
        start: "top top",
        end: () => `+=${translateX}`,
        scrub: true,
        pin: true,
        id: "work",
        invalidateOnRefresh: true,
      },
    });

    timeline.to(".work-flex", {
      x: () => -translateX,
      ease: "none",
    });

    // Gallery screenshots load asynchronously; refreshing once they're in
    // (and once webfonts settle) catches any late layout shift the initial
    // measurement couldn't have known about yet.
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
      ScrollTrigger.removeEventListener("refreshInit", setTranslateX);
      timeline.kill();
      ScrollTrigger.getById("work")?.kill();
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
                    <h4>{project.name}</h4>
                    <p>{project.category}</p>
                  </div>
                </div>
                <h4>Tools and features</h4>
                <p>{project.tools}</p>
                <h4>The hard part</h4>
                <p>{project.insight}</p>
              </div>
              <ProjectGallery
                groups={project.media}
                projectName={project.name}
                link={project.link}
              />
            </div>
          ))}
        </div>
      </div>
    </div>
  );
};

export default Work;
