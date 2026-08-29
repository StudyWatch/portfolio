-- Lead enrichment, privacy-accountability fields and safer public inquiry flow.
-- Apply after 202608280001_initial_schema.sql and 202608280002_seed_content.sql.

alter table public.inquiries
  add column if not exists inquiry_type text not null default 'general',
  add column if not exists tour_id text,
  add column if not exists tour_title text not null default '',
  add column if not exists tour_start date,
  add column if not exists tour_end date,
  add column if not exists privacy_version text not null default '2026-08-28',
  add column if not exists marketing_consent boolean not null default false,
  add column if not exists marketing_consent_at timestamptz,
  add column if not exists retention_until timestamptz not null default (now() + interval '24 months');

alter table public.inquiries
  drop constraint if exists inquiries_inquiry_type_check;
alter table public.inquiries
  add constraint inquiries_inquiry_type_check
  check (inquiry_type in ('general','destination_interest','tour_interest','future_date'));

create index if not exists inquiries_created_at_idx on public.inquiries(created_at desc);
create index if not exists inquiries_status_created_at_idx on public.inquiries(status, created_at desc);
create index if not exists inquiries_tour_id_idx on public.inquiries(tour_id) where tour_id is not null;
create index if not exists inquiries_phone_normalized_idx on public.inquiries ((regexp_replace(phone, '[^0-9]+', '', 'g')));

-- Replace the old RPC so every public inquiry can record its exact context.
drop function if exists public.submit_inquiry(text,text,text,text,text,text,boolean);

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
begin
  -- Honeypot: legitimate visitors never fill this field.
  if coalesce(trim(p_website), '') <> '' then
    raise exception 'invalid_submission' using errcode = '22023';
  end if;

  if coalesce(p_consent,false) is not true then
    raise exception 'consent_required' using errcode = '22023';
  end if;

  if char_length(trim(coalesce(p_name,''))) < 2 or char_length(trim(coalesce(p_name,''))) > 120 then
    raise exception 'invalid_name' using errcode = '22023';
  end if;

  normalized_phone := regexp_replace(coalesce(p_phone,''), '[^0-9]+', '', 'g');
  if char_length(normalized_phone) < 9 or char_length(normalized_phone) > 15 then
    raise exception 'invalid_phone' using errcode = '22023';
  end if;

  if char_length(coalesce(p_message,'')) > 3000 then
    raise exception 'message_too_long' using errcode = '22023';
  end if;

  if coalesce(p_inquiry_type,'general') not in ('general','destination_interest','tour_interest','future_date') then
    raise exception 'invalid_inquiry_type' using errcode = '22023';
  end if;

  -- Low-friction anti-spam / accidental double-submit protection.
  if exists (
    select 1 from public.inquiries i
    where regexp_replace(i.phone, '[^0-9]+', '', 'g') = normalized_phone
      and i.created_at > now() - interval '90 seconds'
  ) then
    raise exception 'rate_limited' using errcode = 'P0001';
  end if;

  insert into public.inquiries(
    name, phone, destination, message, source, consent, consent_at,
    inquiry_type, tour_id, tour_title, tour_start, tour_end,
    privacy_version, marketing_consent, marketing_consent_at, retention_until
  )
  values (
    trim(p_name), trim(p_phone), left(trim(coalesce(p_destination,'')),160),
    trim(coalesce(p_message,'')), left(trim(coalesce(p_source,'website')),80), true, now(),
    coalesce(p_inquiry_type,'general'), nullif(trim(coalesce(p_tour_id,'')),''),
    left(trim(coalesce(p_tour_title,'')),240), p_tour_start, p_tour_end,
    left(trim(coalesce(p_privacy_version,'2026-08-28')),40),
    coalesce(p_marketing_consent,false),
    case when coalesce(p_marketing_consent,false) then now() else null end,
    now() + interval '24 months'
  )
  returning id into new_id;

  return new_id;
end;
$$;

revoke all on function public.submit_inquiry(text,text,text,text,text,text,boolean,text,text,text,date,date,text,boolean) from public;
grant execute on function public.submit_inquiry(text,text,text,text,text,text,boolean,text,text,text,date,date,text,boolean) to anon, authenticated;

-- Recreate admin payload with richer lead context while keeping public data private.
create or replace function public.admin_site_payload()
returns jsonb
language plpgsql
stable
security definer
set search_path = public
as $$
declare result jsonb;
begin
  if not public.is_admin() then
    raise exception 'not_authorized' using errcode = '42501';
  end if;

  select jsonb_build_object(
    'settings', coalesce((select jsonb_build_object(
      'brandName', s.brand_name,
      'slogan', s.slogan,
      'intro', s.intro,
      'whatsapp', s.whatsapp,
      'phoneDisplay', s.phone_display,
      'email', s.email,
      'facebook', s.facebook,
      'lastSourceCheck', s.last_source_check,
      'homeHeadline', s.home_headline,
      'homeSubheadline', s.home_subheadline,
      'showSupplierResearchPublicly', s.show_supplier_research_publicly
    ) from public.site_settings s where s.id = 1), '{}'::jsonb),
    'destinations', coalesce((select jsonb_agg(jsonb_build_object(
      'slug', d.slug,'name', d.name,'kicker', d.kicker,'short', d.short,'description', d.description,
      'hero', d.hero,'card', d.card,'chanaPhoto', d.chana_photo,'highlights', d.highlights,
      'itinerary', d.itinerary,'gallery', d.gallery,'sourceUrl', d.source_url,'sourceNote', d.source_note,
      'featured', d.featured,'storyTitle', d.story_title,'fit', d.fit,'seoTitle', d.seo_title,
      'seoDescription', d.seo_description,'published', d.published
    ) order by d.sort_order, d.name) from public.destinations d), '[]'::jsonb),
    'tours', coalesce((select jsonb_agg(jsonb_build_object(
      'id', t.id,'destination', t.destination,'title', t.title,'start', to_char(t.start_date,'YYYY-MM-DD'),
      'end', to_char(t.end_date,'YYYY-MM-DD'),'nights', t.nights,'board', t.board,'status', t.status,
      'source', t.source,'sourceOnly', t.source_only,'published', t.published,'price', t.price,
      'registrationUrl', t.registration_url,'notes', t.notes,'featured', t.featured
    ) order by t.start_date nulls last, t.id) from public.tours t), '[]'::jsonb),
    'reviews', coalesce((select jsonb_agg(jsonb_build_object(
      'id', r.id,'destination', coalesce(r.destination,'all'),'name', r.name,'text', r.text,
      'featured', r.featured,'published', r.published
    ) order by r.sort_order, r.created_at) from public.reviews r), '[]'::jsonb),
    'prompts', coalesce((select jsonb_agg(jsonb_build_object(
      'id', p.id,'title', p.title,'category', p.category,'description', p.description,'text', p.prompt_text,
      'custom', p.is_custom
    ) order by p.sort_order, p.id) from public.prompts p), '[]'::jsonb),
    'assets', coalesce((select jsonb_agg(jsonb_build_object(
      'id', m.id,'name', m.name,'category', m.category,'src', m.src,'storagePath', m.storage_path,
      'uploaded', m.uploaded,'premium', m.premium
    ) order by m.created_at, m.id) from public.media_assets m), '[]'::jsonb),
    'leads', coalesce((select jsonb_agg(jsonb_build_object(
      'id', i.id::text,
      'name', i.name,
      'phone', i.phone,
      'destination', i.destination,
      'message', i.message,
      'status', i.status,
      'inquiryType', i.inquiry_type,
      'tourId', i.tour_id,
      'tourTitle', i.tour_title,
      'tourStart', case when i.tour_start is null then '' else to_char(i.tour_start,'YYYY-MM-DD') end,
      'tourEnd', case when i.tour_end is null then '' else to_char(i.tour_end,'YYYY-MM-DD') end,
      'privacyVersion', i.privacy_version,
      'marketingConsent', i.marketing_consent,
      'retentionUntil', to_char(i.retention_until at time zone 'Asia/Jerusalem','DD.MM.YYYY'),
      'createdAt', to_char(i.created_at at time zone 'Asia/Jerusalem','DD.MM.YYYY HH24:MI')
    ) order by i.created_at) from public.inquiries i), '[]'::jsonb)
  ) into result;

  return result;
end;
$$;

revoke all on function public.admin_site_payload() from public;
grant execute on function public.admin_site_payload() to authenticated;

-- Admin-only helper to delete expired leads intentionally rather than exposing a scheduled job.
create or replace function public.delete_expired_inquiries()
returns integer
language plpgsql
security definer
set search_path = public
as $$
declare deleted_count integer;
begin
  if not public.is_admin() then
    raise exception 'not_authorized' using errcode = '42501';
  end if;
  delete from public.inquiries
  where retention_until < now() and status = 'handled';
  get diagnostics deleted_count = row_count;
  insert into public.audit_log(admin_user_id, action, entity_type, details)
  values (auth.uid(), 'delete_expired_inquiries', 'inquiry', jsonb_build_object('count', deleted_count));
  return deleted_count;
end;
$$;

revoke all on function public.delete_expired_inquiries() from public;
grant execute on function public.delete_expired_inquiries() to authenticated;

-- Accountability without retaining deleted personal content in the audit log.
create or replace function public.audit_inquiry_change()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
begin
  if tg_op = 'UPDATE' and old.status is distinct from new.status then
    insert into public.audit_log(admin_user_id, action, entity_type, entity_id, details)
    values (auth.uid(), 'inquiry_status_changed', 'inquiry', new.id::text,
      jsonb_build_object('from', old.status, 'to', new.status));
    return new;
  elsif tg_op = 'DELETE' then
    insert into public.audit_log(admin_user_id, action, entity_type, entity_id, details)
    values (auth.uid(), 'inquiry_deleted', 'inquiry', old.id::text, '{}'::jsonb);
    return old;
  end if;
  return coalesce(new, old);
end;
$$;

drop trigger if exists inquiries_audit_update on public.inquiries;
create trigger inquiries_audit_update
after update on public.inquiries
for each row execute function public.audit_inquiry_change();

drop trigger if exists inquiries_audit_delete on public.inquiries;
create trigger inquiries_audit_delete
after delete on public.inquiries
for each row execute function public.audit_inquiry_change();
