-- Chana Tours CRM hardening and communication history
-- Apply after 202608280004_crm_operations.sql.

-- Lightweight contact history so Chana can remember what happened with a traveler
-- without storing message bodies or unnecessary sensitive data.
create table if not exists public.contact_log (
  id uuid primary key default gen_random_uuid(),
  traveler_id uuid not null references public.travelers(id) on delete cascade,
  participant_id uuid references public.trip_participants(id) on delete set null,
  channel text not null default 'note' check (channel in ('phone','whatsapp','email','note','in_person')),
  direction text not null default 'outbound' check (direction in ('outbound','inbound','internal')),
  summary text not null default '' check (char_length(summary) <= 1000),
  occurred_at timestamptz not null default now(),
  created_at timestamptz not null default now()
);
create index if not exists contact_log_traveler_time_idx on public.contact_log(traveler_id, occurred_at desc);
create index if not exists contact_log_participant_time_idx on public.contact_log(participant_id, occurred_at desc) where participant_id is not null;

alter table public.contact_log enable row level security;
revoke all on table public.contact_log from anon, authenticated;
grant select,insert,update,delete on table public.contact_log to authenticated;
create policy crm_admin_contact_log on public.contact_log for all to authenticated
using ((select public.is_admin())) with check ((select public.is_admin()));

-- Keep cross-table relationships consistent even if a future frontend contains a bug.
create or replace function public.validate_participant_group_tour()
returns trigger
language plpgsql
set search_path = public
as $$
declare group_tour text;
begin
  if new.booking_group_id is null then return new; end if;
  select tour_id into group_tour from public.booking_groups where id=new.booking_group_id;
  if group_tour is null then raise exception 'booking_group_not_found' using errcode='23503'; end if;
  if group_tour is distinct from new.tour_id then raise exception 'booking_group_wrong_tour' using errcode='23514'; end if;
  return new;
end;
$$;
drop trigger if exists participants_group_tour_guard on public.trip_participants;
create trigger participants_group_tour_guard
before insert or update of booking_group_id,tour_id on public.trip_participants
for each row execute function public.validate_participant_group_tour();

create or replace function public.validate_room_occupant_tour()
returns trigger
language plpgsql
set search_path = public
as $$
declare room_tour text; participant_tour text;
begin
  select tour_id into room_tour from public.trip_rooms where id=new.room_id;
  select tour_id into participant_tour from public.trip_participants where id=new.participant_id;
  if room_tour is null or participant_tour is null then raise exception 'room_or_participant_not_found' using errcode='23503'; end if;
  if room_tour is distinct from participant_tour then raise exception 'room_participant_wrong_tour' using errcode='23514'; end if;
  return new;
end;
$$;
drop trigger if exists room_occupants_tour_guard on public.room_occupants;
create trigger room_occupants_tour_guard
before insert or update of room_id,participant_id on public.room_occupants
for each row execute function public.validate_room_occupant_tour();

create or replace function public.validate_followup_identity()
returns trigger
language plpgsql
set search_path = public
as $$
declare participant_traveler uuid;
begin
  if new.participant_id is null then return new; end if;
  select traveler_id into participant_traveler from public.trip_participants where id=new.participant_id;
  if participant_traveler is null then raise exception 'participant_not_found' using errcode='23503'; end if;
  if new.traveler_id is not null and new.traveler_id is distinct from participant_traveler then
    raise exception 'followup_traveler_mismatch' using errcode='23514';
  end if;
  if new.traveler_id is null then new.traveler_id := participant_traveler; end if;
  return new;
end;
$$;
drop trigger if exists followups_identity_guard on public.follow_ups;
create trigger followups_identity_guard
before insert or update of traveler_id,participant_id on public.follow_ups
for each row execute function public.validate_followup_identity();

-- Contact entries tied to a participant must belong to that participant's traveler.
create or replace function public.validate_contact_identity()
returns trigger
language plpgsql
set search_path = public
as $$
declare participant_traveler uuid;
begin
  if new.participant_id is null then return new; end if;
  select traveler_id into participant_traveler from public.trip_participants where id=new.participant_id;
  if participant_traveler is null then raise exception 'participant_not_found' using errcode='23503'; end if;
  if participant_traveler is distinct from new.traveler_id then raise exception 'contact_traveler_mismatch' using errcode='23514'; end if;
  return new;
end;
$$;
drop trigger if exists contact_log_identity_guard on public.contact_log;
create trigger contact_log_identity_guard
before insert or update of traveler_id,participant_id on public.contact_log
for each row execute function public.validate_contact_identity();

-- Canonicalize tour context in website inquiries. Visitors cannot forge the title/date of a real tour.
create or replace function public.submit_inquiry(
  p_name text,
  p_phone text,
  p_destination text default '',
  p_message text default '',
  p_source text default 'website',
  p_website text default '',
  p_consent boolean default false,
  p_inquiry_type text default 'general',
  p_tour_id text default null,
  p_tour_title text default '',
  p_tour_start date default null,
  p_tour_end date default null,
  p_privacy_version text default '2026-08-28',
  p_marketing_consent boolean default false
)
returns uuid
language plpgsql
security definer
set search_path = public
as $$
declare
  new_id uuid;
  normalized_phone text;
  canonical_tour public.tours%rowtype;
  final_destination text := left(trim(coalesce(p_destination,'')),160);
  final_tour_title text := left(trim(coalesce(p_tour_title,'')),240);
  final_tour_start date := p_tour_start;
  final_tour_end date := p_tour_end;
begin
  if coalesce(trim(p_website), '') <> '' then raise exception 'invalid_submission' using errcode='22023'; end if;
  if coalesce(p_consent,false) is not true then raise exception 'consent_required' using errcode='22023'; end if;
  if char_length(trim(coalesce(p_name,''))) < 2 or char_length(trim(coalesce(p_name,''))) > 120 then raise exception 'invalid_name' using errcode='22023'; end if;
  normalized_phone := public.normalize_phone(p_phone);
  if char_length(normalized_phone) < 9 or char_length(normalized_phone) > 15 then raise exception 'invalid_phone' using errcode='22023'; end if;
  if char_length(coalesce(p_message,'')) > 3000 then raise exception 'message_too_long' using errcode='22023'; end if;
  if coalesce(p_inquiry_type,'general') not in ('general','destination_interest','tour_interest','future_date') then raise exception 'invalid_inquiry_type' using errcode='22023'; end if;

  if nullif(trim(coalesce(p_tour_id,'')),'') is not null then
    select * into canonical_tour from public.tours
      where id=trim(p_tour_id) and published=true and source_only=false and archived=false;
    if not found then raise exception 'tour_not_available' using errcode='22023'; end if;
    final_tour_title := canonical_tour.title;
    final_tour_start := canonical_tour.start_date;
    final_tour_end := canonical_tour.end_date;
    select name into final_destination from public.destinations where slug=canonical_tour.destination;
  end if;

  if exists (
    select 1 from public.inquiries i
    where public.normalize_phone(i.phone)=normalized_phone
      and i.created_at > now() - interval '90 seconds'
  ) then raise exception 'rate_limited' using errcode='P0001'; end if;

  insert into public.inquiries(
    name,phone,destination,message,source,consent,consent_at,
    inquiry_type,tour_id,tour_title,tour_start,tour_end,
    privacy_version,marketing_consent,marketing_consent_at,retention_until
  ) values (
    trim(p_name),trim(p_phone),coalesce(final_destination,''),trim(coalesce(p_message,'')),left(trim(coalesce(p_source,'website')),80),true,now(),
    coalesce(p_inquiry_type,'general'),nullif(trim(coalesce(p_tour_id,'')),''),coalesce(final_tour_title,''),final_tour_start,final_tour_end,
    left(trim(coalesce(p_privacy_version,'2026-08-28')),40),coalesce(p_marketing_consent,false),
    case when coalesce(p_marketing_consent,false) then now() else null end,
    now()+interval '24 months'
  ) returning id into new_id;
  return new_id;
end;
$$;
revoke all on function public.submit_inquiry(text,text,text,text,text,text,boolean,text,text,text,date,date,text,boolean) from public;
grant execute on function public.submit_inquiry(text,text,text,text,text,text,boolean,text,text,text,date,date,text,boolean) to anon, authenticated;

-- One authenticated request loads the whole private CRM, reducing round trips while preserving RLS/admin checks.
create or replace function public.admin_crm_payload()
returns jsonb
language plpgsql
stable
security definer
set search_path = public
as $$
declare result jsonb;
begin
  if not public.is_admin() then raise exception 'not_authorized' using errcode='42501'; end if;
  select jsonb_build_object(
    'travelers',coalesce((select jsonb_agg(to_jsonb(t) order by t.created_at) from public.travelers t),'[]'::jsonb),
    'participants',coalesce((select jsonb_agg(to_jsonb(p) order by p.created_at) from public.trip_participants p),'[]'::jsonb),
    'payments',coalesce((select jsonb_agg(to_jsonb(p) order by p.paid_on,p.created_at) from public.participant_payments p),'[]'::jsonb),
    'bookingGroups',coalesce((select jsonb_agg(to_jsonb(g) order by g.created_at) from public.booking_groups g),'[]'::jsonb),
    'rooms',coalesce((select jsonb_agg(to_jsonb(r) order by r.created_at) from public.trip_rooms r),'[]'::jsonb),
    'roomOccupants',coalesce((select jsonb_agg(to_jsonb(o) order by o.created_at) from public.room_occupants o),'[]'::jsonb),
    'followUps',coalesce((select jsonb_agg(to_jsonb(f) order by f.due_at) from public.follow_ups f),'[]'::jsonb),
    'tasks',coalesce((select jsonb_agg(to_jsonb(t) order by t.due_date nulls last,t.created_at) from public.trip_tasks t),'[]'::jsonb),
    'documents',coalesce((select jsonb_agg(to_jsonb(d) order by d.created_at) from public.trip_documents d),'[]'::jsonb),
    'contactLog',coalesce((select jsonb_agg(to_jsonb(c) order by c.occurred_at desc) from public.contact_log c),'[]'::jsonb)
  ) into result;
  return result;
end;
$$;
revoke all on function public.admin_crm_payload() from public;
grant execute on function public.admin_crm_payload() to authenticated;

-- Purge old completed internal CRM reminders and communication logs after a long safety window.
-- This is intentionally manual/admin-triggered, not an automatic destructive cron.
create or replace function public.cleanup_old_operational_history(p_before timestamptz default now()-interval '5 years')
returns jsonb
language plpgsql
security definer
set search_path = public
as $$
declare contacts_count integer; followups_count integer;
begin
  if not public.is_admin() then raise exception 'not_authorized' using errcode='42501'; end if;
  delete from public.contact_log where occurred_at < p_before;
  get diagnostics contacts_count = row_count;
  delete from public.follow_ups where status in ('done','cancelled') and coalesce(completed_at,updated_at) < p_before;
  get diagnostics followups_count = row_count;
  insert into public.audit_log(admin_user_id,action,entity_type,details)
  values(auth.uid(),'cleanup_old_operational_history','crm',jsonb_build_object('contacts',contacts_count,'followups',followups_count,'before',p_before));
  return jsonb_build_object('contacts',contacts_count,'followups',followups_count);
end;
$$;
revoke all on function public.cleanup_old_operational_history(timestamptz) from public;
grant execute on function public.cleanup_old_operational_history(timestamptz) to authenticated;
