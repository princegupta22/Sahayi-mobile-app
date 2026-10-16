// Verifies Razorpay's signature server-side, then unlocks the account.
import {
  adminClient, AMOUNT_PAISE, corsHeaders, getUser, hmacSha256Hex, json, markPaid, safeEqual,
} from "../_shared/common.ts";

Deno.serve(async (req) => {
  if (req.method === "OPTIONS") return new Response("ok", { headers: corsHeaders });

  const user = await getUser(req);
  if (!user) return json({ error: "unauthorized" }, 401);

  const { razorpay_order_id, razorpay_payment_id, razorpay_signature } =
    await req.json().catch(() => ({}));
  if (!razorpay_order_id || !razorpay_payment_id || !razorpay_signature) {
    return json({ error: "missing_fields" }, 400);
  }

  const admin = adminClient();

  // The order must be one we created for THIS user at the right amount.
  const { data: row } = await admin
    .from("payments")
    .select("user_id, amount, status")
    .eq("razorpay_order_id", razorpay_order_id)
    .maybeSingle();
  if (!row || row.user_id !== user.id || row.amount !== AMOUNT_PAISE) {
    return json({ error: "order_mismatch" }, 400);
  }
  if (row.status === "paid") return json({ paid: true });

  const expected = await hmacSha256Hex(
    Deno.env.get("RAZORPAY_KEY_SECRET")!,
    `${razorpay_order_id}|${razorpay_payment_id}`,
  );
  if (!safeEqual(expected, razorpay_signature)) {
    await admin.from("payments").update({ status: "failed" })
      .eq("razorpay_order_id", razorpay_order_id);
    return json({ error: "bad_signature" }, 400);
  }

  try {
    await markPaid(admin, razorpay_order_id, razorpay_payment_id);
  } catch (e) {
    console.error(e);
    return json({ error: "db_failed" }, 500);
  }
  return json({ paid: true });
});
