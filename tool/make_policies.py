"""Writes the privacy policy and account-deletion pages.
  website/privacy.html, website/delete-account.html   (site look, for hosting)
  playstore/privacy-policy.html, playstore/delete-account.html  (standalone, upload to Google Docs / Drive)
"""
import os
ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
EMAIL = "sahayi2026@gmail.com"
UPDATED = "12 November 2026"

PRIVACY = f"""<h1 class="p">Privacy Policy</h1>
<p>Last updated: {UPDATED}</p>
<p>Sahayi ("we", "us") is an app that connects people with local home-service workers such as electricians, plumbers, carpenters and cleaners. It is operated by Jestin George, India. This policy explains what information the Sahayi app (Android package <b>com.sahayiapp.in</b>) collects, how it is used and the choices you have. By using Sahayi you agree to this policy.</p>

<h3>1. Information we collect</h3>
<p><b>Account information.</b> Your name, email address and password when you sign up. Passwords are stored in hashed form by our authentication provider; we cannot read them.</p>
<p><b>Worker profile (only if you list yourself as a worker).</b> Your name, service category (or the custom service name you type under "Other"), city and country, years of experience, a short description, profile photo, up to three work photos, your phone number (optional), your Available/Booked status and your contact preferences.</p>
<p><b>Messages.</b> Chat messages you send and receive in the app, with time stamps and read status, so conversations can be delivered and shown to you.</p>
<p><b>Purchase information.</b> When you buy the contact unlock or the worker-profile listing through Google Play, Google tells us the purchase status, order ID, product and purchase token. We never see or store your card, UPI or bank details.</p>
<p><b>Photos you choose.</b> Pictures you pick from your gallery for your profile or work gallery. Sahayi only accesses the photos you select.</p>
<p><b>What we do not collect.</b> We do not collect your device location, contacts, call logs or SMS. We do not use advertising or analytics SDKs, and we do not show ads.</p>

<h3>2. How we use your information</h3>
<ul>
<li>To create and run your account and show worker listings in search results.</li>
<li>To let customers contact workers by chat or phone, as allowed by the worker's contact settings.</li>
<li>To verify purchases and unlock the features you bought.</li>
<li>To prevent spam, fraud and misuse, and to give you support.</li>
</ul>
<p>We do not sell your personal data and we do not use it for advertising.</p>

<h3>3. Who can see what</h3>
<ul>
<li><b>Worker listings</b> (name, service, city, experience, description, photos, rating, availability) are visible to other signed-in Sahayi users.</li>
<li><b>Your phone number</b> is never shown in the listing. If you set "Who can see my number" to <b>Public</b>, a signed-in user who has paid the contact unlock can call you. If you set it to <b>Only me</b>, nobody else can get your number.</li>
<li><b>Messages</b> are visible only to the two people in the conversation. A worker can turn "Get messages" off so that nobody can start a new chat with them.</li>
<li><b>Your email address</b> is not shown to other users.</li>
</ul>

<h3>4. Sharing with service providers</h3>
<p>We share data only with providers that help us run the app, and only as needed:</p>
<ul>
<li><b>Supabase</b> – hosting of our database, user authentication, file storage (photos) and realtime chat.</li>
<li><b>Google Play</b> – processing of in-app purchases.</li>
</ul>
<p>We may also disclose information if required by law or to protect the rights and safety of users. We do not share your data with advertisers or data brokers.</p>

<h3>5. Data security</h3>
<p>Data is sent over encrypted connections (HTTPS/TLS). Access to the database is restricted with row-level security so users can read and change only what they are allowed to. No system is perfectly secure, so please use a strong password and do not share it.</p>

<h3>6. Data retention and deletion</h3>
<p>We keep your information while your account is active. You can ask us to delete your account and data at any time, see <a href="delete-account.html">how to delete your account</a>. After a deletion request we remove your profile, worker listing, photos and chat messages within 30 days. We may keep purchase records for as long as tax and accounting laws require.</p>

<h3>7. Your choices and rights</h3>
<p>You can edit your name, listing, photos, availability and contact settings in the app. You can ask us to access, correct or delete your personal data by emailing <a href="mailto:{EMAIL}">{EMAIL}</a>. You can also revoke photo access in your phone's settings.</p>

<h3>8. Children</h3>
<p>Sahayi is not meant for children under 18 and we do not knowingly collect data from them. If you believe a child has given us information, email us and we will delete it.</p>

<h3>9. Changes to this policy</h3>
<p>We may update this policy from time to time. The "last updated" date above shows the latest version. Significant changes will be notified in the app or on this page.</p>

<h3>10. Contact</h3>
<p>Jestin George, India · <a href="mailto:{EMAIL}">{EMAIL}</a></p>"""

DELETE = f"""<h1 class="p">Delete your Sahayi account</h1>
<p>Last updated: {UPDATED}</p>
<p>This page explains how to delete your account and data for the <b>Sahayi</b> app (Android package <b>com.sahayiapp.in</b>, developer: Jestin George).</p>

<h3>Delete inside the app (fastest)</h3>
<ol>
<li>Open the Sahayi app and sign in.</li>
<li>Go to <b>Profile</b> and tap <b>Delete Account</b> under Settings.</li>
<li>Confirm. Your account and data are deleted immediately.</li>
</ol>

<h3>Or request deletion by email</h3>
<ol>
<li>Send an email to <a href="mailto:{EMAIL}?subject=Delete%20my%20Sahayi%20account">{EMAIL}</a> from the email address you used to sign up.</li>
<li>Use the subject <b>"Delete my Sahayi account"</b> and include your name as shown in the app.</li>
<li>We reply to confirm it is you, then delete the account. This is done within 30 days of your request, usually much sooner.</li>
</ol>

<h3>What is deleted</h3>
<ul>
<li>Your account (name, email and login).</li>
<li>Your worker listing: service, city, experience, description, phone number, availability and contact settings.</li>
<li>Your profile photo and work photos.</li>
<li>Your chat messages and conversations.</li>
<li>The ratings and reviews you wrote.</li>
</ul>

<h3>What we may keep</h3>
<ul>
<li>Records of purchases made through Google Play (order ID, product, date), kept only as long as tax and accounting laws require. They are no longer linked to a usable account.</li>
<li>Copies in routine backups, which are overwritten on the normal backup cycle.</li>
</ul>

<h3>Good to know</h3>
<ul>
<li>Deleting your account cannot be undone. Purchases you made (contact unlock, worker-profile listing) are tied to the account and are not restored after deletion. Refunds are handled under Google Play's refund policy.</li>
<li>If you only want to hide yourself, you can instead set your status to Booked, set your number to "Only me" and turn "Get messages" off in the app.</li>
</ul>

<p>Questions? See our <a href="privacy.html">Privacy Policy</a> or email <a href="mailto:{EMAIL}">{EMAIL}</a>.</p>"""

SITE_HEAD = """<!doctype html><html lang="en"><head><meta charset="utf-8"><meta name="viewport" content="width=device-width,initial-scale=1">
<title>{title} – Sahayi</title><meta name="description" content="Sahayi connects people with trusted local home-service workers."><link rel="stylesheet" href="style.css"></head><body>
<header><nav><img src="logo.png" alt="Sahayi logo"><b>Sahayi</b><a href="index.html">Home</a><a href="pricing.html">Pricing</a><a href="contact.html">Contact</a></nav></header>
<main class="doc">"""
SITE_FOOT = """</main>
<footer><p>© 2026 Sahayi · <a href="privacy.html">Privacy Policy</a> · <a href="delete-account.html">Delete Account</a> · <a href="terms.html">Terms &amp; Conditions</a> · <a href="refund.html">Refund &amp; Cancellation</a> · <a href="contact.html">Contact Us</a></p><p>Operated by Jestin George, India</p></footer></body></html>
"""
STAND_HEAD = """<!doctype html><html lang="en"><head><meta charset="utf-8"><meta name="viewport" content="width=device-width,initial-scale=1">
<title>{title} – Sahayi</title>
<style>body{{font:16px/1.65 Arial,Helvetica,sans-serif;color:#1c2a1f;max-width:760px;margin:32px auto;padding:0 20px}}h1{{color:#1b5e20}}h3{{color:#1b5e20;margin-top:28px}}a{{color:#2e7d32}}</style></head><body>
<p><b style="font-size:20px;color:#1b5e20">Sahayi</b></p>
"""
STAND_FOOT = "\n<hr><p style=\"color:#5b6b5e;font-size:14px\">© 2026 Sahayi · Operated by Jestin George, India</p></body></html>\n"
# standalone copies live on a different host than the site, so use absolute-less links
def standalone(body):
    return body.replace('href="delete-account.html"', 'href="#delete"').replace('href="privacy.html"', 'href="#privacy"')

for name, title, body in [("privacy", "Privacy Policy", PRIVACY), ("delete-account", "Delete Account", DELETE)]:
    open(os.path.join(ROOT, "website", f"{name}.html"), "w").write(SITE_HEAD.format(title=title) + body + "\n" + SITE_FOOT)
    open(os.path.join(ROOT, "playstore", ("privacy-policy" if name == "privacy" else name) + ".html"), "w").write(
        STAND_HEAD.format(title=title) + body.replace('href="delete-account.html"', 'href="mailto:' + EMAIL + '?subject=Delete%20my%20Sahayi%20account"').replace('href="privacy.html"', 'href="mailto:' + EMAIL + '"') + STAND_FOOT)
print("ok")
