import * as THREE from "three";

export const handleMouseMove = (
  event: MouseEvent,
  setMousePosition: (x: number, y: number) => void
) => {
  const mouseX = (event.clientX / window.innerWidth) * 2 - 1;
  const mouseY = -(event.clientY / window.innerHeight) * 2 + 1;
  setMousePosition(mouseX, mouseY);
};

export const handleTouchMove = (
  event: TouchEvent,
  setMousePosition: (x: number, y: number) => void
) => {
  const mouseX = (event.touches[0].clientX / window.innerWidth) * 2 - 1;
  const mouseY = -(event.touches[0].clientY / window.innerHeight) * 2 + 1;
  setMousePosition(mouseX, mouseY);
};

export const handleTouchEnd = (
  setMousePosition: (
    x: number,
    y: number,
    interpolationX: number,
    interpolationY: number
  ) => void
) => {
  setTimeout(() => {
    setMousePosition(0, 0, 0.03, 0.03);
    setTimeout(() => {
      setMousePosition(0, 0, 0.07, 0.07);
    }, 1000);
  }, 2000);
};

// Natural limits for a head look-at-cursor effect - generous enough to read
// as "following the cursor", tight enough to never look broken. Pitch is
// intentionally asymmetric: heads read as more natural with a bit more
// downward range than upward.
const MAX_YAW = THREE.MathUtils.degToRad(28);
const MAX_PITCH_UP = THREE.MathUtils.degToRad(12);
const MAX_PITCH_DOWN = THREE.MathUtils.degToRad(16);

// Below this scroll position, the cursor owns the head. Past it, scroll
// choreography owns the head instead - this is the entire priority system:
// exactly one source ever writes to the head bone in a given frame, so
// there is nothing to fight over.
const SCROLLED_LOOK_THRESHOLD = 200;
const SETTLE_DAMPING = 0.045;

export const handleHeadRotation = (
  headBone: THREE.Object3D,
  mouseX: number,
  mouseY: number,
  interpolationX: number,
  interpolationY: number,
  lerp: (x: number, y: number, t: number) => number
) => {
  if (!headBone) return;

  const cursorOwnsGaze = window.scrollY < SCROLLED_LOOK_THRESHOLD;

  if (cursorOwnsGaze) {
    const clampedX = THREE.MathUtils.clamp(mouseX, -1, 1);
    const clampedY = THREE.MathUtils.clamp(mouseY, -1, 1);

    const targetYaw = clampedX * MAX_YAW;
    const targetPitch =
      clampedY >= 0 ? -clampedY * MAX_PITCH_UP : -clampedY * MAX_PITCH_DOWN;

    headBone.rotation.y = lerp(headBone.rotation.y, targetYaw, interpolationY);
    headBone.rotation.x = lerp(headBone.rotation.x, targetPitch, interpolationX);
  } else if (window.innerWidth > 1024) {
    // Scroll has carried the scene past the hero - settle into a fixed
    // "looking at the workstation" pose. Slow, constant damping makes the
    // handoff read as a deliberate settle rather than a snap.
    headBone.rotation.x = lerp(headBone.rotation.x, -0.4, SETTLE_DAMPING);
    headBone.rotation.y = lerp(headBone.rotation.y, -0.3, SETTLE_DAMPING);
  }
};
