-- Chana Tours - combined migration bundle
-- Apply to a NEW Chana Tours project only, in this exact order.

-- ============================================================
-- 202608280001_initial_schema.sql
-- ============================================================
-- Chana Tours production schema
-- Security model: public visitors use narrow SECURITY DEFINER RPCs only.
-- Authenticated users still receive no table access unless they are listed in admin_profiles.

create extension if not exists pgcrypto with schema extensions;
revoke create on schema public from public;

create table if not exists public.admin_profiles (
  user_id uuid primary key references auth.users(id) on delete cascade,
  display_name text not null default 'חנה',
  active boolean not null default true,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.site_settings (
  id smallint primary key default 1 check (id = 1),
  brand_name text not null default 'לטייל עם חנה',
  slogan text not null default 'חוויה אישית בטיול מאורגן',
  intro text not null default '',
  whatsapp text not null default '',
  phone_display text not null default '',
  email text not null default '',
  facebook text not null default '',
  last_source_check text not null default '',
  home_headline text not null default 'מטיילים בעולם. מרגישים בבית.',
  home_subheadline text not null default '',
  show_supplier_research_publicly boolean not null default false,
  updated_at timestamptz not null default now()
);

create table if not exists public.destinations (
  slug text primary key,
  name text not null,
  kicker text not null default '',
  short text not null default '',
  description text not null default '',
  hero text not null default '',
  card text not null default '',
  chana_photo text not null default '',
  highlights jsonb not null default '[]'::jsonb check (jsonb_typeof(highlights) = 'array'),
  itinerary jsonb not null default '[]'::jsonb check (jsonb_typeof(itinerary) = 'array'),
  gallery jsonb not null default '[]'::jsonb check (jsonb_typeof(gallery) = 'array'),
  source_url text not null default '',
  source_note text not null default '',
  featured boolean not null default false,
  story_title text not null default '',
  fit jsonb not null default '[]'::jsonb check (jsonb_typeof(fit) = 'array'),
  seo_title text not null default '',
  seo_description text not null default '',
  published boolean not null default true,
  sort_order integer not null default 0,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.tours (
  id text primary key,
  destination text not null references public.destinations(slug) on update cascade on delete restrict,
  title text not null,
  start_date date,
  end_date date,
  nights integer not null default 0 check (nights >= 0 and nights <= 90),
  board text not null default '',
  status text not null default 'planned' check (status in ('open','last','full','planned')),
  source text not null default '',
  source_only boolean not null default false,
  published boolean not null default false,
  price text not null default '',
  registration_url text not null default '',
  notes text not null default '',
  featured boolean not null default false,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  check (end_date is null or start_date is null or end_date >= start_date)
);

create table if not exists public.reviews (
  id text primary key,
  destination text,
  name text not null,
  text text not null,
  featured boolean not null default false,
  published boolean not null default true,
  sort_order integer not null default 0,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  constraint reviews_destination_fk foreign key (destination) references public.destinations(slug) on update cascade on delete set null
);

create table if not exists public.prompts (
  id text primary key,
  title text not null,
  category text not null default '',
  description text not null default '',
  prompt_text text not null,
  is_custom boolean not null default false,
  sort_order integer not null default 0,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.media_assets (
  id text primary key,
  name text not null,
  category text not null default 'destination',
  src text not null,
  storage_path text,
  uploaded boolean not null default false,
  premium boolean not null default false,
  visibility text not null default 'public' check (visibility in ('public','admin')),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.inquiries (
  id uuid primary key default gen_random_uuid(),
  name text not null check (char_length(name) between 2 and 120),
  phone text not null check (char_length(phone) between 6 and 32),
  destination text not null default '',
  message text not null default '' check (char_length(message) <= 3000),
  source text not null default 'website' check (char_length(source) <= 80),
  status text not null default 'new' check (status in ('new','contacted','handled')),
  consent boolean not null default false,
  consent_at timestamptz,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.audit_log (
  id bigint generated always as identity primary key,
  admin_user_id uuid references auth.users(id) on delete set null,
  action text not null,
  entity_type text not null default '',
  entity_id text not null default '',
  details jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now()
);

create index if not exists tours_destination_idx on public.tours(destination);
create index if not exists tours_public_dates_idx on public.tours(published, source_only, start_date);
create index if not exists reviews_destination_idx on public.reviews(destination);
create index if not exists reviews_featured_idx on public.reviews(featured, published);
create index if not exists inquiries_status_created_idx on public.inquiries(status, created_at desc);
create index if not exists media_assets_category_idx on public.media_assets(category);
create index if not exists audit_log_admin_user_idx on public.audit_log(admin_user_id, created_at desc);
create unique index if not exists media_assets_storage_path_uidx on public.media_assets(storage_path) where storage_path is not null;

create or replace function public.set_updated_at()
returns trigger
language plpgsql
set search_path = public
as $$
begin
  new.updated_at = now();
  return new;
end;
$$;

create or replace function public.is_admin()
returns boolean
language sql
stable
security definer
set search_path = public
as $$
  select exists (
    select 1 from public.admin_profiles p
    where p.user_id = (select auth.uid()) and p.active = true
  );
$$;

revoke all on function public.is_admin() from public;
grant execute on function public.is_admin() to authenticated;

create trigger admin_profiles_updated_at before update on public.admin_profiles for each row execute function public.set_updated_at();
create trigger site_settings_updated_at before update on public.site_settings for each row execute function public.set_updated_at();
create trigger destinations_updated_at before update on public.destinations for each row execute function public.set_updated_at();
create trigger tours_updated_at before update on public.tours for each row execute function public.set_updated_at();
create trigger reviews_updated_at before update on public.reviews for each row execute function public.set_updated_at();
create trigger prompts_updated_at before update on public.prompts for each row execute function public.set_updated_at();
create trigger media_assets_updated_at before update on public.media_assets for each row execute function public.set_updated_at();
create trigger inquiries_updated_at before update on public.inquiries for each row execute function public.set_updated_at();

alter table public.admin_profiles enable row level security;
alter table public.site_settings enable row level security;
alter table public.destinations enable row level security;
alter table public.tours enable row level security;
alter table public.reviews enable row level security;
alter table public.prompts enable row level security;
alter table public.media_assets enable row level security;
alter table public.inquiries enable row level security;
alter table public.audit_log enable row level security;

-- Defense in depth: clients do not get direct access until explicitly granted below.
revoke all on table public.admin_profiles from anon, authenticated;
revoke all on table public.site_settings from anon, authenticated;
revoke all on table public.destinations from anon, authenticated;
revoke all on table public.tours from anon, authenticated;
revoke all on table public.reviews from anon, authenticated;
revoke all on table public.prompts from anon, authenticated;
revoke all on table public.media_assets from anon, authenticated;
revoke all on table public.inquiries from anon, authenticated;
revoke all on table public.audit_log from anon, authenticated;

-- Admins can manage the content tables directly if needed; RLS still restricts every row.
grant select, insert, update, delete on table public.site_settings to authenticated;
grant select, insert, update, delete on table public.destinations to authenticated;
grant select, insert, update, delete on table public.tours to authenticated;
grant select, insert, update, delete on table public.reviews to authenticated;
grant select, insert, update, delete on table public.prompts to authenticated;
grant select, insert, update, delete on table public.media_assets to authenticated;
grant select, update, delete on table public.inquiries to authenticated;
grant select on table public.audit_log to authenticated;
grant select on table public.admin_profiles to authenticated;

create policy admin_read_profile on public.admin_profiles
for select to authenticated
using (user_id = (select auth.uid()) or (select public.is_admin()));

create policy admin_all_settings on public.site_settings
for all to authenticated using ((select public.is_admin())) with check ((select public.is_admin()));
create policy admin_all_destinations on public.destinations
for all to authenticated using ((select public.is_admin())) with check ((select public.is_admin()));
create policy admin_all_tours on public.tours
for all to authenticated using ((select public.is_admin())) with check ((select public.is_admin()));
create policy admin_all_reviews on public.reviews
for all to authenticated using ((select public.is_admin())) with check ((select public.is_admin()));
create policy admin_all_prompts on public.prompts
for all to authenticated using ((select public.is_admin())) with check ((select public.is_admin()));
create policy admin_all_media on public.media_assets
for all to authenticated using ((select public.is_admin())) with check ((select public.is_admin()));
create policy admin_all_inquiries on public.inquiries
for all to authenticated using ((select public.is_admin())) with check ((select public.is_admin()));
create policy admin_read_audit on public.audit_log
for select to authenticated using ((select public.is_admin()));

-- Public payload exposes only safe, published information. Supplier research and internal notes never leave this RPC.
create or replace function public.public_site_payload()
returns jsonb
language sql
stable
security definer
set search_path = public
as $$
select jsonb_build_object(
  'settings', coalesce((
    select jsonb_build_object(
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
      'showSupplierResearchPublicly', false
    ) from public.site_settings s where s.id = 1
  ), '{}'::jsonb),
  'destinations', coalesce((
    select jsonb_agg(jsonb_build_object(
      'slug', d.slug,
      'name', d.name,
      'kicker', d.kicker,
      'short', d.short,
      'description', d.description,
      'hero', d.hero,
      'card', d.card,
      'chanaPhoto', d.chana_photo,
      'highlights', d.highlights,
      'itinerary', d.itinerary,
      'gallery', d.gallery,
      'featured', d.featured,
      'storyTitle', d.story_title,
      'fit', d.fit,
      'seoTitle', d.seo_title,
      'seoDescription', d.seo_description
    ) order by d.sort_order, d.name)
    from public.destinations d where d.published = true
  ), '[]'::jsonb),
  'tours', coalesce((
    select jsonb_agg(jsonb_build_object(
      'id', t.id,
      'destination', t.destination,
      'title', t.title,
      'start', to_char(t.start_date, 'YYYY-MM-DD'),
      'end', to_char(t.end_date, 'YYYY-MM-DD'),
      'nights', t.nights,
      'board', t.board,
      'status', t.status,
      'sourceOnly', false,
      'published', true,
      'price', t.price,
      'registrationUrl', t.registration_url,
      'featured', t.featured
    ) order by t.start_date nulls last, t.id)
    from public.tours t where t.published = true and t.source_only = false
  ), '[]'::jsonb),
  'reviews', coalesce((
    select jsonb_agg(jsonb_build_object(
      'id', r.id,
      'destination', coalesce(r.destination, 'all'),
      'name', r.name,
      'text', r.text,
      'featured', r.featured
    ) order by r.sort_order, r.created_at)
    from public.reviews r where r.published = true
  ), '[]'::jsonb)
);
$$;

revoke all on function public.public_site_payload() from public;
grant execute on function public.public_site_payload() to anon, authenticated;

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
      'id', i.id::text,'name', i.name,'phone', i.phone,'destination', i.destination,'message', i.message,
      'status', i.status,'createdAt', to_char(i.created_at at time zone 'Asia/Jerusalem','DD.MM.YYYY HH24:MI')
    ) order by i.created_at) from public.inquiries i), '[]'::jsonb)
  ) into result;
  return result;
end;
$$;

revoke all on function public.admin_site_payload() from public;
grant execute on function public.admin_site_payload() to authenticated;

-- Public lead submission. No direct INSERT permission is given to anon.
create or replace function public.submit_inquiry(
  p_name text,
  p_phone text,
  p_destination text default '',
  p_message text default '',
  p_source text default 'website',
  p_website text default '',
  p_consent boolean default false
)
returns uuid
language plpgsql
security definer
set search_path = public
as $$
declare new_id uuid;
begin
  -- Honeypot: bots that fill hidden p_website are silently rejected.
  if coalesce(trim(p_website), '') <> '' then
    raise exception 'invalid_submission' using errcode = '22023';
  end if;
  if coalesce(p_consent,false) is not true then
    raise exception 'consent_required' using errcode = '22023';
  end if;
  if char_length(trim(coalesce(p_name,''))) < 2 or char_length(trim(coalesce(p_name,''))) > 120 then
    raise exception 'invalid_name' using errcode = '22023';
  end if;
  if char_length(regexp_replace(coalesce(p_phone,''), '\\s', '', 'g')) < 6 or char_length(p_phone) > 32 then
    raise exception 'invalid_phone' using errcode = '22023';
  end if;
  if char_length(coalesce(p_message,'')) > 3000 then
    raise exception 'message_too_long' using errcode = '22023';
  end if;
  if exists (
    select 1 from public.inquiries i
    where regexp_replace(i.phone, '[^0-9]+', '', 'g') = regexp_replace(p_phone, '[^0-9]+', '', 'g')
      and i.created_at > now() - interval '90 seconds'
  ) then
    raise exception 'rate_limited' using errcode = 'P0001';
  end if;

  insert into public.inquiries(name, phone, destination, message, source, consent, consent_at)
  values (trim(p_name), trim(p_phone), left(trim(coalesce(p_destination,'')),160), trim(coalesce(p_message,'')), left(trim(coalesce(p_source,'website')),80), true, now())
  returning id into new_id;
  return new_id;
end;
$$;

revoke all on function public.submit_inquiry(text,text,text,text,text,text,boolean) from public;
grant execute on function public.submit_inquiry(text,text,text,text,text,text,boolean) to anon, authenticated;

-- Atomic-ish content replacement from the admin SPA. Inquiries/admins are deliberately preserved.
create or replace function public.replace_site_content(payload jsonb)
returns void
language plpgsql
security definer
set search_path = public
as $$
declare
  s jsonb;
  x jsonb;
  n integer := 0;
begin
  if not public.is_admin() then
    raise exception 'not_authorized' using errcode = '42501';
  end if;
  if jsonb_typeof(payload) <> 'object' then
    raise exception 'invalid_payload' using errcode = '22023';
  end if;

  s := coalesce(payload->'settings','{}'::jsonb);
  insert into public.site_settings(id,brand_name,slogan,intro,whatsapp,phone_display,email,facebook,last_source_check,home_headline,home_subheadline,show_supplier_research_publicly)
  values (1,
    coalesce(s->>'brandName','לטייל עם חנה'), coalesce(s->>'slogan',''), coalesce(s->>'intro',''),
    coalesce(s->>'whatsapp',''), coalesce(s->>'phoneDisplay',''), coalesce(s->>'email',''), coalesce(s->>'facebook',''),
    coalesce(s->>'lastSourceCheck',''), coalesce(s->>'homeHeadline',''), coalesce(s->>'homeSubheadline',''),
    coalesce((s->>'showSupplierResearchPublicly')::boolean,false))
  on conflict(id) do update set
    brand_name=excluded.brand_name,slogan=excluded.slogan,intro=excluded.intro,whatsapp=excluded.whatsapp,
    phone_display=excluded.phone_display,email=excluded.email,facebook=excluded.facebook,last_source_check=excluded.last_source_check,
    home_headline=excluded.home_headline,home_subheadline=excluded.home_subheadline,
    show_supplier_research_publicly=excluded.show_supplier_research_publicly;

  -- Destinations are upserted first so tour FKs remain valid. Slugs missing from payload are removed after tours.
  n := 0;
  for x in select value from jsonb_array_elements(coalesce(payload->'destinations','[]'::jsonb)) loop
    insert into public.destinations(slug,name,kicker,short,description,hero,card,chana_photo,highlights,itinerary,gallery,source_url,source_note,featured,story_title,fit,seo_title,seo_description,published,sort_order)
    values (
      x->>'slug',x->>'name',coalesce(x->>'kicker',''),coalesce(x->>'short',''),coalesce(x->>'description',''),
      coalesce(x->>'hero',''),coalesce(x->>'card',''),coalesce(x->>'chanaPhoto',''),coalesce(x->'highlights','[]'::jsonb),
      coalesce(x->'itinerary','[]'::jsonb),coalesce(x->'gallery','[]'::jsonb),coalesce(x->>'sourceUrl',''),coalesce(x->>'sourceNote',''),
      coalesce((x->>'featured')::boolean,false),coalesce(x->>'storyTitle',''),coalesce(x->'fit','[]'::jsonb),
      coalesce(x->>'seoTitle',''),coalesce(x->>'seoDescription',''),coalesce((x->>'published')::boolean,true),n)
    on conflict(slug) do update set
      name=excluded.name,kicker=excluded.kicker,short=excluded.short,description=excluded.description,hero=excluded.hero,card=excluded.card,
      chana_photo=excluded.chana_photo,highlights=excluded.highlights,itinerary=excluded.itinerary,gallery=excluded.gallery,
      source_url=excluded.source_url,source_note=excluded.source_note,featured=excluded.featured,story_title=excluded.story_title,
      fit=excluded.fit,seo_title=excluded.seo_title,seo_description=excluded.seo_description,published=excluded.published,sort_order=excluded.sort_order;
    n := n + 1;
  end loop;

  delete from public.tours;
  n := 0;
  for x in select value from jsonb_array_elements(coalesce(payload->'tours','[]'::jsonb)) loop
    insert into public.tours(id,destination,title,start_date,end_date,nights,board,status,source,source_only,published,price,registration_url,notes,featured)
    values (
      x->>'id',x->>'destination',x->>'title',nullif(x->>'start','')::date,nullif(x->>'end','')::date,
      coalesce(nullif(x->>'nights','')::integer,0),coalesce(x->>'board',''),coalesce(x->>'status','planned'),coalesce(x->>'source',''),
      coalesce((x->>'sourceOnly')::boolean,false),coalesce((x->>'published')::boolean,false),coalesce(x->>'price',''),
      coalesce(x->>'registrationUrl',''),coalesce(x->>'notes',''),coalesce((x->>'featured')::boolean,false));
    n := n + 1;
  end loop;

  -- Remove destinations no longer present, only after tours have been replaced.
  delete from public.destinations d
  where not exists (
    select 1 from jsonb_array_elements(coalesce(payload->'destinations','[]'::jsonb)) x where x->>'slug'=d.slug
  );

  delete from public.reviews;
  n := 0;
  for x in select value from jsonb_array_elements(coalesce(payload->'reviews','[]'::jsonb)) loop
    insert into public.reviews(id,destination,name,text,featured,published,sort_order)
    values (x->>'id',nullif(x->>'destination','all'),x->>'name',x->>'text',coalesce((x->>'featured')::boolean,false),coalesce((x->>'published')::boolean,true),n);
    n := n + 1;
  end loop;

  delete from public.prompts;
  n := 0;
  for x in select value from jsonb_array_elements(coalesce(payload->'prompts','[]'::jsonb)) loop
    insert into public.prompts(id,title,category,description,prompt_text,is_custom,sort_order)
    values (x->>'id',x->>'title',coalesce(x->>'category',''),coalesce(x->>'description',''),coalesce(x->>'text',''),coalesce((x->>'custom')::boolean,false),n);
    n := n + 1;
  end loop;

  -- Keep uploaded asset rows that may have been created just before a sync. Upsert payload and remove only metadata rows absent from it.
  n := 0;
  for x in select value from jsonb_array_elements(coalesce(payload->'assets','[]'::jsonb)) loop
    insert into public.media_assets(id,name,category,src,storage_path,uploaded,premium,visibility)
    values (x->>'id',x->>'name',coalesce(x->>'category','destination'),coalesce(x->>'src',''),nullif(x->>'storagePath',''),
      coalesce((x->>'uploaded')::boolean,false),coalesce((x->>'premium')::boolean,false),'public')
    on conflict(id) do update set name=excluded.name,category=excluded.category,src=excluded.src,storage_path=excluded.storage_path,
      uploaded=excluded.uploaded,premium=excluded.premium,visibility=excluded.visibility;
    n := n + 1;
  end loop;
  delete from public.media_assets m
  where not exists (
    select 1 from jsonb_array_elements(coalesce(payload->'assets','[]'::jsonb)) x where x->>'id'=m.id
  );

  insert into public.audit_log(admin_user_id,action,entity_type,details)
  values (auth.uid(),'replace_site_content','site',jsonb_build_object(
    'destinations',jsonb_array_length(coalesce(payload->'destinations','[]'::jsonb)),
    'tours',jsonb_array_length(coalesce(payload->'tours','[]'::jsonb)),
    'reviews',jsonb_array_length(coalesce(payload->'reviews','[]'::jsonb)),
    'prompts',jsonb_array_length(coalesce(payload->'prompts','[]'::jsonb)),
    'assets',jsonb_array_length(coalesce(payload->'assets','[]'::jsonb))
  ));
end;
$$;

revoke all on function public.replace_site_content(jsonb) from public;
grant execute on function public.replace_site_content(jsonb) to authenticated;

-- Storage: public site images, admin-only writes. The bucket is public intentionally because all uploaded site-media is intended for the public website.
insert into storage.buckets(id,name,public,file_size_limit,allowed_mime_types)
values ('site-media','site-media',true,10485760,array['image/jpeg','image/png','image/webp','image/avif','image/gif'])
on conflict(id) do update set public=excluded.public,file_size_limit=excluded.file_size_limit,allowed_mime_types=excluded.allowed_mime_types;

create policy chana_media_admin_insert on storage.objects
for insert to authenticated
with check (bucket_id='site-media' and (select public.is_admin()));
create policy chana_media_admin_update on storage.objects
for update to authenticated
using (bucket_id='site-media' and (select public.is_admin()))
with check (bucket_id='site-media' and (select public.is_admin()));
create policy chana_media_admin_delete on storage.objects
for delete to authenticated
using (bucket_id='site-media' and (select public.is_admin()));

-- No service-role or database secret is ever sent to the browser.

-- ============================================================
-- 202608280002_seed_content.sql
-- ============================================================
-- Seed content from ChanaTours_PREMIUM_FINAL. Supplier dates remain private research.

insert into public.site_settings(id,brand_name,slogan,intro,whatsapp,phone_display,email,facebook,last_source_check,home_headline,home_subheadline,show_supplier_research_publicly) values (1,'לטייל עם חנה','חוויה אישית בטיול מאורגן','טיולים מאורגנים לשומרי מסורת, עם ליווי אישי והדרכה מקצועית.','','','','https://www.facebook.com/chana.malul.7','28.08.2026','מטיילים בעולם. מרגישים בבית.','טיולים מאורגנים לשומרי מסורת, עם ליווי אישי, תכנון מוקפד והדרכה שמחברת בין המקומות, הסיפורים והאנשים.',false) on conflict(id) do update set brand_name=excluded.brand_name,slogan=excluded.slogan,intro=excluded.intro,whatsapp=excluded.whatsapp,phone_display=excluded.phone_display,email=excluded.email,facebook=excluded.facebook,last_source_check=excluded.last_source_check,home_headline=excluded.home_headline,home_subheadline=excluded.home_subheadline,show_supplier_research_publicly=excluded.show_supplier_research_publicly;

insert into public.destinations(slug,name,kicker,short,description,hero,card,chana_photo,highlights,itinerary,gallery,source_url,source_note,featured,story_title,fit,seo_title,seo_description,published,sort_order) values ('japan','יפן','מסע של ניגודים והרמוניה','מקדשים שקטים, ערים מסחררות, טבע עוצר נשימה ותרבות שמפתיעה בכל יום.','יפן מצליחה להיות עתיקה וחדשנית באותה נשימה. עוברים בין טוקיו התוססת, אזור הר פוג׳י, קיוטו המסורתית, מקדשים, גנים ורחובות שמספרים סיפור אחר לגמרי. בטיול עם חנה יש מקום גם להבנה של התרבות והמנהגים, לא רק לצילום הבא.','assets/generated/japan-scenic.jpg','assets/generated/japan-feature-1.jpg','assets/chana/final/traveler-three-quarter.webp','["טוקיו - חדשנות, שכונות ססגוניות ומסורת","האקונה והר פוג׳י - טבע והסמל של יפן","קיוטו - מקדשים, גנים ורחובות היסטוריים","נארה - מורשת ואווירה יפנית רגועה","אוסקה והירושימה - עירוניות, קולינריה והיסטוריה"]'::jsonb,'["טוקיו והיכרות עם יפן המודרנית","האקונה ואזור הר פוג׳י","קיוטו - מקדשים, גנים ותרבות מסורתית","נארה ואוסקה","הירושימה במסלולים הכוללים אותה"]'::jsonb,'["assets/generated/japan-feature-1.jpg","assets/generated/japan-feature-2.jpg","assets/generated/japan-feature-3.jpg","assets/generated/japan-feature-4.jpg","assets/generated/japan-feature-5.jpg"]'::jsonb,'https://www.kishrey-teufa.co.il/tours/japan.html','קשרי תעופה מציגה כיום בין היתר את טוקיו-קיוטו ומה שביניהם, פניני יפן וטוקיו-האקונה-קיוטו-נארה-אוסקה-הירושימה. יש לאשר באדמין אילו מועדים חנה מדריכה בפועל.',true,'יפן שמבינים דרך הפרטים הקטנים','[["למי שסקרן לגבי תרבות אחרת","מסע שמוסיף הקשר וסיפור לכל אתר"],["למי שאוהב שילוב","ערים גדולות, מסורת, טבע ומקדשים"],["למי שנהנה מתוכן","הדרכה שעוזרת להבין מנהגים והיסטוריה"],["לשומרי מסורת","התאמות נבדקות ונקבעות לפי היציאה"]]'::jsonb,'טיול מאורגן ליפן עם חנה | לטייל עם חנה','יפן עם חנה: טוקיו, קיוטו, אזור הר פוג׳י, מקדשים, טבע ותרבות. מידע על היעד, מה רואים ומועדים מאושרים.',true,0) on conflict(slug) do nothing;
insert into public.destinations(slug,name,kicker,short,description,hero,card,chana_photo,highlights,itinerary,gallery,source_url,source_note,featured,story_title,fit,seo_title,seo_description,published,sort_order) values ('north-italy','צפון איטליה','אגמים, דולומיטים ועיירות שקשה להיפרד מהן','אגמים כחולים, פסגות מרשימות, ערים היסטוריות ואיטליה בקצב נעים.','צפון איטליה הוא שילוב מדויק בין נופים גדולים לערים מלאות אופי. הדולומיטים, אגם גארדה, ורונה, ונציה ועיירות קטנות יוצרים טיול מגוון מאוד, בלי לוותר על הזמן להסתכל, להרגיש וליהנות מהדרך.','assets/generated/north-italy-scenic.jpg','assets/generated/north-italy-feature-1.jpg','assets/chana/final/smiling-upper.webp','["הדולומיטים - פסגות, אגמים ונוף אלפיני","אגם גארדה - סרמיונה, ריבה דל גארדה ומלצ׳זינה","ורונה - ארנה, כיכרות וסמטאות","פאדובה ובסאנו דל גראפה","ונציה - סן מרקו, התעלות והגטו"]'::jsonb,'["ורונה והסביבה","עיירות נהר המינצ׳יו ובורגטו","הרי הדולומיטים","פאדובה ובסאנו דל גראפה","סרמיונה, ריבה דל גארדה ומלצ׳זינה","ונציה"]'::jsonb,'["assets/generated/north-italy-feature-1.jpg","assets/generated/north-italy-feature-2.jpg","assets/generated/north-italy-feature-3.jpg","assets/generated/north-italy-feature-4.jpg","assets/generated/north-italy-feature-5.jpg"]'::jsonb,'https://www.kishrey-teufa.co.il/tours/italy/north-italy.html','באתר קשרי תעופה קיימים מסלולים לצפון איטליה, לרבות טיולי משפחות וקרנבלים. המסלול המדויק לכל יציאה של חנה יעודכן באדמין.',true,'צפון איטליה בין אגמים, הרים וערים','[["למי שאוהב נוף","אגמים, פסגות ועיירות ציוריות"],["למי שרוצה גיוון","טבע וערים היסטוריות באותו מסע"],["למי שאוהב קצב נעים","ימים מלאים בלי לוותר על זמן ליהנות"],["לשומרי מסורת","ההתאמות נקבעות לפי המסלול והמועד"]]'::jsonb,'טיול לצפון איטליה עם חנה | לטייל עם חנה','צפון איטליה עם חנה: דולומיטים, אגם גארדה, ורונה, ונציה ועיירות ציוריות. מידע, חוויות ומועדים מאושרים.',true,1) on conflict(slug) do nothing;
insert into public.destinations(slug,name,kicker,short,description,hero,card,chana_photo,highlights,itinerary,gallery,source_url,source_note,featured,story_title,fit,seo_title,seo_description,published,sort_order) values ('montenegro','מונטנגרו','הפנינה הנסתרת של הבלקן','מפרצים כחולים, הרים דרמטיים, עיירות עתיקות ונופים שנפתחים בכל פנייה.','מונטנגרו קטנה על המפה אבל מלאה בנופים. מפרץ קוטור, עיירות חוף, הרים, אגמים ותצפיות הופכים אותה ליעד עשיר ומפתיע. זה טיול שמתאים למי שאוהב טבע ונוף, אבל רוצה גם היסטוריה, רחובות עתיקים וקצב נוח.','assets/generated/montenegro-scenic.jpg','assets/generated/montenegro-feature-1.jpg','assets/chana/final/traveler-three-quarter.webp','["קוטור - עיר עתיקה ואתר מורשת עולמית","דורמיטור והאגם השחור","לובצ׳ן וצ׳טנייה","אגם סקאדר ושייט","פטרובאץ וסווטי סטפן"]'::jsonb,'["טיבאט, פורטו מונטנגרו, בודווה ופודגוריצה","אגם סלנסקו, דורמיטור, האגם השחור וגשר נהר הטרה","צ׳טנייה, לובצ׳ן וקוטור","אגם סקאדר, פטרובאץ ותצפית סווטי סטפן","חזרה דרך טיבאט"]'::jsonb,'["assets/generated/montenegro-feature-1.jpg","assets/generated/montenegro-feature-2.jpg","assets/generated/montenegro-feature-3.jpg","assets/generated/montenegro-feature-4.jpg","assets/generated/montenegro-feature-5.jpg"]'::jsonb,'https://www.kishrey-teufa.co.il/tours/montenegro.html','מבוסס על מסלול נופי מונטנגרו המפורסם באתר קשרי תעופה. במסלול המקיף מתווספים גם פיבה, ביוגרדסקה גורה, מורצ׳ה ואוסטרוג.',true,'מונטנגרו של מפרצים, הרים ועיירות עתיקות','[["למי שאוהב טבע","תצפיות, הרים, אגמים ומפרצים"],["למי שאוהב ערים קטנות","רחובות עתיקים ונמלים עם אופי"],["למי שרוצה יעד מגוון","הרבה נוף וחוויה במדינה קומפקטית"],["לשומרי מסורת","ההתאמות נבדקות בכל יציאה"]]'::jsonb,'טיול מאורגן למונטנגרו עם חנה | לטייל עם חנה','מונטנגרו עם חנה: מפרץ קוטור, דורמיטור, האגם השחור, בודווה ונופי הבלקן. מידע, מסלול ומועדים מאושרים.',true,2) on conflict(slug) do nothing;
insert into public.destinations(slug,name,kicker,short,description,hero,card,chana_photo,highlights,itinerary,gallery,source_url,source_note,featured,story_title,fit,seo_title,seo_description,published,sort_order) values ('morocco','מרוקו','צבעים, טעמים וזיכרונות','שווקים ססגוניים, ערים עתיקות, אדריכלות מרהיבה ומדבר שמכניס הכול לפרופורציה.','מרוקו היא יעד של צבע, ריח וקצב. בין מרקש, פאס, קזבלנקה, שווקים, ארמונות ומרחבי מדבר פוגשים תרבות עשירה וסיפור יהודי עמוק. חנה מחברת בין האתרים לסיפורים ולאנשים, כדי שהטיול ירגיש קרוב ולא רק אקזוטי.','assets/generated/morocco-scenic.jpg','assets/generated/morocco-feature-1.jpg','assets/chana/final/traveler-three-quarter.webp','["מרקש - העיר האדומה, גנים ושווקים","פס - המדינה העתיקה ומלאכות מסורתיות","רבאט וקזבלנקה","הרי האטלס","מורשת יהודית ומדבר סהרה במסלולים המתאימים"]'::jsonb,'["מרקש","קזבלנקה","רבאט","פס","הרי האטלס והכפרים","מורשת יהודית, ובמסלולים מסוימים גם אזור הסהרה"]'::jsonb,'["assets/generated/morocco-feature-1.jpg","assets/generated/morocco-feature-2.jpg","assets/generated/morocco-feature-3.jpg","assets/generated/morocco-feature-4.jpg","assets/generated/morocco-feature-5.jpg"]'::jsonb,'https://www.kishrey-teufa.co.il/tours/morroco.html','עמוד מרוקו של קשרי תעופה מדגיש את מרקש, קזבלנקה, רבאט, פס, הרי האטלס, הסהרה והמורשת היהודית. סדר הימים משתנה לפי יציאה.',true,'מרוקו דרך צבע, תרבות וסיפור יהודי','[["למי שאוהב תרבות","שווקים, מלאכות, אדריכלות וסיפורים"],["למי שמחפש חוויה חושית","צבעים, טעמים ונופים שמשתנים בדרך"],["למי שמתחבר למורשת","מפגש עם שכבות של היסטוריה יהודית ומקומית"],["לשומרי מסורת","התאמות הכשרות והשבת נקבעות לפי היציאה"]]'::jsonb,'טיול מאורגן למרוקו עם חנה | לטייל עם חנה','מרוקו עם חנה: מרקש, פאס, קזבלנקה, שווקים, אדריכלות ומורשת יהודית. מידע על היעד ומועדים מאושרים.',true,3) on conflict(slug) do nothing;
insert into public.destinations(slug,name,kicker,short,description,hero,card,chana_photo,highlights,itinerary,gallery,source_url,source_note,featured,story_title,fit,seo_title,seo_description,published,sort_order) values ('azerbaijan','אזרבייג׳ן','מפגש מרתק בין מזרח למערב','באקו המודרנית, העיר העתיקה, נופי קווקז וסיפור מקומי שמתגלה יום אחרי יום.','אזרבייג׳ן משלבת בין באקו החדשה והנוצצת לעיר עתיקה, כפרים ונופי קווקז. זה יעד נוח ומסקרן שמאפשר להכיר תרבות אחרת בלי לוותר על קצב נעים ועל הרבה רגעים יפים בדרך.','assets/generated/azerbaijan-scenic.jpg','assets/generated/azerbaijan-feature-1.jpg','assets/chana/final/smiling-upper.webp','["באקו - טיילת, עיר עתיקה ואדריכלות מודרנית","מגדלי הלהבה","סביבת באקו ואתרי טבע","ארץ האש - מפגש של טבע, היסטוריה וזהות"]'::jsonb,'["באקו והעיר העתיקה","הטיילת והעיר המודרנית","אתרים בסביבת באקו","במסלולים ארוכים - המשך אל אזורי פנים המדינה"]'::jsonb,'["assets/generated/azerbaijan-feature-1.jpg","assets/generated/azerbaijan-feature-2.jpg","assets/generated/azerbaijan-feature-3.jpg","assets/generated/azerbaijan-feature-4.jpg","assets/generated/azerbaijan-feature-5.jpg"]'::jsonb,'https://www.kishrey-teufa.co.il/tours/baku.html','קשרי תעופה מציגה באקו והסביבה ל-4 לילות, ארץ האש הנצחית ל-7 לילות וכן טיול כשר בן 5 ימים לבאקו.',true,'אזרבייג׳ן בין באקו החדשה לעולם הישן','[["למי שאוהב ניגודים","עיר מודרנית לצד רחובות עתיקים"],["למי שמחפש יעד מסקרן","תרבות אחרת במרחק טיסה נוח יחסית"],["למי שאוהב נוף ועיר","באקו לצד אזורי טבע וקווקז"],["לשומרי מסורת","פרטי היציאה נבדקים לפני הפרסום"]]'::jsonb,'טיול לאזרבייג׳ן עם חנה | לטייל עם חנה','אזרבייג׳ן עם חנה: באקו, העיר העתיקה, מגדלי הלהבה ונופי קווקז. מידע, נקודות עניין ומועדים מאושרים.',true,4) on conflict(slug) do nothing;
insert into public.destinations(slug,name,kicker,short,description,hero,card,chana_photo,highlights,itinerary,gallery,source_url,source_note,featured,story_title,fit,seo_title,seo_description,published,sort_order) values ('sri-lanka','סרי לנקה','פנינת האוקיינוס ההודי','מטעי תה, רכבות בין הרים, פילים, מקדשים וחופים טרופיים.','סרי לנקה ירוקה, חמה ומלאת חיים. נוסעים בין מטעי תה, רכבות נוף, אתרים עתיקים, שמורות טבע וחופים, ופוגשים אנשים ותרבות שמוסיפים לטיול הרבה מעבר לנוף. זה מסע מגוון מאוד, צבעוני ומרגש.','assets/generated/sri-lanka-scenic.jpg','assets/generated/sri-lanka-feature-1.jpg','assets/chana/final/traveler-three-quarter.webp','["סיגיריה - מצודת הסלע","מטעי התה וההרים הירוקים","הרכבת בהרים","פילים ושמורות טבע","מקדשים וחופי האוקיינוס"]'::jsonb,'["קולומבו והיכרות עם האי","אזורי תרבות ומקדשים","סיגיריה","אזורי ההרים ומטעי התה","נסיעת רכבת ציורית","שמורות טבע וחופים בהתאם למסלול"]'::jsonb,'["assets/generated/sri-lanka-feature-1.jpg","assets/generated/sri-lanka-feature-2.jpg","assets/generated/sri-lanka-feature-3.jpg","assets/generated/sri-lanka-feature-4.jpg","assets/generated/sri-lanka-feature-5.jpg"]'::jsonb,'https://www.kishrey-teufa.co.il/tours.html','קשרי תעופה מפרסמת טיול מאורגן כשר לסרי לנקה בן 9 לילות. סדר הימים הסופי יעודכן לאחר אישור יציאת חנה.',true,'סרי לנקה של טבע, תרבות וקצב טרופי','[["למי שאוהב טבע","מטעי תה, הרים, חופים ושמורות"],["למי שאוהב חוויות דרך הדרך","רכבות נוף, כפרים ומפגשים מקומיים"],["למי שמחפש יעד צבעוני","תרבות, מקדשים וטבע באותו מסע"],["לשומרי מסורת","ההתאמות נקבעות ומאושרות לכל יציאה"]]'::jsonb,'טיול מאורגן לסרי לנקה עם חנה | לטייל עם חנה','סרי לנקה עם חנה: מטעי תה, רכבות נוף, סיגיריה, שמורות, פילים וחופים. מידע על היעד ומועדים מאושרים.',true,5) on conflict(slug) do nothing;
insert into public.destinations(slug,name,kicker,short,description,hero,card,chana_photo,highlights,itinerary,gallery,source_url,source_note,featured,story_title,fit,seo_title,seo_description,published,sort_order) values ('dubai','דובאי ואבו דאבי','עיר של חדשנות, יוקרה וחוויות','קו רקיע מרשים, מדבר, שווקים, אדריכלות יוצאת דופן וחוויות בקצב אחר.','דובאי מציעה שילוב של חדשנות, אדריכלות, קניות, מדבר ומקומות שלא דומים לשום עיר אחרת. בין גורדי השחקים לשווקים ולנוף המדברי מתקבל טיול קליל, מגוון ומלא רגעים מרשימים.','assets/generated/dubai-scenic.jpg','assets/generated/dubai-feature-1.jpg','assets/chana/final/traveler-three-quarter.webp','["בורג׳ חליפה","דובאי מרינה","מדבר וספארי","אבו דאבי","שווקים וקניות"]'::jsonb,'["דובאי המודרנית והעיר הישנה","בורג׳ חליפה ומרכז העיר","מרינה וקניות","ספארי מדברי","אבו דאבי בהתאם למסלול"]'::jsonb,'["assets/generated/dubai-feature-1.jpg","assets/generated/dubai-feature-2.jpg","assets/generated/dubai-feature-3.jpg","assets/generated/dubai-feature-4.jpg","assets/generated/dubai-feature-5.jpg"]'::jsonb,'https://www.kishrey-teufa.co.il/tours/dubai.html','קשרי תעופה מציגה דובאי ואבו דאבי אקספרס ל-4 לילות, קסמי המדבר ל-6 לילות וכן מסלול דתי/כשר בן 5 ימים.',true,'דובאי ואבו דאבי בין חדשנות, מדבר ואדריכלות','[["למי שאוהב עיר מודרנית","אדריכלות, קניות ואטרקציות בקנה מידה אחר"],["למי שרוצה גיוון","קו רקיע, שווקים ומדבר באותו טיול"],["למי שמעדיף חוויה נגישה","הרבה מוקדי עניין במסלול עירוני"],["לשומרי מסורת","פרטי הכשרות והשבת נקבעים לפי היציאה"]]'::jsonb,'טיול לדובאי ואבו דאבי עם חנה | לטייל עם חנה','דובאי ואבו דאבי עם חנה: בורג׳ חליפה, מרינה, שווקים, מדבר ואדריכלות. מידע ומועדים מאושרים בלבד.',true,6) on conflict(slug) do nothing;

insert into public.tours(id,destination,title,start_date,end_date,nights,board,status,source,source_only,published,price,registration_url,notes,featured) values ('research-japan-181126','japan','טוקיו-קיוטו ומה שביניהם','2026-11-18'::date,'2026-11-25'::date,7,'לינה וארוחת בוקר','planned','קשרי תעופה',true,false,'','','',false) on conflict(id) do nothing;
insert into public.tours(id,destination,title,start_date,end_date,nights,board,status,source,source_only,published,price,registration_url,notes,featured) values ('research-japan-231126','japan','פניני יפן','2026-11-23'::date,'2026-12-01'::date,8,'לינה וארוחת בוקר','planned','קשרי תעופה',true,false,'','','',false) on conflict(id) do nothing;
insert into public.tours(id,destination,title,start_date,end_date,nights,board,status,source,source_only,published,price,registration_url,notes,featured) values ('research-japan-040427','japan','מיטב יפן בפריחת הדובדבן','2027-04-04'::date,'2027-04-14'::date,10,'חצי פנסיון','planned','קשרי תעופה',true,false,'','','',false) on conflict(id) do nothing;
insert into public.tours(id,destination,title,start_date,end_date,nights,board,status,source,source_only,published,price,registration_url,notes,featured) values ('research-northitaly-240926','north-italy','צפון איטליה למשפחות','2026-09-24'::date,'2026-09-30'::date,6,'לינה וארוחת בוקר','planned','קשרי תעופה',true,false,'','','',false) on conflict(id) do nothing;
insert into public.tours(id,destination,title,start_date,end_date,nights,board,status,source,source_only,published,price,registration_url,notes,featured) values ('research-montenegro-100926','montenegro','נופי מונטנגרו','2026-09-10'::date,'2026-09-14'::date,4,'חצי פנסיון','planned','קשרי תעופה',true,false,'','','',false) on conflict(id) do nothing;
insert into public.tours(id,destination,title,start_date,end_date,nights,board,status,source,source_only,published,price,registration_url,notes,featured) values ('research-montenegro-111026','montenegro','הטבע של מונטנגרו - כשר','2026-10-11'::date,'2026-10-15'::date,4,'פנסיון מלא','planned','קשרי תעופה',true,false,'','','',false) on conflict(id) do nothing;
insert into public.tours(id,destination,title,start_date,end_date,nights,board,status,source,source_only,published,price,registration_url,notes,featured) values ('research-baku-251026','azerbaijan','טיול כשר 5 ימים לבאקו','2026-10-25'::date,'2026-10-29'::date,4,'חצי פנסיון כשר','planned','קשרי תעופה',true,false,'','','',false) on conflict(id) do nothing;
insert into public.tours(id,destination,title,start_date,end_date,nights,board,status,source,source_only,published,price,registration_url,notes,featured) values ('research-srilanka-051026','sri-lanka','טיול מאורגן כשר לסרי לנקה','2026-10-05'::date,'2026-10-15'::date,9,'חצי פנסיון כשר','planned','קשרי תעופה',true,false,'','','',false) on conflict(id) do nothing;
insert into public.tours(id,destination,title,start_date,end_date,nights,board,status,source,source_only,published,price,registration_url,notes,featured) values ('research-northitaly-carnival-030227','north-italy','קרנבלים בצפון איטליה','2027-02-03'::date,'2027-02-09'::date,6,'לינה וארוחת בוקר','planned','קשרי תעופה',true,false,'','','',false) on conflict(id) do nothing;
insert into public.tours(id,destination,title,start_date,end_date,nights,board,status,source,source_only,published,price,registration_url,notes,featured) values ('research-montenegro-180926','montenegro','הטבע של מונטנגרו - כשר','2026-10-18'::date,'2026-10-22'::date,4,'פנסיון מלא','planned','קשרי תעופה',true,false,'','','',false) on conflict(id) do nothing;
insert into public.tours(id,destination,title,start_date,end_date,nights,board,status,source,source_only,published,price,registration_url,notes,featured) values ('research-baku-041026','azerbaijan','באקו והסביבה','2026-10-04'::date,'2026-10-08'::date,4,'לינה וארוחת בוקר','planned','קשרי תעופה',true,false,'','','',false) on conflict(id) do nothing;
insert into public.tours(id,destination,title,start_date,end_date,nights,board,status,source,source_only,published,price,registration_url,notes,featured) values ('research-baku-fire-071026','azerbaijan','ארץ האש הנצחית','2026-10-07'::date,'2026-10-14'::date,7,'לינה וארוחת בוקר','planned','קשרי תעופה',true,false,'','','',false) on conflict(id) do nothing;
insert into public.tours(id,destination,title,start_date,end_date,nights,board,status,source,source_only,published,price,registration_url,notes,featured) values ('research-dubai-express-290926','dubai','דובאי ואבו דאבי אקספרס','2026-09-29'::date,'2026-10-03'::date,4,'חצי פנסיון','planned','קשרי תעופה',true,false,'','','',false) on conflict(id) do nothing;
insert into public.tours(id,destination,title,start_date,end_date,nights,board,status,source,source_only,published,price,registration_url,notes,featured) values ('research-dubai-desert-231026','dubai','קסמי המדבר של איחוד האמירויות','2026-09-23'::date,'2026-09-29'::date,6,'חצי פנסיון','planned','קשרי תעופה',true,false,'','','',false) on conflict(id) do nothing;
insert into public.tours(id,destination,title,start_date,end_date,nights,board,status,source,source_only,published,price,registration_url,notes,featured) values ('research-azerbaijan-20261011-14','azerbaijan','באקו והסביבה 4 לילות','2026-10-11'::date,'2026-10-15'::date,4,'לינה וארוחת בוקר','planned','קשרי תעופה',true,false,'','','',false) on conflict(id) do nothing;
insert into public.tours(id,destination,title,start_date,end_date,nights,board,status,source,source_only,published,price,registration_url,notes,featured) values ('research-dubai-20261008-15','dubai','קסמי המדבר של איחוד האמירויות','2026-10-08'::date,'2026-10-14'::date,6,'חצי פנסיון','planned','קשרי תעופה',true,false,'','','',false) on conflict(id) do nothing;
insert into public.tours(id,destination,title,start_date,end_date,nights,board,status,source,source_only,published,price,registration_url,notes,featured) values ('research-dubai-20270112-16','dubai','דובאי ואבו דאבי אקספרס','2027-01-12'::date,'2027-01-16'::date,4,'חצי פנסיון','planned','קשרי תעופה',true,false,'','','',false) on conflict(id) do nothing;

insert into public.reviews(id,destination,name,text,featured,published,sort_order) values ('jp1','japan','מעיין גוטשלק','תודה ענקית על טיול נפלא, מושקע ומלא בחוויות וזיכרונות. חנה, תודה על ההדרכה המקצועית, הידע הרב, הדרך הדידקטית והנעימה, הסיפורים המרתקים, האסרטיביות כשצריך והדאגה שהכול יתקתק. למדתי, צחקתי, טעמתי, טיילתי ובעיקר נהניתי מאוד.',true,true,0) on conflict(id) do nothing;
insert into public.reviews(id,destination,name,text,featured,published,sort_order) values ('jp2','japan','שלום רזפורקר ויהלי לוי','אחרי 13 ימים מטורפים ביפן אנחנו פשוט רוצים להגיד אריגטו. להחזיק ולנווט קבוצה במשך שבועיים זה ממש לא צחוק, ואת עשית את זה כמו נינג׳ה אמיתית. ראינו כמה השקעת וכמה דאגת לכל אחד ואחת. הלב הענק שלך היה הדבר הכי מרשים בטיול.',false,true,1) on conflict(id) do nothing;
insert into public.reviews(id,destination,name,text,featured,published,sort_order) values ('jp3','japan','גילה ורוני בוחניק','חנה הפגינה מקצועיות אינסופית לאורך כל הדרך. היא ידעה להסביר על כל מקום בצורה מרתקת, מובנת ובהירה, והכול תוך חן והומור שהפכו כל סיור לחוויה של ממש.',true,true,2) on conflict(id) do nothing;
insert into public.reviews(id,destination,name,text,featured,published,sort_order) values ('jp4','japan','אלכס ונעמי שץ','מקצועית, בעלת ידע רחב ואנושיות יוצאת דופן. חנה הכילה את כל הקבוצה, דאגה לכל פרט במסירות וברגישות והשרתה עלינו שקט נפשי וביטחון מלא. בזמן קצר הפכה את הקבוצה למשפחה אחת חמה.',false,true,3) on conflict(id) do nothing;
insert into public.reviews(id,destination,name,text,featured,published,sort_order) values ('g1',null,'מטיילת חוזרת','אני בטיול שלישי איתך ואמשיך לראות עולם דרך עינייך. את מקצועית, איכותית ומיוחדת, ונותנת לכל אחד להרגיש שהוא חשוב בעינייך.',true,true,4) on conflict(id) do nothing;
insert into public.reviews(id,destination,name,text,featured,published,sort_order) values ('g2',null,'משפחת מטיילים','הטיול היה מעבר לטיול מאורגן. זו הייתה חוויה עמוקה, שמחה ומלאת מחשבה. תודה על הלב הרחב, הסבלנות, החיוך וההובלה המדהימה. זכינו בך כמדריכה.',false,true,5) on conflict(id) do nothing;
insert into public.reviews(id,destination,name,text,featured,published,sort_order) values ('jp5','japan','נתן וחנה','תודה מכל הלב על טיול נפלא ליפן, על האווירה הטובה, החברות, החוויות והזיכרונות היפים. חנה, תודה מיוחדת על ההשקעה, הסבלנות, הדאגה והליווי לאורך כל הדרך.',false,true,6) on conflict(id) do nothing;
insert into public.reviews(id,destination,name,text,featured,published,sort_order) values ('jp6','japan','מטיילת מהקבוצה','חזרתי מיפן עם המון חוויות וזיכרונות נפלאים, אבל מעל הכול עם קבוצה שהפכה למשפחה. חנה, תודה ענקית על ליווי מסור, מקצועי ואכפתי, תמיד קשובה ודואגת לכל אחד ואחת. זכינו בך כמדריכה.',false,true,7) on conflict(id) do nothing;
insert into public.reviews(id,destination,name,text,featured,published,sort_order) values ('jp7','japan','מטיילת חוזרת','אני בטיול שלישי איתך ואמשיך לראות עולם דרך עינייך והידע שאת מעבירה. את מקצועית, איכותית ומיוחדת, ונתת לכל אחד להרגיש שהוא חשוב בעינייך.',false,true,8) on conflict(id) do nothing;
insert into public.reviews(id,destination,name,text,featured,published,sort_order) values ('jp8','japan','משפחת מטיילים','ההדרכה שלך הייתה מעבר לטיול מאורגן. זו הייתה חוויה עמוקה, שמחה ומלאת מחשבה. ניהלת טיול לשומרי מסורת רב-גילאי במקצועיות ובמסירות, ונתת לנו שקט נפשי וביטחון מלא.',false,true,9) on conflict(id) do nothing;
insert into public.reviews(id,destination,name,text,featured,published,sort_order) values ('jp9','japan','מטיילת ביפן','תודה על מסע מופלא ליפן, על הידע, ההדרכה וההובלה לאורך כל הדרך. עשית זאת ביד רמה ובמקצועיות. זו חוויה בלתי נשכחת, מגוונת ומעניינת.',false,true,10) on conflict(id) do nothing;
insert into public.reviews(id,destination,name,text,featured,published,sort_order) values ('jp10','japan','נוסעים בקבוצת יפן','איזה כיף של טיול. נהנינו מכל רגע. תודה חנה על העזרה, הדאגה, הסבלנות ובעיקר על הנחישות לפתור כל בעיה עד הסוף. מאחלים לך עוד שנים רבות של טיולים והדרכות מסביב לעולם.',false,true,11) on conflict(id) do nothing;
insert into public.reviews(id,destination,name,text,featured,published,sort_order) values ('jp11','japan','נוסעים שכתבו לקשרי תעופה','חנה מקצועית, בעלת ידע רחב ואנושיות יוצאת דופן. היא הכילה את הקבוצה, דאגה לכל פרט במסירות וברגישות, והפכה בזמן קצר קבוצת מטיילים למשפחה אחת חמה שחולקת חוויות של פעם בחיים.',false,true,12) on conflict(id) do nothing;

insert into public.prompts(id,title,category,description,prompt_text,is_custom,sort_order) values ('pdf-rtl','חוברת / PDF עברי מושלם','PDF וחוברות','הפרומפט המלא לחוברת DOCX + PDF עם Visual RTL ובדיקת כל העמודים.','אני מצרפת בהודעה הזו חומר לימוד.

אני רוצה שתכין ממנו חוברת לימוד מקצועית, ברורה, נעימה ומוכנה להדפסה כ-PDF בעברית.

חשוב מאוד:
השתמש אך ורק בקובץ או בקבצים שאני מצרפת בהודעה הנוכחית.

אל תחפש קבצים ב-Library.
אל תשתמש בקבצים משיחות קודמות.
אל תשתמש ב-Google Drive.
אל תניח שיש גרסה קודמת.
אל תשתמש באינטרנט או במקורות חיצוניים אלא אם אבקש זאת במפורש.

החומר המצורף הוא מקור האמת.

==============================
1. טיפול בתוכן
==============================
קרא את כל החומר המצורף לפני שאתה מתחיל ליצור את החוברת.
אל תדלג על עמודים או חלקים.

אם הקובץ כבר מכיל חומר לימוד כתוב ומסודר: שמור על כל המלל הקיים.
אסור למחוק משפטים, פסקאות, כותרות, הסברים, דוגמאות, הערות, רשימות, טבלאות, מספרים, תאריכים, שמות או מקורות.
אל תקצר ואל תסכם חומר קיים על דעת עצמך.

אם החומר הוא חומר גלם שדורש ארגון: מותר לסדר אותו לפרקים, כותרות ופסקאות בצורה טובה יותר, אבל אסור להמציא מידע שלא נמצא במקור.
אם משהו לא ברור או חסר במקור: אל תנחש עובדות.

==============================
2. המטרה: חוברת לימוד אמיתית
==============================
אני רוצה חוברת שקל ללמוד ממנה ולא מסמך צפוף.
סדר את החומר בצורה טבעית וברורה עם כותרת ראשית, פרקים, כותרות משנה, פסקאות בגודל נוח, חלוקה הגיונית, רשימות רק כשצריך, הסברים רציפים, הדגשה עדינה של מושגים חשובים ורווחים נוחים.
אל תהפוך כל משפט לנקודה ברשימה. אל תיצור עשרות קופסאות או אזורים צבעוניים. המראה צריך להיות של חוברת לימוד מקצועית ונעימה.

==============================
3. RTL אמיתי וגם יישור לימין
==============================
זה התנאי החשוב ביותר.
כל הטקסט העברי חייב להיות RIGHT TO LEFT אמיתי וגם מיושר בפועל לצד ימין של העמוד.
לא מספיק להגדיר RTL בקוד ולא מספיק align:right. המבחן היחיד הוא איך ה-PDF נראה לאחר הרינדור.
פסקה בעברית צריכה להתחיל פיזית מהצד הימני של אזור הטקסט ולהמשיך שמאלה.
גוף הטקסט, כותרות משנה, תבליטים, מספור, הערות, מקורות וטבלאות צריכים להופיע נכון לקורא עברי.
Visual RTL קודם לכל הגדרת קוד. אם מאפיין בשם Right Alignment יוצר בפועל PDF שמיושר שמאלה, אל תשתמש בו. סמוך על התוצאה המרונדרת בלבד.

==============================
4. עברית יחד עם אנגלית ומספרים
==============================
שמור בצורה מושלמת גם על טקסט מעורב, למשל: ורונה (Verona), Museo Nicolis, Bonotto Hotel Palladio, Piazza San Marco, 20-27 באוגוסט 2026, 23:25, 1939-1940, 17 ק״מ, Verona → Vicenza.
אסור לבצע reverse על הטקסט. אסור להפוך אותיות או מילים ידנית.
מילים באנגלית/איטלקית ומספרים נשארים בכיוון LTR הטבעי שלהם.
בדוק במיוחד סוגריים, מקפים, טווחי שנים, תאריכים, שעות, מספרים, אחוזים, שמות מקומות, כתובות, URLs, חצים ולוכסנים.

==============================
5. עיצוב החוברת
==============================
פורמט A4, Portrait בדרך כלל. שוליים בערך 1.7-2 ס״מ. כתב גוף 11.5-12.5pt. כותרת ראשית 22-26pt, כותרת פרק 18-21pt, כותרת משנה 14-16pt.
השתמש בפונט עברי ברור ונקי. צבעים: שחור, אפור כהה ואפשר צבע Accent עדין אחד בלבד.
בלי צבעוניות מוגזמת, בלי עיצוב ראוותני, בלי הרבה קופסאות, בלי אייקונים מיותרים, בלי שטחים ריקים עצומים ובלי צפיפות.

==============================
6. עמודים ופסקאות
==============================
שמור על מעברי עמוד הגיוניים. אל תשאיר כותרת לבדה בתחתית העמוד. אל תיצור עמודים ריקים או חצי עמוד ריק ללא סיבה. אל תקטין כתב כדי לדחוס חומר. עדיף עוד עמוד מאשר חוברת צפופה.
מספרי עמודים צריכים להיות ברורים ועדינים.

==============================
7. טבלאות
==============================
טבלאות חייבות להיות RTL גם מבחינת המבנה. העמודה הראשונה לקורא העברי צריכה להופיע בצד ימין. טקסט עברי בתוך תא מיושר לימין וטקסט אנגלי ומספרים נשארים בכיוון התקין.
אם צריך אפשר להשתמש בעמוד Landscape לטבלה רחבה. נסה לא לפצל שורה אחת של טבלה בין שני עמודים.

==============================
8. תמונות
==============================
אם במסמך המקורי קיימות תמונות: אל תמחק אותן, אל תעוות אותן, שמור על יחס הגובה והרוחב, ואפשר לשנות גודל ומיקום כדי ליצור עמוד נעים. שמור כל כיתוב ששייך לתמונה.

==============================
9. חובה לבצע בדיקת רינדור
==============================
אל תמסור PDF מיד אחרי יצירתו. לאחר יצירת ה-DOCX רנדר אותו לעמודים ובדוק ויזואלית. לאחר יצירת ה-PDF רנדר גם אותו. בדוק את כל העמודים אחד-אחד, לא רק דוגמה.

==============================
10. בדיקת RTL בכל עמוד
==============================
בכל עמוד בדוק: האם הפסקאות העבריות בצד ימין? האם כל פסקה מתחילה פיזית מימין? האם הכותרות, התבליטים והמספור במקום הנכון? האם סוגריים, שמות באנגלית/איטלקית, שנים, תאריכים, שעות ומספרים תקינים? האם אין טקסט חתוך, חפיפות או עמודים ריקים?
אם רוב הטקסט נראה צמוד לצד שמאל, זו תקלה. אל תמסור את המסמך; תקן ורנדר שוב.

==============================
11. בדיקת שמירת החומר
==============================
לפני המסירה השווה בין קובץ המקור לבין הקובץ הסופי. ודא שלא נעלמו פסקאות, משפטים, מילים, רשימות, כותרות, מספרים, תאריכים, טבלאות, הערות או מקורות.
אם החומר אמור להישמר ללא שינוי, בצע השוואת טקסט מלאה בין המקור לבין ה-DOCX הסופי. מעברי שורה ועמוד יכולים להשתנות; המלל עצמו לא.

==============================
12. מבחן סופי
==============================
לפני המסירה ודא:
[ ] כל החומר המצורף נקרא.
[ ] לא נעשה שימוש ב-Library או בקבצים משיחות אחרות.
[ ] לא נעלם תוכן.
[ ] ה-PDF הוא RTL אמיתי.
[ ] הטקסט העברי מוצמד בפועל לצד ימין.
[ ] הפסקאות מתחילות מימין.
[ ] תבליטים ומספור נמצאים מימין.
[ ] אנגלית ואיטלקית לא התהפכו.
[ ] מספרים, תאריכים ושעות לא התהפכו.
[ ] סוגריים תקינים.
[ ] אין טקסט חתוך או חפיפות.
[ ] אין עמודים ריקים מיותרים.
[ ] גודל הכתב נוח לקריאה.
[ ] כל עמודי ה-DOCX נבדקו לאחר רינדור.
[ ] כל עמודי ה-PDF נבדקו לאחר רינדור.
אם סעיף אחד נכשל, אל תמסור עדיין. תקן ורנדר מחדש.

==============================
13. התוצאה שאני רוצה
==============================
בסיום תן לי:
1. PDF סופי, איכותי ומוכן להדפסה.
2. DOCX עריך שממנו יצרת את ה-PDF.
אל תשלח טיוטה ואל תבקש ממני לבדוק RTL בשבילך.
בסיום כתוב רק בקצרה: כמה עמודים יש, שכל העמודים נבדקו ויזואלית, שה-RTL נבדק לפי ה-PDF המרונדר, שהטקסט נמצא בפועל בצד ימין, והאם בדיקת שמירת התוכן עברה.

העיקרון החשוב ביותר: אני לא רוצה מסמך ש״רשום בקוד שהוא RTL״. אני רוצה לפתוח את ה-PDF ולראות חוברת עברית טבעית: העברית מתחילה בצד ימין, קוראים מימין לשמאל, אנגלית ומספרים מוצגים נכון, והכול נעים וברור לקריאה.',false,0) on conflict(id) do nothing;
insert into public.prompts(id,title,category,description,prompt_text,is_custom,sort_order) values ('marketing-image','מודעת פרסום לטיול','שיווק ותמונות','הפרומפט המלא למודעת פרימיום עם לוגואים, תמונות מהמסלול ו-RTL.','אני רוצה שתיצור עבורי מודעת פרסום אחת מקצועית, יפה ומושכת לטיול, ברמת פרימיום, בעברית מלאה RTL, בהתבסס על הפרטים, המסלול והלוגואים שאצרף.

לפני שאתה מתחיל:
אם חסר פרט מהותי שבאמת נדרש כדי להכן את המודעה בצורה מושלמת — אל תנחש. שאל אותי קודם בצורה קצרה ומסודרת עד 5 שאלות ממוקדות בלבד.
אם יש מספיק מידע — אל תשאל שאלות, פשוט תכין את התוצר הסופי.

הנה המידע לטיול:
שם הטיול: [למלא]
יעד / מדינה: [למלא]
תאריכי הטיול: [למלא]
מספר לילות: [למלא]
מחיר: [למלא]
קהל יעד: [למלא]
סוג הטיול: [למלא, למשל טיול עומק / טיול מאורגן / משפחות / מבוגרים]
כשרות / מסורת: [למלא]
מה מיוחד בטיול: [למלא]
אתרים / מסלול / נקודות מרכזיות: [למלא או לצרף מסלול]
מה המחיר כולל: [למלא]
מה חשוב להבליט: [למלא]
פרטי יצירת קשר: [למלא]
לוגו 1: קשרי תעופה
לוגו 2: לטייל עם חנה

המשימה:
צור מודעת פרסום אחת מעוצבת ומרשימה, שמתאימה גם לפרסום דיגיטלי וגם להדפסה, ושנראית כמו מודעה של מותג תיירות איכותי, יוקרתי, אמין ומזמין.

מטרת העיצוב: ליצור מודעה שגורמת לאנשים לעצור, לקרוא ולהתעניין בטיול. היא צריכה להיות מסודרת, ברורה, מושכת וצבעונית במידה הנכונה — לא עמוסה מדי, אבל עשירה ומרשימה.

פורמט: A4 אנכי להדפסה, 300DPI, עם פריסה שמתאימה גם להמרה לפוסט/סטורי. שמור על שוליים בטוחים לטקסט וקריאות מצוינת בנייד.

שפה וכיווניות: עברית בלבד, RTL מלא, יישור לימין, עברית תקינה בלבד.

טיפוגרפיה: השתמש בפונט Rubik בלבד. כותרות Rubik Black/Bold, טקסט רגיל Rubik Medium/Regular. לא להשתמש בפונט דק מדי.

נאמנות לטקסט ואיכות עברית — חובה מוחלטת: אסור לשנות או להמציא מילים, אסור שגיאות כתיב, אותיות כפולות או משובשות, ואסור לפצל מילים מוזר. כל טקסט שחייב להופיע צריך להופיע בדיוק כפי שנמסר. בסוף בצע הגהה מלאה לכל מילה.

אם פרט לא נמסר — אל תמציא. אם חסר מחיר כתוב ״לפרטים ועלויות״. אם חסר מספר לילות אל תוסיף. אם חסר ״מה המחיר כולל״ אל תמציא סעיפים. אם הועלה מסלול, השתמש בו כדי לגוון את התמונות לפי האתרים האמיתיים.

סגנון: מותג תיירות איכותי, מודרני, פרימיום, נקי ואלגנטי. צבעוני אך לא ילדותי, עם תחושת חופשה, איכות, נוחות ואמינות. רקע בהיר יוקרתי לבן/שמנת/אוף-ווייט, נגיעות צבע מותאמות ליעד, צללים רכים וקווים נקיים.

לוגואים — חובה: השתמש בלוגו קשרי תעופה ובלוגו לטייל עם חנה כפי שהם. לא לסובב, למתוח, לעוות או לחתוך. שני הלוגואים צריכים להיות ברורים ואופקיים. שלב אותם בחלק העליון בצורה אלגנטית, למשל בקפסולות עדינות, תוך שמירה על איזון וקריאות.

מבנה המודעה:
1. אזור עליון: לוגואים, כותרת ראשית, תאריך/טווח תאריכים ושורת משנה.
2. אזור מרכזי: תמונה ראשית מרשימה, ואם מתאים 2–6 תמונות משנה, יתרונות בולטים, אתרים מרכזיים/מסלול, פרטי כשרות/לילות/מחיר אם נמסרו.
3. אזור תחתון: יצירת קשר בולטת ומסר סיכום קצר אם מתאים.

בחירת תמונות: התמונות חייבות להתאים ליעד, לעונה, למסלול ולאופי הטיול. אם צורף מסלול, גוון לפי האתרים האמיתיים. אל לבחור כמה תמונות שנראות אותו דבר. צור איזון בין טבע, ערים, תרבות ואנשים לפי המסלול.

תוכן: הצג בצורה פרסומית, מושכת, קצרה ומדויקת. היררכיה ברורה: כותרת גדולה, שורת משנה, highlights, פרטים חשובים ויצירת קשר. אם נמסרו נתונים כמו טיול כשר, שומרי מסורת, חצי פנסיון, מספר לילות, מחיר, טיסות ישירות, מלון אחד או מסלול מיוחד — הבלט אותם בכרטיסים/תגיות עדינות.

כללים: לא לחזור על אותו משפט, לא לחזור על השם חנה במרכז אם הוא כבר בלוגו אלא אם נדרש באזור הקשר. הצג רק פרטים שנמסרו בפועל.

אזור יצירת הקשר צריך להיות בולט מאוד, בפס תחתון או כפתור רחב. הצג את הפרטים בדיוק כפי שנמסרו.

גימור: הרבה אוויר, קריאות מעולה, תמונות איכותיות, צבעוניות מדויקת, תחושת יוקרה וחופש, התאמה ליעד ולמסלול, עברית תקינה, ללא כפילויות וללא שינויי טקסט לא רצויים.

לפני הצגת התוצאה בצע בדיקה סופית: שאין שגיאות כתיב, אותיות משובשות, החלפת מילים או כפילויות; שהלוגואים ברורים ולא מעוותים; שהתמונות מתאימות ליעד, לעונה ולמסלול; ושהמחיר, התאריכים, מספר הלילות, הכשרות ופרטי הקשר מוצגים נכון.

אם הכל ברור ויש מספיק פרטים — צור את המודעה הסופית בצורה מושלמת.',false,1) on conflict(id) do nothing;
insert into public.prompts(id,title,category,description,prompt_text,is_custom,sort_order) values ('passenger-booklet','חוברת נוסעים מטיול ומסלול','PDF וחוברות','הופך מסלול וחומר תפעולי לחוברת נוסעים ברורה ומוכנה ל-PDF.','אני מצרפת מסלול וחומר תפעולי לטיול. הכן חוברת נוסעים מקצועית בעברית RTL. השתמש רק בחומר המצורף כמקור אמת ואל תמציא פרטים. סדר: שער עם שם היעד והתאריכים; דבר המדריכה; מידע חשוב לפני יציאה; טיסות ומפגשים אם נמסרו; תוכנית יום-יום; מזג אוויר ולבוש רק אם נמסר או אם אבקש חיפוש; כשרות ושבת; כסף ותקשורת; ציוד מומלץ; פרטי חירום; עמוד אחרון עם מסר חם. שמור על ניסוחים קצרים, הרבה אוויר, A4, RTL אמיתי ויישור ויזואלי לימין. צור DOCX ו-PDF ובדוק כל עמוד לאחר רינדור.',false,2) on conflict(id) do nothing;
insert into public.prompts(id,title,category,description,prompt_text,is_custom,sort_order) values ('destination-page','תוכן לדף יעד באתר','שיווק ותוכן','יוצר טקסט קצר ומגרה לדף יעד בלי להמציא מסלול.','קבל את חומר היעד והמסלול שאצרף וכתוב תוכן מוכן לדף יעד באתר "לטייל עם חנה". הקהל הוא בעיקר שומרי מסורת. אל תמציא עובדות, מסלולים, מחירים או מועדים.

החזר בדיוק בסדר הבא:
1. כותרת Hero של עד 7 מילים.
2. שורת משנה של עד 14 מילים.
3. פסקת פתיחה של 80–120 מילים, טבעית ומעוררת רצון לטייל בלי קלישאות.
4. חמישה כרטיסי "מה רואים בטיול", לכל כרטיס כותרת קצרה ושורה אחת.
5. "למי הטיול מתאים" עם 3–4 נקודות ענייניות.
6. מועדים, רק אם נמסרו ואושרו. אם אין מועד: נוסח CTA "עדכנו אותי כשנפתח מועד".
7. שלוש שאלות נפוצות רלוונטיות.
8. מטא-טייטל ומטא-דסקריפשן ל-SEO.

הסגנון צריך להיות חם, מקצועי, מדויק ואנושי. אל תכתוב בניסוח גנרי או מלאכותי, אל תגזים בתארים ואל תחזור על אותו מסר.',false,3) on conflict(id) do nothing;
insert into public.prompts(id,title,category,description,prompt_text,is_custom,sort_order) values ('whatsapp-tour','הודעת WhatsApp למתעניין','WhatsApp','תבנית אישית לפנייה אוטומטית מהאתר לפי יעד ותאריך.','כתוב הודעת WhatsApp אחת קצרה וטבעית של מטייל שמתעניין בטיול. השתמש בפרטים: יעד [יעד], שם הטיול [שם], תאריכים [תאריכים]. נוסח מומלץ: ״שלום חנה, ראיתי באתר את הטיול ל[יעד] בתאריכים [תאריכים] ואשמח לקבל פרטים.״ אם אין מועד: ״שלום חנה, ראיתי באתר את היעד [יעד]. כרגע לא מצאתי מועד שמתאים לי ואשמח שתעדכני אותי כשייפתח מועד חדש.״ אל תוסיף מידע שלא נמסר.

כללי סגנון חובה: כתוב בעברית טבעית של אדם אמיתי. בלי ניסוח רובוטי, בלי קלישאות שיווקיות, בלי מקף ארוך, בלי רצפים של סימני קריאה ובלי אימוג׳ים, אלא אם ביקשתי במפורש. משפטים קצרים, מכבדים וברורים. אל תמציא מידע שחסר. התוצאה צריכה להישמע כאילו חנה כתבה אותה בעצמה ולא כמו תבנית אוטומטית.',false,4) on conflict(id) do nothing;
insert into public.prompts(id,title,category,description,prompt_text,is_custom,sort_order) values ('whatsapp-before','הודעה לקבוצה לפני הטיול','WhatsApp','הודעת יציאה ברורה וחמה עם מקום מפגש ודגשים.','כתוב הודעת WhatsApp קצרה, חמה ומסודרת לקבוצת מטיילים לפני יציאה. יעד: [יעד]. תאריך: [תאריך]. שעת מפגש: [שעה]. מקום מפגש: [מקום]. דגשים: [דגשים]. עברית טבעית, בלי ניסוח מלאכותי ובלי אימוג׳ים כברירת מחדל. כלול פתיחה חמה, פרטי המפגש, 3–5 דגשים חשובים וסיום שמח לקראת הטיול.

כללי סגנון חובה: כתוב בעברית טבעית של אדם אמיתי. בלי ניסוח רובוטי, בלי קלישאות שיווקיות, בלי מקף ארוך, בלי רצפים של סימני קריאה ובלי אימוג׳ים, אלא אם ביקשתי במפורש. משפטים קצרים, מכבדים וברורים. אל תמציא מידע שחסר. התוצאה צריכה להישמע כאילו חנה כתבה אותה בעצמה ולא כמו תבנית אוטומטית.',false,5) on conflict(id) do nothing;
insert into public.prompts(id,title,category,description,prompt_text,is_custom,sort_order) values ('daily-message','הודעת בוקר יומית לקבוצה','WhatsApp','מסר קצר עם לו״ז, לבוש ודגשי היום.','כתוב הודעת בוקר לקבוצת מטיילים. יום בטיול: [יום]. היעד/המסלול היום: [מסלול]. שעת יציאה: [שעה]. מזג אוויר שסופק לי: [מזג אוויר]. לבוש/ציוד: [דגשים]. ארוחות/שבת/כשרות: [אם רלוונטי]. צור הודעה קצרה מאוד, ברורה, ידידותית, עם לו״ז בנקודות וסיום נעים. אל תמציא מזג אוויר או שעות.

כללי סגנון חובה: כתוב בעברית טבעית של אדם אמיתי. בלי ניסוח רובוטי, בלי קלישאות שיווקיות, בלי מקף ארוך, בלי רצפים של סימני קריאה ובלי אימוג׳ים, אלא אם ביקשתי במפורש. משפטים קצרים, מכבדים וברורים. אל תמציא מידע שחסר. התוצאה צריכה להישמע כאילו חנה כתבה אותה בעצמה ולא כמו תבנית אוטומטית.',false,6) on conflict(id) do nothing;
insert into public.prompts(id,title,category,description,prompt_text,is_custom,sort_order) values ('guide-sheet','דף הדרכה למדריכה','הדרכה','הופך חומר מקור לדף נוח להעברה בעל-פה בשטח.','אני מצרפת חומר על אתר/עיר. הכן לי דף הדרכה למדריכה בעברית: 1) הסבר קצר לעצמי כדי להבין את המקום, 2) 5–8 נקודות שאפשר לומר לקבוצה, 3) שני סיפורים/עובדות מעניינות רק אם קיימים במקור, 4) מה להראות פיזית בשטח, 5) משפט פתיחה ומשפט סיום, 6) אזהרות על עובדות לא ודאיות. אל תמציא מידע. שמור על מבנה שאפשר לסרוק במהירות בטלפון בזמן הדרכה.',false,7) on conflict(id) do nothing;
insert into public.prompts(id,title,category,description,prompt_text,is_custom,sort_order) values ('packing','צ׳קליסט לפני יציאה','תפעול','רשימת בדיקה למדריכה ולנוסעים, כולל שבת וכשרות.','צור צ׳קליסט מסודר לטיול מאורגן ל[יעד] בתאריכים [תאריכים], לקהל שומר מסורת. חלק ל: מסמכים, כסף, ביגוד, תרופות, ציוד אישי, שבת/כשרות, מזג אוויר, טיסות, תקשורת ויום היציאה. אל תוסיף דרישות שלא נמסרו; אם פרט תלוי במסלול סמן ״לבדיקה״. הפרד בין ״למדריכה״ לבין ״לשליחה לנוסעים״.',false,8) on conflict(id) do nothing;
insert into public.prompts(id,title,category,description,prompt_text,is_custom,sort_order) values ('post-trip','הודעת סיכום אחרי הטיול','WhatsApp','סיום אישי וחם לקבוצה לאחר החזרה.','כתוב הודעת סיכום חמה ואישית לקבוצת מטיילים שחזרה מ[יעד]. ציין תודה על האמון, האווירה והביחד, זיכרון כללי מהמסע, איחולי חזרה קלה והזמנה לשמור על קשר. קצר, טבעי, לא מתאמץ ולא מלא אימוג׳ים. אם אצרף רגעים מיוחדים מהטיול, שלב אותם בעדינות.

כללי סגנון חובה: כתוב בעברית טבעית של אדם אמיתי. בלי ניסוח רובוטי, בלי קלישאות שיווקיות, בלי מקף ארוך, בלי רצפים של סימני קריאה ובלי אימוג׳ים, אלא אם ביקשתי במפורש. משפטים קצרים, מכבדים וברורים. אל תמציא מידע שחסר. התוצאה צריכה להישמע כאילו חנה כתבה אותה בעצמה ולא כמו תבנית אוטומטית.',false,9) on conflict(id) do nothing;
insert into public.prompts(id,title,category,description,prompt_text,is_custom,sort_order) values ('review-request','בקשה נעימה לביקורת','שיווק ותוכן','הודעה לא לוחצת לבקשת המלצה מהמטיילים.','כתוב הודעה קצרה מאוד לקבוצה לאחר הטיול שמבקשת, למי שמתאים, לכתוב כמה מילים על החוויה עם חנה. הטון חם ולא לוחץ. אם מצורף קישור לביקורת [קישור] שלב אותו. אל תבקש ״5 כוכבים״ ואל תכתיב מה לכתוב; בקש חוות דעת אמיתית.

כללי סגנון חובה: כתוב בעברית טבעית של אדם אמיתי. בלי ניסוח רובוטי, בלי קלישאות שיווקיות, בלי מקף ארוך, בלי רצפים של סימני קריאה ובלי אימוג׳ים, אלא אם ביקשתי במפורש. משפטים קצרים, מכבדים וברורים. אל תמציא מידע שחסר. התוצאה צריכה להישמע כאילו חנה כתבה אותה בעצמה ולא כמו תבנית אוטומטית.',false,10) on conflict(id) do nothing;
insert into public.prompts(id,title,category,description,prompt_text,is_custom,sort_order) values ('social-post','פוסט לפרסום טיול','שיווק ותוכן','פוסט פייסבוק/WhatsApp קצר שמוביל להתעניינות.','כתוב פוסט פרסומי טבעי בעברית לטיול של ״לטייל עם חנה״. יעד [יעד], תאריכים [תאריכים], אורך [ימים/לילות], אופי [שומרי מסורת/אחר], 4–6 נקודות מסלול [להדביק], ומה מיוחד [להדביק]. פתיחה שמגרה לצאת לדרך, 4 נקודות קצרות, שורת אמון על חוויה אישית בטיול מאורגן, וסיום עם CTA ל-WhatsApp. אל תמציא מחיר, מלון, כשרות או טיסות שלא נמסרו. בלי אימוג׳ים כברירת מחדל.

כללי סגנון חובה: כתוב בעברית טבעית של אדם אמיתי. בלי ניסוח רובוטי, בלי קלישאות שיווקיות, בלי מקף ארוך, בלי רצפים של סימני קריאה ובלי אימוג׳ים, אלא אם ביקשתי במפורש. משפטים קצרים, מכבדים וברורים. אל תמציא מידע שחסר. התוצאה צריכה להישמע כאילו חנה כתבה אותה בעצמה ולא כמו תבנית אוטומטית.',false,11) on conflict(id) do nothing;
insert into public.prompts(id,title,category,description,prompt_text,is_custom,sort_order) values ('tour-summary-card','תקציר טיול לאתר/פלייר','שיווק ותוכן','מזקק מסלול ארוך לכרטיס קצר בלי לאבד דיוק.','אני מצרפת מסלול מלא. חלץ ממנו תקציר שיווקי מדויק בלבד: שם מוצע לטיול, משפט אחד שמסביר את החוויה, 5 highlights אמיתיים, מספר ימים/לילות אם מופיע, ערים/אתרים מרכזיים לפי סדר הגיוני, ומה חשוב לדעת לשומרי מסורת רק אם נכתב במקור. אל תמציא ואל תוסיף יעד שלא מופיע במסלול.',false,12) on conflict(id) do nothing;
insert into public.prompts(id,title,category,description,prompt_text,is_custom,sort_order) values ('supplier-route-research','בדיקת מסלול ספק מול קשרי תעופה','מחקר ותכנון','בודק מסלול רשמי של ספק ומוציא רק מידע שאפשר להשתמש בו בבטחה.','אני מצרפת קישור או מסלול של ספק לטיול ל[יעד]. בדוק את המקור הרשמי בלבד. חלץ: שם המוצר, מספר ימים/לילות, נקודות המסלול לפי הסדר, מלונות/ארוחות/כשרות רק אם נכתבו, הערות חשובות, ומה משתנה בין יציאות אם מצוין. אל תניח שאני מדריכה מועד מסוים רק מפני שהוא מופיע באתר הספק. סמן בנפרד: מידע מאומת, מידע שדורש אישור, ומידע שלא נמצא. בסוף הכן תקציר שאפשר להעתיק לעמוד היעד באתר בלי לייחס לחנה פרטים שלא אושרו.

בסוף צור גם טבלת אימות קצרה: פריט | מה נמצא במקור | בטוח לפרסום? | מה דורש אישור מחנה. אל תייחס לחנה שום יציאה או שירות שלא אושר במפורש.',false,13) on conflict(id) do nothing;
insert into public.prompts(id,title,category,description,prompt_text,is_custom,sort_order) values ('raw-trip-to-marketing-brief','מחומר גלם לבריף שיווקי מלא','שיווק ותוכן','מקבל מסלול לא מסודר והופך אותו לבריף מוכן למודעה, דף יעד ופוסט.','אני מצרפת חומר גלם על טיול. אל תמציא פרטים. הפוך את החומר לבריף שיווקי מסודר עם: שם הטיול, יעד, תאריכים, מספר ימים/לילות אם קיים, קהל יעד, אופי הטיול, כשרות/מסורת אם נמסרו, 5–7 highlights, רשימת אתרים מרכזיים, מה מיוחד בטיול, פרטים שחסרים וצריך להשלים, משפט Hero קצר, תיאור של 80–120 מילים, CTA מוצע, ורשימת 6–10 תמונות שכדאי לחפש/ליצור לפי המסלול. בסוף תן בלוק אחד מוכן להדבקה בתוך פרומפט מודעת הטיול.',false,14) on conflict(id) do nothing;
insert into public.prompts(id,title,category,description,prompt_text,is_custom,sort_order) values ('marketing-image-from-trip','בניית פרומפט תמונה אוטומטי מטיול','שיווק ותמונות','מייצר פרומפט מדויק לתמונה שיווקית מתוך פרטי הטיול והמסלול.','קבל את פרטי הטיול והמסלול שאצרף ובנה עבורי פרומפט אחד מוכן להדבקה בכלי יצירת תמונות. הפרומפט צריך לדרוש מודעת פרימיום בעברית RTL, להשתמש בלוגו קשרי תעופה ובלוגו לטייל עם חנה כפי שאצרף, לבחור תמונה ראשית ו-2–6 תמונות משנה לפי האתרים האמיתיים, ולהדגיש רק פרטים שנמסרו. אל תמציא מחיר, מלון, טיסות, כשרות או מספר לילות. ציין את יחס התמונה הרצוי, היררכיית הטקסט, צבעוניות המתאימה ליעד, אזור ליצירת קשר ובדיקת איות מלאה. החזר בסוף רק פרומפט אחד מסודר ומוכן להעתקה.',false,15) on conflict(id) do nothing;
insert into public.prompts(id,title,category,description,prompt_text,is_custom,sort_order) values ('traveler-info-sheet','דף מידע קצר לנוסעים','PDF וחוברות','דף אחד או שניים עם המידע שהנוסעים באמת צריכים לפני יום/אתר.','אני מצרפת חומר על יום בטיול או אתר. הכן דף מידע קצר ונעים לנוסעים בעברית RTL, עד שני עמודים אלא אם החומר מחייב יותר. שמור על העובדות בלבד. סדר: כותרת, למה המקום מעניין, מה נראה, 5 דברים שכדאי לדעת, לבוש/ציוד רק אם נמסר, נקודת מפגש/שעות רק אם נמסרו, והערה קצרה לשומרי מסורת אם רלוונטית ומאומתת. העיצוב צריך להיות נקי, קריא בנייד ומוכן ל-PDF, עם RTL ויזואלי אמיתי.',false,16) on conflict(id) do nothing;
insert into public.prompts(id,title,category,description,prompt_text,is_custom,sort_order) values ('group-summary-meeting','מפגש סיכום לטיול','הדרכה','בונה פעילות סיום קצרה, חמה ולא מביכה לקבוצה.','בנה לי מפגש סיכום של 20–30 דקות לקבוצת מטיילים שחוזרת מ[יעד]. הקבוצה: [גיל/אופי אם ידוע]. צור פעילות נעימה ולא ילדותית, שאפשר לעשות במלון/אוטובוס/ארוחה. כלול פתיחה קצרה, 2–3 שאלות שמעלות זיכרונות, פעילות אחת שגורמת למשתתפים לשתף בלי לחץ, משפט תודה של המדריכה וסיום מחבר. אם אצרף אירועים מיוחדים מהטיול, שלב אותם.',false,17) on conflict(id) do nothing;
insert into public.prompts(id,title,category,description,prompt_text,is_custom,sort_order) values ('reply-new-lead','מענה ראשון למתעניין','הודעות ללקוחות','תשובה ראשונה קצרה ואישית למי שפנה מהאתר.','כתוב תשובת WhatsApp ראשונה למטייל שפנה לגבי [יעד/טיול]. יש לי את הפרטים הבאים: [להדביק]. המטרה היא לענות בחום, לתת את המידע שכבר ידוע, ולשאול רק שאלה אחת או שתיים שבאמת נחוצות כדי להמשיך. אל תיצור לחץ לסגור ואל תשתמש בשפה מכירתית. אם חסר מחיר או מועד, אמור זאת בפשטות. 

כללי סגנון חובה: כתוב בעברית טבעית של אדם אמיתי. בלי ניסוח רובוטי, בלי קלישאות שיווקיות, בלי מקף ארוך, בלי רצפים של סימני קריאה ובלי אימוג׳ים, אלא אם ביקשתי במפורש. משפטים קצרים, מכבדים וברורים. אל תמציא מידע שחסר. התוצאה צריכה להישמע כאילו חנה כתבה אותה בעצמה ולא כמו תבנית אוטומטית.',false,18) on conflict(id) do nothing;
insert into public.prompts(id,title,category,description,prompt_text,is_custom,sort_order) values ('followup-lead','מעקב עדין אחרי מתעניין','הודעות ללקוחות','הודעת המשך לא לוחצת אחרי שפנייה נשארה פתוחה.','כתוב הודעת המשך קצרה למי שהתעניין ב[יעד/טיול] לפני [מספר ימים] ולא חזר. המטרה רק לבדוק אם עדיין רלוונטי ואם יש שאלה שאפשר לעזור בה. בלי "רק מזכירה", בלי לחץ ובלי שפה של מכירה. 

כללי סגנון חובה: כתוב בעברית טבעית של אדם אמיתי. בלי ניסוח רובוטי, בלי קלישאות שיווקיות, בלי מקף ארוך, בלי רצפים של סימני קריאה ובלי אימוג׳ים, אלא אם ביקשתי במפורש. משפטים קצרים, מכבדים וברורים. אל תמציא מידע שחסר. התוצאה צריכה להישמע כאילו חנה כתבה אותה בעצמה ולא כמו תבנית אוטומטית.',false,19) on conflict(id) do nothing;
insert into public.prompts(id,title,category,description,prompt_text,is_custom,sort_order) values ('after-registration','הודעה אחרי הרשמה','הודעות ללקוחות','אישור אישי ונעים לאחר סגירת ההרשמה.','כתוב הודעת WhatsApp למטייל שנרשם לטיול [שם הטיול] בתאריכים [תאריכים]. אשר שקיבלתי את הפרטים, כתוב מה השלב הבא רק לפי המידע שאמסור: [שלב הבא], וציין שאפשר לפנות אליי אם עולה שאלה. 

כללי סגנון חובה: כתוב בעברית טבעית של אדם אמיתי. בלי ניסוח רובוטי, בלי קלישאות שיווקיות, בלי מקף ארוך, בלי רצפים של סימני קריאה ובלי אימוג׳ים, אלא אם ביקשתי במפורש. משפטים קצרים, מכבדים וברורים. אל תמציא מידע שחסר. התוצאה צריכה להישמע כאילו חנה כתבה אותה בעצמה ולא כמו תבנית אוטומטית.',false,20) on conflict(id) do nothing;
insert into public.prompts(id,title,category,description,prompt_text,is_custom,sort_order) values ('supplier-message','פנייה לספק / מוזיאון / מלון','ספקים ותפעול','הודעה מקצועית וקצרה לספק בארץ או בחו״ל.','כתוב פנייה מקצועית ל[סוג הספק] בנושא [נושא]. הפרטים: [להדביק]. השפה המבוקשת: [עברית/אנגלית/איטלקית]. כתוב קצר, מנומס וישיר. כלול רק את השאלות והבקשות שנמסרו. אם צריך אישור של שעה, מחיר, מספר נוסעים או נקודת מפגש, סדר אותם בצורה שקל לספק לענות עליה. בלי ניסוח מנופח ובלי פרטים שלא נמסרו.',false,21) on conflict(id) do nothing;
insert into public.prompts(id,title,category,description,prompt_text,is_custom,sort_order) values ('schedule-change','עדכון שינוי לקבוצה','הודעות ללקוחות','שינוי שעה או מסלול בלי ליצור לחץ מיותר.','כתוב הודעה לקבוצת מטיילים על שינוי ב[שעה/מסלול/נקודת מפגש]. מה השתנה: [להדביק]. מה נשאר ללא שינוי: [להדביק]. מה כל אחד צריך לעשות עכשיו: [להדביק]. הניסוח צריך להיות רגוע וברור, בלי דרמה ובלי הסברים ארוכים. 

כללי סגנון חובה: כתוב בעברית טבעית של אדם אמיתי. בלי ניסוח רובוטי, בלי קלישאות שיווקיות, בלי מקף ארוך, בלי רצפים של סימני קריאה ובלי אימוג׳ים, אלא אם ביקשתי במפורש. משפטים קצרים, מכבדים וברורים. אל תמציא מידע שחסר. התוצאה צריכה להישמע כאילו חנה כתבה אותה בעצמה ולא כמו תבנית אוטומטית.',false,22) on conflict(id) do nothing;
insert into public.prompts(id,title,category,description,prompt_text,is_custom,sort_order) values ('important-reminder','תזכורת חשובה לקבוצה','הודעות ללקוחות','תזכורת קצרה לשעה, דרכון, לבוש או ציוד.','כתוב תזכורת קצרה לקבוצה לקראת [מחר/הערב/היציאה]. הפרטים שחייבים להופיע: [להדביק]. סדר לפי חשיבות. אל תוסיף שום דבר שאינו נדרש. 

כללי סגנון חובה: כתוב בעברית טבעית של אדם אמיתי. בלי ניסוח רובוטי, בלי קלישאות שיווקיות, בלי מקף ארוך, בלי רצפים של סימני קריאה ובלי אימוג׳ים, אלא אם ביקשתי במפורש. משפטים קצרים, מכבדים וברורים. אל תמציא מידע שחסר. התוצאה צריכה להישמע כאילו חנה כתבה אותה בעצמה ולא כמו תבנית אוטומטית.',false,23) on conflict(id) do nothing;
insert into public.prompts(id,title,category,description,prompt_text,is_custom,sort_order) values ('review-curation','עריכת ביקורת לפרסום','ביקורות','מקצר ביקורת אמיתית בלי לשנות את הקול של המטייל.','אני מצרפת ביקורת אמיתית של מטייל. הכן ממנה שתי גרסאות: 1. גרסה מלאה נקייה לקריאה באתר, עם תיקוני פיסוק בלבד; 2. ציטוט קצר של עד 35 מילים לכרטיס בדף הבית. אסור לשנות משמעות, להמציא מחמאות או להפוך את הטקסט ליותר שיווקי. אם קיצור דורש השמטה, שמור על המשפטים המקוריים וסמן שהגרסה היא קיצור.',false,24) on conflict(id) do nothing;
insert into public.prompts(id,title,category,description,prompt_text,is_custom,sort_order) values ('faq-from-route','שאלות נפוצות מתוך מסלול','שיווק ותוכן','מייצר FAQ רק מהמידע הקיים במסלול.','אני מצרפת מסלול ופרטי טיול. צור 6–8 שאלות נפוצות שבאמת סביר שמטייל ישאל, ותשובות קצרות שמבוססות רק על החומר. נושאים אפשריים: קצב, כשרות, שבת, מלון, מזג אוויר, הליכה, כסף, מזוודות, שעות וטיסות, רק אם המידע קיים. כאשר פרט חסר כתוב "יש לבדוק מול חנה" במקום לנחש.',false,25) on conflict(id) do nothing;
insert into public.prompts(id,title,category,description,prompt_text,is_custom,sort_order) values ('facebook-trip-post-natural','פוסט פייסבוק טבעי לטיול','שיווק ותוכן','פוסט שמרגיש כמו חנה ולא כמו מודעת AI.','כתוב פוסט פייסבוק על הטיול ל[יעד] בתאריכים [תאריכים]. חומר המקור: [להדביק]. כתוב כאילו חנה עצמה משתפת על הטיול: פתיחה אישית קצרה, 3–5 דברים שהופכים את המסלול למעניין, מידע פרקטי שנמסר, וסיום שמזמין לפנות בפרטי או ב-WhatsApp. בלי רשימת תארים, בלי אימוג׳ים כברירת מחדל, בלי הבטחות מוגזמות ובלי מידע שלא קיים.',false,26) on conflict(id) do nothing;
insert into public.prompts(id,title,category,description,prompt_text,is_custom,sort_order) values ('trip-day-explainer','הסבר קצר על יום בטיול','הדרכה','הופך יום מסלול להסבר שחנה יכולה לשלוח או לומר.','אני מצרפת את תוכנית היום. הכן שתי גרסאות: א. הסבר של דקה שאפשר לומר לקבוצה באוטובוס; ב. הודעה קצרה שאפשר לשלוח ב-WhatsApp. הדגש מה רואים, למה זה מעניין ומה חשוב לדעת תפעולית. אל תוסיף היסטוריה או עובדות שלא נמסרו. ההודעה צריכה להיות אנושית, ללא אימוג׳ים אלא אם אבקש.',false,27) on conflict(id) do nothing;

insert into public.media_assets(id,name,category,src,storage_path,uploaded,premium,visibility) values ('chana-final-traveler-3q','חנה - מטיילת 3/4 שקוף','chana','assets/chana/final/traveler-three-quarter.webp',null,false,true,'public') on conflict(id) do nothing;
insert into public.media_assets(id,name,category,src,storage_path,uploaded,premium,visibility) values ('chana-final-traveler','חנה - מטיילת גוף מלא שקוף','chana','assets/chana/final/traveler-full.webp',null,false,true,'public') on conflict(id) do nothing;
insert into public.media_assets(id,name,category,src,storage_path,uploaded,premium,visibility) values ('chana-final-upper','חנה - חצי גוף שקוף','chana','assets/chana/final/smiling-upper.webp',null,false,true,'public') on conflict(id) do nothing;
insert into public.media_assets(id,name,category,src,storage_path,uploaded,premium,visibility) values ('chana-final-smiling','חנה - פורטרט שקוף סופי','chana','assets/chana/final/smiling-portrait.webp',null,false,true,'public') on conflict(id) do nothing;
insert into public.media_assets(id,name,category,src,storage_path,uploaded,premium,visibility) values ('asset-1','group-1.jpg','chana','assets/chana/group-1.jpg',null,false,false,'public') on conflict(id) do nothing;
insert into public.media_assets(id,name,category,src,storage_path,uploaded,premium,visibility) values ('asset-2','group-2.jpg','chana','assets/chana/group-2.jpg',null,false,false,'public') on conflict(id) do nothing;
insert into public.media_assets(id,name,category,src,storage_path,uploaded,premium,visibility) values ('asset-3','group-3.jpg','chana','assets/chana/group-3.jpg',null,false,false,'public') on conflict(id) do nothing;
insert into public.media_assets(id,name,category,src,storage_path,uploaded,premium,visibility) values ('asset-4','guiding.jpg','chana','assets/chana/guiding.jpg',null,false,false,'public') on conflict(id) do nothing;
insert into public.media_assets(id,name,category,src,storage_path,uploaded,premium,visibility) values ('asset-5','montenegro-group.jpg','chana','assets/chana/montenegro-group.jpg',null,false,false,'public') on conflict(id) do nothing;
insert into public.media_assets(id,name,category,src,storage_path,uploaded,premium,visibility) values ('asset-6','smiling-original.jpg','chana','assets/chana/smiling-original.jpg',null,false,false,'public') on conflict(id) do nothing;
insert into public.media_assets(id,name,category,src,storage_path,uploaded,premium,visibility) values ('asset-7','smiling.jpg','chana','assets/chana/smiling.jpg',null,false,false,'public') on conflict(id) do nothing;
insert into public.media_assets(id,name,category,src,storage_path,uploaded,premium,visibility) values ('asset-8','srilanka-temple.jpg','chana','assets/chana/srilanka-temple.jpg',null,false,false,'public') on conflict(id) do nothing;
insert into public.media_assets(id,name,category,src,storage_path,uploaded,premium,visibility) values ('asset-9','srilanka.jpg','chana','assets/chana/srilanka.jpg',null,false,false,'public') on conflict(id) do nothing;
insert into public.media_assets(id,name,category,src,storage_path,uploaded,premium,visibility) values ('asset-10','traveler.jpg','chana','assets/chana/traveler.jpg',null,false,false,'public') on conflict(id) do nothing;
insert into public.media_assets(id,name,category,src,storage_path,uploaded,premium,visibility) values ('asset-11','card.jpg','destination','assets/destinations/azerbaijan/card.jpg',null,false,false,'public') on conflict(id) do nothing;
insert into public.media_assets(id,name,category,src,storage_path,uploaded,premium,visibility) values ('asset-12','hero.jpg','destination','assets/destinations/azerbaijan/hero.jpg',null,false,false,'public') on conflict(id) do nothing;
insert into public.media_assets(id,name,category,src,storage_path,uploaded,premium,visibility) values ('asset-13','card.jpg','destination','assets/destinations/dubai/card.jpg',null,false,false,'public') on conflict(id) do nothing;
insert into public.media_assets(id,name,category,src,storage_path,uploaded,premium,visibility) values ('asset-14','gallery-1.jpg','destination','assets/destinations/dubai/gallery-1.jpg',null,false,false,'public') on conflict(id) do nothing;
insert into public.media_assets(id,name,category,src,storage_path,uploaded,premium,visibility) values ('asset-15','gallery-2.jpg','destination','assets/destinations/dubai/gallery-2.jpg',null,false,false,'public') on conflict(id) do nothing;
insert into public.media_assets(id,name,category,src,storage_path,uploaded,premium,visibility) values ('asset-16','hero.jpg','destination','assets/destinations/dubai/hero.jpg',null,false,false,'public') on conflict(id) do nothing;
insert into public.media_assets(id,name,category,src,storage_path,uploaded,premium,visibility) values ('asset-17','card.jpg','destination','assets/destinations/japan/card.jpg',null,false,false,'public') on conflict(id) do nothing;
insert into public.media_assets(id,name,category,src,storage_path,uploaded,premium,visibility) values ('asset-18','gallery-1.jpg','destination','assets/destinations/japan/gallery-1.jpg',null,false,false,'public') on conflict(id) do nothing;
insert into public.media_assets(id,name,category,src,storage_path,uploaded,premium,visibility) values ('asset-19','gallery-2.jpg','destination','assets/destinations/japan/gallery-2.jpg',null,false,false,'public') on conflict(id) do nothing;
insert into public.media_assets(id,name,category,src,storage_path,uploaded,premium,visibility) values ('asset-20','gallery-3.jpg','destination','assets/destinations/japan/gallery-3.jpg',null,false,false,'public') on conflict(id) do nothing;
insert into public.media_assets(id,name,category,src,storage_path,uploaded,premium,visibility) values ('asset-21','gallery-4.jpg','destination','assets/destinations/japan/gallery-4.jpg',null,false,false,'public') on conflict(id) do nothing;
insert into public.media_assets(id,name,category,src,storage_path,uploaded,premium,visibility) values ('asset-22','hero.jpg','destination','assets/destinations/japan/hero.jpg',null,false,false,'public') on conflict(id) do nothing;
insert into public.media_assets(id,name,category,src,storage_path,uploaded,premium,visibility) values ('asset-23','card.jpg','destination','assets/destinations/montenegro/card.jpg',null,false,false,'public') on conflict(id) do nothing;
insert into public.media_assets(id,name,category,src,storage_path,uploaded,premium,visibility) values ('asset-24','gallery-1.jpg','destination','assets/destinations/montenegro/gallery-1.jpg',null,false,false,'public') on conflict(id) do nothing;
insert into public.media_assets(id,name,category,src,storage_path,uploaded,premium,visibility) values ('asset-25','gallery-2.jpg','destination','assets/destinations/montenegro/gallery-2.jpg',null,false,false,'public') on conflict(id) do nothing;
insert into public.media_assets(id,name,category,src,storage_path,uploaded,premium,visibility) values ('asset-26','gallery-3.jpg','destination','assets/destinations/montenegro/gallery-3.jpg',null,false,false,'public') on conflict(id) do nothing;
insert into public.media_assets(id,name,category,src,storage_path,uploaded,premium,visibility) values ('asset-27','hero.jpg','destination','assets/destinations/montenegro/hero.jpg',null,false,false,'public') on conflict(id) do nothing;
insert into public.media_assets(id,name,category,src,storage_path,uploaded,premium,visibility) values ('asset-28','card.jpg','destination','assets/destinations/morocco/card.jpg',null,false,false,'public') on conflict(id) do nothing;
insert into public.media_assets(id,name,category,src,storage_path,uploaded,premium,visibility) values ('asset-29','hero.jpg','destination','assets/destinations/morocco/hero.jpg',null,false,false,'public') on conflict(id) do nothing;
insert into public.media_assets(id,name,category,src,storage_path,uploaded,premium,visibility) values ('asset-30','card.jpg','destination','assets/destinations/north-italy/card.jpg',null,false,false,'public') on conflict(id) do nothing;
insert into public.media_assets(id,name,category,src,storage_path,uploaded,premium,visibility) values ('asset-31','hero.jpg','destination','assets/destinations/north-italy/hero.jpg',null,false,false,'public') on conflict(id) do nothing;
insert into public.media_assets(id,name,category,src,storage_path,uploaded,premium,visibility) values ('asset-32','card.jpg','destination','assets/destinations/sri-lanka/card.jpg',null,false,false,'public') on conflict(id) do nothing;
insert into public.media_assets(id,name,category,src,storage_path,uploaded,premium,visibility) values ('asset-33','gallery-1.jpg','destination','assets/destinations/sri-lanka/gallery-1.jpg',null,false,false,'public') on conflict(id) do nothing;
insert into public.media_assets(id,name,category,src,storage_path,uploaded,premium,visibility) values ('asset-34','gallery-2.jpg','destination','assets/destinations/sri-lanka/gallery-2.jpg',null,false,false,'public') on conflict(id) do nothing;
insert into public.media_assets(id,name,category,src,storage_path,uploaded,premium,visibility) values ('asset-35','gallery-3.jpg','destination','assets/destinations/sri-lanka/gallery-3.jpg',null,false,false,'public') on conflict(id) do nothing;
insert into public.media_assets(id,name,category,src,storage_path,uploaded,premium,visibility) values ('asset-36','gallery-4.jpg','destination','assets/destinations/sri-lanka/gallery-4.jpg',null,false,false,'public') on conflict(id) do nothing;
insert into public.media_assets(id,name,category,src,storage_path,uploaded,premium,visibility) values ('asset-37','hero.jpg','destination','assets/destinations/sri-lanka/hero.jpg',null,false,false,'public') on conflict(id) do nothing;
insert into public.media_assets(id,name,category,src,storage_path,uploaded,premium,visibility) values ('asset-38','azerbaijan-feature-1.jpg','generated','assets/generated/azerbaijan-feature-1.jpg',null,false,false,'public') on conflict(id) do nothing;
insert into public.media_assets(id,name,category,src,storage_path,uploaded,premium,visibility) values ('asset-39','azerbaijan-feature-2.jpg','generated','assets/generated/azerbaijan-feature-2.jpg',null,false,false,'public') on conflict(id) do nothing;
insert into public.media_assets(id,name,category,src,storage_path,uploaded,premium,visibility) values ('asset-40','azerbaijan-feature-3.jpg','generated','assets/generated/azerbaijan-feature-3.jpg',null,false,false,'public') on conflict(id) do nothing;
insert into public.media_assets(id,name,category,src,storage_path,uploaded,premium,visibility) values ('asset-41','azerbaijan-feature-4.jpg','generated','assets/generated/azerbaijan-feature-4.jpg',null,false,false,'public') on conflict(id) do nothing;
insert into public.media_assets(id,name,category,src,storage_path,uploaded,premium,visibility) values ('asset-42','azerbaijan-feature-5.jpg','generated','assets/generated/azerbaijan-feature-5.jpg',null,false,false,'public') on conflict(id) do nothing;
insert into public.media_assets(id,name,category,src,storage_path,uploaded,premium,visibility) values ('asset-43','azerbaijan-scenic.jpg','generated','assets/generated/azerbaijan-scenic.jpg',null,false,false,'public') on conflict(id) do nothing;
insert into public.media_assets(id,name,category,src,storage_path,uploaded,premium,visibility) values ('asset-44','dubai-feature-1.jpg','generated','assets/generated/dubai-feature-1.jpg',null,false,false,'public') on conflict(id) do nothing;
insert into public.media_assets(id,name,category,src,storage_path,uploaded,premium,visibility) values ('asset-45','dubai-feature-2.jpg','generated','assets/generated/dubai-feature-2.jpg',null,false,false,'public') on conflict(id) do nothing;
insert into public.media_assets(id,name,category,src,storage_path,uploaded,premium,visibility) values ('asset-46','dubai-feature-3.jpg','generated','assets/generated/dubai-feature-3.jpg',null,false,false,'public') on conflict(id) do nothing;
insert into public.media_assets(id,name,category,src,storage_path,uploaded,premium,visibility) values ('asset-47','dubai-feature-4.jpg','generated','assets/generated/dubai-feature-4.jpg',null,false,false,'public') on conflict(id) do nothing;
insert into public.media_assets(id,name,category,src,storage_path,uploaded,premium,visibility) values ('asset-48','dubai-feature-5.jpg','generated','assets/generated/dubai-feature-5.jpg',null,false,false,'public') on conflict(id) do nothing;
insert into public.media_assets(id,name,category,src,storage_path,uploaded,premium,visibility) values ('asset-49','dubai-scenic.jpg','generated','assets/generated/dubai-scenic.jpg',null,false,false,'public') on conflict(id) do nothing;
insert into public.media_assets(id,name,category,src,storage_path,uploaded,premium,visibility) values ('asset-50','home-scenic.jpg','generated','assets/generated/home-scenic.jpg',null,false,false,'public') on conflict(id) do nothing;
insert into public.media_assets(id,name,category,src,storage_path,uploaded,premium,visibility) values ('asset-51','japan-feature-1.jpg','generated','assets/generated/japan-feature-1.jpg',null,false,false,'public') on conflict(id) do nothing;
insert into public.media_assets(id,name,category,src,storage_path,uploaded,premium,visibility) values ('asset-52','japan-feature-2.jpg','generated','assets/generated/japan-feature-2.jpg',null,false,false,'public') on conflict(id) do nothing;
insert into public.media_assets(id,name,category,src,storage_path,uploaded,premium,visibility) values ('asset-53','japan-feature-3.jpg','generated','assets/generated/japan-feature-3.jpg',null,false,false,'public') on conflict(id) do nothing;
insert into public.media_assets(id,name,category,src,storage_path,uploaded,premium,visibility) values ('asset-54','japan-feature-4.jpg','generated','assets/generated/japan-feature-4.jpg',null,false,false,'public') on conflict(id) do nothing;
insert into public.media_assets(id,name,category,src,storage_path,uploaded,premium,visibility) values ('asset-55','japan-feature-5.jpg','generated','assets/generated/japan-feature-5.jpg',null,false,false,'public') on conflict(id) do nothing;
insert into public.media_assets(id,name,category,src,storage_path,uploaded,premium,visibility) values ('asset-56','japan-scenic.jpg','generated','assets/generated/japan-scenic.jpg',null,false,false,'public') on conflict(id) do nothing;
insert into public.media_assets(id,name,category,src,storage_path,uploaded,premium,visibility) values ('asset-57','montenegro-feature-1.jpg','generated','assets/generated/montenegro-feature-1.jpg',null,false,false,'public') on conflict(id) do nothing;
insert into public.media_assets(id,name,category,src,storage_path,uploaded,premium,visibility) values ('asset-58','montenegro-feature-2.jpg','generated','assets/generated/montenegro-feature-2.jpg',null,false,false,'public') on conflict(id) do nothing;
insert into public.media_assets(id,name,category,src,storage_path,uploaded,premium,visibility) values ('asset-59','montenegro-feature-3.jpg','generated','assets/generated/montenegro-feature-3.jpg',null,false,false,'public') on conflict(id) do nothing;
insert into public.media_assets(id,name,category,src,storage_path,uploaded,premium,visibility) values ('asset-60','montenegro-feature-4.jpg','generated','assets/generated/montenegro-feature-4.jpg',null,false,false,'public') on conflict(id) do nothing;
insert into public.media_assets(id,name,category,src,storage_path,uploaded,premium,visibility) values ('asset-61','montenegro-feature-5.jpg','generated','assets/generated/montenegro-feature-5.jpg',null,false,false,'public') on conflict(id) do nothing;
insert into public.media_assets(id,name,category,src,storage_path,uploaded,premium,visibility) values ('asset-62','montenegro-scenic.jpg','generated','assets/generated/montenegro-scenic.jpg',null,false,false,'public') on conflict(id) do nothing;
insert into public.media_assets(id,name,category,src,storage_path,uploaded,premium,visibility) values ('asset-63','morocco-feature-1.jpg','generated','assets/generated/morocco-feature-1.jpg',null,false,false,'public') on conflict(id) do nothing;
insert into public.media_assets(id,name,category,src,storage_path,uploaded,premium,visibility) values ('asset-64','morocco-feature-2.jpg','generated','assets/generated/morocco-feature-2.jpg',null,false,false,'public') on conflict(id) do nothing;
insert into public.media_assets(id,name,category,src,storage_path,uploaded,premium,visibility) values ('asset-65','morocco-feature-3.jpg','generated','assets/generated/morocco-feature-3.jpg',null,false,false,'public') on conflict(id) do nothing;
insert into public.media_assets(id,name,category,src,storage_path,uploaded,premium,visibility) values ('asset-66','morocco-feature-4.jpg','generated','assets/generated/morocco-feature-4.jpg',null,false,false,'public') on conflict(id) do nothing;
insert into public.media_assets(id,name,category,src,storage_path,uploaded,premium,visibility) values ('asset-67','morocco-feature-5.jpg','generated','assets/generated/morocco-feature-5.jpg',null,false,false,'public') on conflict(id) do nothing;
insert into public.media_assets(id,name,category,src,storage_path,uploaded,premium,visibility) values ('asset-68','morocco-scenic.jpg','generated','assets/generated/morocco-scenic.jpg',null,false,false,'public') on conflict(id) do nothing;
insert into public.media_assets(id,name,category,src,storage_path,uploaded,premium,visibility) values ('asset-69','north-italy-feature-1.jpg','generated','assets/generated/north-italy-feature-1.jpg',null,false,false,'public') on conflict(id) do nothing;
insert into public.media_assets(id,name,category,src,storage_path,uploaded,premium,visibility) values ('asset-70','north-italy-feature-2.jpg','generated','assets/generated/north-italy-feature-2.jpg',null,false,false,'public') on conflict(id) do nothing;
insert into public.media_assets(id,name,category,src,storage_path,uploaded,premium,visibility) values ('asset-71','north-italy-feature-3.jpg','generated','assets/generated/north-italy-feature-3.jpg',null,false,false,'public') on conflict(id) do nothing;
insert into public.media_assets(id,name,category,src,storage_path,uploaded,premium,visibility) values ('asset-72','north-italy-feature-4.jpg','generated','assets/generated/north-italy-feature-4.jpg',null,false,false,'public') on conflict(id) do nothing;
insert into public.media_assets(id,name,category,src,storage_path,uploaded,premium,visibility) values ('asset-73','north-italy-feature-5.jpg','generated','assets/generated/north-italy-feature-5.jpg',null,false,false,'public') on conflict(id) do nothing;
insert into public.media_assets(id,name,category,src,storage_path,uploaded,premium,visibility) values ('asset-74','north-italy-scenic.jpg','generated','assets/generated/north-italy-scenic.jpg',null,false,false,'public') on conflict(id) do nothing;
insert into public.media_assets(id,name,category,src,storage_path,uploaded,premium,visibility) values ('asset-75','sri-lanka-feature-1.jpg','generated','assets/generated/sri-lanka-feature-1.jpg',null,false,false,'public') on conflict(id) do nothing;
insert into public.media_assets(id,name,category,src,storage_path,uploaded,premium,visibility) values ('asset-76','sri-lanka-feature-2.jpg','generated','assets/generated/sri-lanka-feature-2.jpg',null,false,false,'public') on conflict(id) do nothing;
insert into public.media_assets(id,name,category,src,storage_path,uploaded,premium,visibility) values ('asset-77','sri-lanka-feature-3.jpg','generated','assets/generated/sri-lanka-feature-3.jpg',null,false,false,'public') on conflict(id) do nothing;
insert into public.media_assets(id,name,category,src,storage_path,uploaded,premium,visibility) values ('asset-78','sri-lanka-feature-4.jpg','generated','assets/generated/sri-lanka-feature-4.jpg',null,false,false,'public') on conflict(id) do nothing;
insert into public.media_assets(id,name,category,src,storage_path,uploaded,premium,visibility) values ('asset-79','sri-lanka-feature-5.jpg','generated','assets/generated/sri-lanka-feature-5.jpg',null,false,false,'public') on conflict(id) do nothing;
insert into public.media_assets(id,name,category,src,storage_path,uploaded,premium,visibility) values ('asset-80','sri-lanka-scenic.jpg','generated','assets/generated/sri-lanka-scenic.jpg',null,false,false,'public') on conflict(id) do nothing;
insert into public.media_assets(id,name,category,src,storage_path,uploaded,premium,visibility) values ('asset-81','home-hero.jpg','destination','assets/home-hero.jpg',null,false,false,'public') on conflict(id) do nothing;
insert into public.media_assets(id,name,category,src,storage_path,uploaded,premium,visibility) values ('asset-82','logo-optimized.jpg','brand','assets/logo-optimized.jpg',null,false,false,'public') on conflict(id) do nothing;
insert into public.media_assets(id,name,category,src,storage_path,uploaded,premium,visibility) values ('asset-83','logo.jpeg','brand','assets/logo.jpeg',null,false,false,'public') on conflict(id) do nothing;
insert into public.media_assets(id,name,category,src,storage_path,uploaded,premium,visibility) values ('asset-84','azerbaijan-reference.png','destination','assets/reference/azerbaijan-reference.png',null,false,false,'public') on conflict(id) do nothing;
insert into public.media_assets(id,name,category,src,storage_path,uploaded,premium,visibility) values ('asset-85','dubai-reference.png','destination','assets/reference/dubai-reference.png',null,false,false,'public') on conflict(id) do nothing;
insert into public.media_assets(id,name,category,src,storage_path,uploaded,premium,visibility) values ('asset-86','home-reference-1.png','destination','assets/reference/home-reference-1.png',null,false,false,'public') on conflict(id) do nothing;
insert into public.media_assets(id,name,category,src,storage_path,uploaded,premium,visibility) values ('asset-87','japan-reference.png','destination','assets/reference/japan-reference.png',null,false,false,'public') on conflict(id) do nothing;
insert into public.media_assets(id,name,category,src,storage_path,uploaded,premium,visibility) values ('asset-88','montenegro-reference.png','destination','assets/reference/montenegro-reference.png',null,false,false,'public') on conflict(id) do nothing;
insert into public.media_assets(id,name,category,src,storage_path,uploaded,premium,visibility) values ('asset-89','morocco-reference.png','destination','assets/reference/morocco-reference.png',null,false,false,'public') on conflict(id) do nothing;
insert into public.media_assets(id,name,category,src,storage_path,uploaded,premium,visibility) values ('asset-90','north-italy-reference.png','destination','assets/reference/north-italy-reference.png',null,false,false,'public') on conflict(id) do nothing;
insert into public.media_assets(id,name,category,src,storage_path,uploaded,premium,visibility) values ('asset-91','sri-lanka-reference.png','destination','assets/reference/sri-lanka-reference.png',null,false,false,'public') on conflict(id) do nothing;
insert into public.media_assets(id,name,category,src,storage_path,uploaded,premium,visibility) values ('asset-92','tours-reference.png','destination','assets/reference/tours-reference.png',null,false,false,'public') on conflict(id) do nothing;
insert into public.media_assets(id,name,category,src,storage_path,uploaded,premium,visibility) values ('asset-93','logo-final.png','brand','assets/logo-final.png',null,false,false,'public') on conflict(id) do nothing;
insert into public.media_assets(id,name,category,src,storage_path,uploaded,premium,visibility) values ('asset-94','traveler-transparent.png','chana','assets/chana/traveler-transparent.png',null,false,false,'public') on conflict(id) do nothing;
insert into public.media_assets(id,name,category,src,storage_path,uploaded,premium,visibility) values ('asset-95','smiling-transparent.png','chana','assets/chana/smiling-transparent.png',null,false,false,'public') on conflict(id) do nothing;

-- ============================================================
-- 202608280003_leads_privacy_accessibility.sql
-- ============================================================
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

-- ============================================================
-- 202608280004_crm_operations.sql
-- ============================================================
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

-- ============================================================
-- 202608280005_crm_hardening.sql
-- ============================================================
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

-- ============================================================
-- 202608280006_post_deploy_advisor_hardening.sql
-- ============================================================
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

-- ============================================================
-- 202608280007_fix_crm_audit_trigger.sql
-- ============================================================
-- Fix polymorphic trigger record access: participant_payments has no status column.
create or replace function public.audit_crm_change()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
declare rid text;
begin
  if tg_op='DELETE' then rid := old.id::text; else rid := new.id::text; end if;

  if tg_table_name='trip_participants' then
    if tg_op='UPDATE' and old.status is distinct from new.status then
      insert into public.audit_log(admin_user_id,action,entity_type,entity_id,details)
      values(auth.uid(),'participant_status_changed','participant',rid,
        jsonb_build_object('from',old.status,'to',new.status,'tour_id',new.tour_id));
    end if;
  elsif tg_table_name='participant_payments' then
    insert into public.audit_log(admin_user_id,action,entity_type,entity_id,details)
    values(auth.uid(),'payment_'||lower(tg_op),'payment',rid,
      case when tg_op='DELETE'
        then jsonb_build_object('participant_id',old.participant_id)
        else jsonb_build_object('participant_id',new.participant_id)
      end);
  end if;

  if tg_op='DELETE' then return old; else return new; end if;
end;
$$;
revoke all on function public.audit_crm_change() from public, anon, authenticated;

-- ============================================================
-- 202608280008_minimize_rpc_surface.sql
-- ============================================================
-- Minimize public Data API RPC surface for internal helper functions.
revoke all on function public.set_updated_at() from public, anon, authenticated;
revoke all on function public.set_traveler_phone_normalized() from public, anon, authenticated;
revoke all on function public.validate_payment_currency() from public, anon, authenticated;
revoke all on function public.validate_participant_group_tour() from public, anon, authenticated;
revoke all on function public.validate_room_occupant_tour() from public, anon, authenticated;
revoke all on function public.validate_followup_identity() from public, anon, authenticated;
revoke all on function public.validate_contact_identity() from public, anon, authenticated;
revoke all on function public.normalize_phone(text) from public, anon, authenticated;
grant execute on function public.normalize_phone(text) to authenticated;



-- ============================================================
-- 202608290009_contact_details
-- ============================================================
-- Chana Tours: approved public contact details
-- Applied after the original provisioning migrations so migration history remains immutable.

update public.site_settings
set
  phone_display = '050-631-6950',
  whatsapp = '972506316950',
  email = 'Chamel71@gmail.com',
  updated_at = now()
where id = 1;

-- Verification
do $$
begin
  if not exists (
    select 1 from public.site_settings
    where id = 1
      and phone_display = '050-631-6950'
      and whatsapp = '972506316950'
      and lower(email) = lower('Chamel71@gmail.com')
  ) then
    raise exception 'Chana Tours contact settings were not applied';
  end if;
end $$;
