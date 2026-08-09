import * as THREE from "three";

// Original "command surface" environment: three floating displays around the
// avatar, each representing one flagship product. Built procedurally (canvas
// textures) rather than modeled/imported, so there is no dependency on any
// third-party asset — and it replaces the reference project's single
// hardcoded "Plane004 / screenlight" monitor mesh with something that
// belongs to this scene's own story.

interface ScreenSpec {
  id: string;
  title: string;
  subtitle: string;
  tags: string[];
  accent: string;
  /**
   * Optional override for the screen's media texture — e.g. a short looping
   * project demo. Defaults to the procedural canvas dashboard below. Any
   * THREE.Texture works here (a THREE.VideoTexture wrapping a looping,
   * muted <video> is the intended future use), since the material is built
   * generically against whatever texture it's given — swapping to video
   * later is a one-line change per project, not a rework of this file.
   */
  media?: () => THREE.Texture;
}

const SPECS: ScreenSpec[] = [
  {
    id: "balihofesh",
    title: "BaliHofesh",
    subtitle: "Student platform — Open University Israel",
    tags: ["51 edge functions", "Dual payment rails", "Realtime"],
    accent: "#7fae94",
  },
  {
    id: "grading",
    title: "AI Grading Engine",
    subtitle: "Fail-closed LLM exam evaluation",
    tags: ["Shadow calibration", "Rubric-secure", "20+ courses live"],
    accent: "#e0954f",
  },
  {
    id: "relive",
    title: "Relive",
    subtitle: "Realtime multi-tenant event media",
    tags: ["2-layer AI moderation", "Signed uploads", "Postgres RLS"],
    accent: "#7ea0c9",
  },
];

const PANEL_W = 1024;
const PANEL_H = 640;

function roundRect(
  ctx: CanvasRenderingContext2D,
  x: number,
  y: number,
  w: number,
  h: number,
  r: number
) {
  ctx.beginPath();
  ctx.moveTo(x + r, y);
  ctx.arcTo(x + w, y, x + w, y + h, r);
  ctx.arcTo(x + w, y + h, x, y + h, r);
  ctx.arcTo(x, y + h, x, y, r);
  ctx.arcTo(x, y, x + w, y, r);
  ctx.closePath();
}

function drawScreenTexture(spec: ScreenSpec): THREE.CanvasTexture {
  const canvas = document.createElement("canvas");
  canvas.width = PANEL_W;
  canvas.height = PANEL_H;
  const ctx = canvas.getContext("2d")!;

  const bg = ctx.createLinearGradient(0, 0, 0, PANEL_H);
  bg.addColorStop(0, "#0c0f12");
  bg.addColorStop(1, "#181c20");
  ctx.fillStyle = bg;
  ctx.fillRect(0, 0, PANEL_W, PANEL_H);

  ctx.fillStyle = spec.accent;
  ctx.fillRect(0, 0, PANEL_W, 10);

  // faint dashboard grid, purely decorative
  ctx.strokeStyle = "rgba(255,255,255,0.06)";
  ctx.lineWidth = 1;
  for (let i = 1; i < 4; i++) {
    const gx = (PANEL_W / 4) * i;
    ctx.beginPath();
    ctx.moveTo(gx, 230);
    ctx.lineTo(gx, PANEL_H - 150);
    ctx.stroke();
  }

  ctx.fillStyle = "#f3f1ea";
  ctx.font = "700 58px 'Segoe UI', Arial, sans-serif";
  ctx.fillText(spec.title, 56, 140);

  ctx.fillStyle = "#9aa3ab";
  ctx.font = "400 30px 'Segoe UI', Arial, sans-serif";
  ctx.fillText(spec.subtitle, 56, 195);

  let x = 56;
  const y = PANEL_H - 120;
  ctx.font = "600 24px 'Segoe UI', Arial, sans-serif";
  spec.tags.forEach((tag) => {
    const w = ctx.measureText(tag).width + 44;
    ctx.strokeStyle = spec.accent;
    ctx.lineWidth = 2;
    roundRect(ctx, x, y, w, 50, 25);
    ctx.stroke();
    ctx.fillStyle = spec.accent;
    ctx.fillText(tag, x + 22, y + 33);
    x += w + 16;
  });

  const texture = new THREE.CanvasTexture(canvas);
  texture.colorSpace = THREE.SRGBColorSpace;
  return texture;
}

export interface CommandScreens {
  group: THREE.Group;
  meshes: THREE.Mesh[];
  materials: THREE.MeshStandardMaterial[];
  /** Material driving the reactive point-light coupling (the center screen). */
  keyMaterial: THREE.MeshStandardMaterial;
}

/**
 * Positions/scales the three screens relative to the loaded avatar's actual
 * bounds, rather than hardcoded world coordinates — so they sit just above
 * and around the character's head like real monitors regardless of which
 * GLB (placeholder or final) is mounted, or its scale.
 */
export function createCommandScreens(
  characterSize: THREE.Vector3,
  characterCenter: THREE.Vector3
): CommandScreens {
  const group = new THREE.Group();
  group.name = "commandScreens";

  const unit = characterSize.y;
  const screenW = unit * 0.56;
  const screenH = screenW / 1.6;

  // Vertical placement is calibrated against the pulled-back "body" camera
  // shot (see cameraFit.ts: bodyTarget sits at center.y + unit*0.1, showing
  // a visible vertical span of unit*1.2 — i.e. the frame's top edge is only
  // ~0.7*unit above center). The old 0.66–0.78 offsets put the middle
  // screen ABOVE that top edge — clipped out of frame entirely, which is
  // exactly why the screens read as "too high" / barely visible. These sit
  // well inside the frame with real margin above and below instead.
  const positions: [number, number, number][] = [
    [
      characterCenter.x - unit * 0.66,
      characterCenter.y + unit * 0.32,
      characterCenter.z - unit * 0.48,
    ],
    [
      characterCenter.x,
      characterCenter.y + unit * 0.42,
      characterCenter.z - unit * 0.66,
    ],
    [
      characterCenter.x + unit * 0.66,
      characterCenter.y + unit * 0.32,
      characterCenter.z - unit * 0.48,
    ],
  ];
  const rotationsY = [0.32, 0, -0.32];

  const meshes: THREE.Mesh[] = [];
  const materials: THREE.MeshStandardMaterial[] = [];

  SPECS.forEach((spec, i) => {
    const texture = spec.media ? spec.media() : drawScreenTexture(spec);
    const material = new THREE.MeshStandardMaterial({
      map: texture,
      emissive: new THREE.Color(spec.accent),
      emissiveMap: texture,
      emissiveIntensity: 0,
      transparent: true,
      opacity: 0,
      roughness: 0.35,
      metalness: 0.1,
    });
    const geometry = new THREE.PlaneGeometry(screenW, screenH);
    const mesh = new THREE.Mesh(geometry, material);
    mesh.name = `screen_${spec.id}`;
    mesh.position.set(...positions[i]);
    mesh.rotation.y = rotationsY[i];
    group.add(mesh);
    meshes.push(mesh);
    materials.push(material);
  });

  return { group, meshes, materials, keyMaterial: materials[1] };
}
