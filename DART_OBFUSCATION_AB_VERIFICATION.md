# DART OBFUSCATION A/B VERIFICATION
**Date:** 2026-06-30  
**Git HEAD:** `e2668d3` — Phase 5 cleanup (all Firestore stubs removed)  
**Auditor:** Claude Sonnet 4.6 (automated release audit)

---

## BUILD PARAMETERS

### A — Obfuscated (release candidate)
```
flutter build appbundle
  --flavor production
  --release
  --obfuscate
  --split-debug-info=C:\Users\Devil\Desktop\LAQTA_closed_testing_release\debug-info
  --dart-define=FLAVOR=prod
```

### B — Non-obfuscated (baseline for comparison only — not for distribution)
```
flutter build appbundle
  --flavor production
  --release
  --dart-define=FLAVOR=prod
```

---

## AAB COMPARISON

| Metric | Obfuscated (A) | Non-obfuscated (B) |
|---|---|---|
| AAB total size | 68.6 MB | 71.2 MB |
| libapp.so size (arm64-v8a) | 8.75 MB | 10.5 MB |
| Size delta | — | non-obf is 1.75 MB larger |

Obfuscated binary is smaller: symbol table entries replaced with short names reduces section sizes.

---

## libapp.so SHA256 COMPARISON

Extracted from `base/lib/arm64-v8a/libapp.so` inside each AAB.

| Build | SHA256 |
|---|---|
| A — Obfuscated | `E4C9BB4EB4291698C112E63CF4489629A680BE3D65F1BDA4252AEEB14A2EC1CD` |
| B — Non-obfuscated | `149F6D340F4CED681353E4F29F46567C864DDDFFA13BCEAB84DFED90898277F5` |

**Result: DIFFERENT — PASS**  
Hashes differ, confirming `--obfuscate` flag produced a transformed binary.

---

## SECURITY SCAN (obfuscated binary only)

| Pattern | Count | Result |
|---|---|---|
| `DebugProbesKt` | 0 | PASS — no Kotlin coroutine debug instrumentation |
| `sk_live_` (Stripe live secret) | 0 | PASS |
| `sk_test_` (Stripe test secret) | 0 | PASS |
| JWT-shaped strings (`eyJ` + ≥20 chars) | 0 | PASS |
| `minioadmin` / `MINIO_SECRET` / `AWS_SECRET` | 0 | PASS |
| `postgresql://` / `postgres://` | 0 | PASS |
| `com.laqta.laqta` | 1 | PASS — expected package name constant |
| `api.laqta.cloud` | 2 | INFO — hardcoded base URL in `BackendApiClient` (intended) |

No secrets or debug hooks found in the distribution binary.

---

## DEBUG SYMBOLS

Location: `C:\Users\Devil\Desktop\LAQTA_closed_testing_release\debug-info\`

| File | Size |
|---|---|
| `app.android-arm.symbols` | 4,622 KB |
| `app.android-arm64.symbols` | 5,356 KB |
| `app.android-x64.symbols` | 5,355 KB |

**Required for:** de-obfuscating crash stack traces in Firebase Crashlytics / Google Play Console.  
**Do NOT commit to git** — symbol files partially reverse obfuscation.  
**Archive permanently** alongside the AAB at the same version.

---

## SIGNING

| Property | Status |
|---|---|
| `android/key.properties` exists | YES — confirmed present, not printed |
| `key.properties` in git | NO — correctly excluded via `.gitignore` |
| Keystore referenced | Production keystore via `key.properties` → `build.gradle.kts` |

---

## RELEASE CANDIDATE ARTIFACT

| Field | Value |
|---|---|
| File | `app-production-release.aab` |
| Path | `C:\Users\Devil\Desktop\LAQTA_closed_testing_release\` |
| Size | 68.6 MB |
| SHA256 | `34EBC4F1B892932CC807AC41B6CEB0CC824502646C174471972DA859D78182EF` |
| Built | 2026-06-30 13:36:23 |
| Git commit | `e2668d3` |

---

## VERDICT

| Check | Result |
|---|---|
| Obfuscation active | PASS |
| libapp.so SHA256 differs from non-obf | PASS |
| DebugProbesKt absent | PASS |
| No secrets in binary | PASS |
| Debug symbols generated and stored | PASS |
| key.properties local only | PASS |
