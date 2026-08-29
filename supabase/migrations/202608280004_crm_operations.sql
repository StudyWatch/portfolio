-- Chana Tours CRM + trip operations
-- Converts the admin area from a content manager into a small, privacy-conscious travel CRM.
-- Apply after 202608280003_leads_privacy_accessibility.sql.

-- Tours become durable operational records. A tour that already has travelers must never be deleted
-- merely because the public content editor no longer includes it.
alter table public.tours
  add column if not exists capacity integer,
  add column if not exists archived boolean not null default false,
  add column if not exists internal_code text not null default '';

alter table public.tours drop constraint if exists tours_capacity_check;
alter table public.tours add constraint tours_capacity_check check (capacity is null or (capacity >= 1 and capacity <= 500));
create index if not exists tours_archived_start_idx on public.tours(archived, start_date);

-- A reusable traveler record. Keep the data set intentionally small; sensitive travel documents are not required here.
create table if not exists public.travelers (
  id uuid primary key default gen_random_uuid(),
  full_name text not null check (char_length(trim(full_name)) between 2 and 160),
  phone text not null check (char_length(phone) between 6 and 32),
  phone_normalized text not null default '',
  email text not null default '' check (char_length(email) <= 254),
  city text not null default '' check (char_length(city) <= 120),
  notes text not null default '' check (char_length(notes) <= 5000),
  tags text[] not null default '{}'::text[],
  marketing_consent boolean not null default false,
  marketing_consent_at timestamptz,
  archived boolean not null default false,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create or replace function public.normalize_phone(p_phone text)
returns text
language sql
immutable
set search_path = public
as $$
  select case
    when regexp_replace(coalesce(p_phone,''), '[^0-9]+', '', 'g') ~ '^9720'
      then '972' || substr(regexp_replace(coalesce(p_phone,''), '[^0-9]+', '', 'g'), 5)
    when regexp_replace(coalesce(p_phone,''), '[^0-9]+', '', 'g') ~ '^0[0-9]'
      then '972' || substr(regexp_replace(coalesce(p_phone,''), '[^0-9]+', '', 'g'), 2)
    else regexp_replace(coalesce(p_phone,''), '[^0-9]+', '', 'g')
  end;
$$;

create or replace function public.set_traveler_phone_normalized()
returns trigger
language plpgsql
set search_path = public
as $$
begin
  new.phone := trim(new.phone);
  new.phone_normalized := public.normalize_phone(new.phone);
  if char_length(new.phone_normalized) < 9 or char_length(new.phone_normalized) > 15 then
    raise exception 'invalid_phone' using errcode = '22023';
  end if;
  return new;
end;
$$;

drop trigger if exists travelers_phone_normalized on public.travelers;
create trigger travelers_phone_normalized before insert or update of phone on public.travelers
for each row execute function public.set_traveler_phone_normalized();

drop trigger if exists travelers_updated_at on public.travelers;
create trigger travelers_updated_at before update on public.travelers
for each row execute function public.set_updated_at();

create unique index if not exists travelers_phone_uidx on public.travelers(phone_normalized) where archived = false;
create index if not exists travelers_name_idx on public.travelers(lower(full_name));
create index if not exists travelers_created_idx on public.travelers(created_at desc);

-- Couple/family/booking group for a specific tour.
create table if not exists public.booking_groups (
  id uuid primary key default gen_random_uuid(),
  tour_id text not null references public.tours(id) on update cascade on delete restrict,
  name text not null default '' check (char_length(name) <= 160),
  group_type text not null default 'other' check (group_type in ('single','couple','family','friends','other')),
  notes text not null default '' check (char_length(notes) <= 3000),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

drop trigger if exists booking_groups_updated_at on public.booking_groups;
create trigger booking_groups_updated_at before update on public.booking_groups
for each row execute function public.set_updated_at();
create index if not exists booking_groups_tour_idx on public.booking_groups(tour_id);

-- One person on one tour. Status here is operational and separate from the public tour status.
create table if not exists public.trip_participants (
  id uuid primary key default gen_random_uuid(),
  tour_id text not null references public.tours(id) on update cascade on delete restrict,
  traveler_id uuid not null references public.travelers(id) on delete restrict,
  source_inquiry_id uuid references public.inquiries(id) on delete set null,
  booking_group_id uuid references public.booking_groups(id) on delete set null,
  status text not null default 'interested' check (status in ('interested','contacted','pending','registered','deposit','paid','waitlist','cancelled')),
  agreed_price numeric(12,2) check (agreed_price is null or agreed_price >= 0),
  currency text not null default 'ILS' check (currency in ('ILS','EUR','USD')),
  pickup_point text not null default '' check (char_length(pickup_point) <= 240),
  room_request text not null default '' check (char_length(room_request) <= 240),
  operational_notes text not null default '' check (char_length(operational_notes) <= 5000),
  registered_at timestamptz,
  cancelled_at timestamptz,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique(tour_id, traveler_id)
);

drop trigger if exists trip_participants_updated_at on public.trip_participants;
create trigger trip_participants_updated_at before update on public.trip_participants
for each row execute function public.set_updated_at();
create index if not exists participants_tour_status_idx on public.trip_participants(tour_id, status);
create index if not exists participants_traveler_idx on public.trip_participants(traveler_id);
create index if not exists participants_source_inquiry_idx on public.trip_participants(source_inquiry_id) where source_inquiry_id is not null;

-- Manual payment ledger only. Never store a card number, CVV, bank password or other payment credential.
create table if not exists public.participant_payments (
  id uuid primary key default gen_random_uuid(),
  participant_id uuid not null references public.trip_participants(id) on delete cascade,
  amount numeric(12,2) not null check (amount > 0),
  currency text not null default 'ILS' check (currency in ('ILS','EUR','USD')),
  paid_on date not null default current_date,
  method text not null default 'other' check (method in ('bank_transfer','cash','supplier','check','other')),
  reference text not null default '' check (char_length(reference) <= 160),
  note text not null default '' check (char_length(note) <= 2000),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

drop trigger if exists participant_payments_updated_at on public.participant_payments;
create trigger participant_payments_updated_at before update on public.participant_payments
for each row execute function public.set_updated_at();
create index if not exists payments_participant_idx on public.participant_payments(participant_id, paid_on);

-- Payment rows must use the same currency as the participant price. This avoids silently summing EUR/USD/ILS together.
create or replace function public.validate_payment_currency()
returns trigger
language plpgsql
set search_path = public
as $$
declare participant_currency text;
begin
  select currency into participant_currency from public.trip_participants where id = new.participant_id;
  if participant_currency is null then
    raise exception 'participant_not_found' using errcode='23503';
  end if;
  if new.currency is distinct from participant_currency then
    raise exception 'payment_currency_mismatch' using errcode='22023';
  end if;
  return new;
end;
$$;
drop trigger if exists participant_payments_currency_guard on public.participant_payments;
create trigger participant_payments_currency_guard before insert or update of participant_id,currency on public.participant_payments
for each row execute function public.validate_payment_currency();

-- Rooming list.
create table if not exists public.trip_rooms (
  id uuid primary key default gen_random_uuid(),
  tour_id text not null references public.tours(id) on update cascade on delete restrict,
  room_label text not null check (char_length(trim(room_label)) between 1 and 120),
  room_type text not null default 'double' check (room_type in ('single','double','twin','triple','family','other')),
  notes text not null default '' check (char_length(notes) <= 2000),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique(tour_id, room_label)
);

drop trigger if exists trip_rooms_updated_at on public.trip_rooms;
create trigger trip_rooms_updated_at before update on public.trip_rooms
for each row execute function public.set_updated_at();
create index if not exists rooms_tour_idx on public.trip_rooms(tour_id);

create table if not exists public.room_occupants (
  room_id uuid not null references public.trip_rooms(id) on delete cascade,
  participant_id uuid primary key references public.trip_participants(id) on delete cascade,
  created_at timestamptz not null default now()
);
create index if not exists room_occupants_room_idx on public.room_occupants(room_id);

-- Follow-ups are the core "what do I need to do today" workflow.
create table if not exists public.follow_ups (
  id uuid primary key default gen_random_uuid(),
  traveler_id uuid references public.travelers(id) on delete cascade,
  participant_id uuid references public.trip_participants(id) on delete cascade,
  due_at timestamptz not null,
  kind text not null default 'follow_up' check (kind in ('follow_up','payment','documents','supplier','other')),
  note text not null check (char_length(trim(note)) between 1 and 3000),
  status text not null default 'pending' check (status in ('pending','done','cancelled')),
  completed_at timestamptz,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  check (traveler_id is not null or participant_id is not null)
);

drop trigger if exists follow_ups_updated_at on public.follow_ups;
create trigger follow_ups_updated_at before update on public.follow_ups
for each row execute function public.set_updated_at();
create index if not exists followups_due_idx on public.follow_ups(status, due_at);
create index if not exists followups_participant_idx on public.follow_ups(participant_id) where participant_id is not null;

-- General trip checklist for operational preparation.
create table if not exists public.trip_tasks (
  id uuid primary key default gen_random_uuid(),
  tour_id text not null references public.tours(id) on update cascade on delete cascade,
  title text not null check (char_length(trim(title)) between 1 and 240),
  due_date date,
  priority text not null default 'normal' check (priority in ('low','normal','high')),
  status text not null default 'open' check (status in ('open','done','cancelled')),
  notes text not null default '' check (char_length(notes) <= 3000),
  completed_at timestamptz,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

drop trigger if exists trip_tasks_updated_at on public.trip_tasks;
create trigger trip_tasks_updated_at before update on public.trip_tasks
for each row execute function public.set_updated_at();
create index if not exists trip_tasks_tour_status_idx on public.trip_tasks(tour_id, status, due_date);

-- Private operational document metadata. File bytes live in a private Storage bucket.
create table if not exists public.trip_documents (
  id uuid primary key default gen_random_uuid(),
  tour_id text not null references public.tours(id) on update cascade on delete cascade,
  title text not null check (char_length(trim(title)) between 1 and 240),
  category text not null default 'other' check (category in ('itinerary','voucher','rooming','passenger_list','booklet','supplier','other')),
  storage_path text not null unique,
  file_name text not null,
  mime_type text not null default '',
  file_size bigint not null default 0 check (file_size >= 0 and file_size <= 26214400),
  created_at timestamptz not null default now()
);
create index if not exists trip_documents_tour_idx on public.trip_documents(tour_id, created_at desc);

-- Expand inquiry status to distinguish a lead converted into the traveler CRM.
alter table public.inquiries drop constraint if exists inquiries_status_check;
alter table public.inquiries add constraint inquiries_status_check check (status in ('new','contacted','handled','converted'));

-- RLS and grants: authenticated users still need public.is_admin() for every row.
alter table public.travelers enable row level security;
alter table public.booking_groups enable row level security;
alter table public.trip_participants enable row level security;
alter table public.participant_payments enable row level security;
alter table public.trip_rooms enable row level security;
alter table public.room_occupants enable row level security;
alter table public.follow_ups enable row level security;
alter table public.trip_tasks enable row level security;
alter table public.trip_documents enable row level security;

revoke all on table public.travelers from anon, authenticated;
revoke all on table public.booking_groups from anon, authenticated;
revoke all on table public.trip_participants from anon, authenticated;
revoke all on table public.participant_payments from anon, authenticated;
revoke all on table public.trip_rooms from anon, authenticated;
revoke all on table public.room_occupants from anon, authenticated;
revoke all on table public.follow_ups from anon, authenticated;
revoke all on table public.trip_tasks from anon, authenticated;
revoke all on table public.trip_documents from anon, authenticated;

grant select,insert,update,delete on table public.travelers to authenticated;
grant select,insert,update,delete on table public.booking_groups to authenticated;
grant select,insert,update,delete on table public.trip_participants to authenticated;
grant select,insert,update,delete on table public.participant_payments to authenticated;
grant select,insert,update,delete on table public.trip_rooms to authenticated;
grant select,insert,update,delete on table public.room_occupants to authenticated;
grant select,insert,update,delete on table public.follow_ups to authenticated;
grant select,insert,update,delete on table public.trip_tasks to authenticated;
grant select,insert,update,delete on table public.trip_documents to authenticated;

create policy crm_admin_travelers on public.travelers for all to authenticated using ((select public.is_admin())) with check ((select public.is_admin()));
create policy crm_admin_booking_groups on public.booking_groups for all to authenticated using ((select public.is_admin())) with check ((select public.is_admin()));
create policy crm_admin_participants on public.trip_participants for all to authenticated using ((select public.is_admin())) with check ((select public.is_admin()));
create policy crm_admin_payments on public.participant_payments for all to authenticated using ((select public.is_admin())) with check ((select public.is_admin()));
create policy crm_admin_rooms on public.trip_rooms for all to authenticated using ((select public.is_admin())) with check ((select public.is_admin()));
create policy crm_admin_room_occupants on public.room_occupants for all to authenticated using ((select public.is_admin())) with check ((select public.is_admin()));
create policy crm_admin_followups on public.follow_ups for all to authenticated using ((select public.is_admin())) with check ((select public.is_admin()));
create policy crm_admin_trip_tasks on public.trip_tasks for all to authenticated using ((select public.is_admin())) with check ((select public.is_admin()));
create policy crm_admin_documents on public.trip_documents for all to authenticated using ((select public.is_admin())) with check ((select public.is_admin()));

-- Convert a website inquiry to a reusable traveler + participant without duplicating a phone number.
create or replace function public.convert_inquiry_to_participant(p_inquiry_id uuid, p_tour_id text default null)
returns jsonb
language plpgsql
security definer
set search_path = public
as $$
declare
  q public.inquiries%rowtype;
  target_tour text;
  traveler_uuid uuid;
  participant_uuid uuid;
  normalized text;
begin
  if not public.is_admin() then
    raise exception 'not_authorized' using errcode = '42501';
  end if;

  select * into q from public.inquiries where id = p_inquiry_id for update;
  if not found then raise exception 'inquiry_not_found' using errcode = 'P0002'; end if;
  target_tour := coalesce(nullif(p_tour_id,''), nullif(q.tour_id,''));
  if target_tour is null then raise exception 'tour_required' using errcode = '22023'; end if;
  if not exists(select 1 from public.tours where id = target_tour) then raise exception 'tour_not_found' using errcode = 'P0002'; end if;

  normalized := public.normalize_phone(q.phone);
  select id into traveler_uuid from public.travelers where phone_normalized = normalized and archived = false limit 1;

  if traveler_uuid is null then
    insert into public.travelers(full_name,phone,marketing_consent,marketing_consent_at)
    values (q.name,q.phone,q.marketing_consent,q.marketing_consent_at)
    returning id into traveler_uuid;
  else
    update public.travelers
      set full_name = case when char_length(trim(full_name)) < 2 then q.name else full_name end,
          marketing_consent = marketing_consent or q.marketing_consent,
          marketing_consent_at = coalesce(marketing_consent_at,q.marketing_consent_at)
    where id = traveler_uuid;
  end if;

  insert into public.trip_participants(tour_id,traveler_id,source_inquiry_id,status)
  values (target_tour,traveler_uuid,q.id,'interested')
  on conflict(tour_id,traveler_id) do update set
    source_inquiry_id = coalesce(public.trip_participants.source_inquiry_id, excluded.source_inquiry_id)
  returning id into participant_uuid;

  update public.inquiries set status='converted' where id=q.id;
  insert into public.audit_log(admin_user_id,action,entity_type,entity_id,details)
  values (auth.uid(),'inquiry_converted','participant',participant_uuid::text,jsonb_build_object('tour_id',target_tour));

  return jsonb_build_object('travelerId',traveler_uuid::text,'participantId',participant_uuid::text,'tourId',target_tour);
end;
$$;
revoke all on function public.convert_inquiry_to_participant(uuid,text) from public;
grant execute on function public.convert_inquiry_to_participant(uuid,text) to authenticated;

-- Complete a follow-up atomically.
create or replace function public.complete_follow_up(p_id uuid)
returns void
language plpgsql
security definer
set search_path = public
as $$
begin
  if not public.is_admin() then raise exception 'not_authorized' using errcode='42501'; end if;
  update public.follow_ups set status='done', completed_at=now() where id=p_id and status='pending';
end;
$$;
revoke all on function public.complete_follow_up(uuid) from public;
grant execute on function public.complete_follow_up(uuid) to authenticated;

-- Remove expired website leads once handled or converted. Converted travelers remain in the CRM.
create or replace function public.delete_expired_inquiries()
returns integer
language plpgsql
security definer
set search_path = public
as $$
declare deleted_count integer;
begin
  if not public.is_admin() then raise exception 'not_authorized' using errcode='42501'; end if;
  delete from public.inquiries
  where retention_until < now() and status in ('handled','converted');
  get diagnostics deleted_count = row_count;
  insert into public.audit_log(admin_user_id,action,entity_type,details)
  values(auth.uid(),'delete_expired_inquiries','inquiry',jsonb_build_object('count',deleted_count));
  return deleted_count;
end;
$$;
revoke all on function public.delete_expired_inquiries() from public;
grant execute on function public.delete_expired_inquiries() to authenticated;

-- Privacy helper: hard-delete a traveler only when no financial or active operational record must be retained.
-- The UI normally archives travelers; this function is for verified deletion requests after review.
create or replace function public.erase_traveler_if_safe(p_traveler_id uuid)
returns boolean
language plpgsql
security definer
set search_path = public
as $$
begin
  if not public.is_admin() then raise exception 'not_authorized' using errcode='42501'; end if;
  if exists(
    select 1 from public.participant_payments pay
    join public.trip_participants p on p.id=pay.participant_id
    where p.traveler_id=p_traveler_id
  ) then raise exception 'financial_records_exist' using errcode='23503'; end if;
  if exists(select 1 from public.trip_participants p where p.traveler_id=p_traveler_id and p.status<>'cancelled') then
    raise exception 'active_trip_record_exists' using errcode='23503';
  end if;
  delete from public.trip_participants where traveler_id=p_traveler_id and status='cancelled';
  delete from public.follow_ups where traveler_id=p_traveler_id;
  delete from public.travelers where id=p_traveler_id;
  if found then
    insert into public.audit_log(admin_user_id,action,entity_type,entity_id,details)
    values(auth.uid(),'traveler_erased','traveler',p_traveler_id::text,'{}'::jsonb);
    return true;
  end if;
  return false;
end;
$$;
revoke all on function public.erase_traveler_if_safe(uuid) from public;
grant execute on function public.erase_traveler_if_safe(uuid) to authenticated;

-- Audit important operational changes without copying personal content into the audit table.
create or replace function public.audit_crm_change()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
declare rid text;
begin
  if tg_op='DELETE' then rid := old.id::text; else rid := new.id::text; end if;
  if tg_table_name='trip_participants' and tg_op='UPDATE' and old.status is distinct from new.status then
    insert into public.audit_log(admin_user_id,action,entity_type,entity_id,details)
    values(auth.uid(),'participant_status_changed','participant',rid,jsonb_build_object('from',old.status,'to',new.status,'tour_id',new.tour_id));
  elsif tg_table_name='participant_payments' then
    insert into public.audit_log(admin_user_id,action,entity_type,entity_id,details)
    values(auth.uid(),'payment_'||lower(tg_op),'payment',rid,
      case when tg_op='DELETE' then jsonb_build_object('participant_id',old.participant_id) else jsonb_build_object('participant_id',new.participant_id) end);
  end if;
  if tg_op='DELETE' then return old; else return new; end if;
end;
$$;

drop trigger if exists participants_audit_status on public.trip_participants;
create trigger participants_audit_status after update on public.trip_participants
for each row execute function public.audit_crm_change();
drop trigger if exists payments_audit_change on public.participant_payments;
create trigger payments_audit_change after insert or update or delete on public.participant_payments
for each row execute function public.audit_crm_change();

-- Private documents bucket. Keep passenger/operational files away from the public image bucket.
insert into storage.buckets(id,name,public,file_size_limit,allowed_mime_types)
values ('admin-documents','admin-documents',false,26214400,array[
  'application/pdf','application/vnd.openxmlformats-officedocument.wordprocessingml.document',
  'application/msword','application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
  'application/vnd.ms-excel','text/csv','image/jpeg','image/png','image/webp'
])
on conflict(id) do update set public=excluded.public,file_size_limit=excluded.file_size_limit,allowed_mime_types=excluded.allowed_mime_types;

create policy chana_docs_admin_select on storage.objects for select to authenticated using (bucket_id='admin-documents' and (select public.is_admin()));
create policy chana_docs_admin_insert on storage.objects for insert to authenticated with check (bucket_id='admin-documents' and (select public.is_admin()));
create policy chana_docs_admin_update on storage.objects for update to authenticated using (bucket_id='admin-documents' and (select public.is_admin())) with check (bucket_id='admin-documents' and (select public.is_admin()));
create policy chana_docs_admin_delete on storage.objects for delete to authenticated using (bucket_id='admin-documents' and (select public.is_admin()));

-- Public payload now ignores archived tours.
create or replace function public.public_site_payload()
returns jsonb
language sql
stable
security definer
set search_path = public
as $$
select jsonb_build_object(
  'settings', coalesce((select jsonb_build_object(
    'brandName',s.brand_name,'slogan',s.slogan,'intro',s.intro,'whatsapp',s.whatsapp,
    'phoneDisplay',s.phone_display,'email',s.email,'facebook',s.facebook,'lastSourceCheck',s.last_source_check,
    'homeHeadline',s.home_headline,'homeSubheadline',s.home_subheadline,'showSupplierResearchPublicly',false
  ) from public.site_settings s where s.id=1),'{}'::jsonb),
  'destinations', coalesce((select jsonb_agg(jsonb_build_object(
    'slug',d.slug,'name',d.name,'kicker',d.kicker,'short',d.short,'description',d.description,'hero',d.hero,
    'card',d.card,'chanaPhoto',d.chana_photo,'highlights',d.highlights,'itinerary',d.itinerary,'gallery',d.gallery,
    'featured',d.featured,'storyTitle',d.story_title,'fit',d.fit,'seoTitle',d.seo_title,'seoDescription',d.seo_description
  ) order by d.sort_order,d.name) from public.destinations d where d.published=true),'[]'::jsonb),
  'tours', coalesce((select jsonb_agg(jsonb_build_object(
    'id',t.id,'destination',t.destination,'title',t.title,'start',to_char(t.start_date,'YYYY-MM-DD'),
    'end',to_char(t.end_date,'YYYY-MM-DD'),'nights',t.nights,'board',t.board,'status',t.status,
    'sourceOnly',false,'published',true,'price',t.price,'registrationUrl',t.registration_url,'featured',t.featured,
    'capacity',t.capacity
  ) order by t.start_date nulls last,t.id) from public.tours t where t.published=true and t.source_only=false and t.archived=false),'[]'::jsonb),
  'reviews', coalesce((select jsonb_agg(jsonb_build_object(
    'id',r.id,'destination',coalesce(r.destination,'all'),'name',r.name,'text',r.text,'featured',r.featured
  ) order by r.sort_order,r.created_at) from public.reviews r where r.published=true),'[]'::jsonb)
);
$$;
revoke all on function public.public_site_payload() from public;
grant execute on function public.public_site_payload() to anon, authenticated;

-- Admin payload includes durable tour fields but CRM data is loaded separately by the CRM client.
create or replace function public.admin_site_payload()
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
    'settings', coalesce((select jsonb_build_object(
      'brandName',s.brand_name,'slogan',s.slogan,'intro',s.intro,'whatsapp',s.whatsapp,'phoneDisplay',s.phone_display,
      'email',s.email,'facebook',s.facebook,'lastSourceCheck',s.last_source_check,'homeHeadline',s.home_headline,
      'homeSubheadline',s.home_subheadline,'showSupplierResearchPublicly',s.show_supplier_research_publicly
    ) from public.site_settings s where s.id=1),'{}'::jsonb),
    'destinations', coalesce((select jsonb_agg(jsonb_build_object(
      'slug',d.slug,'name',d.name,'kicker',d.kicker,'short',d.short,'description',d.description,'hero',d.hero,'card',d.card,
      'chanaPhoto',d.chana_photo,'highlights',d.highlights,'itinerary',d.itinerary,'gallery',d.gallery,'sourceUrl',d.source_url,
      'sourceNote',d.source_note,'featured',d.featured,'storyTitle',d.story_title,'fit',d.fit,'seoTitle',d.seo_title,
      'seoDescription',d.seo_description,'published',d.published
    ) order by d.sort_order,d.name) from public.destinations d),'[]'::jsonb),
    'tours', coalesce((select jsonb_agg(jsonb_build_object(
      'id',t.id,'destination',t.destination,'title',t.title,'start',to_char(t.start_date,'YYYY-MM-DD'),
      'end',to_char(t.end_date,'YYYY-MM-DD'),'nights',t.nights,'board',t.board,'status',t.status,'source',t.source,
      'sourceOnly',t.source_only,'published',t.published,'price',t.price,'registrationUrl',t.registration_url,
      'notes',t.notes,'featured',t.featured,'capacity',t.capacity,'archived',t.archived,'internalCode',t.internal_code
    ) order by t.start_date nulls last,t.id) from public.tours t),'[]'::jsonb),
    'reviews', coalesce((select jsonb_agg(jsonb_build_object(
      'id',r.id,'destination',coalesce(r.destination,'all'),'name',r.name,'text',r.text,'featured',r.featured,'published',r.published
    ) order by r.sort_order,r.created_at) from public.reviews r),'[]'::jsonb),
    'prompts', coalesce((select jsonb_agg(jsonb_build_object(
      'id',p.id,'title',p.title,'category',p.category,'description',p.description,'text',p.prompt_text,'custom',p.is_custom
    ) order by p.sort_order,p.id) from public.prompts p),'[]'::jsonb),
    'assets', coalesce((select jsonb_agg(jsonb_build_object(
      'id',m.id,'name',m.name,'category',m.category,'src',m.src,'storagePath',m.storage_path,'uploaded',m.uploaded,'premium',m.premium
    ) order by m.created_at,m.id) from public.media_assets m),'[]'::jsonb),
    'leads', coalesce((select jsonb_agg(jsonb_build_object(
      'id',i.id::text,'name',i.name,'phone',i.phone,'destination',i.destination,'message',i.message,'status',i.status,
      'inquiryType',i.inquiry_type,'tourId',i.tour_id,'tourTitle',i.tour_title,
      'tourStart',case when i.tour_start is null then '' else to_char(i.tour_start,'YYYY-MM-DD') end,
      'tourEnd',case when i.tour_end is null then '' else to_char(i.tour_end,'YYYY-MM-DD') end,
      'privacyVersion',i.privacy_version,'marketingConsent',i.marketing_consent,
      'retentionUntil',to_char(i.retention_until at time zone 'Asia/Jerusalem','DD.MM.YYYY'),
      'createdAt',to_char(i.created_at at time zone 'Asia/Jerusalem','DD.MM.YYYY HH24:MI')
    ) order by i.created_at) from public.inquiries i),'[]'::jsonb)
  ) into result;
  return result;
end;
$$;
revoke all on function public.admin_site_payload() from public;
grant execute on function public.admin_site_payload() to authenticated;

-- Replace site content without destroying operational tours that already have CRM references.
create or replace function public.replace_site_content(payload jsonb)
returns void
language plpgsql
security definer
set search_path = public
as $$
declare s jsonb; x jsonb; n integer:=0;
begin
  if not public.is_admin() then raise exception 'not_authorized' using errcode='42501'; end if;
  if jsonb_typeof(payload)<>'object' then raise exception 'invalid_payload' using errcode='22023'; end if;
  s:=coalesce(payload->'settings','{}'::jsonb);
  insert into public.site_settings(id,brand_name,slogan,intro,whatsapp,phone_display,email,facebook,last_source_check,home_headline,home_subheadline,show_supplier_research_publicly)
  values(1,coalesce(s->>'brandName','לטייל עם חנה'),coalesce(s->>'slogan',''),coalesce(s->>'intro',''),coalesce(s->>'whatsapp',''),
    coalesce(s->>'phoneDisplay',''),coalesce(s->>'email',''),coalesce(s->>'facebook',''),coalesce(s->>'lastSourceCheck',''),
    coalesce(s->>'homeHeadline',''),coalesce(s->>'homeSubheadline',''),coalesce((s->>'showSupplierResearchPublicly')::boolean,false))
  on conflict(id) do update set brand_name=excluded.brand_name,slogan=excluded.slogan,intro=excluded.intro,whatsapp=excluded.whatsapp,
    phone_display=excluded.phone_display,email=excluded.email,facebook=excluded.facebook,last_source_check=excluded.last_source_check,
    home_headline=excluded.home_headline,home_subheadline=excluded.home_subheadline,show_supplier_research_publicly=excluded.show_supplier_research_publicly;

  n:=0;
  for x in select value from jsonb_array_elements(coalesce(payload->'destinations','[]'::jsonb)) loop
    insert into public.destinations(slug,name,kicker,short,description,hero,card,chana_photo,highlights,itinerary,gallery,source_url,source_note,featured,story_title,fit,seo_title,seo_description,published,sort_order)
    values(x->>'slug',x->>'name',coalesce(x->>'kicker',''),coalesce(x->>'short',''),coalesce(x->>'description',''),coalesce(x->>'hero',''),
      coalesce(x->>'card',''),coalesce(x->>'chanaPhoto',''),coalesce(x->'highlights','[]'::jsonb),coalesce(x->'itinerary','[]'::jsonb),
      coalesce(x->'gallery','[]'::jsonb),coalesce(x->>'sourceUrl',''),coalesce(x->>'sourceNote',''),coalesce((x->>'featured')::boolean,false),
      coalesce(x->>'storyTitle',''),coalesce(x->'fit','[]'::jsonb),coalesce(x->>'seoTitle',''),coalesce(x->>'seoDescription',''),
      coalesce((x->>'published')::boolean,true),n)
    on conflict(slug) do update set name=excluded.name,kicker=excluded.kicker,short=excluded.short,description=excluded.description,hero=excluded.hero,
      card=excluded.card,chana_photo=excluded.chana_photo,highlights=excluded.highlights,itinerary=excluded.itinerary,gallery=excluded.gallery,
      source_url=excluded.source_url,source_note=excluded.source_note,featured=excluded.featured,story_title=excluded.story_title,fit=excluded.fit,
      seo_title=excluded.seo_title,seo_description=excluded.seo_description,published=excluded.published,sort_order=excluded.sort_order;
    n:=n+1;
  end loop;

  n:=0;
  for x in select value from jsonb_array_elements(coalesce(payload->'tours','[]'::jsonb)) loop
    insert into public.tours(id,destination,title,start_date,end_date,nights,board,status,source,source_only,published,price,registration_url,notes,featured,capacity,archived,internal_code)
    values(x->>'id',x->>'destination',x->>'title',nullif(x->>'start','')::date,nullif(x->>'end','')::date,
      coalesce(nullif(x->>'nights','')::integer,0),coalesce(x->>'board',''),coalesce(x->>'status','planned'),coalesce(x->>'source',''),
      coalesce((x->>'sourceOnly')::boolean,false),coalesce((x->>'published')::boolean,false),coalesce(x->>'price',''),
      coalesce(x->>'registrationUrl',''),coalesce(x->>'notes',''),coalesce((x->>'featured')::boolean,false),
      nullif(x->>'capacity','')::integer,coalesce((x->>'archived')::boolean,false),coalesce(x->>'internalCode',''))
    on conflict(id) do update set destination=excluded.destination,title=excluded.title,start_date=excluded.start_date,end_date=excluded.end_date,
      nights=excluded.nights,board=excluded.board,status=excluded.status,source=excluded.source,source_only=excluded.source_only,published=excluded.published,
      price=excluded.price,registration_url=excluded.registration_url,notes=excluded.notes,featured=excluded.featured,capacity=excluded.capacity,
      archived=excluded.archived,internal_code=excluded.internal_code;
    n:=n+1;
  end loop;

  -- Tours removed from the editor are archived if operational data exists, otherwise deleted.
  update public.tours t set archived=true,published=false
  where not exists(select 1 from jsonb_array_elements(coalesce(payload->'tours','[]'::jsonb)) x where x->>'id'=t.id)
    and (exists(select 1 from public.trip_participants p where p.tour_id=t.id)
      or exists(select 1 from public.inquiries i where i.tour_id=t.id));
  delete from public.tours t
  where not exists(select 1 from jsonb_array_elements(coalesce(payload->'tours','[]'::jsonb)) x where x->>'id'=t.id)
    and not exists(select 1 from public.trip_participants p where p.tour_id=t.id)
    and not exists(select 1 from public.inquiries i where i.tour_id=t.id);

  delete from public.destinations d where not exists(select 1 from jsonb_array_elements(coalesce(payload->'destinations','[]'::jsonb)) x where x->>'slug'=d.slug)
    and not exists(select 1 from public.tours t where t.destination=d.slug);

  delete from public.reviews;
  n:=0;
  for x in select value from jsonb_array_elements(coalesce(payload->'reviews','[]'::jsonb)) loop
    insert into public.reviews(id,destination,name,text,featured,published,sort_order)
    values(x->>'id',nullif(x->>'destination','all'),x->>'name',x->>'text',coalesce((x->>'featured')::boolean,false),coalesce((x->>'published')::boolean,true),n);
    n:=n+1;
  end loop;
  delete from public.prompts;
  n:=0;
  for x in select value from jsonb_array_elements(coalesce(payload->'prompts','[]'::jsonb)) loop
    insert into public.prompts(id,title,category,description,prompt_text,is_custom,sort_order)
    values(x->>'id',x->>'title',coalesce(x->>'category',''),coalesce(x->>'description',''),coalesce(x->>'text',''),coalesce((x->>'custom')::boolean,false),n);
    n:=n+1;
  end loop;
  for x in select value from jsonb_array_elements(coalesce(payload->'assets','[]'::jsonb)) loop
    insert into public.media_assets(id,name,category,src,storage_path,uploaded,premium,visibility)
    values(x->>'id',x->>'name',coalesce(x->>'category','destination'),coalesce(x->>'src',''),nullif(x->>'storagePath',''),
      coalesce((x->>'uploaded')::boolean,false),coalesce((x->>'premium')::boolean,false),'public')
    on conflict(id) do update set name=excluded.name,category=excluded.category,src=excluded.src,storage_path=excluded.storage_path,
      uploaded=excluded.uploaded,premium=excluded.premium,visibility=excluded.visibility;
  end loop;
  delete from public.media_assets m where not exists(select 1 from jsonb_array_elements(coalesce(payload->'assets','[]'::jsonb)) x where x->>'id'=m.id);
  insert into public.audit_log(admin_user_id,action,entity_type,details)
  values(auth.uid(),'replace_site_content','site',jsonb_build_object('destinations',jsonb_array_length(coalesce(payload->'destinations','[]'::jsonb)),
    'tours',jsonb_array_length(coalesce(payload->'tours','[]'::jsonb)),'reviews',jsonb_array_length(coalesce(payload->'reviews','[]'::jsonb)),
    'prompts',jsonb_array_length(coalesce(payload->'prompts','[]'::jsonb)),'assets',jsonb_array_length(coalesce(payload->'assets','[]'::jsonb))));
end;
$$;
revoke all on function public.replace_site_content(jsonb) from public;
grant execute on function public.replace_site_content(jsonb) to authenticated;
