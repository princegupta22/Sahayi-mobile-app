-- =====================================================================
--  Sahayi – one-time payments (Razorpay), each with its own flag:
--    • contact (₹99) → profiles.is_paid        : call / message workers
--    • listing (₹99) → profiles.is_worker_paid : publish a worker profile
--  Browsing workers is free. Amounts live in functions/_shared/common.ts.
--  Run AFTER schema.sql: Supabase Dashboard → SQL Editor → New query.
--  Safe to re-run.
-- =====================================================================

-- ---------------------------------------------------------------------
-- 1. Paid flags on profiles
-- ---------------------------------------------------------------------
alter table public.profiles
  add column if not exists is_paid boolean not null default false,
  add column if not exists paid_at timestamptz,
  add column if not exists is_worker_paid boolean not null default false,
  add column if not exists worker_paid_at timestamptz;

-- Clients must never be able to set the paid flags themselves. Only the edge
-- functions (service role) can. Restrict client writes to safe columns.
revoke insert, update on public.profiles from authenticated;
grant  insert (id, name, avatar_url) on public.profiles to authenticated;
grant  update (name, avatar_url)     on public.profiles to authenticated;


-- ---------------------------------------------------------------------
-- 2. payments ledger (written only by edge functions)
-- ---------------------------------------------------------------------
create table if not exists public.payments (
  id                    uuid primary key default gen_random_uuid(),
  user_id               uuid not null references public.profiles (id) on delete cascade,
  razorpay_order_id     text not null unique,
  razorpay_payment_id   text unique,
  amount                int  not null check (amount > 0),         -- in paise (9900 = ₹99)
  purpose               text not null default 'contact'
                          check (purpose in ('contact', 'listing')),
  currency              text not null default 'INR',
  status                text not null default 'created'
                          check (status in ('created', 'paid', 'failed')),
  created_at            timestamptz not null default now(),
  paid_at               timestamptz
);

-- Added later; brings databases created before it up to date.
alter table public.payments
  add column if not exists purpose text not null default 'contact'
    check (purpose in ('contact', 'listing'));

create index if not exists payments_user_idx on public.payments (user_id);

alter table public.payments enable row level security;

drop policy if exists "payments: read own" on public.payments;
create policy "payments: read own"
  on public.payments for select to authenticated
  using (user_id = (select auth.uid()));

revoke insert, update, delete on public.payments from authenticated, anon;


-- ---------------------------------------------------------------------
-- 3. is_paid() helper, used by RLS so the paywall is enforced server-side
--    (killing/reopening the app or calling the API directly won't bypass it)
-- ---------------------------------------------------------------------
create or replace function public.is_paid()
returns boolean
language sql
stable
security definer
set search_path = ''
as $$
  select coalesce(
    (select p.is_paid from public.profiles p where p.id = (select auth.uid())),
    false
  );
$$;

revoke execute on function public.is_paid() from public, anon;
grant  execute on function public.is_paid() to authenticated;

create or replace function public.is_worker_paid()
returns boolean
language sql
stable
security definer
set search_path = ''
as $$
  select coalesce(
    (select p.is_worker_paid from public.profiles p where p.id = (select auth.uid())),
    false
  );
$$;

revoke execute on function public.is_worker_paid() from public, anon;
grant  execute on function public.is_worker_paid() to authenticated;


-- ---------------------------------------------------------------------
-- 4. What the payment unlocks
-- ---------------------------------------------------------------------
-- workers: every signed-in user can browse (this also drops the old ₹19
-- "paid users can read" paywall). Creating a worker profile needs the
-- listing fee; editing an existing one stays free.
drop policy if exists "workers: paid users can read" on public.workers;
drop policy if exists "workers: signed-in users can read" on public.workers;
create policy "workers: signed-in users can read"
  on public.workers for select to authenticated
  using (true);

drop policy if exists "workers: insert own listing" on public.workers;
create policy "workers: insert own listing"
  on public.workers for insert to authenticated
  with check (user_id = (select auth.uid()) and (select public.is_worker_paid()));

drop policy if exists "workers: update own listing" on public.workers;
create policy "workers: update own listing"
  on public.workers for update to authenticated
  using (user_id = (select auth.uid()))
  with check (user_id = (select auth.uid()));

-- ...but the phone column is not readable directly; worker_phone() below
-- hands it out to paid users (and to the listing's owner).
revoke select on public.workers from authenticated;
grant  select (id, user_id, name, category_en, category_ml, city, country,
               experience_years, about, rating, photo_url, work_photo_urls,
               is_available, created_at, updated_at)
  on public.workers to authenticated;

create or replace function public.worker_phone(wid uuid)
returns text
language sql
stable
security definer
set search_path = ''
as $$
  select w.phone
    from public.workers w
   where w.id = wid
     and (w.user_id = (select auth.uid()) or public.is_paid());
$$;

revoke execute on function public.worker_phone(uuid) from public, anon;
grant  execute on function public.worker_phone(uuid) to authenticated;

-- chat: only paid users can START a conversation. Anyone in a conversation
-- can reply, so a worker never has to pay to answer a customer.
drop policy if exists "conversations: members can create" on public.conversations;
create policy "conversations: members can create"
  on public.conversations for insert to authenticated
  with check ((select auth.uid()) in (user_a, user_b) and (select public.is_paid()));

drop policy if exists "messages: members can send as themselves" on public.messages;
create policy "messages: members can send as themselves"
  on public.messages for insert to authenticated
  with check (
    sender_id = (select auth.uid())
    and public.is_conversation_member(conversation_id)
  );
