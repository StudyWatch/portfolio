# Chana Tours - Release Status

## Current status - 29.08.2026

**LIVE backend + deployment-ready frontend package.**

Supabase production is provisioned and verified on the required project. The frontend package is connected with the browser-safe Project URL and Publishable Key and has passed package validation. It is ready to deploy, but this document does not claim that a public frontend deployment was performed from this environment.

## Verified target

- Organization: `Chana tours`
- Project: `Chana Tours`
- Project ref: `rxapuzqnatmcapgacpfb`
- Region: `eu-central-1`
- Status: `ACTIVE_HEALTHY`
- No BaliHofesh project was used or modified.

## Database and security

Eight production migrations are applied and included in this ZIP:

1. `202608280001_initial_schema`
2. `202608280002_seed_content`
3. `202608280003_leads_privacy_accessibility`
4. `202608280004_crm_operations`
5. `202608280005_crm_hardening`
6. `202608280006_post_deploy_advisor_hardening`
7. `202608280007_fix_crm_audit_trigger`
8. `202608280008_minimize_rpc_surface`

- 19 application/CRM tables have RLS enabled.
- `anon` has no direct access to private CRM data.
- `site-media` is public-read with admin-only writes.
- `admin-documents` is private and admin-only.
- Internal trigger helpers are removed from the public RPC surface.
- No service-role key, secret key, or database password is present in the frontend.

## Live content state

- 7 destinations
- 17 supplier-research departures, all `source_only` and unpublished
- 13 reviews
- 28 prompts
- 99 seeded media assets
- 0 approved real public tours at the time of verification
- Auth user של חנה קיים ומאומת; `admin_profiles.active=true` עבור המשתמש שלה.
- Contact phone / WhatsApp / email are configured in LIVE and synchronized into migration 009.

## Final UX round completed

The final package includes an additional usability and safety pass:

- New homepage Hero based on Chana references, with separate optimized desktop and mobile encodes.
- Mobile admin navigation now includes a clear `עוד` menu so every admin section is reachable from a phone.
- New-lead badges and a launch-readiness checklist in the dashboard.
- Supplier-research publishing now requires explicit verification plus typed confirmation.
- Backup import now shows a preview and requires typed confirmation.
- Reset-to-seed is isolated as a dangerous action and requires typed confirmation.
- Destination editing is simple by default; SEO, slug, gallery paths and source fields are under an advanced section.
- Image upload includes preview and automatic WebP optimization before Storage upload.
- The 28 prompts are presented as five practical task groups: traveler messages, marketing, booklets/PDF, guiding, suppliers/planning.
- Prompt favorites and recent-use shortcuts are stored locally on the admin device.
- Prompt cards now explain what information to provide and what result to expect.

## QA completed

- Anonymous lead submission: PASS, test residue removed.
- CRM transactional smoke test: PASS after audit-trigger fix.
- Excel generation/re-open + Hebrew RTL: PASS.
- Security Advisor: accidental findings remediated; remaining warnings correspond to intentionally exposed guarded RPCs.
- Performance Advisor: actionable FK/duplicate-index findings remediated; remaining notices are expected unused-index INFO on a new database.
- `npm run check`: PASS after the final UX and Hero update.
- ZIP integrity and extracted-package validation are required again when the final archive is built.

## Owner inputs still required before sharing publicly

These cannot be safely invented by the package:

1. Auth/admin כבר הוגדרו ב-LIVE. אין צורך ליצור משתמש נוסף; `ADMIN_SETUP.sql` נשאר לשחזור בלבד.
2. Contact details are already configured. Verify them once after deployment; no re-entry is required.
3. Publish at least one verified real Chana tour if the site should show upcoming departures.

See `FINAL_GO_LIVE_CHECKLIST.txt` for the shortest handoff.
