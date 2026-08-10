import * as THREE from "three";
import { Suspense, useEffect, useMemo, useRef, useState } from "react";
import { Canvas, useThree } from "@react-three/fiber";
import { useGLTF, useAnimations } from "@react-three/drei";
import { clone as cloneSkeleton } from "three/examples/jsm/utils/SkeletonUtils.js";

// Same Timor - same face, hair, glasses, beard as the hero - just a small,
// tasteful "effort" moment for How I Work. pushups1.glb and pushups2.glb
// turned out to be the exact same asset (verified by hashing every
// accessor/animation buffer and every embedded image - all byte-identical,
// just repacked with the bufferViews in a different order), so there's only
// one source file now. The left/right visual distinction below
// (three-quarter vs. side-on) comes entirely from two different camera
// azimuths around the same loaded pose - each instance clones the loaded
// scene via SkeletonUtils so the two views can animate/pose independently
// without fighting over one shared skeleton.
type ViewAngle = "threeQuarter" | "side";

const CAMERA_AZIMUTH: Record<ViewAngle, { x: number; z: number }> = {
  // The original single-avatar framing: a moderate diagonal angle.
  threeQuarter: { x: 0.5, z: 0.87 },
  // Weighted almost entirely onto the other horizontal axis for a
  // near-profile, side-on read of the same pose.
  side: { x: 0.985, z: 0.174 },
};

type PushupsModelProps = {
  modelPath: string;
  viewAngle: ViewAngle;
};

function PushupsModel({ modelPath, viewAngle }: PushupsModelProps) {
  // useGLTF caches by URL and returns the SAME parsed scene/skeleton to
  // every caller of the same path - fine for a single instance, but two
  // avatars sharing one live skeleton would fight over the same bone
  // transforms. SkeletonUtils.clone makes each instance its own
  // independent skinned-mesh graph (correctly re-binding bones, unlike a
  // plain Object3D.clone) from the one loaded/decoded source.
  const { scene: sourceScene, animations } = useGLTF(modelPath);
  const scene = useMemo(
    () => cloneSkeleton(sourceScene) as THREE.Object3D,
    [sourceScene]
  );
  const { actions, mixer } = useAnimations(animations, scene);
  const { camera } = useThree();
  const [ready, setReady] = useState(false);
  const fitted = useRef(false);

  useEffect(() => {
    const action = actions["mixamo.com"];
    action?.reset().play();
  }, [actions]);

  useEffect(() => {
    if (fitted.current) return;
    fitted.current = true;
    // Advance into the loop before measuring bounds - the bind pose isn't
    // representative of the animated (prone/plank) silhouette.
    mixer.update(0.6);

    const box = new THREE.Box3().setFromObject(scene);
    const size = new THREE.Vector3();
    box.getSize(size);
    const center = new THREE.Vector3();
    box.getCenter(center);

    const persp = camera as THREE.PerspectiveCamera;
    const azimuth = CAMERA_AZIMUTH[viewAngle];
    const direction = new THREE.Vector3(azimuth.x, 0, azimuth.z).normalize();

    // Fitting against the object's axis-aligned width/height only works
    // when the camera looks straight down one axis. Once the camera swings
    // toward a side-on azimuth, the silhouette actually in frame is the
    // box's extent projected onto the camera's own right/up vectors, not
    // its raw x/z size - using the raw size cropped the head at a near-side
    // angle. Placing the camera at an arbitrary trial distance first, then
    // measuring the real projected half-extents from its own view matrix,
    // fits correctly at any azimuth.
    const trialDistance = Math.max(size.x, size.y, size.z) * 3;
    persp.position.set(
      center.x + direction.x * trialDistance,
      center.y + size.y * 0.22,
      center.z + direction.z * trialDistance
    );
    persp.lookAt(center.x, center.y, center.z);
    persp.updateMatrixWorld(true);

    const viewMatrix = persp.matrixWorldInverse;
    let maxRight = 0;
    let maxUp = 0;
    const corner = new THREE.Vector3();
    for (let i = 0; i < 8; i++) {
      corner.set(
        i & 1 ? box.max.x : box.min.x,
        i & 2 ? box.max.y : box.min.y,
        i & 4 ? box.max.z : box.min.z
      );
      corner.applyMatrix4(viewMatrix);
      maxRight = Math.max(maxRight, Math.abs(corner.x));
      maxUp = Math.max(maxUp, Math.abs(corner.y));
    }

    const verticalFovRad = (persp.fov * Math.PI) / 180;
    const horizontalFovRad =
      2 * Math.atan(Math.tan(verticalFovRad / 2) * persp.aspect);
    const distanceForHeight = (maxUp * 1.1) / Math.tan(verticalFovRad / 2);
    const distanceForWidth =
      (maxRight * 1.1) / Math.tan(horizontalFovRad / 2);
    const distance = Math.max(distanceForHeight, distanceForWidth);

    persp.position.set(
      center.x + direction.x * distance,
      center.y + size.y * 0.22,
      center.z + direction.z * distance
    );
    persp.lookAt(center.x, center.y, center.z);
    persp.updateProjectionMatrix();
    setReady(true);
  }, [camera, mixer, scene, viewAngle]);

  return <primitive object={scene} visible={ready} />;
}

type HowIWorkAvatarProps = {
  modelPath: string;
  viewAngle: ViewAngle;
  // Whether this avatar is near/inside the viewport. Gates the R3F render
  // loop only - never unmounts - so scrolling back into view resumes the
  // same live scene instantly instead of re-loading/re-fitting the camera.
  active: boolean;
};

const HowIWorkAvatar = ({ modelPath, viewAngle, active }: HowIWorkAvatarProps) => {
  return (
    <div className="how-i-work-avatar">
      <Canvas
        camera={{ fov: 28, near: 0.1, far: 50 }}
        gl={{ alpha: true, antialias: true }}
        dpr={[1, 1.5]}
        frameloop={active ? "always" : "demand"}
      >
        <ambientLight intensity={1.1} />
        <directionalLight position={[3, 4, 5]} intensity={1.6} color="#f2b273" />
        <directionalLight position={[-3, 2, -2]} intensity={0.5} color="#7ea0c9" />
        <Suspense fallback={null}>
          <PushupsModel modelPath={modelPath} viewAngle={viewAngle} />
        </Suspense>
      </Canvas>
    </div>
  );
};

export default HowIWorkAvatar;
