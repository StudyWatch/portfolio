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
