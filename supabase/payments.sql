-- =====================================================================
--  Sahayi – ₹19 registration payment (Razorpay)
--  Run AFTER schema.sql: Supabase Dashboard → SQL Editor → New query.
--  Safe to re-run.
-- =====================================================================

-- ---------------------------------------------------------------------
-- 1. Paid flag on profiles
-- ---------------------------------------------------------------------
alter table public.profiles
  add column if not exists is_paid boolean not null default false,
  add column if not exists paid_at timestamptz;

-- Clients must never be able to set is_paid themselves. Only the edge
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
  amount                int  not null check (amount > 0),         -- in paise (1900 = ₹19)
  currency              text not null default 'INR',
  status                text not null default 'created'
                          check (status in ('created', 'paid', 'failed')),
  created_at            timestamptz not null default now(),
  paid_at               timestamptz
);

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


-- ---------------------------------------------------------------------
-- 4. Tighten existing policies: unpaid users get no app features
-- ---------------------------------------------------------------------
-- workers: only paid users can browse / create / edit listings
drop policy if exists "workers: signed-in users can read" on public.workers;
create policy "workers: paid users can read"
  on public.workers for select to authenticated
  using ((select public.is_paid()));

drop policy if exists "workers: insert own listing" on public.workers;
create policy "workers: insert own listing"
  on public.workers for insert to authenticated
  with check (user_id = (select auth.uid()) and (select public.is_paid()));

drop policy if exists "workers: update own listing" on public.workers;
create policy "workers: update own listing"
  on public.workers for update to authenticated
  using (user_id = (select auth.uid()) and (select public.is_paid()))
  with check (user_id = (select auth.uid()) and (select public.is_paid()));

-- chat: only paid users can start conversations or send messages
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
    and (select public.is_paid())
  );
