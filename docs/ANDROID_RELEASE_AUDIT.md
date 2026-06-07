# LAQTA Android Release Audit

## Scope

Audited production Android release artifacts, source scans, and release configuration for pre-launch safety.

## Release Artifact Paths

Expected production outputs:

- APK split artifacts: `build/app/outputs/flutter-apk/app-*-production-release.apk`
- AAB artifact: `build/app/outputs/bundle/productionRelease/app-production-release.aab`

## Checks

| Check | Status | Notes |
|---|---|---|
| Production flavor build | Passed | `flutter build apk --flavor production --release --split-per-abi` and `flutter build appbundle --flavor production --release` succeeded. |
| Debug mode disabled | Passed | Release production Gradle tasks completed. |
| Firebase legacy authentication absent | Passing source scan | No the legacy Firebase login plugin runtime package/import expected. |
| Firestore runtime absent | Passing package scan | Firestore-named compatibility files remain but do not use `cloud_firestore`. |
| Cloud Functions runtime absent | Passing package scan | No `cloud_functions` package/import expected. |
| Firebase Storage absent | Passing package scan | No `firebase_storage` package/import expected. |
| FCM retained | Passing source scan | `firebase_core` and `firebase_messaging` remain. |
| Test OTP bypass absent | Passed source scan | No release OTP bypass path was found in runtime scans. |
| Mock API absent | Passed source scan | Production flavor does not select development backend defaults. |
| Localhost absent from release behavior | Passed with caveat | App production config does not select localhost. APK content scan shows third-party/static library strings (`Stripe SDK`, `libflutter`, public suffix data), not LAQTA API config. |
| VkLayer absent | Passed | APK content scan found zero `VkLayer` entries. |
| Signing | Passed for Android 7+ | `apksigner verify` passed on the arm64 production APK with v2/v3 signatures. v1 is false on this split APK; Google Play AAB upload is unaffected. |
| Zip alignment | Passed | `zipalign -c -v 4` returned `Verification successful` on the arm64 production APK. |

## Firebase Status

Allowed:

- FCM token generation.
- Foreground/background/terminated push handling.

Not allowed:

- Firebase legacy authenticationentication.
- Firestore.
- Firebase Storage.
- Cloud Functions.

## Release Notes

- Final release must be built from production flavor only.
- Debug symbol output under `build/debug-info/` must be stored securely and not committed.
- Google Play upload should use AAB.
- Direct QA installation can use split APKs or the final signed APK.

## Final Artifact Sizes

- `build/app/outputs/flutter-apk/app-armeabi-v7a-production-release.apk`: 37.3 MB
- `build/app/outputs/flutter-apk/app-arm64-v8a-production-release.apk`: 40.0 MB
- `build/app/outputs/flutter-apk/app-x86_64-production-release.apk`: 41.6 MB
- `build/app/outputs/bundle/productionRelease/app-production-release.aab`: 70.0 MB
