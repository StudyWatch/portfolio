# Chana Tours - QA Report

Date: 29.08.2026
Target: `rxapuzqnatmcapgacpfb`

## PASS

- Target project / region / status verified.
- 9 migrations present in live history and package.
- 19 app/CRM tables use RLS.
- Public payload hides all 17 `source_only` supplier-research departures.
- Public lead RPC tested as anonymous role; privacy/consent metadata verified and test residue removed.
- CRM transactional smoke test passed: traveler, participant, payment, balance, booking group, room, occupant, follow-up, task, document metadata, contact log and audit.
- Excel workbook generated and re-opened successfully with Hebrew and RTL worksheet settings.
- Storage buckets and admin policies verified.
- Frontend contains Project URL + Publishable Key only.
- New desktop Hero and dedicated mobile Hero generated and encoded as optimized JPG/WebP assets.
- Mobile admin navigation exposes all sections through `עוד`.
- Prompt library simplified into five task groups with favorites and recent-use shortcuts.
- Supplier-research publish, content import and content reset now require an additional confirmation step.
- Image upload now previews and optimizes images to WebP before upload where supported.
- Destination editor defaults to a simple content view with advanced technical fields collapsed.
- Launch-readiness indicator added to the admin dashboard.
- `npm run check` returned `VALIDATION OK` after this final UX pass.

## Not claimed / requires owner input

- Real Auth user for Chana now exists and is linked to an active admin profile in LIVE.
- Contact phone / WhatsApp / email were supplied by the owner, applied to LIVE, and synchronized into migration 009 and the frontend fallback seed.
- No supplier-research departure was promoted into a public tour for QA.
- A full rendered browser overflow pass remains environment-dependent; source/layout safeguards and mobile-specific Hero were added, but deployment should still be opened once on a real phone and desktop before broadcasting the link.

The package is deployment-ready. Public-launch readiness becomes green after the two remaining owner steps listed in `FINAL_GO_LIVE_CHECKLIST.txt`.


## Visual QA 29.08.2026
- PASS: homepage Hero master 1774x887 plus dedicated 1200x1200 mobile crop.
- PASS: all seven destination Hero JPGs are 1774x887 with WebP alternatives.
- PASS: all 35 destination feature files are 1200x800 and no longer use the previous 720x480 low-quality derivatives.
- PASS: About Hero is full-bleed and the previous pasted transparent portrait is not used in the About Hero.
- PASS: About guiding image is 1448x1086 and three authentic secondary photos are bundled.
- PASS: destination images are visually separated from textual highlight labels, avoiding misleading one-to-one image/caption mapping.
- PASS: final CSS removes Hero backdrop blur and keeps mobile/desktop image object-fit behavior responsive.
- PASS: `npm run check` includes `VISUAL_QUALITY_OK`.
- LIMITATION: container Chromium could not complete a rendered screenshot run in this environment, so a final real-device glance is still recommended after deployment.


### Content-control QA - 29.08.2026
- `homeHeadline` is no longer hardcoded in the rendered homepage.
- Admin Settings exposes headline, optional eyebrow text and subheadline.
- Review assignment supports all destinations or a specific destination.
- About visible photography is based on real Chana photos, with crop-safe display.
- JavaScript syntax and package validation passed after the changes.
