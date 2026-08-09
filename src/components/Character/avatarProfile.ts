import { assetPath } from "../../utils/assetPath";

// Central place describing the avatars mounted in the scene. Nothing else
// in Character/ should hardcode a bone or clip name — everything reads
// through these profiles instead, so swapping/adding an avatar is a
// one-file edit.

export interface AvatarBoneMap {
  /** Root of the rig (hips/pelvis) — used for reference, not currently driven directly. */
  root: string;
  /** Rotated every frame to track the cursor. */
  head: string;
  /** Optional secondary bend, e.g. leaning toward a screen on scroll. */
  neck?: string;
  leftHand?: string;
  rightHand?: string;
}

export interface AvatarMorphMap {
  /** Name of the mesh that owns the morph targets (blend shapes). */
  meshName: string;
  blinkLeft?: string;
  blinkRight?: string;
}

export interface AvatarClipMap {
  /** Looping ambient clip. */
  idle?: string;
  /** Plays once on load, e.g. a wave/greeting. */
  greeting?: string;
  /** Looping "at work" clip — typing, gesturing at a screen, etc. */
  working?: string;
  /** Baked blink clip, used only if no morph-target blink is available. */
  blink?: string;
}

export interface AvatarProfile {
  id: string;
  /** Human-readable note on what this rig actually is and its licensing. */
  label: string;
  glbPath: string;
  bones: AvatarBoneMap;
  morphs?: AvatarMorphMap;
  clips: AvatarClipMap;
  /**
   * Optional bone-name subset used to filter a clip's tracks down to just
   * those bones (e.g. hands), so it can play independently over the rest of
   * the body on the same mixer. Mirrors the reference project's technique
   * of isolating a "typing" clip to finger bones only.
   */
  workingClipBoneNames?: string[];
  /**
   * Bones to strip out of every looping clip in addition to head/neck —
   * e.g. a torso-sway idle that would otherwise carry the head off-axis
   * via the kinematic chain even though the head/neck bones themselves are
   * locked to procedural gaze. Only meant for loop/working clips; a `pose`
   * clip (a deliberately-angled seated hold) is left untouched.
   */
  stableBones?: string[];
  /**
   * Bones whose animated ROOT rotation (not bind pose) should be dropped
   * from loop/working clips — their translation track is kept. Some
   * exports bake a large, near-constant yaw into the root bone's animated
   * rotation itself (as opposed to a bind-pose offset), which rotates the
   * whole body away from camera for the entire clip.
   */
  yawLockBones?: string[];
}

// Shared by every Avaturn.me export used here — all four candidate GLBs
// (Timorfinal, TimorSit, TimorCool, TimorPushups) share this exact rig.
const AVATURN_BONES: AvatarBoneMap = {
  root: "Hips",
  head: "Head",
  neck: "Neck",
  leftHand: "LeftHand",
  rightHand: "RightHand",
};

/**
 * HERO PROFILE — the primary upper-body/face presence shown in the hero and
 * carried through most of the scroll. Avaturn.me export of Timor Malul,
 * chosen over an earlier candidate for closest likeness (that one added
 * glasses not present in reference photos — this generation's glasses ARE
 * intentional/requested).
 */
export const activeAvatarProfile: AvatarProfile = {
  id: "timor-hero",
  label: "Avaturn.me export of Timor Malul — hero/upper-body presence.",
  glbPath: assetPath("models/Timorfinal.glb"),
  bones: AVATURN_BONES,
  // No morph targets on this export (no ARKit blendshapes) — blink is
  // skipped until/unless a baked blink clip or a blendshape export is
  // added.
  clips: {
    idle: "IdleV4.2(maya_head)",
  },
  // The idle clip's own Spine/Spine1/Spine2 tracks carry a torso-sway twist
  // that visibly turns the upper body away from center over the loop, even
  // with Head/Neck locked to gaze — undermining the frontal, symmetric
  // hero presentation cursor-tracking depends on. Stripped so the torso
  // stays put and gaze is the only source of left/right motion up top.
  stableBones: ["Spine", "Spine1", "Spine2"],
  // The idle clip's ANIMATED Hips rotation (distinct from its neutral bind
  // pose) sits at a near-constant ~32° yaw for the whole loop — confirmed
  // by sampling the clip's own keyframe data — which turns the entire body
  // away from camera the whole time the idle plays. This is what was
  // actually causing the "turned to one side" hero look, not the bind
  // pose. Hips' translation (idle bob) is kept; only its rotation is cut.
  yawLockBones: ["Hips"],
};

// NOTE on TimorSit.glb: evaluated as a candidate for a seated/workstation
// moment, but rejected — its bind pose is a plain standing T-pose, and its
// only animation ("mixamo.com") is a badly-retargeted motion (named after
// the source library, not this rig) that produces a broken, contorted
// backward-leaning pose rather than a natural seated stance. Neither the
// bind pose nor the clip gives a usable seated silhouette, so it's not
// wired into the scene. Revisit if a corrected export becomes available.
