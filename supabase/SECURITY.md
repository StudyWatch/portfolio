# Chana Tours — Security model

- The browser receives only the Supabase project URL and the publishable key.
- Database password, Secret Key and `service_role` never belong in browser code, ZIP config or Git.
- Public content is read through `public_site_payload()`; supplier research, internal notes, prompts, leads and CRM are excluded.
- Public inquiries are accepted only by `submit_inquiry()`; anonymous users have no direct inquiry table read permission.
- A supplied public tour id is validated against a real published/non-research/non-archived tour and its title/dates are canonicalized in PostgreSQL.
- Every application table has RLS enabled.
- Admin operations require Supabase Auth plus an active `admin_profiles` row.
- CRM cross-table triggers prevent assigning a room/group/contact/follow-up to the wrong traveler/tour.
- Payment records are a manual operational ledger only. Never store PAN/card number, CVV or banking passwords.
- `site-media` is public-read for website images and admin-write only.
- `admin-documents` is private and opened with short-lived signed URLs.
- A honeypot, field-length validation and same-phone cooldown protect inquiry submission.
- Audit records important participant/payment/content operations without copying full personal content into the audit trail.
- Completed operational history can be purged manually after a long retention window.

Before launch: run `POST_DEPLOY_VERIFY.sql`, Supabase Security Advisor and Performance Advisor, then fix every meaningful finding before publishing.
