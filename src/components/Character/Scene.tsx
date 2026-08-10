import {
  useEffect,
  useRef,
  useState,
} from "react";

import * as THREE from "three";

import setCharacter from "./utils/character";
import setLighting from "./utils/lighting";

import { useLoading } from "../../context/LoadingProvider";

import handleResize from "./utils/resizeUtils";

import {
  handleMouseMove,
  handleTouchEnd,
  handleHeadRotation,
  handleTouchMove,
} from "./utils/mouseUtils";

import setAnimations from "./utils/animationUtils";
import { setProgress } from "../Loading";

import { activeAvatarProfile } from "./avatarProfile";

import {
  createCommandScreens,
  type CommandScreens,
} from "./utils/screens";

import { computeCameraPlan } from "./utils/cameraFit";

import {
  setCharTimeline,
  setAllTimeline,
  clearCharTimelineResources,
} from "../utils/GsapScroll";

import {
  createWaveController,
  type WaveController,
} from "./utils/wave";

const Scene = () => {
  const canvasDiv =
    useRef<HTMLDivElement | null>(
      null
    );

  const hoverDivRef =
    useRef<HTMLDivElement>(null);

  const sceneRef =
    useRef<THREE.Scene | null>(
      null
    );

  if (!sceneRef.current) {
    sceneRef.current =
      new THREE.Scene();
  }

  const { setLoading } =
    useLoading();

  const [, setChar] =
    useState<THREE.Object3D | null>(
      null
    );

  useEffect(() => {
    if (!canvasDiv.current) {
      return;
    }

    let cancelled = false;

    const rect =
      canvasDiv.current.getBoundingClientRect();

    const container = {
      width: rect.width,
      height: rect.height,
    };

    const aspect =
      container.width /
      container.height;

    const scene =
      sceneRef.current!;

    let renderer:
      THREE.WebGLRenderer;

    try {
      renderer =
        new THREE.WebGLRenderer({
          alpha: true,
          antialias: true,
        });

      renderer.setSize(
        container.width,
        container.height
      );

      // Desktop and mobile get different caps rather than a flat 2x: mobile
      // GPUs pay for every extra rendered pixel far more than desktop ones
      // do, and a phone's devicePixelRatio (often 3+) buys very little
      // perceptible sharpness past ~1.5x for this scene.
      const dprCap =
        window.innerWidth <= 1024 ? 1.5 : 1.75;

      renderer.setPixelRatio(
        Math.min(
          window.devicePixelRatio,
          dprCap
        )
      );

      renderer.toneMapping =
        THREE.ACESFilmicToneMapping;

      renderer.toneMappingExposure =
        1;

      canvasDiv.current.appendChild(
        renderer.domElement
      );
    } catch (error) {
      console.error(
        "[Scene] Failed to create WebGL renderer.",
        error
      );

      setLoading(100);

      return;
    }

    const camera =
      new THREE.PerspectiveCamera(
        14.5,
        aspect,
        0.1,
        1000
      );

    camera.position.set(
      0,
      4.5,
      27
    );

    camera.zoom = 1.1;

    camera.updateProjectionMatrix();

    let headBone:
      THREE.Object3D | null =
        null;

    let character:
      THREE.Object3D | null =
        null;

    let mixer:
      THREE.AnimationMixer |
      undefined;

    let screens:
      CommandScreens |
      undefined;

    let wave:
      WaveController | null =
        null;

    const clock =
      new THREE.Clock();

    const light =
      setLighting(scene);

    const progress =
      setProgress(
        (value) =>
          setLoading(value)
      );

    const {
      loadCharacter,
    } = setCharacter(
      renderer,
      scene,
      camera
    );

    let onResize:
      (() => void) | null =
        null;

    let introTimer:
      number | undefined;

    let waveTimer:
      number | undefined;

    loadCharacter()
      .then((gltf) => {
        if (
          cancelled ||
          !gltf
        ) {
          return;
        }

        const animations =
          setAnimations(
            gltf,
            activeAvatarProfile
          );

        if (
          hoverDivRef.current
        ) {
          animations.hover(
            gltf,
            hoverDivRef.current
          );
        }

        mixer =
          animations.mixer;

        character =
          gltf.scene;

        setChar(character);

        scene.add(character);

        headBone =
          character.getObjectByName(
            activeAvatarProfile
              .bones.head
          ) || null;

        const box =
          new THREE.Box3()
            .setFromObject(
              character
            );

        const size =
          new THREE.Vector3();

        box.getSize(size);

        const center =
          new THREE.Vector3();

        box.getCenter(center);

        screens =
          createCommandScreens(
            size,
            center
          );

        scene.add(
          screens.group
        );

        /**
         * NEW:
         * camera is passed into
         * the wave controller so
         * the palm can face the
         * actual viewer.
         */
        wave =
          createWaveController(
            character,
            activeAvatarProfile
              .bones,
            camera
          );

        const cameraPlan =
          computeCameraPlan(
            camera,
            character,
            headBone
          );

        camera.position.set(
          cameraPlan.heroTarget.x,
          cameraPlan.heroTarget.y,
          cameraPlan.heroTarget.z +
            cameraPlan.heroDistance
        );

        camera.lookAt(
          cameraPlan.heroTarget
        );

        camera.updateProjectionMatrix();

        setCharTimeline(
          character,
          camera,
          screens,
          size,
          cameraPlan
        );

        setAllTimeline();

        progress
          .loaded()
          .then(() => {
            if (cancelled) {
              return;
            }

            introTimer =
              window.setTimeout(
                () => {
                  if (
                    cancelled
                  ) {
                    return;
                  }

                  light.turnOnLights();

                  animations.startIntro();

                  /**
                   * Friendly greeting
                   * after hero settles.
                   */
                  waveTimer =
                    window.setTimeout(
                      () => {
                        if (
                          cancelled
                        ) {
                          return;
                        }

                        /**
                         * Do not wave if
                         * user already
                         * scrolled away.
                         */
                        if (
                          window.scrollY <=
                          window.innerHeight *
                            0.45
                        ) {
                          wave?.start();
                        }
                      },
                      1800
                    );
                },
                2500
              );
          });

        onResize = () =>
          handleResize(
            renderer,
            camera,
            canvasDiv,
            character!,
            screens!,
            headBone
          );

        window.addEventListener(
          "resize",
          onResize
        );
      })
      .catch((error) => {
        if (cancelled) {
          return;
        }

        console.error(
          "[Scene] Character failed to load.",
          error
        );

        progress.clear();
      });

    let mouse = {
      x: 0,
      y: 0,
    };

    let interpolation = {
      x: 0.07,
      y: 0.07,
    };

    const onMouseMove = (
      event: MouseEvent
    ) => {
      handleMouseMove(
        event,
        (x, y) => {
          mouse = {
            x,
            y,
          };
        }
      );
    };

    let debounce:
      number | undefined;

    const onTouchStart = (
      event: TouchEvent
    ) => {
      const element =
        event.target as HTMLElement;

      debounce =
        window.setTimeout(
          () => {
            element?.addEventListener(
              "touchmove",
              (
                e: TouchEvent
              ) =>
                handleTouchMove(
                  e,
                  (x, y) => {
                    mouse = {
                      x,
                      y,
                    };
                  }
                )
            );
          },
          200
        );
    };

    const onTouchEnd = () => {
      handleTouchEnd(
        (
          x,
          y,
          interpolationX,
          interpolationY
        ) => {
          mouse = {
            x,
            y,
          };

          interpolation = {
            x: interpolationX,
            y: interpolationY,
          };
        }
      );
    };

    document.addEventListener(
      "mousemove",
      onMouseMove
    );

    const landingDiv =
      document.getElementById(
        "landingDiv"
      );

    if (landingDiv) {
      landingDiv.addEventListener(
        "touchstart",
        onTouchStart
      );

      landingDiv.addEventListener(
        "touchend",
        onTouchEnd
      );
    }

    let rafId = 0;

    // The character's own container is position:fixed and stays visible
    // (via GSAP scrub tweens on its transform) through the whole
    // Landing -> About -> WhatIDo arc, then GSAP animates it fully off
    // -screen (translateY(-100%)) before How I Work. Watching this same
    // element's actual rendered visibility - rather than re-deriving the
    // scroll-position math GsapScroll.ts already owns - means this stays
    // correct automatically if that choreography is ever retuned.
    let isVisible = true;
    let isTabVisible = !document.hidden;

    const visibilityObserver =
      new IntersectionObserver(
        ([entry]) => {
          isVisible =
            entry.isIntersecting;
        },
        { threshold: 0 }
      );

    if (canvasDiv.current) {
      visibilityObserver.observe(
        canvasDiv.current
      );
    }

    const onDocumentVisibility =
      () => {
        isTabVisible =
          !document.hidden;
      };

    document.addEventListener(
      "visibilitychange",
      onDocumentVisibility
    );

    const animate = () => {
      rafId =
        requestAnimationFrame(
          animate
        );

      // Always advance the clock so a resumed frame gets a normal small
      // delta instead of one large jump covering the whole paused span.
      const delta =
        clock.getDelta();

      if (
        !isVisible ||
        !isTabVisible
      ) {
        return;
      }

      /**
       * Correct order:
       *
       * 1. Idle mixer
       * 2. procedural wave
       * 3. head gaze
       */
      if (mixer) {
        mixer.update(delta);
      }

      wave?.update(delta);

      if (headBone) {
        handleHeadRotation(
          headBone,
          mouse.x,
          mouse.y,
          interpolation.x,
          interpolation.y,
          THREE.MathUtils.lerp
        );
      }

      if (screens) {
        light.setPointLight(
          screens.keyMaterial
        );
      }

      renderer.render(
        scene,
        camera
      );
    };

    animate();

    return () => {
      cancelled = true;

      cancelAnimationFrame(
        rafId
      );

      visibilityObserver.disconnect();

      document.removeEventListener(
        "visibilitychange",
        onDocumentVisibility
      );

      clearCharTimelineResources();

      clearTimeout(
        debounce
      );

      if (
        introTimer !== undefined
      ) {
        window.clearTimeout(
          introTimer
        );
      }

      if (
        waveTimer !== undefined
      ) {
        window.clearTimeout(
          waveTimer
        );
      }

      scene.clear();

      renderer.dispose();

      if (onResize) {
        window.removeEventListener(
          "resize",
          onResize
        );
      }

      if (
        canvasDiv.current &&
        renderer.domElement
          .parentElement ===
          canvasDiv.current
      ) {
        canvasDiv.current.removeChild(
          renderer.domElement
        );
      }

      document.removeEventListener(
        "mousemove",
        onMouseMove
      );

      if (landingDiv) {
        landingDiv.removeEventListener(
          "touchstart",
          onTouchStart
        );

        landingDiv.removeEventListener(
          "touchend",
          onTouchEnd
        );
      }
    };
  }, [setLoading]);

  return (
    <div className="character-container">
      <div
        className="character-model"
        ref={canvasDiv}
      >
        <div className="character-rim" />

        <div
          className="character-hover"
          ref={hoverDivRef}
        />
      </div>
    </div>
  );
};

export default Scene;