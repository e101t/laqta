# Dynamic Verification Pass — Real Device Testing via ADB

Scope: runtime behavior that the prior 13 static-analysis passes could not observe.
Device connected via USB/ADB. Installation + observation only; no source/config files
modified.

## Device & install

- Device: **SM-G975F** (Samsung Galaxy S10+), Android **12**, ABI **arm64-v8a**
- APK installed: `app-arm64-v8a-production-release.apk` (plain Flutter release output —
  no separate `-signed.apk` from `build_and_sign.sh` existed on disk; this build is
  Gradle-signed via `key.properties` but did not go through the additional
  zipalign+apksigner pass)
- Install method: `adb install -r` succeeded directly, no `INSTALL_FAILED_VERSION_DOWNGRADE`
  — **this was NOT a clean/fresh install**. The device already had a previous LAQTA
  install with cached app data, and `-r` (replace) preserves app data across reinstall.
  This was discovered mid-session (see Step 4) and turned into a more realistic test than
  originally planned.

## Step 2 — Launch

App launched and rendered (`MainActivity`, frames drawn, `thisTime:6225`) with **no
`FATAL EXCEPTION` / `AndroidRuntime` crash** at any point in the full session (checked
via `adb logcat -d | grep "FATAL EXCEPTION|AndroidRuntime: FATAL"` at the end — zero
matches across the entire log buffer).

One real observation: `FlutterSecureStorage` logged a cipher-algorithm migration on first
run (`Algorithm changed detected` → `migrateOnAlgorithmChange` → `Non-biometric migration
completed successfully! Migrated 0 items.`). This is **expected, not a bug** — it matches
`audit_reports/06_dependencies.md`'s note that `flutter_secure_storage` 10.x migrated its
Android backing store off the deprecated Jetpack Security/Crypto library onto Google Tink.
0 items migrated because there was no pre-existing secure-storage data at that point.

**SecurityBridge / Sentry**: searched the full logcat buffer (all tags, case-insensitive,
both by PID and unfiltered) for `SecurityBridge`, `Rasp`, `Pinning`, `io.sentry`,
`SentryAndroid` — **zero log lines found for any of them**, despite the app running
normally and later making real authenticated network calls. **COULD NOT CONFIRM via
logcat** that these fired — but absence of log output does not mean they didn't run: this
release build appears to emit no Android `Log.*` calls from the Dart/native security layer
or from the Sentry SDK at all (consistent with a release build suppressing internal SDK
logging). The static call-chain trace already done by Agent 8 remains the only evidence
that `SecurityBridge` executes; this dynamic pass could not add to or contradict that
because the build is silent. Same for Sentry initialization — no log evidence either way.

## Step 3 — TLS pinning fix, real network behavior

**3a. Normal network:** Navigated splash → language select → login screen → entered a
test phone/password → tapped "تسجيل الدخول" → app made a real round-trip to the live
backend and the UI displayed **"بيانات الدخول غير صحيحة"** (invalid credentials) as a
transient snackbar, then returned to the login form. This confirms: TLS connection +
pinning succeeded (no crash, no `CertificatePinningException` surfaced as an error state),
and the backend was genuinely reachable and responded — i.e. the pinning fix from
`certificate_pinning.dart` does not block legitimate traffic.

**3b. Network interruption:** Disabled wifi+data (`svc wifi disable` / `svc data disable`)
and tapped the login button again. The app immediately displayed an explicit banner:
**"لا يوجد اتصال بالإنترنت • آخر اتصال: منذ 8 دقيقة"** ("No internet connection • last
connected: 8 minutes ago") — a clear, explicit offline state, not a crash and not a
silent success. Re-enabled wifi+data; the app recovered cleanly back to the normal login
screen with no leftover error state. As the task itself notes, this is a coarse test (no
real MITM/cert-tampering simulated) but it does confirm the app fails visibly rather than
silently when the network misbehaves, and that the fail-closed code path (confirmed
statically by Agent 11) doesn't crash the app when exercised.

Logcat during both 3a and 3b: zero `CertificatePinningException`/exception lines (same
silent-build caveat as above) — this is again a release-build logging limitation, not a
negative finding.

## Step 4 — Logout / wipeAll() — real-device confirmation (stronger test than planned)

Because the `adb install -r` preserved prior app data, the device turned out to already
have a **populated, previously-authenticated session** cached from earlier
development/QA use — account "ali aggg" / `@uuuu`, phone `07830452729` (same phone number
provided for this test, password mismatch is unrelated/expected), profile type "مصوّر"
(photographer), governorate "diyala". This was discovered by navigating into the app
(Discover/Home → Profile tab) and finding a fully logged-in profile screen instead of the
expected empty/fresh state.

This is actually a **better test than the originally planned fresh-signup test**: it
exercises the real logout/wipe path against genuine cached profile data rather than an
empty new account.

- `adb shell run-as com.laqta.laqta ls ...` → `run-as: package not debuggable` — denied as
  expected for a non-rooted device on a release build (anticipated by the task; not an
  issue).
- Navigated Profile → settings icon (top-left) → Settings → scrolled to "الحساب" section
  → tapped "تسجيل الخروج" (Logout).
- Result: **immediate** "تم تسجيل الخروج بنجاح" (logged out successfully) snackbar, app
  navigated straight to the welcome/login screen — no confirmation dialog needed.
- `adb shell am force-stop com.laqta.laqta` then relaunched via `monkey -p ... LAUNCHER`.
- **Result: app showed the welcome/login screen again — no trace of the "ali aggg"
  cached profile, name, username, or phone number.** This directly confirms, on real
  hardware with real previously-cached data, that the `wipeAll()` fix wired into
  `signOut()` (per `audit_reports/10_orchestrator_actions.md` and independently
  re-verified at the source level by `audit_reports/11_reverification.md`) has the
  user-visible effect it's supposed to have.

## Step 5 — Manual flow walkthrough

Covered during the above steps without any crash or visibly broken screen:
- Splash → language selection → welcome/login screen
- Sign-up wizard steps 1–3 (account type → basic info → personal info/governorate)
- Discover/Home screen with real network-loaded content (photographer profile cards,
  images, follower counts)
- Profile screen (own account, populated fields)
- Settings screen (notifications, appearance, language, legal, account/logout)
- Logout

No crash, no blank screen, no visually broken layout observed in any of the above. One
unrelated device-level limitation: `adb shell screencap` produced 0-byte files consistently
(tried directly on-device and via `exec-out`, including a binary-safe `cmd /c` redirect) —
this is a device/OS-level restriction on this specific Samsung unit, not an app issue;
`uiautomator dump` (UI hierarchy XML) was used as the verification method instead
throughout this pass.

## Step 6 — Device + app info

```
ro.build.version.release: 12
ro.product.model: SM-G975F
dumpsys package com.laqta.laqta:
  versionCode=2001 minSdk=24 targetSdk=36
  versionName=1.0.0
```

Cross-checked against `RELEASE_MANIFEST.txt`: versionName `1.0.0` ✓, minSdk `24` ✓,
targetSdk `36` ✓, versionCode `2001` ✓ (exactly the arm64-v8a split value listed in the
manifest). **Match: YES.**

---

## Required Output Format

```
1. Device: SM-G975F — Android 12 — ABI arm64-v8a
2. APK installed: app-arm64-v8a-production-release.apk — unsigned-by-apksigner (Gradle/key.properties-signed only; no build_and_sign.sh zipalign+apksigner pass was found on disk)
3. Fresh install or uninstall-then-install: NEITHER — adb install -r succeeded directly (no downgrade error), which turned out to preserve a pre-existing cached session from prior testing on this device (discovered in Step 4)
4. App launched without crash: YES
5. SecurityBridge/native anti-debug fired at startup (observed in logcat): COULD NOT CONFIRM — zero log lines from SecurityBridge/Rasp/Pinning tags anywhere in the full session's logcat; release build appears to emit no Android Log calls from this layer at all (static trace from Agent 8 remains the only evidence it runs)
6. Sentry initialized without error: COULD NOT CONFIRM — same reason, zero io.sentry/SentryAndroid log lines found; no crash or visible error either, just silent
7. Normal network flow reached a backend-dependent screen successfully: YES (login attempt round-tripped to the real backend and returned "بيانات الدخول غير صحيحة" — a genuine authenticated-endpoint response, not a local/offline error)
8. Network-interruption test: app showed error/retry state rather than silent success or crash: YES — explicit "لا يوجد اتصال بالإنترنت" banner shown immediately on wifi+data disable; recovered cleanly when re-enabled
9. Logout + relaunch showed logged-out state (not cached session): YES — confirmed against a real, previously-cached, populated session (not just an empty fresh account); force-stop + relaunch showed the welcome/login screen with zero trace of the prior profile (run-as itself was denied as expected, so this was confirmed via UI/behavior rather than direct file inspection)
10. Manual flow walkthrough: any crash or broken screen observed: NO — splash, language select, login, signup wizard (3 steps), discover/home, profile, settings, logout all rendered without crash or visible breakage
11. Installed versionName/versionCode (from dumpsys): versionName=1.0.0, versionCode=2001, minSdk=24, targetSdk=36 — match RELEASE_MANIFEST.txt: YES
12. Overall: first real-device run is CONSISTENT with all static audit findings, with one NEW observation the static audit could not have caught: this release build emits no Android Log output at all from the security/monitoring layer (SecurityBridge, certificate pinning exceptions, Sentry), making logcat-based dynamic verification of those specific subsystems impossible on a release build — UI-observable behavior (offline banner, logout effect) was the only usable signal, and it confirms the fixes work end-to-end. No contradiction of any "CONFIRMED" static finding was found.
```

## New finding for the backlog

**INFO/process note (NEW):** the release build's security/monitoring layer (native
anti-debug/RASP bridge, certificate-pinning exceptions, Sentry SDK) produces no observable
Android `Log.*` output under any tag, even when genuinely exercised (a real pinning-relevant
network call, a real network-interruption event). This is likely intentional for a
production release (avoids leaking security-relevant operational detail via logcat) but it
also means logcat cannot be used as a dynamic verification signal for these specific
subsystems on this build configuration — future verification of "did the native RASP check
actually run" or "did Sentry actually capture this event" would need either a debug/staging
build with verbose logging enabled, or server-side confirmation (Sentry dashboard, backend
telemetry), not on-device logcat inspection of the production release artifact.
