// Permanently deletes the signed-in user's account.
//
// Removes the uploaded photos from Storage, then deletes the auth user.
// Everything else (profile, worker listing, reviews, conversations, messages,
// payment rows) goes with it through ON DELETE CASCADE, and the ratings of
// workers the user reviewed are recalculated by the reviews trigger.
//
// Deploy: supabase functions deploy delete-account
// (default JWT verification stays ON; the user is read from the token.)
import {
  adminClient, corsHeaders, getUser, json,
} from "../_shared/common.ts";

const BUCKETS = ["avatars", "work-photos"];

Deno.serve(async (req) => {
  if (req.method === "OPTIONS") return new Response("ok", { headers: corsHeaders });
  if (req.method !== "POST") return json({ error: "method_not_allowed" }, 405);

  const user = await getUser(req);
  if (!user) return json({ error: "unauthorized" }, 401);

  const admin = adminClient();

  // Photos live at <user-id>/<file>. Best effort: a storage hiccup must not
  // stop the user from deleting their account.
  for (const bucket of BUCKETS) {
    try {
      const { data } = await admin.storage
        .from(bucket)
        .list(user.id, { limit: 1000 });
      if (data?.length) {
        await admin.storage
          .from(bucket)
          .remove(data.map((f) => `${user.id}/${f.name}`));
      }
    } catch (e) {
      console.error(`storage cleanup failed (${bucket})`, e);
    }
  }

  const { error } = await admin.auth.admin.deleteUser(user.id);
  if (error) {
    console.error("deleteUser failed", error);
    return json({ error: "delete_failed" }, 500);
  }
  return json({ deleted: true });
});
