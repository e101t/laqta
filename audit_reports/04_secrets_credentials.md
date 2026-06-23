# Agent 4 — Secrets & Credentials Audit

**Target:** `build/app/outputs/apk/production/release/app-production-arm64-v8a-release.apk` (production release APK)
**Method:** APK extracted via `unzip` to a temp working dir; all 4 `classes*.dex` files, all `lib/arm64-v8a/lib*.so` libraries (including `libapp.so`, the compiled Dart/Flutter app code containing all Dart string constants), `resources.arsc`, and `assets/` (including `assets/flutter_assets/`) were scanned byte-for-byte with a Python ASCII-string/regex extractor for the following patterns: `AIza...` (Google API key), `sk_live_`/`sk_test_` (Stripe secret key), `pk_live_`/`pk_test_` (Stripe publishable key), `AKIA...` (AWS key), PEM/PKCS private key headers, JWT-shaped strings, Firebase server-key-shaped strings, Supabase/Firebase RTDB URLs, and generic `api_key=`/`secret=`/`password=`/`token=` literal assignments.

## Summary of Findings

| # | Finding | Rating | Status |
|---|---------|--------|--------|
| 1 | Firebase Android `google_api_key` hardcoded in `libapp.so` / `resources.arsc` | INFO | NEW (expected client-visible) |
| 2 | Google Maps Platform API key hardcoded in `resources.arsc` (via `AndroidManifest.xml` meta-data) | LOW | NEW (expected client-visible, restriction posture unverified) |
| 3 | No Stripe secret key (`sk_live_`/`sk_test_`) found anywhere in APK | — | RE-CONFIRMATION of locked Stripe-bridge claim |
| 4 | No private key material (`BEGIN PRIVATE KEY`/`BEGIN RSA PRIVATE KEY`) found anywhere in APK | INFO | NEW |
| 5 | No AWS keys, JWTs, service-account tokens, Supabase/Firebase-RTDB URLs, or generic password/secret literals found | INFO | NEW |
| 6 | DEX files (`classes.dex` – `classes4.dex`) contain no flagged secrets | INFO | NEW |
| 7 | Native `.so` libraries (Flutter engine, Sentry, image pipeline, security lib, etc.) contain no flagged secrets | INFO | NEW |
| 8 | `assets/ds-*.pem` / `ds-*.crt` / `ds-*.cer` are Stripe's public CA certificates for card-network 3DS pinning — not secrets | INFO | NEW |

---

## Detailed Findings

### Finding 1 — Firebase `google_api_key` (Android) hardcoded — INFO / expected-client-visible

- **Location 1:** `lib/arm64-v8a/libapp.so`, offset ~463387 (compiled Dart string pool), value truncated: `AIza...dCIY`
- **Location 2:** `resources.arsc`, offset ~140925, value truncated: `AIza...dCIY`
- **Source in repo:** `lib/firebase_options.dart` line 37 (`FirebaseOptions.apiKey` for Android), and mirrored into `android/app/google-services.json`, `android/app/src/development/google-services.json`, `android/app/src/staging/google-services.json`, and generated Android resource `google_api_key` / `google_crash_reporting_api_key` strings.
- **Classification:** Expected client-visible. This is the standard Firebase Android "API key" that ships in every Firebase Android app via `google-services.json` / `FirebaseOptions`. It is not a secret in the traditional sense — Google's documented security model for this key is restriction by Android package name + SHA-1/SHA-256 app-signing certificate fingerprint (configured in Google Cloud Console → API key restrictions), not confidentiality. It cannot be used to access Firestore/RTDB/Storage directly (those are gated by Firebase Security Rules and Auth), and Cloud Messaging send operations require a separate server key/service-account, not this key.
- **Action recommended:** Verify in Google Cloud Console that this key has **Application restrictions = Android apps** scoped to the LAQTA package name + release signing cert SHA-1, and **API restrictions** limited to the specific Firebase/Google APIs actually used (Firebase Installations, Cloud Messaging registration, Identity Toolkit if Firebase Auth is used, etc.). If the key is currently unrestricted, that is a configuration gap (not a code-level secret leak) — recommend tightening it, but this is standard hygiene, not a "ship-stopper."

### Finding 2 — Google Maps Platform API key hardcoded — LOW / expected-client-visible, verify restrictions

- **Location:** `resources.arsc`, offset ~140967, immediately adjacent to Finding 1's key in the string pool — value truncated: `AIza...mGSs`
- **Source in repo:** `android/local.properties` (`googleMapsApiKey=...`), injected via Gradle into `android/app/src/main/AndroidManifest.xml` as `<meta-data android:name="com.google.android.geo.API_KEY" android:value="@string/google_maps_key" />`.
- **Classification:** Expected client-visible — this is the conventional way to ship a Google Maps SDK key on Android (it must be readable by the Maps SDK at runtime, so it cannot be kept server-side). The standard mitigation is **API key restriction** in Google Cloud Console: restrict by Android app (package name + SHA-1 cert fingerprint) and restrict the API surface to only "Maps SDK for Android" (and Places/Directions if actually used).
- **Action recommended:** Confirm this key is restricted to the app's package name/cert fingerprint and to only the specific Maps APIs in use. If it is also reused for server-side calls (e.g., a backend Directions/Places API call), it should be split into a separate, IP-restricted server key — could not verify backend usage from the APK alone. No code change required if restrictions are already correctly configured at the Google Cloud project level.

### Finding 3 — Stripe secret key: NOT FOUND — RE-CONFIRMATION

Exhaustive regex scan for `sk_live_[A-Za-z0-9]+` and `sk_test_[A-Za-z0-9]+` across all DEX files, all `.so` libraries (including `libapp.so`), `resources.arsc`, and all asset files returned **zero matches**. This re-confirms the locked finding that the Stripe WebView bridge does not expose a secret key client-side — no `sk_live_`/`sk_test_` value exists anywhere in the shipped production APK. Only the publishable-key pattern space was searched for separately; no `pk_live_`/`pk_test_` literal was found hardcoded either (consistent with the locked claim that the publishable key is fetched from the backend at runtime rather than embedded in the binary).

### Finding 4 — No private key material found — INFO

Scanned for `-----BEGIN PRIVATE KEY-----`, `-----BEGIN RSA PRIVATE KEY-----`, and generic `BEGIN...PRIVATE` patterns across all binaries and assets. Zero matches. The only PEM/CRT/CER files shipped (`assets/ds-amex.pem`, `assets/ds-cartesbancaires.pem`, `assets/ds-discover.cer`, `assets/ds-mastercard.crt`, `assets/ds-visa.crt`) were individually verified to contain `-----BEGIN CERTIFICATE-----` (public X.509 certs), not private keys. These are Stripe's standard card-network root/intermediate certificates used for 3-D Secure certificate pinning — normal and expected to ship client-side.

### Finding 5 — No AWS keys / JWTs / service-account tokens / DB URLs found — INFO

Regex scan for `AKIA[0-9A-Z]{12,20}` (AWS access key id), JWT-shaped triples (`eyJ...eyJ...`), `service_account`/`service-account`, `supabase`, and `firebaseio` (Firebase Realtime Database URL pattern) returned zero matches in any binary or asset.

### Finding 6 — DEX files clean — INFO

`classes.dex`, `classes2.dex`, `classes3.dex`, `classes4.dex` (Java/Kotlin-compiled Android code — Firebase SDK, Sentry SDK, Stripe Android SDK glue, AndroidX, etc.) were scanned with the full pattern set. No matches of any kind (the actual app business logic lives in `libapp.so` as compiled Dart AOT code, not in the DEX files, since this is a Flutter app — DEX only contains the Android platform/plugin glue code).

### Finding 7 — Native .so libraries clean — INFO

Scanned: `libandroidx.graphics.path.so`, `libapp.so`, `libdartjni.so`, `libdatastore_shared_counter.so`, `libflutter.so`, `libimagepipeline.so`, `libnative-filters.so`, `libnative-imagetranscoder.so`, `libsecurity.so`, `libsentry-android.so`, `libsentry.so`. Only `libapp.so` contained matches, and those were the two Google API keys covered in Findings 1–2, plus benign false-positive hits on repeated `AAAA...`/`A000...` character runs (font glyph/lookup tables, also reproduced identically in vanilla `libflutter.so`) that matched the loose `FIREBASE_SERVER_KEY`-shaped regex but are not real Firebase server keys (no realistic key has 60+ repeated identical characters) — verified as noise, not findings.

### Finding 8 — Bundled Stripe network certificates — INFO

`assets/ds-amex.pem`, `assets/ds-cartesbancaires.pem`, `assets/ds-discover.cer`, `assets/ds-mastercard.crt`, `assets/ds-visa.crt`, plus `assets/au_becs_bsb.json` (Stripe AU BECS bank-branch reference data) and `assets/PublicSuffixDatabase.list` (standard public suffix list, likely from an HTTP/cookie library) are all public, non-sensitive reference data bundled by the Stripe Android SDK and/or OkHttp. No action needed.

---

## Out-of-scope observation (not part of APK binary scope, informational only)

`android/local.properties` and `android/app/google-services.json` (+ `src/development` and `src/staging` variants) contain the same Maps/Firebase keys in plaintext in the source tree, but `git ls-files` confirms **none of these files are tracked in git** — they are local-only / gitignored, so there is no source-control leak. Mentioned for completeness only; does not change the APK-level findings above.

---

## Overall Assessment

No true secrets (Stripe secret keys, private signing keys, AWS credentials, backend service-account tokens, raw DB credentials) were found anywhere in the production release APK's DEX files, native libraries, `libapp.so` (compiled Dart code), `resources.arsc`, or asset bundle. The only embedded credentials are a Firebase Android API key and a Google Maps Platform API key, both of which are part of Google's standard "restrict by app identity, not by secrecy" model for client apps. Recommended follow-up is purely a cloud-console configuration check (confirm both keys are restricted to the app's package name + signing certificate and to the minimum required API scope) rather than a code or build change.
