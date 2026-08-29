-- Post-deploy hardening from Supabase Security/Performance Advisors.
-- Trigger/event-trigger helpers should never be callable through the Data API.
revoke all on function public.audit_crm_change() from public, anon, authenticated;
revoke all on function public.audit_inquiry_change() from public, anon, authenticated;
revoke all on function public.rls_auto_enable() from public, anon, authenticated;

-- Cover foreign keys used by deletes/joins.
create index if not exists followups_traveler_idx on public.follow_ups(traveler_id) where traveler_id is not null;
create index if not exists participants_booking_group_idx on public.trip_participants(booking_group_id) where booking_group_id is not null;

-- Migration 003 duplicated the original status/created_at index. Keep the original name from migration 001.
drop index if exists public.inquiries_status_created_at_idx;
