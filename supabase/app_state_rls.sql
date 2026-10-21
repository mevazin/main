-- Row-level security for the app_state table.
-- Paste into Supabase → SQL Editor → New query → Run. Safe to run more than once.
-- Afterwards each signed-in user can read and write only their own rows, and
-- the public anon key in index.html can no longer read anyone's data.

alter table public.app_state enable row level security;

drop policy if exists "app_state_select_own" on public.app_state;
drop policy if exists "app_state_insert_own" on public.app_state;
drop policy if exists "app_state_update_own" on public.app_state;
drop policy if exists "app_state_delete_own" on public.app_state;

create policy "app_state_select_own" on public.app_state
  for select to authenticated
  using ((select auth.uid())::text = user_id::text);

create policy "app_state_insert_own" on public.app_state
  for insert to authenticated
  with check ((select auth.uid())::text = user_id::text);

create policy "app_state_update_own" on public.app_state
  for update to authenticated
  using ((select auth.uid())::text = user_id::text)
  with check ((select auth.uid())::text = user_id::text);

create policy "app_state_delete_own" on public.app_state
  for delete to authenticated
  using ((select auth.uid())::text = user_id::text);

-- Signed-out visitors get nothing.
revoke all on public.app_state from anon;

-- Check: this should list the four policies above and rowsecurity = true.
select tablename, rowsecurity from pg_tables where schemaname = 'public' and tablename = 'app_state';
select policyname, cmd, roles from pg_policies where schemaname = 'public' and tablename = 'app_state';
