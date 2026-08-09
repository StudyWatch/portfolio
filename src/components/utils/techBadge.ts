import * as THREE from "three";
import type { TechItem } from "../../data/techStack";

// Procedural sphere textures for every tech-stack item — logos included.
// A full-bleed color fill means there's no transparent/black dead zone as
// the sphere rotates: every ball reads as a designed, colored object rather
// than a dark orb with a small icon on it. Logo images are composited on
// top of that same colored background rather than used as the sphere
// texture directly, since several source assets flatten their "transparent"
// background to solid black RGB (invisible to material.color tinting,
// since black × any tint is still black).
const SIZE = 512;

function fillBackground(ctx: CanvasRenderingContext2D, item: TechItem) {
  const gradient = ctx.createLinearGradient(0, 0, SIZE, SIZE);
  gradient.addColorStop(0, item.color);
  gradient.addColorStop(1, item.colorAlt ?? item.color);
  ctx.fillStyle = gradient;
  ctx.fillRect(0, 0, SIZE, SIZE);

  const vignette = ctx.createRadialGradient(
    SIZE / 2,
    SIZE / 2,
    SIZE * 0.1,
    SIZE / 2,
    SIZE / 2,
    SIZE * 0.68
  );
  vignette.addColorStop(0, "rgba(0,0,0,0)");
  vignette.addColorStop(1, "rgba(0,0,0,0.3)");
  ctx.fillStyle = vignette;
  ctx.fillRect(0, 0, SIZE, SIZE);
}

export function drawBadgeTexture(item: TechItem): THREE.CanvasTexture {
  const canvas = document.createElement("canvas");
  canvas.width = SIZE;
  canvas.height = SIZE;
  const ctx = canvas.getContext("2d")!;

  fillBackground(ctx, item);

  ctx.fillStyle = "#f7f5f0";
  ctx.textAlign = "center";
  ctx.textBaseline = "middle";

  const words = item.label.split(" ");
  const fontSize = words.length > 1 ? 62 : 76;
  ctx.font = `700 ${fontSize}px 'Segoe UI', Arial, sans-serif`;
  ctx.shadowColor = "rgba(0,0,0,0.35)";
  ctx.shadowBlur = 14;

  if (words.length > 1) {
    const lineHeight = fontSize * 1.08;
    const startY = SIZE / 2 - ((words.length - 1) * lineHeight) / 2;
    words.forEach((word, i) => {
      ctx.fillText(word, SIZE / 2, startY + i * lineHeight);
    });
  } else {
    ctx.fillText(item.label, SIZE / 2, SIZE / 2);
  }

  ctx.shadowBlur = 0;

  const texture = new THREE.CanvasTexture(canvas);
  texture.colorSpace = THREE.SRGBColorSpace;
  return texture;
}

/** Loads a logo image and composites it onto the item's colored background.
 * SVGs in this project are single-color icons that render black-on-transparent
 * by default, so they're recolored to a clean off-white via a composite
 * step; WEBP logos already carry their own brand colors and are drawn as-is. */
export function drawLogoBadgeTexture(item: TechItem): Promise<THREE.CanvasTexture> {
  return new Promise((resolve) => {
    const canvas = document.createElement("canvas");
    canvas.width = SIZE;
    canvas.height = SIZE;
    const ctx = canvas.getContext("2d")!;
    fillBackground(ctx, item);

    const finish = () => {
      const texture = new THREE.CanvasTexture(canvas);
      texture.colorSpace = THREE.SRGBColorSpace;
      resolve(texture);
    };

    if (!item.image) {
      finish();
      return;
    }

    const img = new Image();
    img.onload = () => {
      const logoSize = SIZE * 0.42;
      const x = (SIZE - logoSize) / 2;
      const y = (SIZE - logoSize) / 2;

      if (item.image!.endsWith(".svg")) {
        // Recolor the black default fill to a clean off-white, keeping alpha.
        const iconCanvas = document.createElement("canvas");
        iconCanvas.width = SIZE;
        iconCanvas.height = SIZE;
        const iconCtx = iconCanvas.getContext("2d")!;
        iconCtx.drawImage(img, x, y, logoSize, logoSize);
        iconCtx.globalCompositeOperation = "source-in";
        iconCtx.fillStyle = "#f7f5f0";
        iconCtx.fillRect(0, 0, SIZE, SIZE);
        ctx.drawImage(iconCanvas, 0, 0);
      } else {
        ctx.drawImage(img, x, y, logoSize, logoSize);
      }
      finish();
    };
    img.onerror = () => finish();
    img.src = item.image;
  });
}
