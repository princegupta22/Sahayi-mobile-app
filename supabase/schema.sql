-- =====================================================================
--  Sahayi – Supabase schema, RLS policies, storage and realtime
--  Run the whole file once in: Supabase Dashboard → SQL Editor → New query
--  (Safe to re-run: uses IF NOT EXISTS / OR REPLACE / DROP POLICY IF EXISTS.)
--
--  BEFORE running, in Dashboard → Authentication → Providers → Email:
--    • keep "Email" provider ON
--    • turn "Confirm email" OFF   (users sign up and log in with their real
--      email + password and are signed in immediately after sign-up)
-- =====================================================================


-- ---------------------------------------------------------------------
-- 0. Helpers
-- ---------------------------------------------------------------------
create or replace function public.set_updated_at()
returns trigger
language plpgsql
set search_path = ''
as $$
begin
  new.updated_at = now();
  return new;
end;
$$;


-- ---------------------------------------------------------------------
-- 1. profiles  (one row per auth user; created automatically on sign-up)
--    NOTE: the login email is NOT stored here, so it is never
--    visible to other users. It only lives in auth.users.
-- ---------------------------------------------------------------------
create table if not exists public.profiles (
  id          uuid primary key references auth.users (id) on delete cascade,
  name        text not null default '' check (char_length(name) <= 80),
  avatar_url  text,
  created_at  timestamptz not null default now(),
  updated_at  timestamptz not null default now()
);

drop trigger if exists profiles_set_updated_at on public.profiles;
create trigger profiles_set_updated_at
  before update on public.profiles
  for each row execute function public.set_updated_at();

-- Auto-create the profile when a user signs up (name comes from sign-up metadata).
create or replace function public.handle_new_user()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
begin
  insert into public.profiles (id, name)
  values (new.id, coalesce(new.raw_user_meta_data ->> 'name', ''))
  on conflict (id) do nothing;
  return new;
end;
$$;

drop trigger if exists on_auth_user_created on auth.users;
create trigger on_auth_user_created
  after insert on auth.users
  for each row execute function public.handle_new_user();

alter table public.profiles enable row level security;

drop policy if exists "profiles: signed-in users can read" on public.profiles;
create policy "profiles: signed-in users can read"
  on public.profiles for select to authenticated
  using (true);

drop policy if exists "profiles: insert own" on public.profiles;
create policy "profiles: insert own"
  on public.profiles for insert to authenticated
  with check (id = (select auth.uid()));

drop policy if exists "profiles: update own" on public.profiles;
create policy "profiles: update own"
  on public.profiles for update to authenticated
  using (id = (select auth.uid()))
  with check (id = (select auth.uid()));
-- (no delete policy: profile is removed with the auth user via ON DELETE CASCADE)


-- ---------------------------------------------------------------------
-- 2. workers  (the "Find Work" listing – at most one per user)
-- ---------------------------------------------------------------------
create table if not exists public.workers (
  id                uuid primary key default gen_random_uuid(),
  user_id           uuid not null unique references public.profiles (id) on delete cascade,
  name              text not null check (char_length(btrim(name)) between 1 and 80),
  category_en       text not null,
  category_ml       text not null,
  city              text not null check (char_length(btrim(city)) between 1 and 80),
  country           text not null default 'India',
  experience_years  int  not null default 0 check (experience_years between 0 and 60),
  about             text not null default '' check (char_length(about) <= 500),
  phone             text not null default '' check (phone = '' or phone ~ '^[0-9]{10}$'),
  photo_url         text,
  work_photo_urls   text[] not null default '{}' check (cardinality(work_photo_urls) <= 3),
  rating            numeric(2,1) not null default 0 check (rating between 0 and 5),
  is_available      boolean not null default true,   -- false = shown as "Booked"
  created_at        timestamptz not null default now(),
  updated_at        timestamptz not null default now()
);

-- Added later; brings databases created before it up to date.
alter table public.workers
  add column if not exists is_available boolean not null default true;

create index if not exists workers_category_idx   on public.workers (category_en);
create index if not exists workers_city_idx       on public.workers (lower(city));
create index if not exists workers_created_at_idx on public.workers (created_at desc);

drop trigger if exists workers_set_updated_at on public.workers;
create trigger workers_set_updated_at
  before update on public.workers
  for each row execute function public.set_updated_at();

alter table public.workers enable row level security;

drop policy if exists "workers: signed-in users can read" on public.workers;
create policy "workers: signed-in users can read"
  on public.workers for select to authenticated
  using (true);

drop policy if exists "workers: insert own listing" on public.workers;
create policy "workers: insert own listing"
  on public.workers for insert to authenticated
  with check (user_id = (select auth.uid()));

drop policy if exists "workers: update own listing" on public.workers;
create policy "workers: update own listing"
  on public.workers for update to authenticated
  using (user_id = (select auth.uid()))
  with check (user_id = (select auth.uid()));

drop policy if exists "workers: delete own listing" on public.workers;
create policy "workers: delete own listing"
  on public.workers for delete to authenticated
  using (user_id = (select auth.uid()));

-- Users must not be able to set their own rating: only grant the editable columns.
revoke insert, update on public.workers from authenticated;
grant  insert (user_id, name, category_en, category_ml, city, country,
               experience_years, about, phone, photo_url, work_photo_urls,
               is_available)
  on public.workers to authenticated;
grant  update (name, category_en, category_ml, city, country,
               experience_years, about, phone, photo_url, work_photo_urls,
               is_available)
  on public.workers to authenticated;


-- ---------------------------------------------------------------------
-- 3. conversations  (one row per pair of users; user_a < user_b)
-- ---------------------------------------------------------------------
create table if not exists public.conversations (
  id               uuid primary key default gen_random_uuid(),
  user_a           uuid not null references public.profiles (id) on delete cascade,
  user_b           uuid not null references public.profiles (id) on delete cascade,
  last_message     text,
  last_message_at  timestamptz not null default now(),
  created_at       timestamptz not null default now(),
  check (user_a < user_b),
  unique (user_a, user_b)
);

create index if not exists conversations_user_a_idx on public.conversations (user_a);
create index if not exists conversations_user_b_idx on public.conversations (user_b);

alter table public.conversations enable row level security;

drop policy if exists "conversations: members can read" on public.conversations;
create policy "conversations: members can read"
  on public.conversations for select to authenticated
  using ((select auth.uid()) in (user_a, user_b));

drop policy if exists "conversations: members can create" on public.conversations;
create policy "conversations: members can create"
  on public.conversations for insert to authenticated
  with check ((select auth.uid()) in (user_a, user_b));
-- (no update/delete from clients; last_message is maintained by a trigger)

revoke update, delete on public.conversations from authenticated;


-- ---------------------------------------------------------------------
-- 4. messages
-- ---------------------------------------------------------------------
create table if not exists public.messages (
  id               bigint generated always as identity primary key,
  conversation_id  uuid not null references public.conversations (id) on delete cascade,
  sender_id        uuid not null default auth.uid() references public.profiles (id) on delete cascade,
  body             text not null check (char_length(btrim(body)) between 1 and 2000),
  created_at       timestamptz not null default now(),
  read_at          timestamptz
);

create index if not exists messages_conversation_idx
  on public.messages (conversation_id, created_at desc);

-- Membership check used by RLS (security definer avoids recursive policy lookups).
create or replace function public.is_conversation_member(cid uuid)
returns boolean
language sql
stable
security definer
set search_path = ''
as $$
  select exists (
    select 1
    from public.conversations c
    where c.id = cid
      and (select auth.uid()) in (c.user_a, c.user_b)
  );
$$;

alter table public.messages enable row level security;

drop policy if exists "messages: members can read" on public.messages;
create policy "messages: members can read"
  on public.messages for select to authenticated
  using (public.is_conversation_member(conversation_id));

drop policy if exists "messages: members can send as themselves" on public.messages;
create policy "messages: members can send as themselves"
  on public.messages for insert to authenticated
  with check (
    sender_id = (select auth.uid())
    and public.is_conversation_member(conversation_id)
  );

-- Only the RECIPIENT may update a message (to mark it read).
drop policy if exists "messages: recipient can mark read" on public.messages;
create policy "messages: recipient can mark read"
  on public.messages for update to authenticated
  using (
    sender_id <> (select auth.uid())
    and public.is_conversation_member(conversation_id)
  )
  with check (
    sender_id <> (select auth.uid())
    and public.is_conversation_member(conversation_id)
  );
-- (no delete policy)

revoke insert, update, delete on public.messages from authenticated;
grant  insert (conversation_id, body) on public.messages to authenticated;
grant  update (read_at)               on public.messages to authenticated;

-- Keep conversations.last_message in sync.
create or replace function public.touch_conversation()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
begin
  update public.conversations
     set last_message = new.body,
         last_message_at = new.created_at
   where id = new.conversation_id;
  return new;
end;
$$;

drop trigger if exists messages_touch_conversation on public.messages;
create trigger messages_touch_conversation
  after insert on public.messages
  for each row execute function public.touch_conversation();


-- ---------------------------------------------------------------------
-- 5. RPC functions used by the app
-- ---------------------------------------------------------------------

-- Returns the conversation id between me and `other_user`, creating it if needed.
create or replace function public.get_or_create_conversation(other_user uuid)
returns uuid
language plpgsql
security invoker
set search_path = ''
as $$
declare
  me  uuid := (select auth.uid());
  a   uuid;
  b   uuid;
  cid uuid;
begin
  if me is null then
    raise exception 'not authenticated';
  end if;
  if other_user is null or other_user = me then
    raise exception 'invalid conversation partner';
  end if;

  a := least(me, other_user);
  b := greatest(me, other_user);

  insert into public.conversations (user_a, user_b)
  values (a, b)
  on conflict (user_a, user_b) do nothing;

  select id into cid
    from public.conversations
   where user_a = a and user_b = b;

  return cid;
end;
$$;

-- Inbox: one row per conversation that has at least one message.
create or replace function public.my_conversations()
returns table (
  id               uuid,
  other_user_id    uuid,
  other_name       text,
  other_avatar_url text,
  last_message     text,
  last_message_at  timestamptz,
  unread_count     bigint
)
language sql
stable
security invoker
set search_path = ''
as $$
  select
    c.id,
    p.id,
    p.name,
    p.avatar_url,
    c.last_message,
    c.last_message_at,
    (select count(*)
       from public.messages m
      where m.conversation_id = c.id
        and m.sender_id <> (select auth.uid())
        and m.read_at is null)
  from public.conversations c
  join public.profiles p
    on p.id = case when c.user_a = (select auth.uid()) then c.user_b else c.user_a end
  where (select auth.uid()) in (c.user_a, c.user_b)
    and c.last_message is not null
  order by c.last_message_at desc;
$$;

-- Marks every incoming message in a conversation as read.
create or replace function public.mark_conversation_read(cid uuid)
returns void
language sql
security invoker
set search_path = ''
as $$
  update public.messages
     set read_at = now()
   where conversation_id = cid
     and sender_id <> (select auth.uid())
     and read_at is null;
$$;

revoke execute on function public.get_or_create_conversation(uuid) from public, anon;
revoke execute on function public.my_conversations()               from public, anon;
revoke execute on function public.mark_conversation_read(uuid)     from public, anon;
grant  execute on function public.get_or_create_conversation(uuid) to authenticated;
grant  execute on function public.my_conversations()               to authenticated;
grant  execute on function public.mark_conversation_read(uuid)     to authenticated;


-- ---------------------------------------------------------------------
-- 6. Storage buckets  (public read, write only inside your own folder)
--    File path convention:  <user-id>/<filename>
-- ---------------------------------------------------------------------
insert into storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
values
  ('avatars',     'avatars',     true, 5242880, array['image/jpeg','image/png','image/webp']),
  ('work-photos', 'work-photos', true, 5242880, array['image/jpeg','image/png','image/webp'])
on conflict (id) do update
  set public = excluded.public,
      file_size_limit = excluded.file_size_limit,
      allowed_mime_types = excluded.allowed_mime_types;

drop policy if exists "sahayi images: signed-in users can read" on storage.objects;
create policy "sahayi images: signed-in users can read"
  on storage.objects for select to authenticated
  using (bucket_id in ('avatars', 'work-photos'));

drop policy if exists "sahayi images: upload to own folder" on storage.objects;
create policy "sahayi images: upload to own folder"
  on storage.objects for insert to authenticated
  with check (
    bucket_id in ('avatars', 'work-photos')
    and (storage.foldername(name))[1] = (select auth.uid())::text
  );

drop policy if exists "sahayi images: update own files" on storage.objects;
create policy "sahayi images: update own files"
  on storage.objects for update to authenticated
  using (
    bucket_id in ('avatars', 'work-photos')
    and (storage.foldername(name))[1] = (select auth.uid())::text
  );

drop policy if exists "sahayi images: delete own files" on storage.objects;
create policy "sahayi images: delete own files"
  on storage.objects for delete to authenticated
  using (
    bucket_id in ('avatars', 'work-photos')
    and (storage.foldername(name))[1] = (select auth.uid())::text
  );


-- ---------------------------------------------------------------------
-- 7. Realtime (live chat). RLS still applies to realtime events.
-- ---------------------------------------------------------------------
do $$
begin
  alter publication supabase_realtime add table public.messages;
exception when duplicate_object then null;
end $$;
