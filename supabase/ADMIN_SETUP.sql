-- Chana Tours: create/update the first real admin profile.
-- Run ONLY after Chana has a genuine Supabase Auth user in this exact project.
-- Chana's approved Auth email is prefilled below. Never insert a fake row into auth.users manually.

do $$
declare
  target_email text := lower(trim('Chamel71@gmail.com'));
  target_user uuid;
begin
  if target_email = '' then
    raise exception 'Chana admin email is empty';
  end if;

  select id into target_user
  from auth.users
  where lower(email)=target_email;

  if target_user is null then
    raise exception 'No real Supabase Auth user exists for email % in this project. Create/invite the user first.', target_email;
  end if;

  insert into public.admin_profiles(user_id,display_name,active)
  values(target_user,'חנה',true)
  on conflict(user_id) do update
    set display_name='חנה',active=true,updated_at=now();
end $$;

-- Must return exactly the intended real Auth user.
select p.user_id,u.email,p.display_name,p.active,p.updated_at
from public.admin_profiles p
join auth.users u on u.id=p.user_id
where p.active=true
order by p.updated_at desc;
