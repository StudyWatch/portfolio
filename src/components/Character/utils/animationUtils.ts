import * as THREE from "three";
import { GLTF } from "three-stdlib";
import type { AvatarProfile } from "../avatarProfile";

// Profile-driven animation wiring: every clip name is looked up through the
// given profile's `clips` map instead of being hardcoded, and every lookup
// is defensive - a clip that doesn't exist on the currently-mounted rig is
// skipped rather than throwing, so swapping/adding avatars never crashes
// the scene. Takes the profile explicitly (rather than importing a single
// module-level active one) so any avatar can be mounted without touching
// this file.

const setAnimations = (gltf: GLTF, profile: AvatarProfile) => {
  const character = gltf.scene;
  const mixer = new THREE.AnimationMixer(character);
  const { clips, workingClipBoneNames } = profile;

  const findClip = (name?: string) =>
    name ? THREE.AnimationClip.findByName(gltf.animations, name) : undefined;

  // The head (and neck, if configured) must never be driven by a baked
  // clip - cursor-gaze tracking owns those bones exclusively, every frame.
  // Without this, a looping clip's own head/neck keyframes (e.g. an idle
  // bob) fight the procedural rotation set in Scene.tsx's render loop,
  // which is exactly what caused the head to snap/jitter instead of
  // tracking the cursor smoothly.
  const gazeBones = [profile.bones.head, profile.bones.neck].filter(
    (name): name is string => Boolean(name)
  );
  // Applied to looping/working clips only - a `pose` clip is a deliberate
  // seated hold and should keep whatever torso angle it was authored with.
  const loopExcludeBones = [...gazeBones, ...(profile.stableBones ?? [])];

  // Root-bone yaw only (translation - the idle "bob" - is kept). Some
  // exports bake a near-constant yaw offset into the ROOT bone's animated
  // rotation (not its bind pose) - e.g. a ~32° turn found on this rig's
  // Hips track - which rotates the entire body away from camera for the
  // whole idle loop. Stripped so the torso/body stays front-facing while
  // still breathing/bobbing via its translation track.
  const yawLockBones = profile.yawLockBones ?? [];

  const idleClip = findClip(clips.idle);
  if (idleClip) {
    const strippedIdle = excludeBoneRotationTracks(
      excludeBoneTracks(idleClip, loopExcludeBones),
      yawLockBones
    );
    const idleAction = mixer.clipAction(strippedIdle);
    idleAction.play();
  }

  if (clips.working) {
    const workingAction = workingClipBoneNames
      ? createBoneAction(gltf, mixer, clips.working, workingClipBoneNames)
      : mixer.clipAction(
          excludeBoneRotationTracks(
            excludeBoneTracks(findClip(clips.working)!, loopExcludeBones),
            yawLockBones
          )
        );
    if (workingAction) {
      workingAction.enabled = true;
      workingAction.play();
      workingAction.timeScale = 1;
    }
  }

  function startIntro() {
    const greetingClip = findClip(clips.greeting);
    if (greetingClip) {
      const greetingAction = mixer.clipAction(greetingClip);
      greetingAction.setLoop(THREE.LoopOnce, 1);
      greetingAction.clampWhenFinished = true;
      greetingAction.reset().play();
    }
    const blinkClip = findClip(clips.blink);
    if (blinkClip) {
      setTimeout(() => {
        mixer.clipAction(blinkClip).play().fadeIn(0.5);
      }, 2500);
    }
  }

  // Reserved for a future subtle reaction (e.g. an eyebrow-raise / smile
  // morph) once the final avatar's face rig is known - no-ops safely until
  // then rather than being ripped out.
  function hover(_gltf: GLTF, hoverDiv: HTMLDivElement | null) {
    if (!hoverDiv) return;
    return () => {};
  }

  return { mixer, startIntro, hover };
};

const createBoneAction = (
  gltf: GLTF,
  mixer: THREE.AnimationMixer,
  clip: string,
  boneNames: string[]
): THREE.AnimationAction | null => {
  const animationClip = THREE.AnimationClip.findByName(gltf.animations, clip);
  if (!animationClip) {
    console.warn(`Animation "${clip}" not found on the current avatar.`);
    return null;
  }

  const filteredClip = filterAnimationTracks(animationClip, boneNames);
  return mixer.clipAction(filteredClip);
};

const filterAnimationTracks = (
  clip: THREE.AnimationClip,
  boneNames: string[]
): THREE.AnimationClip => {
  const filteredTracks = clip.tracks.filter((track) =>
    boneNames.some((boneName) => track.name.includes(boneName))
  );

  return new THREE.AnimationClip(
    clip.name + "_filtered",
    clip.duration,
    filteredTracks
  );
};

// Inverse of filterAnimationTracks: strips any track targeting the given
// bone names (matched by track-name prefix, e.g. "Head.rotation" or
// "Head.morphTargetInfluences"), leaving everything else untouched. Used to
// keep gaze-controlled bones out of baked clips entirely.
const excludeBoneTracks = (
  clip: THREE.AnimationClip,
  boneNames: string[]
): THREE.AnimationClip => {
  if (boneNames.length === 0) return clip;
  const keptTracks = clip.tracks.filter(
    (track) => !boneNames.some((boneName) => track.name.startsWith(boneName + "."))
  );
  return new THREE.AnimationClip(clip.name + "_gazeSafe", clip.duration, keptTracks);
};

// Like excludeBoneTracks, but only drops the given bones' ROTATION track
// (glTF exports as "<bone>.quaternion"), leaving position/scale tracks for
// those same bones untouched - used to kill an unwanted baked root-bone yaw
// without also losing an idle translation bob on the same bone.
const excludeBoneRotationTracks = (
  clip: THREE.AnimationClip,
  boneNames: string[]
): THREE.AnimationClip => {
  if (boneNames.length === 0) return clip;
  const keptTracks = clip.tracks.filter(
    (track) => !boneNames.some((boneName) => track.name === boneName + ".quaternion")
  );
  return new THREE.AnimationClip(clip.name + "_yawSafe", clip.duration, keptTracks);
};

export default setAnimations;
