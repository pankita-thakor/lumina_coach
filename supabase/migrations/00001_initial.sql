-- Lumina Coach — schema aligned with BACKEND.md (+ updated_at on all tables).
-- Auth remains Supabase Auth; public.users mirrors profile data for app use.

create extension if not exists pgcrypto;

-- public.users (BACKEND §2.2) — extended with optional onboarding fields
create table if not exists public.users (
  id uuid primary key references auth.users on delete cascade,
  email text,
  name text,
  communication_goal text,
  tone_style text,
  challenges text[],
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create index if not exists users_email_idx on public.users (email);

alter table public.users enable row level security;

drop policy if exists "users select own" on public.users;
drop policy if exists "users update own" on public.users;
drop policy if exists "users insert own" on public.users;

create policy "users select own"
on public.users for select using (auth.uid() = id);
create policy "users insert own"
on public.users for insert with check (auth.uid() = id);
create policy "users update own"
on public.users for update using (auth.uid() = id) with check (auth.uid() = id);

-- messages
create table if not exists public.messages (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users on delete cascade,
  content text not null,
  context text not null default 'general',
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create index if not exists messages_user_id_idx on public.messages (user_id);
create index if not exists messages_user_created_idx on public.messages (user_id, created_at desc);

alter table public.messages enable row level security;

drop policy if exists "messages select own" on public.messages;
drop policy if exists "messages insert own" on public.messages;
drop policy if exists "messages update own" on public.messages;
drop policy if exists "messages delete own" on public.messages;

create policy "messages select own" on public.messages for select using (auth.uid() = user_id);
create policy "messages insert own" on public.messages for insert with check (auth.uid() = user_id);
create policy "messages update own" on public.messages for update using (auth.uid() = user_id);
create policy "messages delete own" on public.messages for delete using (auth.uid() = user_id);

-- rewrites (response jsonb per BACKEND)
create table if not exists public.rewrites (
  id uuid primary key default gen_random_uuid(),
  message_id uuid not null references public.messages(id) on delete cascade,
  response jsonb not null,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create index if not exists rewrites_message_id_idx on public.rewrites (message_id);

alter table public.rewrites enable row level security;

drop policy if exists "rewrites own" on public.rewrites;
create policy "rewrites own" on public.rewrites for all
using (exists (select 1 from public.messages m where m.id = message_id and m.user_id = auth.uid()))
with check (exists (select 1 from public.messages m where m.id = message_id and m.user_id = auth.uid()));

-- tone_analysis (scalar scores per BACKEND)
create table if not exists public.tone_analysis (
  id uuid primary key default gen_random_uuid(),
  message_id uuid not null references public.messages(id) on delete cascade,
  empathy_score integer not null,
  clarity_score integer not null,
  assertiveness_score integer not null,
  warmth_score integer not null,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create index if not exists tone_analysis_message_id_idx on public.tone_analysis (message_id);

alter table public.tone_analysis enable row level security;

drop policy if exists "tone_analysis own" on public.tone_analysis;
create policy "tone_analysis own" on public.tone_analysis for all
using (exists (select 1 from public.messages m where m.id = message_id and m.user_id = auth.uid()))
with check (exists (select 1 from public.messages m where m.id = message_id and m.user_id = auth.uid()));

-- sessions (messages jsonb per BACKEND)
create table if not exists public.sessions (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users on delete cascade,
  messages jsonb not null default '[]'::jsonb,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create index if not exists sessions_user_id_idx on public.sessions (user_id);

alter table public.sessions enable row level security;

drop policy if exists "sessions own" on public.sessions;
create policy "sessions own" on public.sessions for all
using (auth.uid() = user_id) with check (auth.uid() = user_id);

-- insights (summary text per BACKEND)
create table if not exists public.insights (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users on delete cascade,
  summary text not null,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create index if not exists insights_user_created_idx on public.insights (user_id, created_at desc);

alter table public.insights enable row level security;

drop policy if exists "insights own" on public.insights;
create policy "insights own" on public.insights for all
using (auth.uid() = user_id) with check (auth.uid() = user_id);

-- Sync auth.users -> public.users on signup
create or replace function public.handle_new_user()
returns trigger as $$
begin
  insert into public.users (id, email, name, created_at, updated_at)
  values (
    new.id,
    new.email,
    coalesce(new.raw_user_meta_data->>'full_name', new.raw_user_meta_data->>'name', ''),
    now(),
    now()
  )
  on conflict (id) do update set
    email = excluded.email,
    updated_at = now();
  return new;
end;
$$ language plpgsql security definer set search_path = public;

drop trigger if exists on_auth_user_created on auth.users;
create trigger on_auth_user_created
  after insert on auth.users
  for each row execute function public.handle_new_user();
