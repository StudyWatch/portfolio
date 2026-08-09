# Timor Malul — Portfolio

Personal portfolio for Timor Malul, Applied AI & Full-Stack Developer.

## Tech Stack

React • TypeScript • Vite • GSAP (ScrollTrigger / ScrollSmoother / SplitText) • Three.js • WebGL • Tailwind

## Development

```bash
npm install
npm run dev
```

## Avatar

The 3D character at `public/models/timor-avatar.glb` is Timor's real likeness, generated via
[Avaturn.me](https://avaturn.me) from his own reference photos — not a third-party asset.
Bone/clip names used throughout `Character/` are read from
`src/components/Character/avatarProfile.ts` rather than hardcoded, so swapping in an updated
export later is a one-file edit; see that file's header comment for the exact steps.

## Credits

The scroll-driven camera/lighting choreography, GSAP timeline structure, and general
3D-scene architecture in this project were studied from and adapted from
[Moncy Yohannan](https://moncy.dev)'s open-source portfolio reference project
(personal-portfolio-license v1.0), per that project's attribution requirement. No original
assets (3D models, avatar, textures, copy, or visual branding) from that project are used
here — this is an original scene, avatar, and content set built specifically for Timor
Malul.
