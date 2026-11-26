// Verifies a Google Play one-time purchase with the Google Play Developer
// API, records it, unlocks the account, then consumes the purchase so the
// same Google account can buy again for another Sahayi account.
//
// Secrets (supabase secrets set ...):
//   GOOGLE_PLAY_SERVICE_ACCOUNT  full service-account JSON (Play Console →
//                                 Setup → API access, "View financial data"
//                                 + "Manage orders" permissions)
//   ANDROID_PACKAGE_NAME         e.g. com.sahayi.app (defaults to the app id below)
import {
  adminClient, corsHeaders, getUser, grant, json, PURPOSES, toPurpose,
} from "../_shared/common.ts";

const PACKAGE = Deno.env.get("ANDROID_PACKAGE_NAME") ?? "com.sahayiapp.in";
const API = "https://androidpublisher.googleapis.com/androidpublisher/v3";

const b64url = (data: ArrayBuffer | string) => {
  const bytes = typeof data === "string"
    ? new TextEncoder().encode(data)
    : new Uint8Array(data);
  return btoa(String.fromCharCode(...bytes))
    .replace(/\+/g, "-").replace(/\//g, "_").replace(/=+$/, "");
};

/** OAuth access token for the service account (signed JWT, RS256). */
async function accessToken(): Promise<string> {
  const sa = JSON.parse(Deno.env.get("GOOGLE_PLAY_SERVICE_ACCOUNT")!);
  const now = Math.floor(Date.now() / 1000);
  const unsigned = `${b64url(JSON.stringify({ alg: "RS256", typ: "JWT" }))}.${
    b64url(JSON.stringify({
      iss: sa.client_email,
      scope: "https://www.googleapis.com/auth/androidpublisher",
      aud: "https://oauth2.googleapis.com/token",
      iat: now,
      exp: now + 3600,
    }))
  }`;
  const der = Uint8Array.from(
    atob(String(sa.private_key).replace(/-----[^-]+-----|\s/g, "")),
    (c) => c.charCodeAt(0),
  );
  const key = await crypto.subtle.importKey(
    "pkcs8",
    der,
    { name: "RSASSA-PKCS1-v1_5", hash: "SHA-256" },
    false,
    ["sign"],
  );
  const sig = await crypto.subtle.sign(
    "RSASSA-PKCS1-v1_5",
    key,
    new TextEncoder().encode(unsigned),
  );
  const res = await fetch("https://oauth2.googleapis.com/token", {
    method: "POST",
    headers: { "Content-Type": "application/x-www-form-urlencoded" },
    body: new URLSearchParams({
      grant_type: "urn:ietf:params:oauth:grant-type:jwt-bearer",
      assertion: `${unsigned}.${b64url(sig)}`,
    }),
  });
  const body = await res.json();
  if (!res.ok) throw new Error(`google token error: ${JSON.stringify(body)}`);
  return body.access_token;
}

Deno.serve(async (req) => {
  if (req.method === "OPTIONS") return new Response("ok", { headers: corsHeaders });

  const user = await getUser(req);
  if (!user) return json({ error: "unauthorized" }, 401);

  const { purpose: rawPurpose, product_id, purchase_token } =
    await req.json().catch(() => ({}));
  const purpose = toPurpose(rawPurpose);
  const cfg = PURPOSES[purpose];
  if (product_id !== cfg.productId || typeof purchase_token !== "string" ||
      purchase_token.length < 10) {
    return json({ error: "bad_request" }, 400);
  }

  const admin = adminClient();

  // A token can only ever unlock ONE Sahayi account.
  const { data: existing } = await admin
    .from("payments")
    .select("user_id, status")
    .eq("play_purchase_token", purchase_token)
    .maybeSingle();
  if (existing) {
    if (existing.user_id !== user.id) return json({ error: "purchase_used" }, 409);
    if (existing.status === "paid") {
      try { await grant(admin, user.id, purpose); } catch (e) {
        console.error(e);
        return json({ error: "db_failed" }, 500);
      }
      return json({ paid: true });
    }
  }

  // Ask Google whether this purchase is real.
  let token: string;
  try {
    token = await accessToken();
  } catch (e) {
    console.error(e);
    return json({ error: "google_auth_failed" }, 500);
  }
  const base = `${API}/applications/${PACKAGE}/purchases/products/${cfg.productId}/tokens/${
    encodeURIComponent(purchase_token)
  }`;
  const res = await fetch(base, { headers: { Authorization: `Bearer ${token}` } });
  const purchase = await res.json();
  if (!res.ok) {
    console.error("play lookup failed", purchase);
    return json({ error: "invalid_purchase" }, 400);
  }
  // 0 = purchased, 1 = canceled, 2 = pending (e.g. slow cash/UPI payment)
  if (purchase.purchaseState === 2) return json({ pending: true });
  if (purchase.purchaseState !== 0) return json({ error: "invalid_purchase" }, 400);
  // The app tags every purchase with the buyer's user id.
  if (purchase.obfuscatedExternalAccountId !== user.id) {
    return json({ error: "account_mismatch" }, 400);
  }

  // Record (the unique token column makes a double-spend impossible).
  const { error: insErr } = await admin.from("payments").upsert({
    user_id: user.id,
    provider: "google_play",
    play_product_id: cfg.productId,
    play_purchase_token: purchase_token,
    play_order_id: purchase.orderId ?? null,
    amount: cfg.amount,
    currency: "INR",
    purpose,
    status: "paid",
    paid_at: new Date().toISOString(),
  }, { onConflict: "play_purchase_token" });
  if (insErr) {
    console.error(insErr);
    return json({ error: "db_failed" }, 500);
  }

  try {
    await grant(admin, user.id, purpose);
  } catch (e) {
    console.error(e);
    return json({ error: "db_failed" }, 500);
  }

  // Consume (this also acknowledges). Best effort: if it fails, the app
  // acknowledges the purchase itself, so Google won't refund it.
  const consumed = await fetch(`${base}:consume`, {
    method: "POST",
    headers: { Authorization: `Bearer ${token}` },
  });
  if (!consumed.ok) console.error("consume failed", await consumed.text());

  return json({ paid: true });
});
