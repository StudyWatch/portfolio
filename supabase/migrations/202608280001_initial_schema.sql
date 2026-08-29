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
