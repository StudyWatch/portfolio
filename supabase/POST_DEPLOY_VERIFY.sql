-- Chana Tours post-deploy verification — READ ONLY
-- Expected target: rxapuzqnatmcapgacpfb. Run after migrations; this file performs no mutations.

-- 1) Application table count: expected 19.
select 'project_tables' as check_name, count(*)::text as result
from information_schema.tables
where table_schema='public' and table_name in (
 'admin_profiles','site_settings','destinations','tours','reviews','prompts','media_assets','inquiries','audit_log',
 'travelers','booking_groups','trip_participants','participant_payments','trip_rooms','room_occupants','follow_ups','trip_tasks','trip_documents','contact_log'
);

-- 2) RLS must be true for every application table.
select c.relname as table_name, c.relrowsecurity as rls_enabled
from pg_class c join pg_namespace n on n.oid=c.relnamespace
where n.nspname='public' and c.relkind='r' and c.relname in (
 'admin_profiles','site_settings','destinations','tours','reviews','prompts','media_assets','inquiries','audit_log',
 'travelers','booking_groups','trip_participants','participant_payments','trip_rooms','room_occupants','follow_ups','trip_tasks','trip_documents','contact_log'
)
order by c.relname;

-- 3) Seed/public state. Expected: 7 / 17 / 13 / 28 / 99, supplier exposed = 0.
select jsonb_build_object(
 'destinations',(select count(*) from public.destinations),
 'supplierResearch',(select count(*) from public.tours where source_only=true),
 'supplierResearchPublished',(select count(*) from public.tours where source_only=true and published=true),
 'realPublishedTours',(select count(*) from public.tours where source_only=false and published=true and archived=false),
 'reviews',(select count(*) from public.reviews),
 'prompts',(select count(*) from public.prompts),
 'mediaAssets',(select count(*) from public.media_assets)
) as seed_state;

-- 4) Public payload must never include source_only tours.
select jsonb_build_object(
 'destinations',jsonb_array_length(coalesce(public.public_site_payload()->'destinations','[]'::jsonb)),
 'tours',jsonb_array_length(coalesce(public.public_site_payload()->'tours','[]'::jsonb)),
 'reviews',jsonb_array_length(coalesce(public.public_site_payload()->'reviews','[]'::jsonb)),
 'hasSourceOnly',exists(
   select 1 from jsonb_array_elements(coalesce(public.public_site_payload()->'tours','[]'::jsonb)) x
   where coalesce((x->>'sourceOnly')::boolean,false)=true
 )
) as public_payload_state;

-- 5) Anonymous users must have no direct privileges on private CRM/PII tables. Expected: 0 rows.
select grantee,table_name,privilege_type
from information_schema.role_table_grants
where grantee='anon'
  and table_schema='public'
  and table_name in ('inquiries','travelers','booking_groups','trip_participants','participant_payments','trip_rooms','room_occupants','follow_ups','trip_tasks','trip_documents','contact_log','audit_log')
order by table_name,privilege_type;

-- 6) Storage buckets and policies.
select id,public,file_size_limit,allowed_mime_types
from storage.buckets
where id in ('site-media','admin-documents')
order by id;

select policyname,cmd,roles,qual,with_check
from pg_policies
where schemaname='storage' and tablename='objects'
  and policyname like 'chana_%'
order by policyname;

-- 7) Security-definer functions and fixed search_path.
select p.proname,
       p.prosecdef as security_definer,
       array_to_string(p.proconfig,',') as function_config,
       has_function_privilege('anon',p.oid,'EXECUTE') as anon_execute,
       has_function_privilege('authenticated',p.oid,'EXECUTE') as authenticated_execute
from pg_proc p
join pg_namespace n on n.oid=p.pronamespace
where n.nspname='public' and p.prosecdef
order by p.proname;

-- 8) Auth/admin status. 0 is acceptable until the real Chana Auth invite is created.
select jsonb_build_object(
 'authUsers',(select count(*) from auth.users),
 'activeAdmins',(select count(*) from public.admin_profiles where active=true)
) as auth_state;

-- 9) Migration history. Expected package migrations: 8 names beginning 202608280001..008.
select version,name
from supabase_migrations.schema_migrations
where name like '20260828000%'
order by version;
