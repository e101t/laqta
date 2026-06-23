# Final Gate — Direct AAB Manifest Verification via bundletool

Scope: closes the one outstanding gap noted in `audit_reports/12_release_consolidation.md`
— the AAB's manifest values (versionName, versionCode, minSdkVersion, targetSdkVersion,
permission set) were previously only INFERRED from the shared `android/app/build.gradle.kts`
config because `aapt2` cannot read an AAB's protobuf-format manifest directly. This pass
performs a direct, literal read of the AAB's actual `AndroidManifest.xml` using `bundletool`,
which was not available in any prior audit pass.

Read-only verification. No source/config files modified, no rebuild performed, no prior
audit artifact touched.

---

## 1. Tooling

`bundletool` was not present anywhere on the machine (`Get-ChildItem -Recurse -Filter
"bundletool*.jar"` → no matches). Downloaded the official release jar:

```
Invoke-WebRequest -Uri "https://github.com/google/bundletool/releases/download/1.17.2/bundletool-all-1.17.2.jar" -OutFile "$env:TEMP\bundletool.jar"
```

Confirmed valid (32,519,278 bytes):
```
$ java -jar bundletool.jar version
1.17.2
```

## 2. Direct manifest dump

```
java -jar bundletool.jar dump manifest --bundle="build\app\outputs\bundle\productionRelease\app-production-release.aab" --module=base
```

This printed the literal `AndroidManifest.xml` content from the AAB's `base` module — not
cross-referenced, not inferred. Full raw output captured in this session's transcript.

## 3. Field-by-field comparison against the already-verified APK values

| Field | AAB (direct read) | Expected (from `12_release_consolidation.md`, verified per-APK via `aapt2`) | Match |
|---|---|---|---|
| `versionName` | `1.0.0` | `1.0.0` | YES |
| `minSdkVersion` | `24` | `24` | YES |
| `targetSdkVersion` | `36` | `36` | YES |
| `versionCode` | `1` | n/a (APKs show 1001/2001/4001, per-ABI offsets) | YES — see note below |

**versionCode note:** The AAB's base-module versionCode is `1`, not 1001/2001/4001. This is
expected and correct, not a discrepancy: `pubspec.yaml` declares `version: 1.0.0+1` (build
number `1`), and Flutter's standard per-ABI split scheme computes each split APK's
versionCode as `abiOffset*1000 + baseVersionCode` (armeabi-v7a offset 1 → 1001, arm64-v8a
offset 2 → 2001, x86_64 offset 4 → 4001). `baseVersionCode = 1` is exactly the value the AAB
manifest shows, confirming the relationship that was previously only inferred is in fact
correct.

### Permission set — verbatim `<uses-permission>` entries found in the AAB manifest

```
android.permission.INTERNET
android.permission.POST_NOTIFICATIONS
android.permission.ACCESS_NETWORK_STATE
android.permission.WAKE_LOCK
com.google.android.c2dm.permission.RECEIVE
com.laqta.laqta.DYNAMIC_RECEIVER_NOT_EXPORTED_PERMISSION
```

Exactly 6 entries — matches the expected set exactly, no extra, no missing. (A separate
`<permission>` declaration, not `<uses-permission>`, also exists for
`DYNAMIC_RECEIVER_NOT_EXPORTED_PERMISSION` with `protectionLevel="0x00000002"` (signature) —
this is the app declaring its own custom permission so it can self-grant it; not an
additional granted permission, not a discrepancy.)

## 4. Secondary cross-check (Step 4) — skipped, non-blocking

```
java -jar bundletool.jar dump resources --bundle=... --module=base | Select-String "versionCode|versionName"
```

Errored: `InvalidCommandException: The module is unnecessary as the 'dump resources' by
default searches across all modules.` This is a command-syntax incompatibility with this
bundletool version's `dump resources` subcommand (it doesn't accept `--module`), not a
finding about the bundle itself. Per the task's own instructions this check is secondary
and skippable since the manifest dump (Section 2) is the authoritative source and was
already successfully captured.

## 5. Structural validation (Step 5, bonus)

```
java -jar bundletool.jar validate --bundle="build\app\outputs\bundle\productionRelease\app-production-release.aab"
```

Result: **PASS**. The command completed with exit code 0 and printed bundletool's normal
valid-bundle output (a full file/module inventory — assets, Stripe payment-sheet modules,
Apache Tika SPI/mime files present as expected per `audit_reports/06_dependencies.md`,
Kotlin metadata, etc.). No `ValidationException` or error was thrown. Note: this checks
bundle structure only, not the signing certificate — the signing certificate fingerprint
(`910329bb...cbc25200`) was already independently verified across the AAB and all 3 split
APKs in Phase 3 (`audit_reports/12_release_consolidation.md`) via `apksigner`/`openssl`.

---

## Final Conclusion

All AAB manifest values are now **directly verified** (literal protobuf manifest read via
`bundletool dump manifest`), not inferred from shared Gradle config. Every value matches
the already-verified per-APK values exactly:

- `versionName`: MATCH
- `minSdkVersion`: MATCH
- `targetSdkVersion`: MATCH
- Permission set: MATCH (exact set, no discrepancies)
- `versionCode`: explained and confirmed consistent (base value `1`, traceable to
  `pubspec.yaml`'s `1.0.0+1`, mathematically consistent with the per-ABI split codes)
- Bundle structural validation: PASS

**No new findings. No mismatches.** This closes the last open verification gap from the
12-agent audit. Release status remains: **READY FOR CLOSED TESTING.**
