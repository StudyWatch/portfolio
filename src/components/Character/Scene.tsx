import { useEffect, useRef, useState } from "react";
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
import { createCommandScreens, type CommandScreens } from "./utils/screens";
import { computeCameraPlan } from "./utils/cameraFit";
import { setCharTimeline, setAllTimeline } from "../utils/GsapScroll";

const Scene = () => {
  const canvasDiv = useRef<HTMLDivElement | null>(null);
  const hoverDivRef = useRef<HTMLDivElement>(null);
  const sceneRef = useRef<THREE.Scene | null>(null);
  if (!sceneRef.current) sceneRef.current = new THREE.Scene();
  const { setLoading } = useLoading();

  const [, setChar] = useState<THREE.Object3D | null>(null);
  useEffect(() => {
    if (!canvasDiv.current) return;

    // React 18 StrictMode double-invokes effects in dev (mount, cleanup,
    // mount again). Every async/imperative Three.js callback below checks
    // this flag before touching the camera/renderer/scene, so a
    // late-resolving load from a cleaned-up instance can never fight the
    // live one for control of the shared canvas.
    let cancelled = false;

    let rect = canvasDiv.current.getBoundingClientRect();
    let container = { width: rect.width, height: rect.height };
    const aspect = container.width / container.height;
    const scene = sceneRef.current!;

    const renderer = new THREE.WebGLRenderer({
      alpha: true,
      antialias: true,
    });
    renderer.setSize(container.width, container.height);
    renderer.setPixelRatio(window.devicePixelRatio);
    renderer.toneMapping = THREE.ACESFilmicToneMapping;
    renderer.toneMappingExposure = 1;
    canvasDiv.current.appendChild(renderer.domElement);

    // Base position is a reasonable guess for a roughly human-scale rig —
    // it gets re-fitted to the loaded avatar's actual bounds below, since
    // different GLBs won't share scale.
    const camera = new THREE.PerspectiveCamera(14.5, aspect, 0.1, 1000);
    camera.position.set(0, 4.5, 27);
    camera.zoom = 1.1;
    camera.updateProjectionMatrix();

    let headBone: THREE.Object3D | null = null;
    let character: THREE.Object3D | null = null;
    let mixer: THREE.AnimationMixer | undefined;
    let screens: CommandScreens | undefined;

    const clock = new THREE.Clock();

    const light = setLighting(scene);
    const progress = setProgress((value) => setLoading(value));
    const { loadCharacter } = setCharacter(renderer, scene, camera);

    let onResize: (() => void) | null = null;

    loadCharacter().then((gltf) => {
      if (cancelled || !gltf) return;

      const animations = setAnimations(gltf, activeAvatarProfile);
      hoverDivRef.current && animations.hover(gltf, hoverDivRef.current);
      mixer = animations.mixer;
      character = gltf.scene;
      setChar(character);
      scene.add(character);
      headBone =
        character.getObjectByName(activeAvatarProfile.bones.head) || null;

      const box = new THREE.Box3().setFromObject(character);
      const size = new THREE.Vector3();
      box.getSize(size);
      const center = new THREE.Vector3();
      box.getCenter(center);

      // The command screens are positioned relative to the character's
      // actual measured bounds (not hardcoded world coordinates), so they
      // read as monitors around THIS avatar regardless of its scale.
      screens = createCommandScreens(size, center);
      scene.add(screens.group);

      // Two-stage framing: hero = tight face/upper-body portrait (the
      // cursor-gaze interaction has to read clearly here), body = pulled
      // back to reveal the command-screens workstation context around the
      // same standing avatar, revealed as the user scrolls into About.
      const cameraPlan = computeCameraPlan(camera, character, headBone);
      camera.position.set(
        cameraPlan.heroTarget.x,
        cameraPlan.heroTarget.y,
        cameraPlan.heroTarget.z + cameraPlan.heroDistance
      );
      camera.lookAt(cameraPlan.heroTarget);
      camera.updateProjectionMatrix();

      // Scroll timelines must be built AFTER the camera is fitted — GSAP's
      // .to() tweens capture the property's value at creation time as their
      // implicit start, so building them earlier bakes in the wrong
      // baseline position.
      setCharTimeline(character, camera, screens, size, cameraPlan);
      setAllTimeline();

      progress.loaded().then(() => {
        if (cancelled) return;
        setTimeout(() => {
          if (cancelled) return;
          light.turnOnLights();
          animations.startIntro();
        }, 2500);
      });

      onResize = () =>
        handleResize(renderer, camera, canvasDiv, character!, screens!, headBone);
      window.addEventListener("resize", onResize);
    });

    let mouse = { x: 0, y: 0 },
      interpolation = { x: 0.07, y: 0.07 };

    const onMouseMove = (event: MouseEvent) => {
      handleMouseMove(event, (x, y) => (mouse = { x, y }));
    };
    let debounce: number | undefined;
    const onTouchStart = (event: TouchEvent) => {
      const element = event.target as HTMLElement;
      debounce = setTimeout(() => {
        element?.addEventListener("touchmove", (e: TouchEvent) =>
          handleTouchMove(e, (x, y) => (mouse = { x, y }))
        );
      }, 200);
    };

    const onTouchEnd = () => {
      handleTouchEnd((x, y, interpolationX, interpolationY) => {
        mouse = { x, y };
        interpolation = { x: interpolationX, y: interpolationY };
      });
    };

    document.addEventListener("mousemove", onMouseMove);
    const landingDiv = document.getElementById("landingDiv");
    if (landingDiv) {
      landingDiv.addEventListener("touchstart", onTouchStart);
      landingDiv.addEventListener("touchend", onTouchEnd);
    }

    let rafId = 0;
    const animate = () => {
      rafId = requestAnimationFrame(animate);
      // Advance the mixer FIRST, then apply procedural gaze — gaze must be
      // the last write to the head/neck bones each frame so it always wins
      // over anything a clip proposes (see excludeBoneTracks in
      // animationUtils.ts for the loop-clip half of this fix; this ordering
      // covers one-shot clips like the greeting wave too).
      const delta = clock.getDelta();
      if (mixer) {
        mixer.update(delta);
      }
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
        light.setPointLight(screens.keyMaterial);
      }
      renderer.render(scene, camera);
    };
    animate();

    return () => {
      cancelled = true;
      cancelAnimationFrame(rafId);
      clearTimeout(debounce);
      scene.clear();
      renderer.dispose();
      if (onResize) window.removeEventListener("resize", onResize);
      if (canvasDiv.current && renderer.domElement.parentElement === canvasDiv.current) {
        canvasDiv.current.removeChild(renderer.domElement);
      }
      document.removeEventListener("mousemove", onMouseMove);
      if (landingDiv) {
        landingDiv.removeEventListener("touchstart", onTouchStart);
        landingDiv.removeEventListener("touchend", onTouchEnd);
      }
    };
  }, []);

  return (
    <>
      <div className="character-container">
        <div className="character-model" ref={canvasDiv}>
          <div className="character-rim"></div>
          <div className="character-hover" ref={hoverDivRef}></div>
        </div>
      </div>
    </>
  );
};

export default Scene;
