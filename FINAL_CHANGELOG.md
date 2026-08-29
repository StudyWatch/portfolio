# FINAL CHANGELOG - LIVE-connected 2.3.0 Visual Final

## Supabase LIVE
- Target verified: `Chana Tours` / `rxapuzqnatmcapgacpfb` / `eu-central-1`.
- Frontend wired to the real Project URL + browser-safe Publishable Key.
- 9 migrations synchronized between the live project and this package, including approved contact details in migration 009.
- `ALL_MIGRATIONS.sql` updated as a one-shot reference for a new/empty project only.
- No Service Role, Secret Key or database password is included.

## Database / security
- RLS on every application/CRM table.
- Public website reads through `public_site_payload()` only.
- Public leads through `submit_inquiry()` only; direct anonymous PII reads are blocked.
- 17 supplier-research departures remain `source_only` and unpublished.
- Advisor remediation added missing FK indexes, removed a duplicate index and removed trigger helpers from the RPC surface.
- CRM audit runtime bug on `participant_payments` fixed in migration 007.
- Internal helper functions removed from unnecessary public/authenticated RPC exposure in migration 008.

## Storage
- `site-media`: public-read, admin-write/update/delete only.
- `admin-documents`: private, admin-only, short-lived signed URL access.

## Frontend / design
- Assistant + RTL + cream/navy/gold retained.
- Home hero uses one full integrated photograph with Chana naturally inside the scene.
- Destination/tours heroes remain sharp full-bleed scenic photography.
- Repeated floating/cut-out Chana portraits are not used in public heroes.
- Interest CTA is connected to the live public lead RPC.
- favicon, Apple Touch Icon, manifest and Vercel security headers retained.

## Leads / privacy
- Name + phone required.
- Tour/destination context and privacy consent metadata supported.
- Operational consent required; marketing consent separate and optional.
- Retention timestamp + safe cleanup tooling.
- Privacy / Accessibility / Terms included.

## CRM
- Central traveler database.
- Lead -> traveler/participant conversion RPC.
- Participant statuses, manual payments and balances.
- Booking groups/families, rooming, follow-ups, trip tasks, private documents and contact history.
- No card number, CVV or banking-password fields.

## Exports / recovery
- Real XLSX exports with Hebrew RTL sheets.
- Travelers, tour participants, payments/balances, rooming and full CRM workbook.
- JSON CRM/content backup paths retained.

## Final QA state
- `npm run check`: PASS / VALIDATION OK.
- Public anon payload: verified.
- Public anon lead: verified and cleaned up.
- CRM transactional smoke test: verified after migration 007, then rolled back.
- Excel generation/reopen/RTL: verified.
- Security + Performance Advisors: reviewed; meaningful actionable findings addressed.

## Remaining manual launch inputs
- Chana Auth user is now created and linked to an active admin profile in LIVE. `ADMIN_SETUP.sql` is retained for restore/recovery only.
- Approved phone/WhatsApp/email were supplied and synchronized to LIVE + migration 009.
- Publish only real Chana-led tours after confirmation.
- Perform final rendered browser/mobile overflow acceptance in a normal browser environment.

## 29.08.2026 - Final usability / Hero pass

- Replaced the homepage Hero with the new natural lakeside composition based on Chana reference photos.
- Added a dedicated mobile Hero encode/crop.
- Added mobile admin `עוד` navigation and lead badges.
- Added launch-readiness status to the admin dashboard.
- Added two-step confirmation for supplier-research publication.
- Added preview + typed confirmation for JSON content import.
- Moved reset-to-seed into a protected dangerous flow.
- Simplified destination editing and collapsed technical fields into an advanced section.
- Added image preview + browser-side WebP optimization before Storage upload.
- Reorganized prompt discovery into five practical task groups.
- Added prompt favorites, recently used shortcuts, and input/output hints.
- Updated release documentation to distinguish live backend from frontend deployment.


## Final visual quality pass - 29.08.2026
- Replaced all 7 destination Hero files with sharp premium masters.
- Rebuilt all 35 destination feature images to production quality, minimum 1200x800.
- Added WebP versions with high-quality JPG fallbacks.
- Replaced the About Hero cutout/composite with a natural full-bleed portrait.
- Replaced the large low-quality About guiding image with a high-resolution guiding scene.
- Added three authentic user-supplied travel photos to the About secondary gallery.
- Reduced Hero veil and removed backdrop blur from Hero content cards so imagery remains visibly sharp.
- Added responsive destination visual gallery and mobile scroll behavior.
- Kept all existing DB image paths stable, so the LIVE Supabase payload remains compatible without a data migration.
- Retained premium master files in assets/premium-source for future re-export.


## 29.08.2026 - Content control and About fidelity pass
- Homepage Hero headline now reads `settings.homeHeadline` and is editable from Admin > Settings.
- The small Hero eyebrow uses `settings.slogan`; if it matches the main headline it is hidden automatically to avoid duplicate text.
- Admin reviews now expose clear destination/global assignment and destination filtering.
- About page now prioritizes real photos of Chana; generated likeness images were removed from the visible About layout.
- Real About photos use non-destructive crop/contain rules so faces are not cut off.
- Footer bottom was simplified and hidden toast placeholders are now fully invisible when inactive.
