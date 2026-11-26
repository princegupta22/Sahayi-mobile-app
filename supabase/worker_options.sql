-- =====================================================================
--  Sahayi – worker contact options + "Other service"
--    • workers.phone_public    : true  = paid users can see/call the number
--                                false = "Only me" (nobody else gets it)
--    • workers.allow_messages  : false = nobody can start a chat or send a
--                                new message to this worker ("Get messages: Disable")
--    • workers.custom_service  : free-text service name used when the worker
--                                picks category "Other" (e.g. "Wall painting artist")
--  Run AFTER schema.sql and payments.sql:
--  Supabase Dashboard → SQL Editor → New query → paste → Run.
--  Safe to re-run.
-- =====================================================================

-- ---------------------------------------------------------------------
-- 1. New columns (existing workers keep today's behaviour: number public,
--    messages on, no custom service)
-- ---------------------------------------------------------------------
alter table public.workers
  add column if not exists phone_public   boolean not null default true,
  add column if not exists allow_messages boolean not null default true,
  add column if not exists custom_service text    not null default ''
    check (char_length(custom_service) <= 60);

-- ---------------------------------------------------------------------
-- 2. Column privileges (phone itself stays hidden; the new columns are safe
--    to show everyone because the app needs them to draw the Call / Message
--    buttons)
-- ---------------------------------------------------------------------
grant select (phone_public, allow_messages, custom_service)
  on public.workers to authenticated;
grant insert (phone_public, allow_messages, custom_service)
  on public.workers to authenticated;
grant update (phone_public, allow_messages, custom_service)
  on public.workers to authenticated;

-- ---------------------------------------------------------------------
-- 3. Phone number: owner always; others only if paid AND the worker made
--    the number Public.
-- ---------------------------------------------------------------------
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
     and (
       w.user_id = (select auth.uid())
       or (public.is_paid() and w.phone_public)
     );
$$;

revoke execute on function public.worker_phone(uuid) from public, anon;
grant  execute on function public.worker_phone(uuid) to authenticated;

-- ---------------------------------------------------------------------
-- 4. Messages: nobody can start a chat with, or send a new message to,
--    a worker who disabled "Get messages". The worker can still reply to
--    people who already wrote to them.
-- ---------------------------------------------------------------------
create or replace function public.user_accepts_messages(uid uuid)
returns boolean
language sql
stable
security definer
set search_path = ''
as $$
  select not exists (
    select 1 from public.workers w
     where w.user_id = uid and not w.allow_messages
  );
$$;

revoke execute on function public.user_accepts_messages(uuid) from public, anon;
grant  execute on function public.user_accepts_messages(uuid) to authenticated;

-- True if the OTHER person in this conversation accepts messages.
create or replace function public.conversation_accepts_messages(cid uuid)
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
       and public.user_accepts_messages(
             case when c.user_a = (select auth.uid()) then c.user_b else c.user_a end
           )
  );
$$;

revoke execute on function public.conversation_accepts_messages(uuid) from public, anon;
grant  execute on function public.conversation_accepts_messages(uuid) to authenticated;

drop policy if exists "conversations: members can create" on public.conversations;
create policy "conversations: members can create"
  on public.conversations for insert to authenticated
  with check (
    (select auth.uid()) in (user_a, user_b)
    and (select public.is_paid())
    and public.user_accepts_messages(
          case when user_a = (select auth.uid()) then user_b else user_a end
        )
  );

drop policy if exists "messages: members can send as themselves" on public.messages;
create policy "messages: members can send as themselves"
  on public.messages for insert to authenticated
  with check (
    sender_id = (select auth.uid())
    and public.is_conversation_member(conversation_id)
    and public.conversation_accepts_messages(conversation_id)
  );
