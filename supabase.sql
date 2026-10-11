-- Database setup for the app. Run it once in the Supabase dashboard:
-- SQL Editor → New query → paste this file → Run.
--
-- Sign up and sign in use Supabase Auth, so they need no tables here.
-- Every table below has row level security turned on and explicit grants:
-- Supabase no longer gives the API roles access to new tables on its own.

create table public.profiles (
  id uuid primary key references auth.users (id) on delete cascade on update cascade,
  name text not null,
  created_at timestamptz not null default now()
);

alter table public.profiles enable row level security;

create policy "Signed-in users can read all profiles"
  on public.profiles for select
  to authenticated
  using (true);

grant select on public.profiles to authenticated;

create function public.handle_new_user()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
begin
  insert into public.profiles (id, name)
  values (new.id, new.raw_user_meta_data ->> 'name');
  return new;
end;
$$;

create trigger on_auth_user_created
  after insert on auth.users
  for each row execute function public.handle_new_user();

create table public.posts (
  id uuid primary key default gen_random_uuid(),
  author_id uuid not null default auth.uid()
    references public.profiles (id) on delete cascade on update cascade,
  created_at timestamptz not null default now(),
  title text not null,
  content text not null
);

alter table public.posts enable row level security;

create policy "Signed-in users can read all posts"
  on public.posts for select
  to authenticated
  using (true);

create policy "Users can create their own posts"
  on public.posts for insert
  to authenticated
  with check ((select auth.uid()) = author_id);

grant select on public.posts to authenticated;
grant insert on public.posts to authenticated;
