-- =====================================================================
--  Sahayi – worker ratings + written reviews
--    • worker_reviews        : one review (1-5 stars + optional message)
--                              per customer per worker
--    • workers.rating        : average, kept up to date by a trigger
--    • workers.rating_count  : number of reviews, kept up to date by a trigger
--  Run AFTER schema.sql, payments.sql and worker_options.sql:
--  Supabase Dashboard → SQL Editor → New query → paste → Run.
--  RUN THIS BEFORE releasing the new app version (the app now reads
--  workers.rating_count). Safe to re-run.
-- =====================================================================

-- ---------------------------------------------------------------------
-- 1. rating_count on workers (rating itself already exists)
-- ---------------------------------------------------------------------
alter table public.workers
  add column if not exists rating_count int not null default 0;

-- workers has column-level grants (see payments.sql), so expose the new one.
-- Clients still cannot write rating / rating_count: only the trigger can.
grant select (rating_count) on public.workers to authenticated;

-- ---------------------------------------------------------------------
-- 2. worker_reviews
-- ---------------------------------------------------------------------
create table if not exists public.worker_reviews (
  id           uuid primary key default gen_random_uuid(),
  worker_id    uuid not null references public.workers (id)  on delete cascade,
  reviewer_id  uuid not null default auth.uid()
                 references public.profiles (id) on delete cascade,
  rating       numeric(2,1) not null
                 check (rating between 0.5 and 5 and rating * 2 = floor(rating * 2)),
  comment      text not null default '' check (char_length(comment) <= 500),
  created_at   timestamptz not null default now(),
  updated_at   timestamptz not null default now(),
  unique (worker_id, reviewer_id)                -- one review per person
);

-- Half stars: tables created by an earlier version of this file (smallint,
-- whole stars only) are converted here. No-op on a fresh install.
do $$
declare c record;
begin
  if (select data_type from information_schema.columns
       where table_schema = 'public' and table_name = 'worker_reviews'
         and column_name = 'rating') <> 'numeric' then
    for c in
      select conname from pg_constraint
       where conrelid = 'public.worker_reviews'::regclass
         and contype = 'c' and pg_get_constraintdef(oid) ilike '%rating%'
    loop
      execute format('alter table public.worker_reviews drop constraint %I', c.conname);
    end loop;
    alter table public.worker_reviews
      alter column rating type numeric(2,1) using rating::numeric;
    alter table public.worker_reviews
      add constraint worker_reviews_rating_half_check
      check (rating between 0.5 and 5 and rating * 2 = floor(rating * 2));
  end if;
end $$;

create index if not exists worker_reviews_worker_idx
  on public.worker_reviews (worker_id, created_at desc);

drop trigger if exists worker_reviews_set_updated_at on public.worker_reviews;
create trigger worker_reviews_set_updated_at
  before update on public.worker_reviews
  for each row execute function public.set_updated_at();

-- ---------------------------------------------------------------------
-- 3. Keep workers.rating / rating_count in sync
-- ---------------------------------------------------------------------
create or replace function public.refresh_worker_rating()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
declare
  wid uuid := coalesce(new.worker_id, old.worker_id);
begin
  update public.workers w
     set rating = coalesce(
           (select round(avg(r.rating)::numeric, 1)
              from public.worker_reviews r where r.worker_id = wid), 0),
         rating_count =
           (select count(*) from public.worker_reviews r where r.worker_id = wid)
   where w.id = wid;
  return null;
end;
$$;

drop trigger if exists worker_reviews_refresh_rating on public.worker_reviews;
create trigger worker_reviews_refresh_rating
  after insert or update or delete on public.worker_reviews
  for each row execute function public.refresh_worker_rating();

-- ---------------------------------------------------------------------
-- 4. Row level security
-- ---------------------------------------------------------------------
-- True if the listing belongs to the signed-in user (nobody rates themselves).
create or replace function public.is_own_listing(wid uuid)
returns boolean
language sql
stable
security definer
set search_path = ''
as $$
  select exists (
    select 1 from public.workers w
     where w.id = wid and w.user_id = (select auth.uid())
  );
$$;

revoke execute on function public.is_own_listing(uuid) from public, anon;
grant  execute on function public.is_own_listing(uuid) to authenticated;

alter table public.worker_reviews enable row level security;

drop policy if exists "reviews: signed-in users can read" on public.worker_reviews;
create policy "reviews: signed-in users can read"
  on public.worker_reviews for select to authenticated
  using (true);

drop policy if exists "reviews: write own review" on public.worker_reviews;
create policy "reviews: write own review"
  on public.worker_reviews for insert to authenticated
  with check (
    reviewer_id = (select auth.uid())
    and not public.is_own_listing(worker_id)
  );

drop policy if exists "reviews: edit own review" on public.worker_reviews;
create policy "reviews: edit own review"
  on public.worker_reviews for update to authenticated
  using (reviewer_id = (select auth.uid()))
  with check (reviewer_id = (select auth.uid()));

drop policy if exists "reviews: delete own review" on public.worker_reviews;
create policy "reviews: delete own review"
  on public.worker_reviews for delete to authenticated
  using (reviewer_id = (select auth.uid()));

-- Clients may only send worker_id / rating / comment; reviewer_id is filled
-- in from the login, timestamps by the database.
revoke insert, update, delete on public.worker_reviews from authenticated, anon;
revoke select on public.worker_reviews from anon;
grant  insert (worker_id, rating, comment) on public.worker_reviews to authenticated;
grant  update (rating, comment)            on public.worker_reviews to authenticated;
grant  delete                              on public.worker_reviews to authenticated;
