# Agent 7 — Payment Flow Audit

Scope: lib/features/payment/**, functions/index.js, functions/payment_validation.js, firestore.rules.
All findings below are derived from fresh reads of current repo state (master branch, working tree as of audit time), not from prior audit docs.

---

## LOCKED-STATE RE-CHECK: "Stripe WebView bridge"

**STATUS: CONTRADICTED BY FRESH EVIDENCE — the claimed component does not exist in the current codebase.**

I searched exhaustively for any WebView usage tied to payments:

- `grep -rn "WebView|InAppWebView|WebViewController|JavascriptChannel|addJavaScriptHandler"` across `lib/**/*.dart`: **0 matches**.
- `pubspec.yaml` / `pubspec.lock`: no `webview_flutter`, `flutter_inappwebview`, or any webview package declared.
- Repo-wide file search for `*webview*`: the only hits are pre-built Java `.class` files under `build/url_launcher_android/...` (e.g. `build/url_launcher_android/intermediates/javac/release/.../WebViewActivity.class`), which belong to the `url_launcher` plugin's Android implementation (used for opening external links in a browser) — unrelated to payments and not application code.
- `pubspec.yaml` declares `flutter_stripe: ^12.1.1`, confirmed in `lib/features/payment/presentation/screens/payment_screen.dart:3` (`import 'package:flutter_stripe/flutter_stripe.dart';`) and used via `Stripe.instance.initPaymentSheet` / `Stripe.instance.presentPaymentSheet` (lines 143–154). This is the **native PaymentSheet** flutter_stripe component (native Android/iOS UI rendered by the Stripe SDK), not a WebView-based card form.

**Conclusion: There is no Stripe WebView bridge in this codebase to verify.** Sub-points #4 and #5 of this assignment (WebView navigation allowlist, JS bridge reachability) target a component that is not present. I cannot confirm or deny the previously "locked" claims about WebView asset-only loading and JS handler isolation because the code does not exist to inspect — this may reflect a different branch/version, a removed feature, or a misattributed locked-state note carried over from a different app/module. **Flagged as INFO/discrepancy, not as a vulnerability**, since an absent WebView cannot itself leak secrets — but the "locked" claim should be re-scoped or retracted by whoever owns the master locked-state list.

Rating: **INFO** (process/documentation discrepancy, not a security flaw — re-verify against the intended branch/commit if a WebView-based card capture flow exists elsewhere).
Status: **NEW — contradicts prior locked claim; could not verify #4/#5 because the targeted code is absent.**

---

## 1. Where clientSecret is obtained

**Finding: clientSecret always originates from a network response (Firebase Callable Function), never hardcoded or client-derived.**

Trace:

- `lib/features/payment/presentation/screens/payment_screen.dart:114-130` — `_createPaymentIntent()` calls `PaymentDependencies.createPaymentIntent().call(bookingId:, amount:, currency:)` and returns `result.valueOrNull` (a `PaymentIntentData`).
- `lib/features/payment/data/repositories/payment_repository_impl.dart:14-32` — `createPaymentIntent()` delegates to `_gatewayDataSource.createPaymentIntent(...)` and maps `dto.toDomain()`.
- `lib/features/payment/data/datasources/payment_gateway_remote_data_source.dart:20-35`:
  ```dart
  final callable = _functions.httpsCallable('createPaymentIntent');
  final result = await callable.call({...});
  final data = Map<String, dynamic>.from(result.data as Map);
  return PaymentIntentDto.fromMap(data);
  ```
  This is a Firebase Cloud Functions **httpsCallable** network call — the clientSecret comes from `result.data`, i.e. the backend's HTTP response.
- `lib/features/payment/data/dtos/payment_intent_dto.dart:16-23` — `PaymentIntentDto.fromMap` reads `data['clientSecret']` strictly from the network response map; no fallback/default/hardcoded value exists.
- Backend side: `functions/index.js:199-247` (`exports.createPaymentIntent`) creates the PaymentIntent via `stripe.paymentIntents.create(...)` server-side (using the secret key, never sent to the client) and returns `{ paymentIntentId: intent.id, clientSecret: intent.client_secret }` (line 243-246) — this is the only place `clientSecret` is produced.
- The client then feeds this into `Stripe.instance.initPaymentSheet(paymentIntentClientSecret: paymentIntent.clientSecret, ...)` at `lib/features/payment/presentation/screens/payment_screen.dart:145`.

No hardcoded or client-fabricated clientSecret exists anywhere in `lib/`.

Rating: **INFO** (confirms correct design).
Status: **NEW (fresh verification) — RE-CONFIRMED WITH FRESH EVIDENCE** (this sub-point was not explicitly in the prior locked list, but aligns with it).

---

## 2. Does payment confirmation round-trip through the backend as source of truth?

**Finding: Yes. There is no Stripe webhook handler, but the backend treats the client's "success" signal only as a trigger to re-verify with Stripe's API directly — it does not trust the client's reported status.**

- Webhook search: `grep -rn "webhook|constructEvent|stripe-signature|payment_intent.succeeded"` across `functions/` → **0 matches**. `functions/index.js` has only one `onRequest` handler, at line 1935 (`maintenanceCleanupStories`), unrelated to Stripe. **There is no Stripe webhook endpoint in this codebase.**
- Instead, the client-side flow is:
  - `lib/features/payment/presentation/screens/payment_screen.dart:80-86`: after `Stripe.instance.presentPaymentSheet()` returns success (`_confirmPayment`), the client calls `_updateBookingPaymentStatus(paymentIntent.paymentIntentId)`.
  - `lib/features/payment/data/datasources/firestore_payment_remote_data_source.dart:11-22`: this calls the `confirmPaymentIntent` httpsCallable, passing `bookingId`, `paymentIntentId`, and the **client-supplied amount** (used only for an early-reject double-check, not as authoritative data — see below).
- Backend (`functions/index.js:430-527`, `exports.confirmPaymentIntent`) does NOT trust the client's claim of success. It:
  1. Requires auth (`context.auth`, line 431-436) and booking ownership (`assertBookingOwnership`, line 456).
  2. **Re-fetches the PaymentIntent directly from Stripe's API**: `intent = await stripe.paymentIntents.retrieve(paymentIntentId)` (line 471).
  3. Hard-fails unless `intent.status === "succeeded"` per Stripe's own server (lines 478-483) — the client cannot spoof this; it must be true on Stripe's servers.
  4. Cross-checks `intent.currency`/`intent.amount` against the booking's authoritative price (`expectedAmount = Math.round(toNumber(booking.data.price))`, lines 458-493) — the **client-supplied `amount` argument is not used for this critical check, only Stripe's retrieved `intent.amount`/`intent.currency` and the booking doc's `price` are**.
  5. Cross-checks `intent.metadata.bookingId` / `intent.metadata.userId` (set server-side at PaymentIntent creation time, see #3) against the request, preventing intent-substitution / replay against a different booking (lines 495-504).
  6. Only then writes `payment.status = "succeeded"` and `payment.amount = intent.amount` (the Stripe-verified amount, not the client's) inside a Firestore transaction (lines 506-524), with an idempotency guard (`if (data.payment && data.payment.status === "succeeded") return;`, lines 513-515).

This is functionally equivalent to webhook-grade verification (re-querying Stripe as ground truth) even though no webhook exists. The absence of a webhook is a **resilience gap** (if the user closes the app/loses connectivity right after Stripe confirms but before the callable runs, the booking is never marked paid even though Stripe charged the customer — an operational/reconciliation issue), but it is **not a security bypass**: a malicious client cannot forge a "succeeded" status without an actual successful charge on Stripe's servers, because the callable independently re-verifies via `stripe.paymentIntents.retrieve`.

Rating: **MEDIUM** (operational/reliability gap — no webhook means missed confirmations aren't reconciled automatically; recommend adding a Stripe webhook for `payment_intent.succeeded` as a safety net) but **NOT a security bypass** for the trust question asked.
Status: **NEW finding (the "no webhook" fact) — RE-CONFIRMED WITH FRESH EVIDENCE that the backend independently verifies via Stripe API rather than trusting client-reported success.**

---

## 3. Can the client influence the charged amount/currency without backend validation?

**Finding: No. The amount is validated server-side against the booking's stored price at both PaymentIntent creation and confirmation. The client cannot charge an arbitrary amount.**

- `functions/payment_validation.js:1-26`:
  ```js
  const ALLOWED_CURRENCIES = new Set(['iqd']);
  function validateAmountAndCurrency(bookingData, amount, currency) {
    const bookingAmount = toNumber(bookingData.price);
    const bookingCurrency = normalizeCurrency(bookingData.currency || 'iqd');
    if (bookingAmount == null || bookingAmount <= 0) return 'invalid_booking_amount';
    if (amount == null || amount <= 0 || Math.round(amount) !== Math.round(bookingAmount)) return 'amount_mismatch';
    if (!ALLOWED_CURRENCIES.has(currency) || currency !== bookingCurrency) return 'currency_mismatch';
    return null;
  }
  ```
  The client-submitted `amount`/`currency` must exactly equal (rounded) the booking document's stored `price`/`currency` field. The booking's `price` is set when the booking is created server-side via `acceptOfferWithBooking` (`functions/index.js:284+`, using `buildBookingForAcceptedOffer` from `functions/booking_authority.js`), not writable by the client afterward for payment purposes (see Firestore rules below).
- `functions/index.js:199-247` (`createPaymentIntent`): calls `assertAmountAndCurrency(booking, amount, currency)` (line 219) **before** calling `stripe.paymentIntents.create({ amount: Math.round(amount), currency, ... })` (line 221-234). Since `assertAmountAndCurrency` throws unless `amount` matches the booking's stored price, the value passed to Stripe is constrained to equal the server-stored price — the client cannot inject an arbitrary amount.
- `functions/index.js:430-493` (`confirmPaymentIntent`): independently re-derives `expectedAmount` from `booking.data.price` (line 461) and compares it against `intent.amount` retrieved from Stripe directly (lines 485-493) — a second, independent server-side check at confirmation time, not relying on what the client claims was charged.
- **Firestore rules** (`firestore.rules:1760-1790`, `bookings/{bookingId}`): `allow create` requires `request.resource.data.payment.status == 'pending'` (line 1769) — the client cannot create a booking already marked paid. `allow update` for participants is gated by `bookingParticipantUpdateAllowed(bookingId)` (`firestore.rules:639-679`), whose `changed.hasOnly([...])` allow-list (lines 651-665: `status`, `notes`, `location`, `chatId`, `updatedAt`, `date`, `time`, `duration`, `type`, `deliveryId`, `revisionCount`, `canceledBy`, `timeline`) **does not include `payment` or `price`** — so a client cannot directly write `payment.status`, `payment.amount`, or `price` via the Firestore SDK; only the Cloud Functions admin SDK (which bypasses security rules) can write those fields, and it only does so after the validations above.

No code path lets the client set the Stripe-charged amount/currency independently of the booking's server-stored price, and no code path lets the client write a "paid" status directly to Firestore.

Rating: **INFO** (confirms correct design; no CRITICAL issue found).
Status: **NEW (fresh verification, with line-level proof) — RE-CONFIRMED WITH FRESH EVIDENCE.**

---

## 4 & 5. WebView navigation allowlist / JS bridge reachability

**STATUS: COULD NOT VERIFY — not applicable.** As established above, no WebView, `InAppWebView`, `WebViewController`, `JavascriptChannel`, or `addJavaScriptHandler` exists anywhere in `lib/` or the plugin manifest (`pubspec.yaml`/`pubspec.lock`). The payment UI is `flutter_stripe`'s native PaymentSheet (`lib/features/payment/presentation/screens/payment_screen.dart:143-154`), which renders native platform UI for card entry — there is no embedded HTML/JS asset and no JS bridge to audit.

If a WebView-based card capture flow exists in a different branch/module not covered by this checkout, it was not found here and must be located and audited separately; this report cannot confirm or deny its security properties.

Rating: N/A (no component to rate).
Status: **COULD NOT FULLY VERIFY — component absent from current codebase; do not treat as confirmed-safe nor as fixed.**

---

## Summary Table

| # | Item | Rating | Status |
|---|------|--------|--------|
| Locked-state | "Stripe WebView bridge" exists with asset-only loading | INFO (discrepancy) | NEW — contradicts prior claim; component not found in current code |
| 1 | clientSecret always from backend network response | INFO | RE-CONFIRMED WITH FRESH EVIDENCE |
| 2 | Backend re-verifies payment via Stripe API (no webhook present) | MEDIUM (reliability gap, not a security bypass) | NEW finding (no webhook) + RE-CONFIRMED (server-side re-verification logic) |
| 3 | Client cannot influence charged amount/currency | INFO | RE-CONFIRMED WITH FRESH EVIDENCE |
| 4 | WebView navigation allowlist | N/A | COULD NOT FULLY VERIFY — no WebView present |
| 5 | JS bridge reachable only from local asset | N/A | COULD NOT FULLY VERIFY — no WebView/JS bridge present |

## Recommendations
1. Add a Stripe webhook (`payment_intent.succeeded` / `.payment_failed`) as a reconciliation safety net so bookings aren't stuck "pending" if the client never calls `confirmPaymentIntent` after a successful charge (addresses MEDIUM finding in #2).
2. Reconcile the "Stripe WebView bridge" locked-state claim with the actual codebase — either the claim refers to a different branch/version, or it should be retracted/corrected, since flutter_stripe v12 uses native PaymentSheet, not a WebView.
