import * as THREE from "three";

// Two-stage framing plan, computed once from the loaded avatar's actual
// bounds: a tight "hero" shot (face + shoulders + upper chest, so the
// cursor-gaze interaction reads clearly) and a pulled-back "body" shot
// (the full standing figure plus the command-screens workstation context
// around it, revealed as the user scrolls into About). Both are derived
// from the same measurements, so they always agree on scale.
export interface CameraPlan {
  heroTarget: THREE.Vector3;
  heroDistance: number;
  bodyTarget: THREE.Vector3;
  bodyDistance: number;
}

export function computeCameraPlan(
  camera: THREE.PerspectiveCamera,
  character: THREE.Object3D,
  headBone: THREE.Object3D | null
): CameraPlan {
  const box = new THREE.Box3().setFromObject(character);
  const size = new THREE.Vector3();
  box.getSize(size);
  const center = new THREE.Vector3();
  box.getCenter(center);

  const headWorldPos = new THREE.Vector3();
  if (headBone) {
    headBone.getWorldPosition(headWorldPos);
  } else {
    headWorldPos.set(center.x, center.y + size.y * 0.38, center.z);
  }

  const verticalFovRad = (camera.fov * Math.PI) / 180;
  // Three.js zoom > 1 narrows the EFFECTIVE fov (more magnification), so a
  // target height requires MORE distance at higher zoom, not less —
  // multiply, don't divide (visible height at distance d is
  // 2*d*tan(fov/2)/zoom, so solving for d needs *zoom).
  const distanceForHeight = (h: number) =>
    (h * camera.zoom) / (2 * Math.tan(verticalFovRad / 2));

  // Hero: face, glasses, beard, shoulders, upper torso and a hint of
  // waist — balanced rather than a tight crop. The look-at point sits well
  // below the head (toward the chest) so there's real headroom above the
  // head and body below the shoulders, instead of the head sitting at the
  // very top edge of frame.
  const heroTarget = new THREE.Vector3(
    headWorldPos.x,
    headWorldPos.y - size.y * 0.14,
    headWorldPos.z
  );
  const heroDistance = distanceForHeight(size.y * 0.54);

  // Body: pulled back enough to show the full standing figure and the
  // command screens around it as a workstation composition.
  const bodyTarget = new THREE.Vector3(
    center.x,
    center.y + size.y * 0.1,
    center.z
  );
  const bodyDistance = distanceForHeight(size.y * 1.2);

  return { heroTarget, heroDistance, bodyTarget, bodyDistance };
}
