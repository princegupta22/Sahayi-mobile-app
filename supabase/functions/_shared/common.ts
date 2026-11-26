import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

/** One-time purchases (Google Play Billing, Android only).
 *  Each one is a "one-time product" in Play Console and unlocks a flag on
 *  profiles. Keep productId in sync with lib/services/payment_service.dart. */
export const PURPOSES = {
  contact: {
    productId: "contact_unlock",
    amount: 14900, // ₹149 – ledger only; the real price is set in Play Console
    flag: "is_paid",
    paidAt: "paid_at",
  },
  listing: {
    productId: "worker_listing",
    amount: 14900,
    flag: "is_worker_paid",
    paidAt: "worker_paid_at",
  },
} as const;
export type Purpose = keyof typeof PURPOSES;

export const toPurpose = (v: unknown): Purpose =>
  v === "listing" ? "listing" : "contact";

export const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers":
    "authorization, x-client-info, apikey, content-type",
};

export const json = (body: unknown, status = 200) =>
  new Response(JSON.stringify(body), {
    status,
    headers: { ...corsHeaders, "Content-Type": "application/json" },
  });

/** Service-role client: bypasses RLS. Only used inside edge functions. */
export const adminClient = () =>
  createClient(
    Deno.env.get("SUPABASE_URL")!,
    Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!,
  );

/** Returns the signed-in user from the request's JWT, or null. */
export async function getUser(req: Request) {
  const auth = req.headers.get("Authorization");
  if (!auth) return null;
  const client = createClient(
    Deno.env.get("SUPABASE_URL")!,
    Deno.env.get("SUPABASE_ANON_KEY")!,
    { global: { headers: { Authorization: auth } } },
  );
  const { data, error } = await client.auth.getUser();
  return error ? null : data.user;
}

/** Turns on the profile flag a purchase unlocks. Idempotent. */
export async function grant(
  admin: ReturnType<typeof adminClient>,
  userId: string,
  purpose: Purpose,
) {
  const { flag, paidAt } = PURPOSES[purpose];
  const { error } = await admin
    .from("profiles")
    .update({ [flag]: true, [paidAt]: new Date().toISOString() })
    .eq("id", userId);
  if (error) throw error;
}
