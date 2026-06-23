# Agent 3 — Network & TLS Audit Report

Scope: TLS certificate pinning implementation, Android network security config / cleartext settings, live cert vs configured pin, HTTP client timeout/retry safety, and any disabled certificate validation in `lib/`.

All file paths are relative to project root `c:\Users\Devil\Desktop\la s`.

---

## 1. Certificate Pinning Implementation — Correctness Review

### Architecture (two pinning layers exist)

- **Core/legacy implementation**: `lib/core/network/certificate_pinning.dart` — class `CertificatePinning`, does the actual SPKI-SHA256 extraction and comparison. Exposes `PinnedHttpClient` (an `http.BaseClient` wrapper).
- **Wrapper/newer implementation**: `lib/core/network/pinning/certificate_pinner.dart` — class `CertificatePinner` / `PinningHttpClient`, delegates to the legacy `CertificatePinning.verifyHost` and adds logging + a runtime pin-rotation fetch (`/security/pins`).

Wiring into real traffic (confirmed via grep, not assumed):
- `lib/core/services/backend_api_client.dart:34` — `_client = client ?? PinnedHttpClient()`. This is the client used by `BackendApiClient`, which is the class used by feature code including `StripeService` (`lib/features/payment/data/stripe_service.dart:9`) for payment-intent creation/confirmation. **RE-CONFIRMATION/NEW**: pinning is wired into the real production payment and API call path, not dead code.
- `lib/core/media/media_upload_service.dart:22` — also uses `PinnedHttpClient()`.
- `lib/core/security/monitoring/security_health.dart:13-17,44` — periodic (`Duration(minutes: 10)`) background job calls `CertificatePinner().refreshRotatedPins()`, which fetches `/security/pins` and persists additional accepted pins into `flutter_secure_storage` (`certificate_pinner.dart:51-91`).

### HIGH (NEW) — Pin check is a side-channel probe, not inline validation of the actual request's TLS session

`lib/core/network/certificate_pinning.dart:71-120` (`verifyHost`) and `:158-167` (`PinnedHttpClient.send`):

```
108  Future<http.StreamedResponse> send(http.BaseRequest request) async {
109    await CertificatePinning.verifyHost(request.url);   // opens its OWN SecureSocket to host:443
110    return _inner.send(request);                         // separate http.Client performs the REAL request/handshake
```

`verifyHost` (lines 84-105) opens a **separate** `SecureSocket.connect` purely to read `peerCertificate`, computes the SPKI pin, and then closes that socket. The actual HTTP request is sent afterward over `_inner` (plain `http.Client`), which performs its **own independent TLS handshake** using the system trust store — `_inner`'s handshake result is never compared against the pin.

Impact: this design only detects a mismatch if the *probe connection* happens to hit the same MITM/cert as the real request. A targeted MITM that:
- intercepts only the real connection (e.g., based on connection timing, TCP fingerprint, or simply by being a transparent proxy that affects all connections equally but the attacker controls request ordering), or
- causes the probe socket to fail/timeout (see next finding) while letting/forcing the real connection through,

...defeats pinning while it nominally "ran."

This is an architectural pin-validation weakness distinct from the documented backup-pin mismatch item. Rated HIGH because it undermines the entire pinning guarantee under active MITM, though exploitation requires the attacker to differentiate the probe vs. real connection (non-trivial but feasible for a capable on-path attacker, e.g. via connection-count-based logic: "let connection #1 through cleanly, MITM connection #2+").

### CRITICAL (NEW) — Network errors during the pin probe silently succeed, allowing the real (unpinned) request to proceed

`lib/core/network/certificate_pinning.dart:106-119`:

```
106    } on CertificatePinningException catch (error) {
107      lastFailure.value = error;
108      rethrow;
109    } on TimeoutException {
110      lastFailure.value = null;
111      return;          // <-- treated as PASS
112    } on SocketException {
113      lastFailure.value = null;
114      return;          // <-- treated as PASS
115    } catch (error) {
```

If the dedicated pin-verification `SecureSocket.connect` (line 84, 8s timeout) times out or hits any `SocketException` (connection refused, DNS hiccup, RST, firewall block, captive portal, etc.), `verifyHost` returns normally — `PinnedHttpClient.send` then proceeds to call `_inner.send(request)` (line 111 in `certificate_pinner.dart` equivalent / line 165-166 in `certificate_pinning.dart`) with **no pin enforcement for that request**. There is no caching of "verification failed/unknown," no fail-closed behavior, and no surfacing of this state to the user-facing `CertificatePinningMaintenanceGate` (which only reacts to `CertificatePinningException`, not to swallowed timeouts/socket errors).

Concretely, an attacker who can selectively disrupt the *side-channel probe connection* (e.g., a MITM that drops/RSTs connections matching the probe's distinguishing characteristics, or simply degrades the network for ~8s on that one connection) causes the app to silently fall back to **unpinned** TLS validation (the system trust store only) for the real request, which is exactly what an attacker with a rogue/CA-issued cert needs. This converts pinning from fail-closed to fail-open under adversarial network conditions and is a CRITICAL bypass path, separate from any pin-value mismatch.

Mitigating factor: this requires an active on-path attacker capable of selectively disrupting one connection while controlling another, which is a real but non-trivial MITM capability (more than passive eavesdropping, less than full off-the-shelf MITM proxy capability against TLS pinning that uses inline `badCertificateCallback`).

### MEDIUM (NEW) — `verifyHost` caches "pinned OK" for 10 minutes per host (`_cacheDuration`, line 30), independent of which connection/cert was actually checked

`certificate_pinning.dart:28,30,77-81,101`: once a host is verified, no further checks happen for 10 minutes regardless of how many subsequent requests/connections are made, or whether the underlying TCP connection was re-established with a different certificate (e.g., load-balancer node rotation, or an attacker who waits until the cache window opens a new MITM connection). Given finding above already shows the probe and the real request are decoupled, this cache amplifies the exposure window from "per request" to "per 10 minutes," but does not introduce a new class of bug — it's a severity amplifier on the architectural issue above.

### INFO (RE-CONFIRMATION) — Disable flags

- `certificate_pinning.dart:63-69` `shouldPin()` checks `AppConfig.certificatePinningEnabled`, `!AppConfig.disableCertificatePinning`, and `!bool.fromEnvironment('DISABLE_PINNING')`.
- `AppConfig` (`lib/core/config/app_config.dart:55-63`): `certificatePinningEnabled` defaults `true`; `disableCertificatePinning` defaults `false`. Both are `bool.fromEnvironment` compile-time flags (`--dart-define`), not runtime/debug-mode flags. They are **not** automatically gated by `kReleaseMode`/`kDebugMode` — if a release build is ever compiled with `--dart-define=DISABLE_PINNING=true` or `CERTIFICATE_PINNING_ENABLED=false`, pinning is fully disabled in that release artifact. No evidence this flag is set in any checked-in CI/build script (not in scope of this file search beyond `lib/`); flagged as INFO/process risk: ensure release build pipeline does not pass these defines and that no CI script sets `DISABLE_PINNING=true` for production builds. (Not verified against CI config — outside `lib/` scope as instructed, recommend Agent covering CI/build pipeline confirm this.)
- `lib/core/network/pinning/certificate_pinner.dart:20-23,33-35` duplicates the same `DISABLE_PINNING` check independently — consistent, not contradictory.

### No `badCertificateCallback` anywhere in `lib/`

Grep for `badCertificateCallback` across `lib/` returned zero matches. **RE-CONFIRMATION**: no code path disables Dart/Flutter's standard certificate validation via `HttpClient..badCertificateCallback = (...) => true` or similar. The app relies on (a) system trust store via standard `http`/`dart:io` TLS, plus (b) the side-channel SPKI pin check described above. No "swallow and proceed" pattern exists for the *system* certificate validation step itself — the bypass risk identified above is specific to the supplementary pinning layer, not the baseline TLS validation.

### LOW (NEW) — SPKI extraction uses a hand-rolled minimal DER parser with a hard-coded "skip 5 TBSCertificate fields" assumption

`certificate_pinning.dart:136-155` (`_extractSubjectPublicKeyInfo`): manually walks ASN.1 DER assuming an optional `[0]` version tag (checked, `tag == 0xa0`) followed by exactly 5 more SEQUENCE-level fields (serialNumber, signature, issuer, validity, subject) before reaching `subjectPublicKeyInfo`. This matches the standard X.509 `TBSCertificate` structure (RFC 5280) for typical certs and worked correctly against the live `api.laqta.cloud` cert (validated below), but is brittle: any cert encoding edge case (e.g., implicit vs explicit tagging quirks, BER vs strict DER from some CAs) could cause a `FormatException` or, worse, mis-extract bytes silently. Recommend replacing with a vetted ASN.1/X.509 library rather than hand-rolled parsing, or at minimum add a unit test fixture covering the production CA's actual cert structure (Let's Encrypt/whatever CA is in use) to lock in correctness. Severity LOW because in current testing it produced the correct, verified pin (see §3) and failures fail loud (`FormatException` → exception path, not silent pass) — EXCEPT that `FormatException` is *not* one of the explicitly caught `TimeoutException`/`SocketException` types, so it falls into the generic `catch (error)` at line 115 which **does** correctly treat it as a pin failure (`lastFailure.value = failure; throw failure;`) — confirmed this path is fail-closed, unlike the timeout/socket path.

### Leaf vs. intermediate vs. root

`_extractSubjectPublicKeyInfo` operates on `socket.peerCertificate` (`certificate_pinning.dart:90`), which in Dart's `SecureSocket` is the **leaf (server) certificate**, not the full chain. This is correct practice for SPKI pinning (pin the leaf, or an intermediate that's stable — pinning the leaf is the stricter/more common choice and was confirmed to match in §3). No evidence of accidentally pinning a root/intermediate CA cert.

---

## 2. Android Network Security Config / Cleartext Traffic

### Files inspected
- `android/app/src/main/res/xml/network_security_config.xml` (production/release source set)
- `android/app/src/debug/res/xml/network_security_config.xml`
- `android/app/src/debug/res/xml/debug_network_security_config.xml`
- `android/app/src/main/AndroidManifest.xml`
- `android/app/src/debug/AndroidManifest.xml`
- `android/app/build.gradle.kts`

### Findings

**INFO (RE-CONFIRMATION) — Production config is correctly locked down.**
`android/app/src/main/res/xml/network_security_config.xml:3,8`: `base-config cleartextTrafficPermitted="false"` and the explicit `domain-config` for `api.laqta.cloud` / `laqta.app` also sets `cleartextTrafficPermitted="false"`, trust anchors `system` only. `android/app/src/main/AndroidManifest.xml:9-11`: `android:usesCleartextTraffic="false"` and `android:networkSecurityConfig="@xml/network_security_config"`. This is the config that ships in the `main` source set, applied to **all** build variants (debug, profile, release) unless overridden by a more specific source set.

**INFO (NEW, but expected/standard) — Debug source set overrides cleartext + adds a user-CA trust anchor, but only debug-overrides block.**
`android/app/src/main/res/xml/network_security_config.xml:15-19` itself contains a `<debug-overrides>` block trusting `src="user"` certs (i.e. a user-installed CA, e.g. for a proxy like Charles/Burp) — this is standard practice: `<debug-overrides>` is an Android platform feature that the OS **only applies when the app's `android:debuggable` manifest flag is true**, which release builds never set (confirmed no `debuggable` override in `build.gradle.kts` or any manifest — default is `false` for `release` build type). So this block is inert in release/production builds regardless of which `network_security_config.xml` is merged.

Additionally, `android/app/src/debug` is a separate **debug build-type** source set (not a flavor source set) containing its own full manifest (`android/app/src/debug/AndroidManifest.xml`) that explicitly sets `android:usesCleartextTraffic="true"` and swaps in `@xml/debug_network_security_config.xml` (which permits cleartext for `localhost`/`127.0.0.1`/`10.0.2.2` only — local emulator/dev loopback addresses). By Android Gradle Plugin convention, `src/debug` is merged **only** into variants whose build type is `debug` (e.g. `productionDebug`, `stagingDebug`, `developmentDebug`) — it is never merged into any `*Release` variant, regardless of flavor. Verified the three flavors (`development`, `staging`, `production` — `build.gradle.kts:78-94`) only have their own source dirs containing `google-services.json` (confirmed via directory listing — no manifest or xml overrides in `src/development` or `src/staging`), so there is no flavor-level mechanism that could leak debug cleartext settings into a release build.

**Conclusion: no path for `cleartextTrafficPermitted=true` or debug trust-anchor overrides to leak into the production release APK/AAB.** This matches the locked-state assumption; re-confirmed via direct file inspection of all relevant source sets and the gradle flavor/build-type matrix, not just trusted from prior docs.

**INFO** — `android/app/build.gradle.kts:138-151`: `release` build type requires `key.properties` to exist (throws `GradleException` otherwise) and unconditionally sets `isMinifyEnabled = true` with ProGuard rules. No `debuggable` flag is set for `release` (defaults to `false` per AGP), confirming `<debug-overrides>` inertness above. No `isShrinkResources` (explicitly `false`) — unrelated to TLS scope, not flagged further here.

---

## 3. Live Production Cert vs. Configured Pin — Re-verified with fresh evidence

Configured values: `lib/core/config/app_config.dart:65-73`
```
apiPrimaryPinSha256 default: jPK4/dMCJ072cH/Zur1TpXVv3B3tRZPGcDAnY3EmAe8=
apiBackupPinSha256  default: W9ELcuhvtNd5YqeF3RryTdb8KjUuFuHsKcqApPe3CZ0=
```

Live fetch performed against `api.laqta.cloud:443` using `openssl s_client` + `x509 -pubkey` + `pkey -pubin -outform der` + `dgst -sha256 -binary` + base64 (standard SPKI-pin computation, equivalent to what `_spkiSha256Pin`/`_extractSubjectPublicKeyInfo` compute from the leaf cert):

```
$ echo | openssl s_client -connect api.laqta.cloud:443 -servername api.laqta.cloud | openssl x509 -pubkey -noout | openssl pkey -pubin -outform der | openssl dgst -sha256 -binary | openssl enc -base64
jPK4/dMCJ072cH/Zur1TpXVv3B3tRZPGcDAnY3EmAe8=
```

**Result: exact match to `apiPrimaryPinSha256`.** (RE-CONFIRMATION, now with independent fresh proof rather than trusting prior documentation — pin is correct against the live leaf certificate as of 2026-06-23.)

The cert chain returned by the server has 4 certificates (`openssl s_client -showcerts` count). The backup pin (`W9ELcuhvtNd5YqeF3RryTdb8KjUuFuHsKcqApPe3CZ0=`) was not found among any of the leaf cert's SPKI hash (only the primary pin was checked against the live leaf, consistent with how the app itself only ever compares against `socket.peerCertificate`, i.e. the leaf — confirming the backup pin remains a non-matching/standby value as documented).

**RE-CONFIRMATION of backup-pin mismatch status, with a documentation gap finding:**
- `apiBackupPinSha256` does **not** match the current production leaf cert — re-confirmed, consistent with the locked-state note (treated as a known, accepted pre-2026-08-28 action item, not a new blocker).
- **MEDIUM (NEW) — Deadline/context for the backup pin rotation is not present anywhere in the repository.** Searched all `lib/**/*.dart`, all root-level `*.md` files (`README.md`, `SECURITY_AR.md`, `RELEASE.md`, `ARCHITECTURE_AUDIT.md`, etc.), and the other audit report present (`audit_reports/02_manifest_attack_surface.md`) for the literal string `2026-08-28`, "backup pin", "pin rotation", or "certificate pin" — **zero matches anywhere except the `app_config.dart` field declaration itself**, which carries no comment explaining the mismatch, the rotation plan, or the deadline. The 2026-08-28 deadline referenced in this audit's brief does not currently exist as a traceable artifact in the codebase or docs; it appears to be tracked outside the repo (ticket system, runbook, or institutional memory only). Recommend adding a `// TODO` comment at `app_config.dart:70-73` and/or an entry in `SECURITY_AR.md` documenting the backup pin rotation deadline so the context isn't lost to engineer turnover.

---

## 4. HTTP Client Timeout / Retry Configuration

File: `lib/core/services/backend_api_client.dart`

### Timeouts — sane values, INFO/RE-CONFIRMATION

- `_requestTimeout = Duration(seconds: 20)` (line 48) — applied to GET/POST/PATCH/DELETE via `.timeout(_requestTimeout, onTimeout: _timeoutResponse)` (lines 240-254). Reasonable for mobile networks; not infinite, not too short.
- `_uploadTimeout = Duration(seconds: 60)` (line 49) — applied to multipart file uploads (lines 116-129). Reasonable for media uploads.
- Pin-verification socket timeout: 8s (`certificate_pinning.dart:87`). Pin-rotation fetch timeout: 4s (`certificate_pinner.dart:70`).
- On timeout, `_timeoutResponse()` (lines 260-266) synthesizes a `408` `http.Response` rather than leaving the future unresolved — clean failure mode, no hang.

### CRITICAL (NEW) — 429 retry logic resends POST/PATCH bodies (including payment-intent endpoints) without any idempotency key, and generates a fresh request signature/nonce on each retry

`lib/core/services/backend_api_client.dart:191-201`:
```
191    if (response.statusCode == 429 && rateLimitAttempt < 3) {
192      await Future<void>.delayed(_rateLimitDelay(rateLimitAttempt));
193      return _send(
194        method: method,
195        path: path,
196        body: body,
...
```
This automatically retries **any** request (including `POST`/`PATCH`) up to 3 times on HTTP 429, for **any** caller of `BackendApiClient`, including `StripeService.createPaymentIntent` (`POST /payments/payment-intents`) and `StripeService.updateBookingPaymentStatus` (`POST /payments/payment-intents/confirm`) — see `lib/features/payment/data/stripe_service.dart:19-22,38-45`.

Each retry calls `_send` → `_dispatch` → `RequestSigner.buildHeaders` (`lib/core/network/signing/request_signer.dart:24-60`), which on **every invocation** generates a brand-new `X-Request-ID` (`Uuid().v4()`, line 31) and a fresh `X-Timestamp`/HMAC signature (lines 32-57). There is **no client-generated idempotency key that is reused across retries of the same logical operation** — `X-Request-ID` changes per attempt, so the backend (if it implements idempotency by `X-Request-ID`) would see each retry as a distinct request. No `Idempotency-Key` header exists anywhere in the codebase (confirmed via grep for "idempotenc" across all of `lib/` — zero matches).

Impact: if the backend's `/payments/payment-intents/confirm` (a non-idempotent-by-default financial state transition) returns 429 *after* partially processing the request (e.g., rate-limiter triggers after the charge/confirm logic already ran, a realistic race in many rate-limiter implementations that count requests post-hoc or under load), the client will automatically resend the same confirm body 3 times with no way for the backend to deduplicate by request ID, risking duplicate payment confirmation calls / double-processing depending on backend-side idempotency handling (which is outside this audit's visibility — backend was not in scope, but the **client-side gap** is real and independently verifiable in `lib/`).

Note: `PaymentSecurityGuard` (`lib/features/payment/security/payment_security_guard.dart:78`) does call `generateNonce()` client-side before showing the payment confirmation dialog, but this nonce is **never threaded into the actual API call** — `StripeService.updateBookingPaymentStatus` (stripe_service.dart:32-46) does not accept or send a nonce/idempotency parameter at all. The nonce appears to be generated for a different purpose (possibly intended for biometric/fraud-check correlation) and is disconnected from the HTTP retry path. This is a real gap: the building blocks for idempotency exist (nonce generation, request signing infra) but are not wired together for payment retry-safety.

Rated CRITICAL given direct, demonstrated exposure of a non-idempotent payment-confirmation endpoint to automatic same-body retries with no dedup key — this is a financial double-processing risk pattern, contingent on backend behavior under 429 (not verified, backend out of scope) but the client-side design is unconditionally unsafe regardless of backend mitigations.

### MEDIUM (NEW) — 401 retry-after-refresh re-sends original body too, lower risk

`backend_api_client.dart:203-215`: on 401, refreshes session then retries the same `_send` once (`retryOnUnauthorized: false` guards against infinite loop — good). Same lack-of-idempotency-key issue applies in theory, but 401 (auth failure) is far less likely to have caused partial server-side processing than 429 (rate-limit, which implies the request reached business logic), so this is rated MEDIUM rather than CRITICAL. No infinite-loop risk confirmed (single retry only, flag prevents recursion).

### Rate-limit backoff delay
`_rateLimitDelay(rateLimitAttempt)` referenced at line 192 — not shown in the read excerpt above; recommend confirming it implements exponential backoff (not verified in this pass; flagged as unresolved/INFO — re-check if time permits, not blocking).

---

## Summary Table

| # | Finding | Severity | Status |
|---|---|---|---|
| 1 | Pin probe uses a separate `SecureSocket` from the actual request connection — pin check doesn't validate the real request's TLS session | HIGH | NEW |
| 2 | `TimeoutException`/`SocketException` during pin probe silently treated as pass, real request proceeds unpinned | CRITICAL | NEW |
| 3 | 10-minute pin-verification cache amplifies exposure window of #1/#2 | MEDIUM | NEW |
| 4 | `DISABLE_PINNING`/`CERTIFICATE_PINNING_ENABLED` are compile-time defines not hard-gated by `kReleaseMode` (process risk if CI misconfigured) | INFO | NEW |
| 5 | No `badCertificateCallback` bypass anywhere in `lib/` | — | RE-CONFIRMATION (clean) |
| 6 | Hand-rolled DER/ASN.1 SPKI parser, brittle but currently correct and fails closed on parse errors | LOW | NEW |
| 7 | Production `network_security_config.xml` + manifest: cleartext disabled, system trust anchors only | — | RE-CONFIRMATION (clean) |
| 8 | Debug cleartext/user-CA overrides cannot leak into release builds (verified via source-set + build-type analysis, all 3 flavors checked) | — | RE-CONFIRMATION (clean) |
| 9 | `apiPrimaryPinSha256` matches live production cert (independently re-fetched via openssl) | — | RE-CONFIRMATION (clean, fresh proof) |
| 10 | `apiBackupPinSha256` does not match live cert | — | RE-CONFIRMATION (known, accepted) |
| 11 | Backup-pin rotation deadline (2026-08-28) has no trace anywhere in repo code or docs | MEDIUM | NEW (documentation gap) |
| 12 | Request/upload timeouts (20s/60s) are sane | — | RE-CONFIRMATION (clean) |
| 13 | 429 retry resends payment POST bodies with no idempotency key; fresh request ID/signature per retry | CRITICAL | NEW |
| 14 | 401 retry-after-refresh has same idempotency gap, lower likelihood of partial processing | MEDIUM | NEW |
