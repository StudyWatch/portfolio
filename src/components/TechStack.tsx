import * as THREE from "three";
import { useRef, useMemo, useState, useEffect } from "react";
import { Canvas, useFrame, useThree } from "@react-three/fiber";
import { Environment } from "@react-three/drei";
import { EffectComposer, N8AO } from "@react-three/postprocessing";
import {
  BallCollider,
  Physics,
  RigidBody,
  CylinderCollider,
  RapierRigidBody,
} from "@react-three/rapier";
import { TECH_ITEMS, type TechItem, type TechTier } from "../data/techStack";
import { drawBadgeTexture, drawLogoBadgeTexture } from "./utils/techBadge";
import { assetPath } from "../utils/assetPath";

// A curated, evidence-backed map of what Timor actually builds with - not a
// random logo cycle. Every item in TECH_ITEMS traces to a real project
// (BaliHofesh's 50+ edge functions, Relive's realtime moderation pipeline,
// the AI grading engine's structured-output pipeline, etc.) - see
// src/data/techStack.ts for the reasoning per item.
//
// Physics below is a deliberate regression baseline: the original MoncyDev
// TechStack (git show bafac1a:src/components/TechStack.tsx) used a real
// kinematic pointer collider and a constant-magnitude center pull, and that
// combination is what produced the "collective mass, controlled kick" feel.
// A prior pass replaced both with manual/visual workarounds while chasing an
// unrelated bug (spheres respawning on every mouse move, fixed below via
// stable spawnPosition) - this restores the original mechanism now that the
// actual bug is fixed.

// Kept close to the original's [0.7, 0.8, 1, 1, 1] spread (not the later
// 0.72–1.55 range) so mass - left at Rapier's default density - never
// varies enough between balls to make the cluster read as independently
// floating objects instead of one weighted mass.
const TIER_SCALE: Record<TechTier, number> = {
  core: 1.25,
  primary: 1,
  supporting: 0.85,
  aiTool: 0.75,
};

const sphereGeometry = new THREE.SphereGeometry(1, 32, 32);

type SphereProps = {
  vec?: THREE.Vector3;
  item: TechItem;
  texture: THREE.Texture;
  r?: typeof THREE.MathUtils.randFloatSpread;
  isActive: boolean;
  onHover: (item: TechItem | null) => void;
};

function SphereGeo({
  vec = new THREE.Vector3(),
  item,
  texture,
  r = THREE.MathUtils.randFloatSpread,
  isActive,
  onHover,
}: SphereProps) {
  const api = useRef<RapierRigidBody | null>(null);
  const scale = TIER_SCALE[item.tier];

  // Computed ONCE per mount, not inline in JSX. RigidBody applies its
  // `position` prop reactively (it re-syncs the body's transform whenever
  // the prop value changes between renders) - an inline `r(20)` call would
  // re-evaluate on every re-render of this component. TechStack no longer
  // re-renders on pointer movement (see the tooltip-position ref below),
  // but this stays as a correctness guarantee regardless of what else ever
  // triggers a re-render here.
  const spawnPosition = useRef<[number, number, number]>([
    r(20),
    r(20) - 25,
    r(20) - 10,
  ]).current;

  const material = useMemo(() => {
    // The texture is already a full-bleed colored composite (see
    // techBadge.ts) - no material.color tint is needed, and none would help
    // for pixels that started fully black anyway (black × tint = black).
    return new THREE.MeshPhysicalMaterial({
      map: texture,
      emissive: item.color,
      emissiveMap: texture,
      emissiveIntensity: 0.4,
      metalness: 0.1,
      roughness: 0.75,
      clearcoat: 0.25,
      clearcoatRoughness: 0.3,
    });
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [texture]);

  // Original MoncyDev center-pull, verbatim: a constant-magnitude impulse
  // (not distance-proportional) toward the origin, direction normalized
  // from the ball's own position, magnitude scaled by the ball's own
  // radius. Y pulls ~3x harder than X/Z - the original's signature
  // "settles into a squat cluster" shape.
  useFrame((_state, delta) => {
    const rb = api.current;
    if (!rb || !isActive) return;
    const clampedDelta = Math.min(0.1, delta);
    const impulse = vec
      .copy(rb.translation())
      .normalize()
      .multiply(
        new THREE.Vector3(
          -50 * clampedDelta * scale,
          -150 * clampedDelta * scale,
          -50 * clampedDelta * scale
        )
      );
    rb.applyImpulse(impulse, true);
  });

  return (
    <RigidBody
      linearDamping={0.75}
      angularDamping={0.15}
      friction={0.2}
      position={spawnPosition}
      ref={api}
      colliders={false}
    >
      <BallCollider args={[scale]} />
      <CylinderCollider
        rotation={[Math.PI / 2, 0, 0]}
        position={[0, 0, 1.2 * scale]}
        args={[0.15 * scale, 0.275 * scale]}
      />
      <mesh
        castShadow
        receiveShadow
        scale={scale}
        geometry={sphereGeometry}
        material={material}
        rotation={[0.3, 1, 1]}
        onPointerOver={(e) => {
          e.stopPropagation();
          onHover(item);
        }}
        onPointerOut={() => onHover(null)}
      />
    </RigidBody>
  );
}

type PointerProps = {
  vec?: THREE.Vector3;
  isActive: boolean;
};

// A real kinematic physics body, exactly like the original - the "kick"
// comes from Rapier's own collision response to this collider moving
// through the pack, not a manual force calculation layered on top.
function Pointer({ vec, isActive }: PointerProps) {
  const ref = useRef<RapierRigidBody>(null);
  // Stable across re-renders (this component barely re-renders now, but a
  // fresh Vector3 each render would silently reset the lerp regardless).
  const fallbackVec = useRef(new THREE.Vector3()).current;
  const target = vec ?? fallbackVec;

  useFrame(({ pointer, viewport }) => {
    if (!isActive) return;
    const targetVec = target.lerp(
      new THREE.Vector3(
        (pointer.x * viewport.width) / 2,
        (pointer.y * viewport.height) / 2,
        0
      ),
      0.2
    );
    ref.current?.setNextKinematicTranslation(targetVec);
  });

  return (
    <RigidBody
      position={[100, 100, 100]}
      type="kinematicPosition"
      colliders={false}
      ref={ref}
    >
      <BallCollider args={[2]} />
    </RigidBody>
  );
}

// The camera was tuned once for a wide desktop aspect (position z: 20,
// fov: 32.5) and left untouched here for that case. On a narrow/portrait
// canvas the SAME vertical fov maps to a much smaller horizontal fov
// (hFov = 2*atan(tan(vFov/2) * aspect)), so at a phone aspect (~0.46) the
// cluster was almost entirely cropped off the sides - this is why
// TechStack was disabled on mobile rather than just looking bad there.
//
// Fix: for aspect ratios narrower than roughly "landscape", pull the
// camera back just enough that a fixed world-space radius still fits
// both the width and height of the frame (same fit-to-both-axes approach
// as HowIWorkAvatar's camera framing). The desktop branch reproduces the
// original fixed z/fov exactly, so desktop framing is unchanged.
const DESKTOP_FOV = 32.5;
const DESKTOP_Z = 20;
// Half-extent (world units) the settled cluster actually occupies at the
// original desktop framing, with a little margin - the number the mobile
// fit solves around so the same cluster reads as "the same composition,
// just smaller," not cropped.
const CLUSTER_RADIUS = 6;

function ResponsiveCameraRig() {
  const { camera, size } = useThree();

  useEffect(() => {
    const persp = camera as THREE.PerspectiveCamera;
    const aspect = size.width / size.height;

    persp.fov = DESKTOP_FOV;

    if (aspect >= 1.2) {
      persp.position.set(0, 0, DESKTOP_Z);
    } else {
      const vFovRad = THREE.MathUtils.degToRad(DESKTOP_FOV);
      const distanceForHeight = CLUSTER_RADIUS / Math.tan(vFovRad / 2);
      const hFovRad = 2 * Math.atan(Math.tan(vFovRad / 2) * aspect);
      const distanceForWidth = CLUSTER_RADIUS / Math.tan(hFovRad / 2);
      const distance = Math.max(distanceForHeight, distanceForWidth);
      persp.position.set(0, 0, distance);
    }

    persp.updateProjectionMatrix();
  }, [camera, size]);

  return null;
}

const TechStack = () => {
  const [isActive, setIsActive] = useState(false);
  // Only gates postprocessing/shadow cost, never the physics/pointer
  // behavior - the cluster itself renders identically on every width.
  const [isNarrow, setIsNarrow] = useState(
    () => window.innerWidth <= 1024
  );
  const [hovered, setHovered] = useState<TechItem | null>(null);
  // Tooltip position is tracked via ref + direct DOM writes, never React
  // state - mousemove firing setState would re-render this whole subtree
  // (including every SphereGeo/RigidBody) on every pixel of cursor motion.
  // That exact pattern was the root cause of the sphere-teleport bug this
  // file used to have; keeping pointer tracking out of React state entirely
  // removes the whole class of regression rather than just patching around
  // it once.
  const pointerScreenRef = useRef({ x: 0, y: 0 });
  const tooltipRef = useRef<HTMLDivElement>(null);
  const [textures, setTextures] = useState<Map<string, THREE.Texture> | null>(
    null
  );

  const handlePointerMove = (e: React.PointerEvent<HTMLDivElement>) => {
    pointerScreenRef.current = { x: e.clientX, y: e.clientY };
    if (tooltipRef.current) {
      tooltipRef.current.style.left = `${e.clientX}px`;
      tooltipRef.current.style.top = `${e.clientY}px`;
    }
  };

  // The old activation check compared window.scrollY (document-space) to
  // element.getBoundingClientRect().top (viewport-space) directly - two
  // different coordinate systems, which made the simulation wake up around
  // halfway down the page instead of near TechStack itself.
  //
  // IntersectionObserver alone is the "correct" fix, but it's a single
  // fragile path: its callback can be delayed or skipped entirely in some
  // environments (backgrounded/occluded tabs, certain instant scroll-jumps),
  // and there's no worse failure mode here than "the balls silently never
  // wake up." So this activation is deliberately redundant: the observer is
  // the primary signal, but a debounced scroll/resize listener independently
  // re-checks the same geometry directly via getBoundingClientRect (this
  // time correctly - both sides of the comparison in viewport space), plus
  // one immediate synchronous check on mount so activation never depends on
  // waiting for a first scroll or a first observer tick.
  const sectionRef = useRef<HTMLDivElement | null>(null);

  useEffect(() => {
    const node = sectionRef.current;
    if (!node) return;

    const margin = 400;
    const checkProximity = () => {
      const rect = node.getBoundingClientRect();
      const near =
        rect.top < window.innerHeight + margin && rect.bottom > -margin;
      setIsActive(near);
    };

    const observer = new IntersectionObserver(
      ([entry]) => setIsActive(entry.isIntersecting),
      // Wakes the physics/render loop shortly before the section is
      // actually on-screen, so the cluster is already settled by the time
      // it's visible, and keeps it awake slightly after leaving to avoid
      // flicker on small scroll-direction reversals right at the edge.
      { rootMargin: `${margin}px 0px ${margin}px 0px`, threshold: 0 }
    );
    observer.observe(node);

    let scrollTimeout: ReturnType<typeof setTimeout>;
    const onScroll = () => {
      clearTimeout(scrollTimeout);
      scrollTimeout = setTimeout(checkProximity, 150);
    };
    window.addEventListener("scroll", onScroll, { passive: true });
    window.addEventListener("resize", onScroll);
    checkProximity();

    return () => {
      observer.disconnect();
      clearTimeout(scrollTimeout);
      window.removeEventListener("scroll", onScroll);
      window.removeEventListener("resize", onScroll);
    };
    // Re-run once `textures` finishes loading: before that, the component
    // returns an early, ref-less placeholder (see the `!textures` branch
    // below), so sectionRef.current is still null on the very first mount
    // and this effect would otherwise bail out permanently, leaving
    // isActive stuck false forever - the actual root cause of the balls
    // never waking up in production.
  }, [textures]);

  useEffect(() => {
    let resizeTimeout: ReturnType<typeof setTimeout>;
    const onResize = () => {
      clearTimeout(resizeTimeout);
      resizeTimeout = setTimeout(
        () => setIsNarrow(window.innerWidth <= 1024),
        200
      );
    };
    window.addEventListener("resize", onResize);
    return () => {
      clearTimeout(resizeTimeout);
      window.removeEventListener("resize", onResize);
    };
  }, []);

  useEffect(() => {
    let cancelled = false;
    Promise.all(
      TECH_ITEMS.map(async (item) => {
        const texture =
          item.kind === "logo"
            ? await drawLogoBadgeTexture(item)
            : drawBadgeTexture(item);
        return [item.id, texture] as const;
      })
    ).then((entries) => {
      if (cancelled) return;
      setTextures(new Map(entries));
    });
    return () => {
      cancelled = true;
    };
  }, []);

  if (!textures) {
    return <div className="techstack" />;
  }

  return (
    <div
      className="techstack"
      ref={sectionRef}
      onPointerMove={handlePointerMove}
    >
      <h2>Applied AI · Backend &amp; Data · Full-Stack · Automation</h2>

      <Canvas
        shadows={!isNarrow}
        gl={{ alpha: true, stencil: false, depth: false, antialias: false }}
        camera={{ position: [0, 0, 20], fov: 32.5, near: 1, far: 100 }}
        onCreated={(state) => (state.gl.toneMappingExposure = 1.5)}
        className="tech-canvas"
        dpr={isNarrow ? [1, 1.4] : [1, 1.75]}
        // Physics stepping and rendering both ride the same R3F per-frame
        // loop, so "demand" fully stops both while the section is out of
        // view - not just the visual draw - without unmounting the canvas
        // (no re-init flash/black-screen on scrolling back).
        frameloop={isActive ? "always" : "demand"}
      >
        <ResponsiveCameraRig />
        <ambientLight intensity={1} />
        <spotLight
          position={[20, 20, 25]}
          penumbra={1}
          angle={0.2}
          color="white"
          castShadow={!isNarrow}
          shadow-mapSize={[512, 512]}
        />
        <directionalLight position={[0, 5, -4]} intensity={2} />
        <Physics gravity={[0, 0, 0]}>
          <Pointer isActive={isActive} />
          {TECH_ITEMS.map((item) => (
            <SphereGeo
              key={item.id}
              item={item}
              texture={textures.get(item.id)!}
              isActive={isActive}
              onHover={setHovered}
            />
          ))}
        </Physics>
        <Environment
          files={assetPath("models/command-environment.hdr")}
          environmentIntensity={0.5}
          environmentRotation={[0, 4, 2]}
        />
        {!isNarrow && (
          <EffectComposer enableNormalPass={false}>
            <N8AO color="#0f002c" aoRadius={2} intensity={1.15} />
          </EffectComposer>
        )}
      </Canvas>

      {hovered && (
        <div
          ref={tooltipRef}
          className="tech-tooltip"
          style={{
            left: pointerScreenRef.current.x,
            top: pointerScreenRef.current.y,
          }}
        >
          <span className="tech-tooltip-label">{hovered.label}</span>
          <span className="tech-tooltip-descriptor">{hovered.descriptor}</span>
        </div>
      )}
    </div>
  );
};

export default TechStack;
