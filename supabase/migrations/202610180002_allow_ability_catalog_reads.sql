-- Ability definitions are shared gameplay configuration. Anonymous Auth users
-- have the authenticated role, so guests need the same read access as accounts.
begin;

grant select on table public.abilities to authenticated;

drop policy if exists "Authenticated players can read ability definitions"
  on public.abilities;
create policy "Authenticated players can read ability definitions"
  on public.abilities
  for select
  to authenticated
  using (true);

commit;
