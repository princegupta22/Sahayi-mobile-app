// Creates a ₹19 Razorpay order for the signed-in user.
import { adminClient, AMOUNT_PAISE, corsHeaders, getUser, json } from "../_shared/common.ts";

Deno.serve(async (req) => {
  if (req.method === "OPTIONS") return new Response("ok", { headers: corsHeaders });

  const user = await getUser(req);
  if (!user) return json({ error: "unauthorized" }, 401);

  const admin = adminClient();
  const { data: profile } = await admin
    .from("profiles").select("is_paid").eq("id", user.id).single();
  if (profile?.is_paid) return json({ already_paid: true });

  const keyId = Deno.env.get("RAZORPAY_KEY_ID")!;
  const keySecret = Deno.env.get("RAZORPAY_KEY_SECRET")!;

  const res = await fetch("https://api.razorpay.com/v1/orders", {
    method: "POST",
    headers: {
      "Content-Type": "application/json",
      Authorization: "Basic " + btoa(`${keyId}:${keySecret}`),
    },
    body: JSON.stringify({
      amount: AMOUNT_PAISE,
      currency: "INR",
      receipt: `sahayi_${user.id.slice(0, 8)}_${Date.now()}`,
      notes: { user_id: user.id },
    }),
  });
  const order = await res.json();
  if (!res.ok) {
    console.error("razorpay order error", order);
    return json({ error: "order_failed" }, 502);
  }

  const { error } = await admin.from("payments").insert({
    user_id: user.id,
    razorpay_order_id: order.id,
    amount: AMOUNT_PAISE,
    currency: "INR",
  });
  if (error) {
    console.error(error);
    return json({ error: "db_failed" }, 500);
  }

  return json({
    order_id: order.id,
    amount: AMOUNT_PAISE,
    currency: "INR",
    key_id: keyId, // public key id is safe to send to the app
  });
});
