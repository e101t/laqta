# Agent 1 — Build & Obfuscation Audit

Scope: current build artifacts on disk under `build/app/outputs/**`, plus
`build_and_sign.sh`, `android/app/build.gradle.kts`, `.github/workflows/release.yml`.
Baseline docs read first: `DART_OBFUSCATION_AB_VERIFICATION.md`,
`OBFUSCATED_AAB_FINAL_VERIFICATION.md` (both root of repo, byte-identical content).

## 0. Baseline-doc integrity issue (NEW, INFO)

Both `DART_OBFUSCATION_AB_VERIFICATION.md` and `OBFUSCATED_AAB_FINAL_VERIFICATION.md`
contain unresolved PowerShell template artifacts instead of rendered values, e.g.
line 25: `Final libapp.so SHA256 | $(@{final_aab_path=...}.libapp_sha256)` and line 28
`Final AAB SHA256 | $aabSha`. The report-generation script was never re-run to
interpolate its own output, so the "locked state" doc itself is not fully trustworthy
as a record — the only genuinely usable numeric values in it are the two "known bad"
hashes and the non-obfuscated baseline hash, which are written as literals (lines 22-24).
The "Final libapp.so SHA256" the doc claims to certify (`b4926fd0...`) cannot be
confirmed from the doc text alone since it's a broken template, not a verified report.

## 1. libapp.so hash / obfuscation verification

Commands:
```
unzip -o -j build/app/outputs/apk/production/release/app-production-<abi>-release.apk lib/<abi>/libapp.so
unzip -o -j build/app/outputs/bundle/productionRelease/app-production-release.aab base/lib/<abi>/libapp.so
sha256sum <extracted files>
```

Results:

| Source | ABI | SHA256 |
|---|---|---|
| APK (apk/production/release) | arm64-v8a | `1f2527bfdec9c8bedf54643a26c8d0043ef4b3458b13cf2198d865872ed2a2c6` |
| APK (apk/production/release) | armeabi-v7a | `3d73719afa9176cd77cc0a040bc8ae350f7fa839d42bf16103475ba1d07d6d60` |
| APK (apk/production/release) | x86_64 | `3194eb28347067332debc7e609006eb6e26057821fee542492f2b1fc028ec2e7` |
| AAB (`base/lib/.../libapp.so`) | arm64-v8a | `5706815d82d36e06479013865004d0dd92aedf25aa039b4b694a69b78530ae80` |
| AAB | armeabi-v7a | `df8cd63684982debd0424554ea174b0538f7694d70aee1d8cd875c8ee5e41915` |
| AAB | x86_64 | `6176d6400e558dd30b459847a550c8fc4eb0074ae78ee5ac0b963037f005ee0d` |

Doc-stated reference hashes (literal values from line 22-24 of both baseline docs):
- Non-obfuscated baseline: `6cfd8834d1b00d1d9c5f35d96ab8c144277cf2ec736dfa700c622b4ec92d9191`
- Known-bad #1: `9818c3a8b89135e2093a7abc3388da7f2c65278c01a8fc2854766f5772838b0` (63 hex chars — malformed/truncated in the doc itself, unusable as a comparison value)
- Known-bad #2: `5706815d82d36e06479013865004d0dd92aedf25aa039b4b694a69b78530ae80`

### CRITICAL / NEW — AAB's arm64-v8a libapp.so hash exactly matches the documented "known-bad #2" hash

`base/lib/arm64-v8a/libapp.so` inside the **current** `app-production-release.aab`
hashes to `5706815d82d36e06479013865004d0dd92aedf25aa039b4b694a69b78530ae80`, an exact
64-character match for "Known bad libapp.so SHA256 #2" cited in both baseline docs.
This directly contradicts the locked-state claim ("libapp.so hash differs from known-bad
hashes"). File size matches the doc's claimed final build (9,110,448 bytes) but content
hash differs from the doc's own claimed "Final libapp.so SHA256" (`b4926fd0...`) too —
i.e. the AAB currently sitting in `build/app/outputs/bundle/productionRelease/` is **not**
the same libapp.so that the verification docs describe, despite being the one file
present in the repo today. None of the 3 per-ABI APK libapp.so hashes match either the
AAB's or each other's hashes, and none match the doc's claimed "Final"/non-obfuscated
hashes — every one of the 4 build artifacts (AAB + 3 APKs) is a distinct, never-previously-
verified binary. **Treat this as an open contradiction of the locked state requiring
re-verification before any release**, not a confirmed pass. It is possible the "known-bad"
label is stale/over-broad (e.g. it may have been generated from an early non-obfuscated
test build whose hash simply collided in the historical record), but as written, the
current AAB fails the documented bad-hash check.

### NEW — Build-machine path string still embedded in libapp.so (all 4 artifacts)

Python ASCII string scan (`scan.py`, pattern `[\x20-\x7e]{6,}`) on every extracted
libapp.so (AAB arm64, APK arm64-v8a, APK armeabi-v7a, APK x86_64) found the identical
literal string in all 4:

```
file:///C:/Users/Devil/Desktop/la%20s/.dart_tool/flutter_build/dart_plugin_registrant.dart
```

This is the real on-disk path of this project (`C:\Users\Devil\Desktop\la s`, URL-encoded
space) and the actual machine username "Devil". It is the build-machine source path, not
a sanitized path. This directly contradicts the locked-state claim "no
`package:laqta/` source paths appear in strings" — that specific claim still holds
(`package:laqta` occurrence count is 0 in all 4 binaries, confirmed), but the
broader claim in the baseline doc ("C:\Users\Devil\Desktop paths: 1 -> 0", i.e. the doc's
own A/B table says this was eliminated in their verified build) is **not true of the
artifacts currently on disk** — the build that produced the current `build/app/outputs/**`
artifacts was run directly from this working directory, not from a sanitized copy as the
docs describe doing for their reference build. Severity: MEDIUM — it is a single
plugin-registrant file URI (a known low-sensitivity Flutter framework artifact: every
Flutter app embeds this path because `dart_plugin_registrant.dart` is generated at
`.dart_tool/flutter_build/` and referenced by a stack-trace/asset-resolution string), and
it does not reveal application source code or logic. But it does confirm the build was not
produced via the sanitized-path process the locked-state docs describe, and it does leak
the local username "Devil" and project folder name.

Other string-leak checks (all 4 libapp.so binaries, all PASS / re-confirmation of locked state):
- `package:laqta` occurrences: 0 in all 4 binaries.
- `.dart` string occurrences: 6 in all 4 binaries (all are framework paths:
  `package:flutter/src/services/platform_channel.dart`,
  `package:ffi/src/allocation.dart`,
  `package:flutter/src/services/message_codec.dart`,
  `package:firebase_messaging_platform_interface/.../method_channel_messaging.dart`,
  `package:flutter/src/dart_plugin_registrant.dart`, and the file URI above) — consistent
  with the locked-state note that "Flutter/Dart obfuscation does not encrypt all string
  literals; framework/plugin runtime strings remain expected."
- `/admin` literal occurrences: 0 in all 4 (matches doc's "0" for final build).
- `/booking` literal occurrences: 3 in all 4 (matches doc's "3" for final build, down
  from 21 in non-obfuscated baseline per doc).
- Total readable strings: 13,531 (AAB arm64) / 13,504 (APK arm64-v8a) / 13,335
  (armeabi-v7a) / 15,983 (x86_64) — all far below the doc's stated non-obfuscated
  baseline of 50,979 and in the same ballpark as the doc's "final obfuscated" figure of
  35,992 (different binary, so not an exact comparison, but consistent with obfuscation
  being active rather than absent).

**Net assessment on obfuscation itself: obfuscation does appear to be ACTIVE** (very low
string count vs. non-obfuscated baseline, zero `package:laqta` strings, zero Dart source
paths beyond framework boilerplate) — re-confirming that part of the locked state. But the
exact-hash match to "known-bad #2" for the AAB's arm64 libapp.so, and the embedded
build-machine path, are NEW findings that were not true of whatever binary the original
docs verified, and must be re-investigated (e.g. by hashing whatever binary the original
audit actually inspected to determine whether "known-bad #2" is itself a mislabeled
historical artifact, since label provenance could not be confirmed from the docs).

## 2. Debug-info (`--split-debug-info`) archival location

`build_and_sign.sh:65` and `.github/workflows/release.yml:52` both invoke:
```
--split-debug-info=build/debug-info
```
`build/debug-info` is a sibling of `build/app/outputs`, not nested inside it, so symbol
files are **not packaged into the APK/AAB itself** — confirmed no `.symbols` files exist
anywhere under `build/app/outputs` (`find build/app/outputs -iname "*.symbols"` → empty)
and no `.symbols` files exist anywhere under `build/` at all on the current disk state
(`find build -iname "*.symbols"` → empty; the dir doesn't currently exist on disk).

The actual symbol archives referenced by the verification docs live outside the repo
entirely, on the Desktop:
```
/c/Users/Devil/Desktop/LAQTA_closed_testing_release/debug-info/app.android-{arm,arm64,x64}.symbols
/c/Users/Devil/Desktop/LAQTA_hardening_pass/debug-info/...
/c/Users/Devil/Desktop/LAQTA_obfuscation_check/debug-info*/...
```
RE-CONFIRMATION of locked state: symbol files are not shipped inside the
APK/AAB and are stored outside `build/app/outputs`.

### HIGH — NEW: CI workflow ships `build/debug-info` in the same release artifact bundle as the AAB/APK

`.github/workflows/release.yml` lines 61-67:
```yaml
- uses: actions/upload-artifact@v4
  with:
    name: laqta-android-release
    path: |
      build/app/outputs/bundle/productionRelease/app-production-release.aab
      build/app/outputs/flutter-apk/app-release-signed.apk
      build/debug-info
```
and lines 69-82, the `github_release` job downloads this exact artifact bundle and
publishes its full contents (`release-artifacts/**`) to the GitHub Release via
`softprops/action-gh-release@v2`. This means the Dart debug-info / symbol maps that can
be used to de-symbolicate the obfuscated `libapp.so` (reversing much of the protection
obfuscation provides) are bundled into the same downloadable zip as the public release
binaries, and from there are attached directly to the GitHub Release — i.e., publicly or
semi-publicly distributed alongside the very build they can deobfuscate, rather than kept
in a separate restricted-access store (e.g. Play Console's own symbol upload, or a
private artifact bucket). This is a NEW finding — `build/debug-info` not being inside
`build/app/outputs` satisfies "not shipped inside the binary," but the CI pipeline as
written defeats the purpose by re-attaching it at the release-publishing step.
Recommendation: drop `build/debug-info` from the `upload-artifact`/release path, or
upload it to a separate, access-restricted artifact (not attached to the public GitHub
Release).

### LOW — NEW: signed-APK filename mismatch between `build_and_sign.sh` and the CI workflow

`build_and_sign.sh` lines 56-59 produce
`build/app/outputs/flutter-apk/app-${RELEASE_APK_ABI}-production-release-signed.apk`
(default ABI `arm64-v8a`, so actually
`app-arm64-v8a-production-release-signed.apk`), but `release.yml` line 66 looks for
`build/app/outputs/flutter-apk/app-release-signed.apk` (no ABI, no `-production-`
segment). These paths never match, so the signed APK silently fails to upload as part
of the release artifact (a glob/path bug, not a security leak, but it means the signed
APK referenced by the release pipeline doc/process does not actually get published —
worth fixing for release integrity, out of strict scope for obfuscation/build-leak
auditing but noted since it affects "what build outputs actually ship").

## 3. Build-machine paths / usernames in shipped binaries

### libapp.so (all 4 ABIs/sources)
See section 1 — `C:/Users/Devil/Desktop/la%20s/...` and the username `Devil` are present
in all 4 libapp.so binaries via the `dart_plugin_registrant.dart` file URI. This is a
**NEW** finding (contradicts the locked-state doc's specific claim that this path count
went from 1 to 0 in their verified build).

### DEX files (classes.dex, classes2.dex, classes3.dex, classes4.dex — extracted from `app-production-arm64-v8a-release.apk`)
Same python string-scan method run against all 4 DEX files:
- `package:laqta` occurrences: 0 in all 4.
- `.dart` string occurrences: 0 / 2 (`sentry.dart`, `sentry.dart.flutter`) / 2
  (jni plugin registration error-message strings referencing `.JniPlugin`/`.JniFlutterPlugin`,
  not `.dart` paths — these are Kotlin/Java plugin-registration log strings, false-positive
  matches on the literal substring "jni" not ".dart") / 0.
- `Devil` / `C:\Users` / `C:/Users` occurrences: **0 in all 4 DEX files.**

RE-CONFIRMATION of locked state for DEX: no build-machine paths or usernames found in
the DEX bytecode. The leak is confined to libapp.so's embedded `dart_plugin_registrant.dart`
file URI, not present in Java/Kotlin bytecode.

## 4. `--split-per-abi` and version consistency

Confirmed `--split-per-abi` was used: each APK contains exactly one ABI's native libs and
`aapt2 dump badging` reports a single `native-code` entry per APK:

```
$ aapt2 dump badging build/app/outputs/apk/production/release/app-production-arm64-v8a-release.apk
package: name='com.laqta.laqta' versionCode='2001' versionName='1.0.0' ... 
native-code: 'arm64-v8a'

$ aapt2 dump badging .../app-production-armeabi-v7a-release.apk
package: name='com.laqta.laqta' versionCode='1001' versionName='1.0.0' ...
native-code: 'armeabi-v7a'

$ aapt2 dump badging .../app-production-x86_64-release.apk
package: name='com.laqta.laqta' versionCode='4001' versionName='1.0.0' ...
native-code: 'x86_64'
```
Identical results for the equivalent files under `build/app/outputs/flutter-apk/`
(`app-<abi>-production-release.apk`).

`build/app/outputs/apk/production/release/output-metadata.json` independently confirms
the same versionCode/versionName triples (1001/2001/4001, all `versionName: "1.0.0"`),
consistent with Flutter's standard `--split-per-abi` auto-assigned ABI version-code
offsets (armeabi-v7a=+0 → base*1, arm64-v8a → base*2, x86_64 → base*4 relative to a
1000-multiplier scheme) — there is no custom abiVersionCode logic in
`android/app/build.gradle.kts` (confirmed by reading the file: `versionCode =
flutter.versionCode` at line 63, no per-ABI override), so this splitting is Flutter
tooling's default behavior, not bespoke/risky build logic.

`android/app/build.gradle.kts` line 63-64 confirms `versionCode`/`versionName` both come
from `flutter.versionCode` / `flutter.versionName` (resolved from
`--build-name`/`--build-number` at build invocation time, or `pubspec.yaml` version), so
all 3 APKs and the AAB necessarily share the same versionName and a consistently-derived
versionCode family.

AAB version values could not be directly read with `aapt2 dump badging` because the
AAB's `base/manifest/AndroidManifest.xml` is protobuf-encoded (`aapt2 dump badging`
expects a binary-XML APK manifest, not the AAB's protobuf `XmlNode` format, and errored
with "failed opening zip: Invalid file" when run against the raw extracted file without
bundletool). This is a tooling limitation (no `bundletool` available in this environment),
not a finding — version consistency for the AAB was inferred from `versionCode =
flutter.versionCode` being a single shared Gradle config value applied identically
across all variants/flavors, and is the same property used by all 3 split APKs.
**This one item (#4, AAB-specific version readout) is PARTIALLY VERIFIED** — confirmed by
build-config-logic inspection rather than direct AAB manifest binary readout. Recommend a
follow-up with `bundletool dump manifest --bundle=... ` if available, to directly confirm.

RE-CONFIRMATION of locked state (version consistency, split-per-abi usage):
PASS — versionName uniform at "1.0.0" across all 3 split APKs; versionCode follows
expected per-ABI offset pattern from a single source value; `--split-per-abi` confirmed
via single-ABI native-code in each APK.

## Summary table

| # | Finding | Status | Severity |
|---|---|---|---|
| 1 | Obfuscation appears active (low string count, 0 `package:laqta`, 0 `.dart` source paths beyond framework) | RE-CONFIRMATION | INFO |
| 2 | AAB arm64-v8a libapp.so SHA256 exactly matches documented "known-bad #2" hash | **NEW / CONTRADICTS LOCKED STATE** | CRITICAL |
| 3 | None of the 4 current libapp.so binaries (AAB + 3 APKs) match the doc's claimed "Final" hash or each other | NEW | HIGH |
| 4 | Build-machine path `C:/Users/Devil/Desktop/la%20s/...` + username `Devil` embedded in all 4 libapp.so binaries via `dart_plugin_registrant.dart` URI | **NEW / CONTRADICTS LOCKED STATE** | MEDIUM |
| 5 | DEX files contain no build-machine paths/usernames | RE-CONFIRMATION | INFO |
| 6 | Dart debug-info not packaged inside `build/app/outputs` on current disk state | RE-CONFIRMATION | INFO |
| 7 | CI workflow attaches `build/debug-info` to the same public GitHub Release as the AAB/APK | NEW | HIGH |
| 8 | Signed-APK filename mismatch between `build_and_sign.sh` output and `release.yml` upload path | NEW | LOW |
| 9 | `--split-per-abi` confirmed; versionName/versionCode consistent across all 3 APKs | RE-CONFIRMATION | INFO |
| 10 | Baseline verification docs contain unresolved template placeholders, reducing their evidentiary value | NEW | INFO |
| 11 | AAB version readout not directly confirmed (protobuf manifest, no bundletool) — inferred from Gradle config only | PARTIAL | INFO |

## Baseline-doc files referenced
- `C:\Users\Devil\Desktop\la s\DART_OBFUSCATION_AB_VERIFICATION.md`
- `C:\Users\Devil\Desktop\la s\OBFUSCATED_AAB_FINAL_VERIFICATION.md`

## Build/config files referenced
- `C:\Users\Devil\Desktop\la s\build_and_sign.sh` (lines 56-67)
- `C:\Users\Devil\Desktop\la s\android\app\build.gradle.kts` (lines 58-64)
- `C:\Users\Devil\Desktop\la s\.github\workflows\release.yml` (lines 46-67)

## Build artifacts inspected
- `build/app/outputs/bundle/productionRelease/app-production-release.aab`
- `build/app/outputs/apk/production/release/app-production-{arm64-v8a,armeabi-v7a,x86_64}-release.apk`
- `build/app/outputs/flutter-apk/app-{arm64-v8a,armeabi-v7a,x86_64}-production-release.apk`
- `build/app/outputs/apk/production/release/output-metadata.json`
