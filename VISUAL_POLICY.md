# Visual policy — premium travel brand

These rules reflect the approved visual direction and should not be regressed during backend work.

1. The homepage hero uses a complete scene with Chana naturally inside the image. Do not reintroduce a floating transparent cutout over a blurred background.
2. Destination heroes default to full-bleed scenic destination photography. Chana should not be pasted into every destination hero.
3. Avoid repetitive AI-looking portraits: same hat, badge/lanyard, phone/camera in hand, or identical pose on every destination.
4. Do not use guide badges/lanyards as a recurring visual motif. Avoid the previously rejected Dubai-style portrait as a default hero.
5. Keep Assistant typography, navy/gold/warm-cream palette, subtle shadows, restrained gradients and high image clarity.
6. Do not add heavy blur/white wash over destination photos. Text readability should use a controlled directional gradient only.
7. Preserve all current hero assets; experimental/old Chana assets may remain in the asset library but must not be silently switched back into public hero defaults.
8. Public mobile pages must remain uncluttered, with no cropped head/body or awkward hero positioning.

## Final homepage Hero rule - 29.08.2026

The active homepage Hero is `assets/generated/home-chana-premium.webp` / `.jpg`, with a dedicated mobile source `home-chana-premium-mobile.webp`.

- Chana appears naturally on the left side of one coherent lakeside scene.
- The right side remains calm and open for RTL copy.
- No collage of multiple countries, no pasted transparent cutout, no phone/tag/hat motif repeated across destinations.
- Destination Heroes remain scenic full-bleed images and do not force Chana into every destination.
- Do not replace the final Hero with a lower-resolution or heavily blurred image.


## FINAL QUALITY PASS - 29.08.2026
- All seven destination hero files use high-resolution premium masters, with JPG fallback + WebP.
- Destination cards/highlights are no longer 720px low-quality derivatives; production feature files are 1200x800.
- About Hero is a full-bleed natural photograph, not a cutout pasted over a blurred background.
- Destination photography is separated from the textual highlight list to avoid misleading image-caption pairing.
- Mobile Hero crops preserve the subject and use an opaque content card rather than heavy backdrop blur.
- Original premium masters are retained under `assets/premium-source/` for future re-export.
