import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

export const AMOUNT_PAISE = 1900; // ₹19, fixed on the server – never trust the client

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

export async function hmacSha256Hex(secret: string, message: string) {
  const key = await crypto.subtle.importKey(
    "raw",
    new TextEncoder().encode(secret),
    { name: "HMAC", hash: "SHA-256" },
    false,
    ["sign"],
  );
  const sig = await crypto.subtle.sign(
    "HMAC",
    key,
    new TextEncoder().encode(message),
  );
  return [...new Uint8Array(sig)].map((b) => b.toString(16).padStart(2, "0"))
    .join("");
}

export function safeEqual(a: string, b: string) {
  if (a.length !== b.length) return false;
  let diff = 0;
  for (let i = 0; i < a.length; i++) diff |= a.charCodeAt(i) ^ b.charCodeAt(i);
  return diff === 0;
}

/** Marks a payment row paid and flips profiles.is_paid. Idempotent. */
export async function markPaid(
  admin: ReturnType<typeof adminClient>,
  orderId: string,
  paymentId: string,
) {
  const { data: row, error } = await admin
    .from("payments")
    .update({
      status: "paid",
      razorpay_payment_id: paymentId,
      paid_at: new Date().toISOString(),
    })
    .eq("razorpay_order_id", orderId)
    .select("user_id")
    .single();
  if (error || !row) throw new Error("payment row not found");

  const { error: pErr } = await admin
    .from("profiles")
    .update({ is_paid: true, paid_at: new Date().toISOString() })
    .eq("id", row.user_id);
  if (pErr) throw pErr;
}
