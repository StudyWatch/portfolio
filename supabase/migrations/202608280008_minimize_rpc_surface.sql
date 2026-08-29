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
