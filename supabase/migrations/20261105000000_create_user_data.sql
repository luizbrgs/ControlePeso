-- Supabase schema for ControlePeso
-- One JSON document per authenticated user keeps the existing app data model intact.
create table public.user_data (
  user_id uuid primary key references auth.users(id) on delete cascade,
  data jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  constraint user_data_is_object check (jsonb_typeof(data) = 'object')
);

alter table public.user_data enable row level security;

create policy "Users can read their own data"
  on public.user_data for select to authenticated
  using ((select auth.uid()) = user_id);

create policy "Users can insert their own data"
  on public.user_data for insert to authenticated
  with check ((select auth.uid()) = user_id);

create policy "Users can update their own data"
  on public.user_data for update to authenticated
  using ((select auth.uid()) = user_id)
  with check ((select auth.uid()) = user_id);

create policy "Users can delete their own data"
  on public.user_data for delete to authenticated
  using ((select auth.uid()) = user_id);

grant usage on schema public to authenticated;
grant select, insert, update, delete on public.user_data to authenticated;
revoke all on public.user_data from anon;
