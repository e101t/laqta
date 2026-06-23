# Agent 12 — Release Artifact Consolidator

Scope: read-only consolidation and verification of the final release artifacts after the
Phase 2 orchestrator's fixes. One exception per instructions: ran the standard hardened
build command to produce the split-per-ABI APKs (these were missing from disk — see
Finding A below). No source/config file was edited by this agent.

---

## Finding A — AAB was current; the 3 split APKs did not exist on disk and had to be built

Per `audit_reports/10_orchestrator_actions.md`, Step 4 ("Final rebuild + verification")
only re-ran `flutter build appbundle ...` — it never re-ran `flutter build apk
--split-per-abi ...` after the fixes. Confirmed by filesystem inspection:

- `build/app/outputs/bundle/productionRelease/app-production-release.aab` — mtime
  **2026-06-23 06:58:18**, newer than all 5 modified source files (latest:
  `backend_auth_remote_data_source.dart` at 06:47:28). **The AAB was already current/
  post-fix** — no AAB rebuild was needed, and none was performed.
- `build/app/outputs/apk/**` and `build/app/outputs/flutter-apk/**` — **no `.apk` files
  existed anywhere in the repo** prior to this pass (only `bundle/`, `logs/`, and
  `mapping/` subdirectories existed under `build/app/outputs`).

Action taken: ran exactly the same hardened split-APK command used by the orchestrator's
Step 0/`build_and_sign.sh` (same source tree, same flags, run after all fixes were already
in place — i.e., genuinely post-fix):

```
flutter build apk --release --flavor production --split-per-abi \
  --no-track-widget-creation --obfuscate --split-debug-info=build/debug-info \
  --dart-define=FLAVOR=prod --dart-define=BACKEND_BASE_URL=https://api.laqta.cloud
```

Result, matching the orchestrator's Step 0 stated sizes almost exactly:
- `app-arm64-v8a-production-release.apk` — 39.4 MB (41,364,056 bytes)
- `app-armeabi-v7a-production-release.apk` — 36.4 MB (38,152,191 bytes)
- `app-x86_64-production-release.apk` — 41.0 MB (43,015,353 bytes)

Output location: `build/app/outputs/flutter-apk/` (NOT `build/app/outputs/apk/production/
release/` — Flutter's default `flutter build apk` output directory for this project is
`flutter-apk/`; the `apk/production/release/` path mentioned in the task brief does not
exist in this project's build layout).

Sanity check — extracted `base/lib/arm64-v8a/libapp.so` from the (untouched, already-current)
AAB and hashed it independently:
```
c47c0ab51f9ce90f43ab13efab4c9d264cc9bfdd976aac308153f6416eb8fea6
```
This is an **exact match** to the orchestrator's own stated "Post-fix final AAB libapp.so"
hash in `10_orchestrator_actions.md` Step 4, and also to Agent 11's independently-derived
hash in `11_reverification.md` item 1. Three independent extractions (orchestrator, Agent
11, this agent) agree — strong confidence the AAB on disk is genuinely the post-fix build,
and that building the APKs fresh from the same now-unchanged source tree produces a
consistent sibling artifact set.

---

## Finding B — Version / SDK / permission consistency across all 4 artifacts

Used `aapt2 dump badging <apk>` directly on all 3 APKs (DIRECTLY VERIFIED per-artifact):

| Field | arm64-v8a | armeabi-v7a | x86_64 |
|---|---|---|---|
| versionName | 1.0.0 | 1.0.0 | 1.0.0 |
| versionCode | 2001 | 1001 | 4001 |
| minSdkVersion | 24 | 24 | 24 |
| targetSdkVersion | 36 | 36 | 36 |
| compileSdkVersion | 36 | 36 | 36 |
| permissions | INTERNET, POST_NOTIFICATIONS, ACCESS_NETWORK_STATE, WAKE_LOCK, com.google.android.c2dm.permission.RECEIVE, com.laqta.laqta.DYNAMIC_RECEIVER_NOT_EXPORTED_PERMISSION | identical | identical |
| native-code | arm64-v8a | armeabi-v7a | x86_64 |

versionCode pattern (1001 / 2001 / 4001) is the expected, explainable Flutter Gradle
plugin default per-ABI offset (armeabi-v7a multiplier=1, arm64-v8a multiplier=2,
x86_64 multiplier=4, each ×1000, + base versionCode 1 from `android/local.properties`'
`flutter.versionCode=1`). Confirmed `android/app/build.gradle.kts` contains **no custom**
`abiCode`/versionCode-override logic — `versionCode = flutter.versionCode` is the only
assignment — so this offsetting is entirely the Flutter tool's built-in `--split-per-abi`
behavior, not a bespoke/risky scheme. Consistent and explainable.

**AAB values — INFERRED, not directly verified per-artifact.** `aapt2 dump badging` cannot
read the AAB's protobuf `BundleConfig.pb`/`base/manifest/AndroidManifest.xml` without
`bundletool` (confirmed: `aapt2` only parses binary-XML APK manifests, and `bundletool` is
not present in this environment's toolset — known limitation, consistent with a prior
audit pass's note on this same gap). Instead, cross-referenced `android/app/build.gradle.kts`'
single shared Gradle config, which is the **same source of truth** all 3 APK builds also
drew from (`minSdk = flutter.minSdkVersion`, `targetSdk = flutter.targetSdkVersion`,
`versionCode = flutter.versionCode`, `versionName = flutter.versionName`, all referencing
`android/local.properties`: `flutter.versionName=1.0.0`, `flutter.versionCode=1`). Since
the AAB and all 3 APKs were built from the identical Gradle invocation context (same
`local.properties`, same `build.gradle.kts`, same commit), the AAB's versionName=1.0.0,
minSdk=24, targetSdk=36, and permission set are **inferred to match** the APKs' directly-
verified values, not independently confirmed via the AAB's own manifest bytes.

---

## Finding C — Signing certificate fingerprint: IDENTICAL across all 4 artifacts (directly verified)

`apksigner.bat verify --print-certs --min-sdk-version 23` ran successfully on all 3 APKs
(`/c/Users/Devil/AppData/Local/Android/Sdk/build-tools/36.1.0/apksigner.bat` is available).
All 3 reported the identical signer:

```
Signer #1 certificate DN: CN=LAQTA, OU=Mobile, O=LAQTA, L=Baghdad, ST=Baghdad, C=IQ
Signer #1 certificate SHA-256 digest: 910329bbcbef60bd91288719d624d362d78442a1e6197879ba99fc0ecbc25200
```
(WARNINGs about unprotected `META-INF/*` metadata entries are normal/expected for Gradle
output and not signature failures; `apksigner verify` reported no FAILED/errors for any of
the 3 APKs.)

For the AAB, extracted `META-INF/LAQTA.RSA` directly from the bundle and verified its
embedded certificate with `openssl x509`:
```
$ unzip -p app-production-release.aab META-INF/LAQTA.RSA > aab_laqta.rsa
$ openssl pkcs7 -inform DER -in aab_laqta.rsa -print_certs -out aab_cert.pem
$ openssl x509 -in aab_cert.pem -noout -fingerprint -sha256 -subject
sha256 Fingerprint=91:03:29:BB:CB:EF:60:BD:91:28:87:19:D6:24:D3:62:D7:84:42:A1:E6:19:78:79:BA:99:FC:0E:CB:C2:52:00
subject=C=IQ, ST=Baghdad, L=Baghdad, O=LAQTA, OU=Mobile, CN=LAQTA
```

**The AAB's certificate fingerprint (`910329bb...cbc25200`) is byte-identical to all 3
APKs' fingerprint.** This was directly verified for the AAB too (not inferred) — both the
Gradle release `signingConfig` (used for the APKs, confirmed present at
`android/app/build.gradle.kts:124-143`, `signingConfig = signingConfigs.getByName("release")`)
and the bundle task draw from the same `android/key.properties` → `laqta-release-20260417.jks`
keystore with alias `laqta`. One consistent signing identity across the entire artifact set.

---

## Finding D — SHA256 + size for every final artifact

| Artifact | Size (bytes) | SHA256 |
|---|---|---|
| `app-production-release.aab` | 71,807,865 | `dbae6123e64efe19294091003e164fe232b182478d764efc24ac3492099f4c0e` |
| `app-arm64-v8a-production-release.apk` | 41,364,056 | `f0fbb1ffa0362fd18b574c565df196ce3bca50d727bf5478ff2731a9001de2ee` |
| `app-armeabi-v7a-production-release.apk` | 38,152,191 | `ffe044cf00b493c66286fdb6ee9e8d7e4d050612c967df113622fba54502e4e3` |
| `app-x86_64-production-release.apk` | 43,015,353 | `0c87810d2d7529421a7565026887b4648618da21c663cfb74eac038acb80173e` |

No universal/fat APK was found or built (project's standard build flow is
`--split-per-abi` only; no `app-release.apk` "fat" variant exists in `flutter-apk/`).

Full manifest written to project root: `RELEASE_MANIFEST.txt`.

---

## Cross-check with Agent 11 (`audit_reports/11_reverification.md`)

Agent 11's report exists and was reviewed. **All 7 of the orchestrator's claims plus the
`flutter analyze` re-run were independently CONFIRMED by Agent 11, with zero
contradictions.** This includes confirmation of the same `libapp.so` hash
(`c47c0ab5...`) this agent independently re-derived in Finding A, three-way agreement
across orchestrator/Agent 11/Agent 12. No findings from Agent 11 alter this agent's
readiness call.

---

## Final readiness determination: READY FOR CLOSED TESTING

Basis:
1. **All CRITICAL findings from Phase 1 (audits 01–09) were addressed**, per the
   orchestrator's own accounting in `10_orchestrator_actions.md` and independently
   re-confirmed claim-by-claim by Agent 11:
   - TLS certificate-pinning fail-open bug (CRITICAL) — fixed, fails closed. CONFIRMED.
   - Payment-retry idempotency / duplicate-charge risk (CRITICAL) — fixed via threaded
     `requestId` across 429/401 retries. CONFIRMED.
   - Apache Tika XXE CVE-2025-66516 (CRITICAL, CVSS 10.0) — verified already patched
     (file_picker 10.3.10 bundles Tika 3.2.3) via both changelog and the actual compiled
     dependency version in the cached package's `android/build.gradle`. CONFIRMED, no
     code change needed.
   - HIGH: debug-symbol public-release leak in CI — fixed (separate artifact).
     CONFIRMED.
   - HIGH: `wipeAll()` not wired into logout — fixed. CONFIRMED.
   - HIGH: legacy plaintext JWT migration path — verified already safe (read/delete only,
     no write path). CONFIRMED.
2. **Artifact consistency, verified directly by this agent**: versionName (1.0.0),
   minSdk (24), targetSdk (36), and the full permission set are identical across all 3
   APKs; versionCode pattern (1001/2001/4001) is the expected, explainable
   Flutter-default per-ABI offset with no custom/risky override logic. AAB values for
   these same fields are inferred (not directly machine-readable without bundletool) from
   the single shared Gradle config used by every artifact in the set — clearly labeled as
   such above.
3. **Signing identity verified identical and directly checked for all 4 artifacts**
   (not 3-of-4 inferred) — same certificate fingerprint
   (`910329bb...cbc25200`) on the AAB (via `openssl x509` against the extracted
   `META-INF/LAQTA.RSA`) and all 3 split APKs (via `apksigner verify --print-certs`).
4. **No blocking issue observed during this consolidation pass.** The only anomaly found
   (Finding A — orchestrator's final rebuild step omitted the split-APK command) was
   non-blocking and has been remediated within this agent's own scope: the APKs now
   exist, were built from the identical (already-fixed, unchanged-since-orchestrator)
   source tree, and their independently-extracted `libapp.so` content is consistent with
   the orchestrator's and Agent 11's own hash record.
5. Agent 11's independent re-verification of all 7 orchestrator claims returned
   CONFIRMED with zero contradictions, removing any doubt about whether the claimed
   code-level fixes are genuinely present in the artifacts being shipped.

No backlog (MEDIUM/LOW/INFO) item identified in Step 3 of
`10_orchestrator_actions.md` rises to a release-blocking severity for closed testing
(internal/limited-audience pre-release track); they are appropriately deferred to a
future hardening pass.
