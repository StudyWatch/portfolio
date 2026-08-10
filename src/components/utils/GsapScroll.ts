import * as THREE from "three";
import gsap from "gsap";
import { activeAvatarProfile } from "../Character/avatarProfile";
import type { CommandScreens } from "../Character/utils/screens";
import type { CameraPlan } from "../Character/utils/cameraFit";

// setCharTimeline creates two persistent, non-ScrollTrigger-driven
// resources (the glow-intensity interval and the infinite screen-glow
// timeline) that keep running/ticking forever once started. handleResize
// calls setCharTimeline again on every resize/orientation change, so
// without explicit ownership here each call would leave the previous
// interval and timeline running underneath the new ones - accumulating
// duplicate glow loops indefinitely. Track the currently-owned instances
// at module scope and kill/clear them before creating new ones.
let glowInterval: ReturnType<typeof setInterval> | undefined;
let glowTimeline: gsap.core.Timeline | undefined;

export function clearCharTimelineResources() {
  if (glowInterval !== undefined) {
    clearInterval(glowInterval);
    glowInterval = undefined;
  }
  if (glowTimeline) {
    glowTimeline.kill();
    glowTimeline = undefined;
  }
}

export function setCharTimeline(
  character: THREE.Object3D<THREE.Object3DEventMap> | null,
  camera: THREE.PerspectiveCamera,
  screens: CommandScreens,
  characterSize: THREE.Vector3,
  cameraPlan: CameraPlan
) {
  clearCharTimelineResources();

  // Every camera move below is expressed as an offset from the camera's
  // already-fitted base position, scaled to the avatar's own height (`unit`)
  // - never an absolute world coordinate. That's what keeps the landing →
  // about → whatIDo moves reading as one continuous camera move instead of
  // three independently-tuned jumps, and keeps it correct regardless of
  // which avatar (placeholder or final) is mounted.
  const unit = characterSize.y;
  const baseCameraPos = camera.position.clone();

  // The camera's look-AT point is animated alongside its position - a
  // plain object GSAP can tween, applied via onUpdate. Without this the
  // rotation set once in Scene.tsx would stay frozen at the hero framing
  // while position moves, so pulling back for the body reveal would aim
  // at the wrong point instead of recomposing the shot.
  const gazeTarget = cameraPlan.heroTarget.clone();
  const applyGaze = () => camera.lookAt(gazeTarget);

  let intensity: number = 0;
  glowInterval = setInterval(() => {
    intensity = Math.random();
  }, 200);
  const tl1 = gsap.timeline({
    scrollTrigger: {
      trigger: ".landing-section",
      start: "top top",
      end: "bottom top",
      scrub: true,
      invalidateOnRefresh: true,
    },
  });
  const tl2 = gsap.timeline({
    scrollTrigger: {
      trigger: ".about-section",
      start: "center 55%",
      end: "bottom top",
      scrub: true,
      invalidateOnRefresh: true,
    },
  });
  // This trigger deliberately runs LONGER than ".whatIDO" itself - it ends
  // once How I Work's own top has scrolled to viewport center, not at
  // WhatIDo's bottom edge. character-model is position:fixed, so its exit
  // has to be FULLY complete (not partway through a short scrub range)
  // before How I Work's heading/avatar are meaningfully on screen, or the
  // still-visible character overlaps them. Cramming "screens reveal + hold
  // + exit" into just WhatIDo's own (short) height was exactly what caused
  // the character to still be exiting mid-way through How I Work.
  const tl3 = gsap.timeline({
    scrollTrigger: {
      trigger: ".whatIDO",
      start: "top top",
      endTrigger: ".how-i-work-section",
      end: "top center",
      scrub: true,
      invalidateOnRefresh: true,
    },
  });
  // Reactive "screen glow" - the center display's flicker drives the point
  // light (see lighting.ts), the same emissive->light coupling technique as
  // the reference project, just pointed at our own procedural screens.
  glowTimeline = gsap
    .timeline({ repeat: -1, repeatRefresh: true })
    .to(screens.keyMaterial, {
      emissiveIntensity: () => 1.2 + intensity * 2.2,
      duration: () => Math.random() * 0.6,
      delay: () => Math.random() * 0.1,
    });

  const neckBone = activeAvatarProfile.bones.neck
    ? character?.getObjectByName(activeAvatarProfile.bones.neck)
    : undefined;

  if (window.innerWidth > 1024) {
    if (character) {
      tl1
        .fromTo(character.rotation, { y: 0 }, { y: 0.7, duration: 1 }, 0)
        .to(
          camera.position,
          { z: baseCameraPos.z - unit * 0.05, onUpdate: applyGaze },
          0
        )
        .fromTo(".character-model", { x: 0 }, { x: "-15%", duration: 1 }, 0)
        .to(".landing-container", { opacity: 0, duration: 0.4 }, 0)
        .to(".landing-container", { y: "40%", duration: 0.8 }, 0)
        .fromTo(".about-me", { y: "-50%" }, { y: "0%" }, 0);

      tl2
        .to(
          gazeTarget,
          {
            x: cameraPlan.bodyTarget.x,
            y: cameraPlan.bodyTarget.y,
            z: cameraPlan.bodyTarget.z,
            duration: 6,
            delay: 2,
            ease: "power3.inOut",
          },
          0
        )
        .to(
          camera.position,
          {
            x: cameraPlan.bodyTarget.x,
            y: cameraPlan.bodyTarget.y,
            z: cameraPlan.bodyTarget.z + cameraPlan.bodyDistance,
            duration: 6,
            delay: 2,
            ease: "power3.inOut",
            onUpdate: applyGaze,
          },
          0
        )
        .to(".about-section", { y: "30%", duration: 6 }, 0)
        .to(".about-section", { opacity: 0, delay: 3, duration: 2 }, 0)
        .fromTo(
          ".character-model",
          { pointerEvents: "inherit" },
          { pointerEvents: "none", x: "-8%", delay: 2, duration: 5 },
          0
        )
        .to(character.rotation, { y: 0.92, x: 0.12, delay: 3, duration: 3 }, 0)
        .fromTo(
          ".what-box-in",
          { display: "none" },
          { display: "flex", duration: 0.1, delay: 6 },
          0
        )
        .fromTo(
          screens.group.position,
          { y: screens.group.position.y - unit * 0.35 },
          { y: screens.group.position.y, delay: 1.5, duration: 3 },
          0
        )
        .fromTo(
          ".character-rim",
          { opacity: 1, scaleX: 1.4 },
          { opacity: 0, scale: 0, y: "-70%", duration: 5, delay: 2 },
          0.3
        );

      if (neckBone) {
        tl2.to(neckBone.rotation, { x: 0.6, delay: 2, duration: 3 }, 0);
      }

      // Screens deliberately do NOT fade in here. They used to (tied to
      // this same About-section scrub), which meant they were already
      // fully opaque before the user had even reached the WhatIDo
      // trigger - covering "Applied AI"/"Full-Stack" the moment those
      // cards appeared. Their reveal now lives entirely in tl3, sequenced
      // as its own beat after WhatIDo has had scroll time to be read. See
      // screens.ts: materials start at opacity 0, so simply not touching
      // them here is enough to keep them hidden through this whole pull-back.

      // WhatIDo's own beat: nothing here - the section's cards are already
      // driven by their own reveal (see WhatIDo.tsx / the `what-box-in`
      // tween below), and get the full 0–25% of this (now much longer)
      // scrub to be read with nothing overlapping them.
      tl3
        // 20%–40%: the project command surface gets its own reveal -
        // screens fade in one at a time, with the character turning
        // slightly back toward them as if presenting the work.
        .to(character.rotation, { y: 0.55, duration: 1.6, delay: 1.6 }, 0)
        // 40%–62%: hold - screens fully visible and readable, character
        // still present, nothing else moving. This is the beat where the
        // project screens are the main focus, per spec.
        // 62%–100%: exit. Character (and everything in its canvas, screens
        // included) slides off together, with the full remaining range to
        // complete in - well clear of How I Work's own content.
        .fromTo(
          ".character-model",
          { y: "0%" },
          { y: "-100%", duration: 3.2, ease: "none", delay: 5 },
          0
        )
        .fromTo(".whatIDO", { y: 0 }, { y: "15%", duration: 2 }, 0)
        .to(character.rotation, { x: -0.04, duration: 2, delay: 5 }, 0);

      screens.materials.forEach((material, i) => {
        tl3.to(material, { opacity: 1, duration: 0.7, delay: 1.8 + i * 0.3 }, 0);
        if (material !== screens.keyMaterial) {
          tl3.to(
            material,
            { emissiveIntensity: 1.1, duration: 0.7, delay: 2.2 + i * 0.3 },
            0
          );
        }
      });
    }
  } else {
    if (character) {
      const tM2 = gsap.timeline({
        scrollTrigger: {
          trigger: ".what-box-in",
          start: "top 70%",
          end: "bottom top",
        },
      });
      tM2.to(".what-box-in", { display: "flex", duration: 0.1, delay: 0 }, 0);
    }
  }
}

export function setAllTimeline() {
  const careerTimeline = gsap.timeline({
    scrollTrigger: {
      trigger: ".career-section",
      start: "top 30%",
      end: "100% center",
      scrub: true,
      invalidateOnRefresh: true,
    },
  });
  careerTimeline
    .fromTo(
      ".career-timeline",
      { maxHeight: "10%" },
      { maxHeight: "100%", duration: 0.5 },
      0
    )

    .fromTo(
      ".career-timeline",
      { opacity: 0 },
      { opacity: 1, duration: 0.1 },
      0
    )
    .fromTo(
      ".career-info-box",
      { opacity: 0 },
      { opacity: 1, stagger: 0.1, duration: 0.5 },
      0
    )
    .fromTo(
      ".career-dot",
      { animationIterationCount: "infinite" },
      {
        animationIterationCount: "1",
        delay: 0.3,
        duration: 0.1,
      },
      0
    );

  if (window.innerWidth > 1024) {
    careerTimeline.fromTo(
      ".career-section",
      { y: 0 },
      { y: "20%", duration: 0.5, delay: 0.2 },
      0
    );
  } else {
    careerTimeline.fromTo(
      ".career-section",
      { y: 0 },
      { y: 0, duration: 0.5, delay: 0.2 },
      0
    );
  }
}
