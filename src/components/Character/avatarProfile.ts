import { assetPath } from "../../utils/assetPath";

export interface AvatarBoneMap {
  root: string;

  head: string;
  neck?: string;

  rightShoulder?: string;
  rightUpperArm?: string;
  rightForeArm?: string;
  rightHand?: string;

  leftShoulder?: string;
  leftUpperArm?: string;
  leftForeArm?: string;
  leftHand?: string;
}

export interface AvatarMorphMap {
  meshName: string;
  blinkLeft?: string;
  blinkRight?: string;
}

export interface AvatarClipMap {
  idle?: string;
  greeting?: string;
  working?: string;
  blink?: string;
}

export interface AvatarProfile {
  id: string;
  label: string;
  glbPath: string;

  bones: AvatarBoneMap;

  morphs?: AvatarMorphMap;

  clips: AvatarClipMap;

  workingClipBoneNames?: string[];

  stableBones?: string[];

  yawLockBones?: string[];
}

const AVATURN_BONES: AvatarBoneMap = {
  root: "Hips",

  head: "Head",
  neck: "Neck",

  rightShoulder: "RightShoulder",
  rightUpperArm: "RightArm",
  rightForeArm: "RightForeArm",
  rightHand: "RightHand",

  leftShoulder: "LeftShoulder",
  leftUpperArm: "LeftArm",
  leftForeArm: "LeftForeArm",
  leftHand: "LeftHand",
};

export const activeAvatarProfile: AvatarProfile = {
  id: "timor-hero",

  label:
    "Avaturn.me Timor hero avatar",

  glbPath: assetPath(
    "models/Timorfinal.glb"
  ),

  bones: AVATURN_BONES,

  clips: {
    idle: "IdleV4.2(maya_head)",
  },

  stableBones: [
    "Spine",
    "Spine1",
    "Spine2",
  ],

  yawLockBones: [
    "Hips",
  ],
};