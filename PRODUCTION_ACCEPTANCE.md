# Chana Tours — Production Acceptance Checklist

The release is approved only when every critical item below passes.

## Supabase target
- [x] Connector reports project ref `rxapuzqnatmcapgacpfb`.
- [x] Project belongs to Organization `Chana tours`.
- [x] Region is `eu-central-1` and status is healthy.
- [x] No mutation was made to BaliHofesh.

## Database and security
- [x] All migrations are present in Supabase migration history or equivalent verified schema state.
- [x] Expected public tables exist.
- [x] RLS is enabled on every application/CRM table.
- [x] Anonymous users cannot SELECT inquiries, travelers, participants, payments, rooming, follow-ups, documents, contact log or audit log.
- [ ] Admin RPC/functions reject authenticated non-admin users.
- [x] Public payload exposes only published, non-source-only tours.
- [x] Supplier research dates remain hidden from the public site.
- [x] `site-media` bucket is public-read/admin-write only.
- [x] `admin-documents` bucket is private and admin-only.
- [x] No browser file contains service_role, DB password or another secret.

## Lead flow
- [x] "אני מעוניין/ת" requires valid name + Israeli/international phone format accepted by server validation.
- [x] Lead stores destination/tour/date context and privacy consent version.
- [x] Marketing consent is separate and optional, not prechecked.
- [x] Lead appears in admin only, never public.
- [ ] Lead can be converted to an existing/new traveler without duplicate phone records.

## CRM
- [x] Traveler can be assigned to multiple trips.
- [x] Participant status workflow works.
- [x] Manual payment, balance and currency consistency work.
- [x] No card/CVV/bank password fields exist.
- [x] Booking groups / couples / families work.
- [x] Rooming list works.
- [x] Follow-up tasks work.
- [x] Trip documents use private storage.
- [x] Safe privacy deletion refuses deletion when operational/financial records require retention.

## Export
- [x] Travelers export opens in Excel with proper Hebrew.
- [x] Trip participant export works.
- [x] Payments/balances export works.
- [x] Rooming list export works.
- [x] Full CRM workbook creates separate sheets as designed.

## Public site
- [x] 7 destinations render.
- [x] Home hero uses complete premium image with Chana, not pasted PNG.
- [x] Destination heroes remain clear, sharp and scenic.
- [ ] Desktop and mobile have no horizontal overflow.
- [ ] Contact/interest forms work from localhost and production origin.
- [x] Privacy, accessibility and terms pages open from footer.
- [x] Real phone, WhatsApp and email are configured in LIVE and in the final package.

## Final security checks
- [x] Run Supabase Security Advisor and resolve all meaningful findings.
- [x] Run Supabase Performance Advisor and review all findings.
- [x] Run `supabase/POST_DEPLOY_VERIFY.sql` and inspect every result.
- [x] Run `npm run check` locally and receive `VALIDATION OK`.
- [ ] Create one end-to-end test lead, convert to traveler/participant, add a test payment/room/follow-up, export Excel, then remove test data safely.
