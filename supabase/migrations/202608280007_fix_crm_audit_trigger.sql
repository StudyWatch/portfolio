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
