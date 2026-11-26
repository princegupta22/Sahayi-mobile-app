-- =====================================================================
--  Sahayi – switch payments from Razorpay to Google Play Billing (Android).
--  Run AFTER payments.sql: Supabase Dashboard → SQL Editor → New query.
--  Old Razorpay rows and every user's paid flags are kept. Safe to re-run.
-- =====================================================================

alter table public.payments
  alter column razorpay_order_id drop not null;          -- Play rows have none

alter table public.payments
  add column if not exists provider            text not null default 'razorpay',
  add column if not exists play_product_id     text,
  add column if not exists play_purchase_token text,
  add column if not exists play_order_id       text;

alter table public.payments drop constraint if exists payments_provider_check;
alter table public.payments
  add constraint payments_provider_check
  check (provider in ('razorpay', 'google_play'));

-- One Google Play purchase can unlock one Sahayi account, ever.
-- (NULLs don't clash, so old Razorpay rows are fine.)
create unique index if not exists payments_play_purchase_token_key
  on public.payments (play_purchase_token);
