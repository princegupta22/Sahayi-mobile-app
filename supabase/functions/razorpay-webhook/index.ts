// Safety net: if the app is killed right after paying, Razorpay still tells
// us, so the user is unlocked anyway. Deploy with --no-verify-jwt.
import { adminClient, hmacSha256Hex, markPaid, safeEqual } from "../_shared/common.ts";

Deno.serve(async (req) => {
  const body = await req.text();
  const sig = req.headers.get("x-razorpay-signature") ?? "";
  const expected = await hmacSha256Hex(Deno.env.get("RAZORPAY_WEBHOOK_SECRET")!, body);
  if (!safeEqual(expected, sig)) return new Response("bad signature", { status: 400 });

  const event = JSON.parse(body);
  if (event.event === "payment.captured" || event.event === "order.paid") {
    const payment = event.payload?.payment?.entity;
    if (payment?.order_id && payment?.id) {
      try {
        await markPaid(adminClient(), payment.order_id, payment.id);
      } catch (e) {
        console.error(e);
        return new Response("error", { status: 500 }); // Razorpay will retry
      }
    }
  }
  return new Response("ok");
});
