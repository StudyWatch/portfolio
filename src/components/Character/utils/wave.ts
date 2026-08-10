import * as THREE from "three";
import type { AvatarBoneMap } from "../avatarProfile";

/**
 * Timor hero - one-shot greeting wave.
 *
 * Goals:
 * - right elbow stays around shoulder height
 * - forearm bends upward toward the head
 * - hand stays beside the head, not far outside the frame
 * - palm faces the visitor/camera
 * - fingers point upward
 * - small, normal greeting motion
 * - smooth blend back to the live Idle animation
 */

const LIFT_DURATION = 0.75;
const HOLD_BEFORE_WAVE = 0.15;
const WAVE_CYCLE_DURATION = 0.5;
const WAVE_CYCLES = 3;
const WAVE_DURATION = WAVE_CYCLE_DURATION * WAVE_CYCLES;
const HOLD_AFTER_WAVE = 0.12;
const LOWER_DURATION = 0.75;

const TOTAL_DURATION =
  LIFT_DURATION +
  HOLD_BEFORE_WAVE +
  WAVE_DURATION +
  HOLD_AFTER_WAVE +
  LOWER_DURATION;

/**
 * Calibrated pose, not IK.
 *
 * Generic IK targeting (aim the elbow/wrist at a computed world-space
 * point) kept producing poses that were geometrically "correct" but read
 * as anatomically warped on this specific rig - the elbow/shoulder
 * skinning stretched, and pushing the wrist target toward the camera for
 * visibility caused perspective enlargement at this tight hero framing.
 * Repeated retargeting only traded one deformation for another.
 *
 * Instead these are absolute local-space Euler angles (degrees) for the
 * RightArm/RightForeArm bones, found by direct visual calibration against
 * the live hero camera (see the removed debugSetPose harness) - the exact
 * fallback the pose spec called for. They are ONLY valid for this rig's
 * rest pose (Timorfinal.glb); a different avatar would need recalibrating.
 *
 * Idle reference for this rig: upperArm ≈ (65, -7, 12)°, forearm ≈ (2, -1,
 * -19)°. The calibrated pose below reads as a moderate, natural greeting -
 * elbow near shoulder height, forearm folded up toward the head without
 * touching it, no visible shoulder/sleeve stretching at any zoom level
 * tested - deliberately short of the more dramatic (and slightly warped
 * at the shoulder) 95°/125° version tried during calibration.
 */
const UPPER_ARM_POSE_DEG = { x: 25, y: 75, z: 12 };
const FOREARM_POSE_DEG = { x: 100, y: -1.1, z: -19.4 };

const WRIST_WAVE_DEGREES = 5;

const MAX_FRAME_DELTA = 0.05;

/**
 * If the BACK of the hand faces the camera,
 * change this value from 1 to -1.
 */
const PALM_SIGN = 1;

function clamp01(value: number): number {
  return THREE.MathUtils.clamp(value, 0, 1);
}

function smootherStep(value: number): number {
  const t = clamp01(value);

  return (
    t *
    t *
    t *
    (t * (t * 6 - 15) + 10)
  );
}

function getBone(
  character: THREE.Object3D,
  name?: string
): THREE.Object3D | null {
  if (!name) {
    return null;
  }

  return character.getObjectByName(name) ?? null;
}

function findFirstBone(
  character: THREE.Object3D,
  names: string[]
): THREE.Object3D | null {
  for (const name of names) {
    const result = character.getObjectByName(name);

    if (result) {
      return result;
    }
  }

  return null;
}

function worldPosition(
  object: THREE.Object3D
): THREE.Vector3 {
  const result = new THREE.Vector3();
  object.getWorldPosition(result);
  return result;
}

function worldQuaternion(
  object: THREE.Object3D
): THREE.Quaternion {
  const result = new THREE.Quaternion();
  object.getWorldQuaternion(result);
  return result;
}

function worldToLocalQuaternion(
  bone: THREE.Object3D,
  desiredWorldQuaternion: THREE.Quaternion
): THREE.Quaternion {
  if (!bone.parent) {
    return desiredWorldQuaternion.clone().normalize();
  }

  const parentWorldInverse = worldQuaternion(
    bone.parent
  ).invert();

  return parentWorldInverse
    .multiply(desiredWorldQuaternion)
    .normalize();
}

interface HandBasis {
  fingers: THREE.Vector3;
  thumb: THREE.Vector3;
  palm: THREE.Vector3;
}

/**
 * Determine the hand's real local anatomical directions
 * from the finger and thumb bones.
 */
function deriveHandBasis(
  hand: THREE.Object3D,
  finger: THREE.Object3D | null,
  thumb: THREE.Object3D | null
): HandBasis {
  /**
   * Fallback for Avaturn if finger lookup ever fails.
   */
  const fallback: HandBasis = {
    fingers: new THREE.Vector3(0, 1, 0),
    thumb: new THREE.Vector3(0, 0, -1),
    palm: new THREE.Vector3(
      PALM_SIGN,
      0,
      0
    ),
  };

  if (!finger || !thumb) {
    return fallback;
  }

  hand.updateWorldMatrix(true, true);

  const handPosition = worldPosition(hand);

  const inverseHandWorld =
    worldQuaternion(hand).invert();

  const fingerDirection = worldPosition(finger)
    .sub(handPosition)
    .applyQuaternion(inverseHandWorld);

  const thumbDirection = worldPosition(thumb)
    .sub(handPosition)
    .applyQuaternion(inverseHandWorld);

  if (
    fingerDirection.lengthSq() < 1e-8 ||
    thumbDirection.lengthSq() < 1e-8
  ) {
    return fallback;
  }

  fingerDirection.normalize();

  /**
   * Make thumb perpendicular to finger direction.
   */
  thumbDirection.addScaledVector(
    fingerDirection,
    -thumbDirection.dot(fingerDirection)
  );

  if (thumbDirection.lengthSq() < 1e-8) {
    return fallback;
  }

  thumbDirection.normalize();

  let palmDirection = thumbDirection
    .clone()
    .cross(fingerDirection)
    .normalize()
    .multiplyScalar(PALM_SIGN);

  /**
   * Recalculate thumb so all three axes are exactly orthogonal.
   */
  const correctedThumb = fingerDirection
    .clone()
    .cross(palmDirection)
    .normalize();

  palmDirection = correctedThumb
    .clone()
    .cross(fingerDirection)
    .normalize();

  return {
    fingers: fingerDirection,
    thumb: correctedThumb,
    palm: palmDirection,
  };
}

function quaternionFromBasis(
  localX: THREE.Vector3,
  localY: THREE.Vector3,
  localZ: THREE.Vector3,
  worldX: THREE.Vector3,
  worldY: THREE.Vector3,
  worldZ: THREE.Vector3
): THREE.Quaternion {
  const localMatrix = new THREE.Matrix4().makeBasis(
    localX,
    localY,
    localZ
  );

  const worldMatrix = new THREE.Matrix4().makeBasis(
    worldX,
    worldY,
    worldZ
  );

  const localInverse = localMatrix.clone().invert();

  const rotationMatrix = worldMatrix.multiply(
    localInverse
  );

  return new THREE.Quaternion()
    .setFromRotationMatrix(rotationMatrix)
    .normalize();
}

/**
 * Build the hand orientation we want:
 *
 * fingers -> up
 * palm -> camera
 * thumb -> inward toward the face
 */
function makeGreetingHandQuaternion(
  bodyUp: THREE.Vector3,
  towardCamera: THREE.Vector3,
  inward: THREE.Vector3,
  handBasis: HandBasis
): THREE.Quaternion {
  const fingersWorld = bodyUp
    .clone()
    .normalize();

  let palmWorld = towardCamera.clone();

  /**
   * Keep the palm normal perpendicular to fingers.
   */
  palmWorld.addScaledVector(
    fingersWorld,
    -palmWorld.dot(fingersWorld)
  );

  if (palmWorld.lengthSq() < 1e-8) {
    palmWorld.set(0, 0, 1);
  }

  palmWorld.normalize();

  let thumbWorld = inward.clone();

  /**
   * Thumb lies in the plane of the palm.
   */
  thumbWorld.addScaledVector(
    fingersWorld,
    -thumbWorld.dot(fingersWorld)
  );

  thumbWorld.addScaledVector(
    palmWorld,
    -thumbWorld.dot(palmWorld)
  );

  if (thumbWorld.lengthSq() < 1e-8) {
    thumbWorld = fingersWorld
      .clone()
      .cross(palmWorld);
  }

  thumbWorld.normalize();

  /**
   * Ensure:
   * thumb x fingers = palm
   */
  const directionCheck = thumbWorld
    .clone()
    .cross(fingersWorld)
    .dot(palmWorld);

  if (directionCheck < 0) {
    thumbWorld.negate();
  }

  palmWorld = thumbWorld
    .clone()
    .cross(fingersWorld)
    .normalize();

  thumbWorld = fingersWorld
    .clone()
    .cross(palmWorld)
    .normalize();

  return quaternionFromBasis(
    handBasis.thumb,
    handBasis.fingers,
    handBasis.palm,

    thumbWorld,
    fingersWorld,
    palmWorld
  );
}

/**
 * Apply a small rotation around a world-space axis.
 */
function rotateAroundWorldAxis(
  bone: THREE.Object3D,
  axisWorld: THREE.Vector3,
  radians: number
): void {
  if (
    !bone.parent ||
    Math.abs(radians) < 1e-7
  ) {
    return;
  }

  bone.updateWorldMatrix(true, false);

  const currentWorld = worldQuaternion(bone);

  const delta =
    new THREE.Quaternion().setFromAxisAngle(
      axisWorld.clone().normalize(),
      radians
    );

  const desiredWorldQuaternion = delta
    .multiply(currentWorld)
    .normalize();

  bone.quaternion.copy(
    worldToLocalQuaternion(
      bone,
      desiredWorldQuaternion
    )
  );
}

export interface WaveController {
  start: () => void;
  update: (delta: number) => void;
}

export function createWaveController(
  character: THREE.Object3D,
  bones: AvatarBoneMap,
  camera: THREE.Camera
): WaveController | null {
  const upperArmFound = getBone(
    character,
    bones.rightUpperArm
  );

  const forearmFound = getBone(
    character,
    bones.rightForeArm
  );

  const handFound = getBone(
    character,
    bones.rightHand
  );

  const headFound = getBone(
    character,
    bones.head
  );

  const hipsFound = getBone(
    character,
    bones.root
  );

  if (
    !upperArmFound ||
    !forearmFound ||
    !handFound ||
    !headFound ||
    !hipsFound
  ) {
    console.warn(
      "[wave] Required Timor avatar bones are missing. Wave disabled."
    );

    return null;
  }

  /**
   * Explicit aliases after validation.
   * TypeScript now knows these can never be null.
   */
  const upperArm: THREE.Object3D =
    upperArmFound;

  const forearm: THREE.Object3D =
    forearmFound;

  const hand: THREE.Object3D =
    handFound;

  const head: THREE.Object3D =
    headFound;

  const hips: THREE.Object3D =
    hipsFound;

  const leftUpperArm: THREE.Object3D | null =
    getBone(
      character,
      bones.leftUpperArm
    );

  const finger = findFirstBone(character, [
    "RightHandMiddle1",
    "RightHandIndex1",
    "RightHandMiddle2",
    "RightHandIndex2",
    "mixamorigRightHandMiddle1",
    "mixamorig:RightHandMiddle1",
    "mixamorigRightHandIndex1",
    "mixamorig:RightHandIndex1",
  ]);

  const thumb = findFirstBone(character, [
    "RightHandThumb1",
    "RightHandThumb2",
    "mixamorigRightHandThumb1",
    "mixamorig:RightHandThumb1",
  ]);

  /**
   * IMPORTANT:
   * This is never nullable.
   */
  const stableHandBasis: HandBasis =
    deriveHandBasis(
      hand,
      finger,
      thumb
    );

  /**
   * Shared per-frame geometry: body-up, anatomical right/inward, and the
   * real direction toward the visitor's actual camera. Used by both the
   * normal wave pose and the calibration debug pose so the hand's
   * palm-faces-camera math stays identical in both.
   */
  function computeGreetingFrame() {
    const headPosition = worldPosition(head);
    const hipsPosition = worldPosition(hips);
    const cameraPosition = worldPosition(camera);

    const bodyUp = headPosition
      .clone()
      .sub(hipsPosition)
      .normalize();

    let anatomicalRight: THREE.Vector3;

    if (leftUpperArm) {
      anatomicalRight = worldPosition(upperArm)
        .clone()
        .sub(worldPosition(leftUpperArm))
        .normalize();
    } else {
      anatomicalRight = worldPosition(upperArm)
        .clone()
        .sub(headPosition);

      anatomicalRight.addScaledVector(
        bodyUp,
        -anatomicalRight.dot(bodyUp)
      );

      anatomicalRight.normalize();
    }

    const inwardTowardFace = anatomicalRight
      .clone()
      .negate();

    let towardCamera = cameraPosition
      .clone()
      .sub(headPosition);

    towardCamera.addScaledVector(
      bodyUp,
      -towardCamera.dot(bodyUp)
    );

    if (towardCamera.lengthSq() < 1e-8) {
      towardCamera.set(0, 0, 1);
    }

    towardCamera.normalize();

    return {
      headPosition,
      hipsPosition,
      cameraPosition,
      bodyUp,
      anatomicalRight,
      inwardTowardFace,
      towardCamera,
    };
  }

  let active = false;
  let completed = false;
  let elapsed = 0;

  function start(): void {
    if (active || completed) {
      return;
    }

    if (
      typeof window !== "undefined" &&
      window.matchMedia?.(
        "(prefers-reduced-motion: reduce)"
      ).matches
    ) {
      completed = true;
      return;
    }

    elapsed = 0;
    active = true;
  }

  function update(delta: number): void {
    if (!active) {
      return;
    }

    elapsed += Math.min(
      delta,
      MAX_FRAME_DELTA
    );

    if (elapsed >= TOTAL_DURATION) {
      active = false;
      completed = true;
      return;
    }

    let raise = 0;
    let waveProgress = -1;

    if (elapsed < LIFT_DURATION) {
      raise = smootherStep(
        elapsed / LIFT_DURATION
      );
    } else if (
      elapsed <
      LIFT_DURATION +
        HOLD_BEFORE_WAVE
    ) {
      raise = 1;
    } else if (
      elapsed <
      LIFT_DURATION +
        HOLD_BEFORE_WAVE +
        WAVE_DURATION
    ) {
      raise = 1;

      waveProgress =
        (
          elapsed -
          LIFT_DURATION -
          HOLD_BEFORE_WAVE
        ) /
        WAVE_DURATION;
    } else if (
      elapsed <
      LIFT_DURATION +
        HOLD_BEFORE_WAVE +
        WAVE_DURATION +
        HOLD_AFTER_WAVE
    ) {
      raise = 1;
    } else {
      const loweringStarts =
        LIFT_DURATION +
        HOLD_BEFORE_WAVE +
        WAVE_DURATION +
        HOLD_AFTER_WAVE;

      raise =
        1 -
        smootherStep(
          (
            elapsed -
            loweringStarts
          ) /
            LOWER_DURATION
        );
    }

    /**
     * mixer.update() has already run in Scene.tsx.
     * This is the current live Idle hand quaternion.
     */
    const idleHand =
      hand.quaternion.clone();

    character.updateMatrixWorld(true);
    camera.updateMatrixWorld(true);

    /**
     * 1 & 2. Upper arm + forearm:
     *
     * A calibrated absolute local pose for THIS rig (see the constants'
     * comment above) - not IK. Only the palm/finger orientation below is
     * still computed from live geometry, since that has to react to the
     * real camera and stays cheap/robust to get right.
     */
    const raisedUpperArm =
      new THREE.Quaternion().setFromEuler(
        new THREE.Euler(
          THREE.MathUtils.degToRad(
            UPPER_ARM_POSE_DEG.x
          ),
          THREE.MathUtils.degToRad(
            UPPER_ARM_POSE_DEG.y
          ),
          THREE.MathUtils.degToRad(
            UPPER_ARM_POSE_DEG.z
          )
        )
      );

    const raisedForearm =
      new THREE.Quaternion().setFromEuler(
        new THREE.Euler(
          THREE.MathUtils.degToRad(
            FOREARM_POSE_DEG.x
          ),
          THREE.MathUtils.degToRad(
            FOREARM_POSE_DEG.y
          ),
          THREE.MathUtils.degToRad(
            FOREARM_POSE_DEG.z
          )
        )
      );

    /**
     * Smooth Idle -> greeting pose.
     */
    upperArm.quaternion.slerp(
      raisedUpperArm,
      raise
    );

    forearm.quaternion.slerp(
      raisedForearm,
      raise
    );

    character.updateMatrixWorld(true);

    /**
     * 3. Hand:
     *
     * fingers = upward
     * thumb = toward face
     * palm = toward camera
     *
     * Computed fresh from live geometry (head/camera positions), unlike
     * the calibrated upper-arm/forearm pose above - this has to react to
     * the real camera, and doing so is cheap and robust to get right.
     */
    const frame = computeGreetingFrame();

    const desiredHandWorld =
      makeGreetingHandQuaternion(
        frame.bodyUp,
        frame.towardCamera,
        frame.inwardTowardFace,
        stableHandBasis
      );

    const desiredHandLocal =
      worldToLocalQuaternion(
        hand,
        desiredHandWorld
      );

    hand.quaternion
      .copy(idleHand)
      .slerp(
        desiredHandLocal,
        raise
      );

    character.updateMatrixWorld(true);

    /**
     * 4. Small, conventional wrist greeting.
     *
     * Palm continues to face camera.
     */
    if (waveProgress >= 0) {
      const p = clamp01(
        waveProgress
      );

      const envelope =
        Math.sin(Math.PI * p);

      const oscillation =
        Math.sin(
          p *
            Math.PI *
            2 *
            WAVE_CYCLES
        );

      const wristRotation =
        oscillation *
        envelope *
        THREE.MathUtils.degToRad(
          WRIST_WAVE_DEGREES
        );

      rotateAroundWorldAxis(
        hand,
        frame.towardCamera,
        wristRotation
      );
    }
  }

  return {
    start,
    update,
  };
}