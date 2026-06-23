# Agent 2 — Manifest & Attack Surface Audit

Scope: `com.laqta.laqta` (LAQTA), built release APKs in
`build/app/outputs/apk/production/release/` (arm64-v8a, armeabi-v7a, x86_64),
plus source manifest `android/app/src/main/AndroidManifest.xml`.

Tools used: `aapt2 dump badging`, `aapt2 dump xmltree --file AndroidManifest.xml`
against `app-production-arm64-v8a-release.apk` (versionCode 2001), cross-checked
permission set against the other two ABI splits (armeabi-v7a versionCode 1001,
x86_64 versionCode 4001 — identical permission/component set, confirmed below).

---

## 1. Exported components (final merged manifest)

Source: `aapt2 dump xmltree app-production-arm64-v8a-release.apk --file AndroidManifest.xml`
(saved as working file `/tmp/xmltree.txt`, line numbers below refer to that dump).

| Component | Type | exported | Protected by permission | Why exported | Verdict |
|---|---|---|---|---|---|
| `com.laqta.laqta.MainActivity` (xmltree line 74-115; source `AndroidManifest.xml:12-46`) | activity | true | — | LAUNCHER + VIEW/BROWSABLE intent filters (deep links) require export | INFO — RE-CONFIRMATION (expected, app's own launcher/deep-link activity) |
| `io.flutter.plugins.firebase.messaging.FlutterFirebaseMessagingReceiver` (line 246) | receiver | true | `com.google.android.c2dm.permission.SEND` | Required by FCM to receive `com.google.android.c2dm.intent.RECEIVE` | INFO — **RE-CONFIRMATION of locked state**, correct, not flagged further |
| `com.google.firebase.iid.FirebaseInstanceIdReceiver` (line 528) | receiver | true | `com.google.android.c2dm.permission.SEND` | Same FCM/GCM mechanism, legacy Instance-ID receiver bundled by `firebase-messaging`/play-services-gcm transitively | INFO — same protection class as the locked FlutterFirebaseMessagingReceiver finding; only senders holding the signature-protected `SEND` permission (i.e., the Google Play Services package) can deliver to it. Not independently exploitable. **NEW observation** (not previously enumerated) but **not a new risk** — same justification as the locked item. |
| `androidx.profileinstaller.ProfileInstallReceiver` (line 565-582) | receiver | true | `android.permission.DUMP` | Standard AndroidX Profile Installer component (baseline profile installation), exported by the library itself | LOW / INFO — **NEW finding**, not previously enumerated by name. `android.permission.DUMP` is a **signature\|privileged** level permission; third-party apps cannot hold it, so this receiver cannot be triggered by an arbitrary installed app. This is the well-known, intentional AndroidX Profile Installer pattern (same component ships in nearly every Jetpack app) and is not exploitable in practice. Rated LOW/INFO, no action needed. |
| `com.reactnativestripesdk.StripeConnectDeepLinkInterceptorActivity` (line 181-196) | activity | true | — | `stripe-connect://` VIEW/BROWSABLE filter — required for Stripe Connect deep-link handoff | INFO — covered by locked-state Stripe exemption |
| `com.stripe.android.financialconnections.FinancialConnectionsSheetRedirectActivity` (line 261-300) | activity | true | — | `stripe-auth://link-accounts`, `link-native-accounts`, `native-redirect`, and `stripe://auth-redirect` — required for Financial Connections / bank-login redirect return | INFO — covered by locked-state Stripe exemption |
| `com.stripe.android.link.LinkRedirectHandlerActivity` (line 383-400) | activity | true | — | `link-popup://complete` — required for Stripe Link 3DS/bank popup return | INFO — covered by locked-state Stripe exemption |
| `com.stripe.android.payments.StripeBrowserProxyReturnActivity` (line 421-438) | activity | true | — | `stripesdk://payment_return_url` — required for standard Stripe PaymentIntent browser-return flow (3DS) | INFO — covered by locked-state Stripe exemption |
| `com.stripe.android.financialconnections.lite.FinancialConnectionsSheetLiteRedirectActivity` (line 471-486) | activity | true | — | `stripe://financial-connections-lite/...auth_redirect` — required for the "lite" Financial Connections bank-login flow | INFO — covered by locked-state Stripe exemption |

All other declared components (`ComponentDiscoveryService`, `FirebaseInitProvider` removed via `tools:node="remove"`, `ShareFileProvider`, `StripeFileProvider`, `ImagePickerFileProvider`, `SentryPerformanceProvider`, `androidx-startup InitializationProvider`, `WebViewActivity`, `FlutterFirebaseMessagingBackgroundService`, `FlutterFirebaseMessagingService`, `FlutterFirebaseMessagingInitProvider`, the remaining ~15 Stripe internal activities — `PaymentAuthWebViewActivity`, `PaymentRelayActivity`, `StripeBrowserLauncherActivity`, `Stripe3ds2TransactionActivity`, `GooglePayLauncherActivity`, `GooglePayPaymentMethodLauncherActivity`, `PaymentLauncherConfirmationActivity`, `CollectBankAccountActivity`, `PassiveChallengeActivity`/`PassiveChallengeWarmerActivity`, `IntentConfirmationChallengeActivity`, `ChallengeActivity`, `CustomPaymentMethodActivity` — and Play-services internals `GoogleApiActivity`, `ModuleDependencies`, `TransportBackendDiscovery`, `JobInfoSchedulerService`, `AlarmManagerSchedulerBroadcastReceiver`, `PlayCoreDialogWrapperActivity`) are **`exported=false`** (explicitly verified in xmltree dump, e.g. lines 117/137/145/153/176/198/203/207/216/229/234/238/255/265/268/273/277/281/285/289/293/297/301/305/309/325/330/361/365/369/390/394/398/402/406/410/414/418/442/462/466/481/490/517/524/527/531). No issues.

**No unjustified exported component found.** Every `exported=true` component is either the app's own launcher/deep-link activity, FCM's two C2DM receivers (signature-permission gated, one already locked, the other newly enumerated with the same justification), the AndroidX Profile Installer receiver (signature\|privileged-gated, ubiquitous and benign), or a Stripe-required redirect activity already covered by the locked exemption.

---

## 2. Deep link schemes and hosts

Source manifest (`android/app/src/main/AndroidManifest.xml:30-45`) and merged xmltree (lines 92-113):

| Scheme | Host / path | autoVerify | Owner | Notes |
|---|---|---|---|---|
| `https` | `laqta.app` (no path constraint) | `true` (App Links) | `MainActivity` | Android App Links — verified via `.well-known/assetlinks.json` hosted at `https://laqta.app/.well-known/assetlinks.json` (not present in repo/APK, must be served server-side; **could not verify the live file from this audit** — see Finding M-1 below). Also referenced in `network_security_config.xml:10` (`laqta.app` + subdomains, cleartext disabled). |
| `laqta` | (any host/path) | n/a (custom scheme, not App Links) | `MainActivity` | Custom scheme, no autoVerify (custom schemes don't support it). Any app can register `laqta://` and a multi-app race/"first-installed-wins" ambiguity is possible — inherent OS limitation of custom schemes, not unique to this app. |
| `stripe-connect` | (any) | no | `StripeConnectDeepLinkInterceptorActivity` (Stripe SDK) | Library-owned, not app surface. |
| `stripe-auth` | `link-accounts`, `link-native-accounts`, `native-redirect` (with `/com.laqta.laqta/...` path prefixes) | no | `FinancialConnectionsSheetRedirectActivity` (Stripe SDK) | Library-owned. Path prefix includes app package name, reducing collision risk with other apps' Stripe integrations. |
| `stripe` | `auth-redirect`, `financial-connections-lite` (with `/com.laqta.laqta/...` path prefixes) | no | Stripe SDK activities | Library-owned, same package-scoped path pattern. |
| `link-popup` | `complete` (path `/com.laqta.laqta`) | no | `LinkRedirectHandlerActivity` (Stripe SDK) | Library-owned. |
| `stripesdk` | `payment_return_url` (path `/com.laqta.laqta`) | no | `StripeBrowserProxyReturnActivity` (Stripe SDK) | Library-owned. |

**Application-level deep link validation** (`lib/core/routing/deep_link_handler.dart:97-117`): the app's own
`_isAllowedScheme()` restricts handling to `https://laqta.app/*` and `laqta://*` only; `_hasUnsafeParts()`
rejects any URI containing query parameters or `../` / `%2e%2e` path-traversal sequences; `resolve()` uses
a closed switch-statement allowlist (`explore`, `chat/:id`, `profile/:id`, `post/:id`) and returns `null`
(silently logged as `invalid_deep_link`, severity `warning`) for anything else. This is solid defense-in-depth
beyond the manifest — even if a malicious app intent-spoofed a VIEW intent matching the filter, the Dart-level
router will reject any unrecognized path/host or any URI carrying query parameters. **INFO — no issue.**

**Finding M-1 (MEDIUM, NEW, requires live verification, not provable from this audit):**
`autoVerify="true"` on the `https://laqta.app` intent filter only succeeds at install time if
`https://laqta.app/.well-known/assetlinks.json` is correctly published and lists this app's package
name (`com.laqta.laqta`) and signing certificate SHA-256 fingerprint(s) for all relevant signing
configs (release + any upload key via Play App Signing). No such file exists in this repository
(confirmed via `find . -iname "assetlinks.json"` — no results), which is expected since it's served
server-side, but it means **this audit cannot confirm App Link verification is actually live**.
If verification fails or is missing, Android falls back to showing a disambiguation dialog for
`https://laqta.app/...` links (still requires user action to open in-app — not a hijack vector, but
a UX/functionality gap, not a security hole). Recommend: confirm `assetlinks.json` is live and lists
the correct SHA-256 cert fingerprint(s) as a deployment checklist item. Not a vulnerability by itself.

---

## 3. Full permission set

Source: `aapt2 dump badging` on all 3 release APKs (arm64-v8a, armeabi-v7a, x86_64) — **identical set across all ABIs**:

```
android.permission.INTERNET
android.permission.POST_NOTIFICATIONS
android.permission.ACCESS_NETWORK_STATE
android.permission.WAKE_LOCK
com.google.android.c2dm.permission.RECEIVE
com.laqta.laqta.DYNAMIC_RECEIVER_NOT_EXPORTED_PERMISSION   (app-defined, signature-protected, protectionLevel=0x2/signature)
```

Assessment against expected profile (auth + FCM push + Stripe payments + booking app):

| Permission | Expected? | Rationale |
|---|---|---|
| `INTERNET` | Yes | Core requirement for any networked app. |
| `POST_NOTIFICATIONS` | Yes | Android 13+ runtime permission for FCM push notifications. |
| `ACCESS_NETWORK_STATE` | Yes | Standard, used by FCM/connectivity checks; minimal privacy impact. |
| `WAKE_LOCK` | Yes | Standard for FCM background message processing. |
| `com.google.android.c2dm.permission.RECEIVE` | Yes | Required to receive GCM/FCM broadcasts. |
| `com.laqta.laqta.DYNAMIC_RECEIVER_NOT_EXPORTED_PERMISSION` | Yes | Auto-generated by AGP/Firebase tooling to lock dynamically-registered (`Context.registerReceiver`) broadcast receivers to the app's own signature on API 26-32, per Android's dynamic-receiver export requirements. Standard boilerplate, not a custom/unusual permission. |

**No camera, location, contacts, SMS, call log, storage (legacy or `MANAGE_EXTERNAL_STORAGE`), accessibility,
`REQUEST_INSTALL_PACKAGES`, `SYSTEM_ALERT_WINDOW`, `BLUETOOTH`, `RECORD_AUDIO`, or `READ_PHONE_STATE`
permissions were found.** This is a notably **minimal and well-scoped** permission set — narrower than
many comparable apps. Camera/gallery image picking is handled by `io.flutter.plugins.imagepicker.ImagePickerFileProvider`
via the Android Photo Picker / system camera intent (no `CAMERA` or storage permission declared, consistent
with using the scoped, permissionless Android Photo Picker API on modern Android versions).

**Verdict: INFO / no findings.** Permission set is appropriate and minimal for the app's stated purpose.
No broad or unusual permissions requested. This is a positive finding, not a gap.

---

## 4. Intent filter overlap / hijacking analysis

Checked all `VIEW` + `BROWSABLE` intent filters across the merged manifest for scheme/host/path collisions
that could cause ambiguous resolution between two *app-controlled* exported activities:

| Scheme+host+path | Activity |
|---|---|
| `https://laqta.app` | `MainActivity` only |
| `laqta://*` | `MainActivity` only |
| `stripe-connect://*` | `StripeConnectDeepLinkInterceptorActivity` only |
| `stripe-auth://link-accounts/...`, `link-native-accounts/...`, `native-redirect/...` | `FinancialConnectionsSheetRedirectActivity` only |
| `stripe://auth-redirect/...` | `FinancialConnectionsSheetRedirectActivity` only |
| `stripe://financial-connections-lite/...` | `FinancialConnectionsSheetLiteRedirectActivity` only |
| `link-popup://complete/...` | `LinkRedirectHandlerActivity` only |
| `stripesdk://payment_return_url/...` | `StripeBrowserProxyReturnActivity` only |

**No two exported activities in this manifest share the same scheme+host+path combination.** Each
scheme is claimed by exactly one component. No intra-app intent-filter collision/ambiguity exists.

The only theoretical ambiguity is the standard Android OS-level one: a **different, malicious app**
could also register an intent filter for the bare custom scheme `laqta://` (custom schemes are
global and unprotected by App Links verification), and on devices where the user has multiple
apps claiming the same scheme, the OS will show a disambiguation chooser (or, in older/rooted/
modified OS behavior, a malicious app could attempt scheme squatting). This is a generic Android
custom-URI-scheme limitation, not a defect in this app's manifest, and is mitigated by:
(a) the primary/preferred channel being `https://laqta.app` App Links (verified, no chooser dialog
if verification succeeds), and (b) the app-level strict allowlisting in `deep_link_handler.dart`
described in section 2, which means even if a malicious actor tricks a user into installing a
scheme-squatting app, *the reverse* (malicious app's `laqta://` payloads landing in this app) is
bounded by the same strict validator. Rated **LOW / INFO**, not a manifest defect — inherent to
custom URI schemes industry-wide, already mitigated at the application layer.

**No path/host overlap found among Stripe-owned redirect activities either** — each uses a distinct
scheme or distinct host, and all path-scoped ones include the app's own package name
(`/com.laqta.laqta/...`) as a path prefix, which further reduces any cross-app collision risk for
multi-tenant Stripe integrations on the same device.

---

## Summary of findings

| # | Severity | Status | Finding |
|---|---|---|---|
| 1 | INFO | RE-CONFIRMATION | `allowBackup=false`, `usesCleartextTraffic=false`, `networkSecurityConfig` present — confirmed in xmltree (lines 65-69). |
| 2 | INFO | RE-CONFIRMATION | `FlutterFirebaseMessagingReceiver` exported + `c2dm.permission.SEND`-gated — confirmed, correct, not flagged. |
| 3 | INFO | RE-CONFIRMATION | Stripe SDK exported redirect activities (5 found: `StripeConnectDeepLinkInterceptorActivity`, `FinancialConnectionsSheetRedirectActivity`, `LinkRedirectHandlerActivity`, `StripeBrowserProxyReturnActivity`, `FinancialConnectionsSheetLiteRedirectActivity`) — all required for off-app payment/3DS/bank redirects, not flagged. |
| 4 | INFO | NEW (same class as #2) | `FirebaseInstanceIdReceiver` also exported + `c2dm.permission.SEND`-gated — newly enumerated but same protection mechanism as the locked finding; no new risk. |
| 5 | LOW/INFO | NEW | `androidx.profileinstaller.ProfileInstallReceiver` exported + gated by signature\|privileged `android.permission.DUMP` — standard AndroidX library component present in virtually all Jetpack apps; not exploitable by third-party apps; no action needed. |
| 6 | MEDIUM | NEW (unverifiable from artifacts) | Cannot confirm from build artifacts whether `https://laqta.app/.well-known/assetlinks.json` is correctly published/verified server-side for App Links auto-verify; recommend confirming as a release checklist item. Not itself a vulnerability — failure mode is a disambiguation dialog, not a hijack. |
| 7 | LOW/INFO | NEW | Custom scheme `laqta://` is globally registrable by any app (inherent OS limitation of non-App-Links schemes); mitigated by strict app-side allowlist validation in `deep_link_handler.dart` (rejects query params, path traversal, unknown routes). |
| 8 | INFO | NEW (positive finding) | Permission set is minimal/well-scoped: only `INTERNET`, `POST_NOTIFICATIONS`, `ACCESS_NETWORK_STATE`, `WAKE_LOCK`, `c2dm.permission.RECEIVE`, and an app-signature-scoped dynamic-receiver permission. No camera/location/contacts/SMS/storage/install-packages/accessibility permissions present. |
| 9 | INFO | NEW | No intent-filter collisions found among the app's own exported activities or among Stripe SDK redirect activities — each scheme/host/path combination maps to exactly one component. |

**No CRITICAL or HIGH severity findings.** The manifest attack surface is well-controlled: minimal
exported surface, all exports justified by library/OS requirements or the app's own deep-link need,
minimal permission footprint, and defense-in-depth at the application layer for deep link handling.
