import * as THREE from "three";
import { useRef, useMemo, useState, useEffect } from "react";
import { Canvas, useFrame } from "@react-three/fiber";
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

const TechStack = () => {
  const [isActive, setIsActive] = useState(false);
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

  const handlePointerMove = (e: React.PointerEvent<HTMLDivElement>) => {
    pointerScreenRef.current = { x: e.clientX, y: e.clientY };
    if (tooltipRef.current) {
      tooltipRef.current.style.left = `${e.clientX}px`;
      tooltipRef.current.style.top = `${e.clientY}px`;
    }
  };

  useEffect(() => {
    const handleScroll = () => {
      const scrollY = window.scrollY || document.documentElement.scrollTop;
      const threshold = document
        .getElementById("work")!
        .getBoundingClientRect().top;
      setIsActive(scrollY > threshold);
    };
    document.querySelectorAll(".header a").forEach((elem) => {
      const element = elem as HTMLAnchorElement;
      element.addEventListener("click", () => {
        const interval = setInterval(() => {
          handleScroll();
        }, 10);
        setTimeout(() => {
          clearInterval(interval);
        }, 1000);
      });
    });
    window.addEventListener("scroll", handleScroll);
    return () => {
      window.removeEventListener("scroll", handleScroll);
    };
  }, []);

  const [textures, setTextures] = useState<Map<string, THREE.Texture> | null>(
    null
  );

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
    <div className="techstack" onPointerMove={handlePointerMove}>
      <h2>Applied AI · Backend &amp; Data · Full-Stack · Automation</h2>

      <Canvas
        shadows
        gl={{ alpha: true, stencil: false, depth: false, antialias: false }}
        camera={{ position: [0, 0, 20], fov: 32.5, near: 1, far: 100 }}
        onCreated={(state) => (state.gl.toneMappingExposure = 1.5)}
        className="tech-canvas"
      >
        <ambientLight intensity={1} />
        <spotLight
          position={[20, 20, 25]}
          penumbra={1}
          angle={0.2}
          color="white"
          castShadow
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
        <EffectComposer enableNormalPass={false}>
          <N8AO color="#0f002c" aoRadius={2} intensity={1.15} />
        </EffectComposer>
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
