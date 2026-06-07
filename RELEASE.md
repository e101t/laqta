# LAQTA Android Release Process

## Required secrets

- `android/key.properties` must exist locally and must not be committed.
- The keystore referenced by `storeFile` must exist under `android/keystore/`.
- `STRIPE_PUBLISHABLE_KEY`, `GOOGLE_MAPS_API_KEY`, and backend URLs must be supplied through build-time defines or environment-specific release tooling.
- Never place Stripe secret keys, MinIO credentials, JWT secrets, or database credentials in Flutter code.

## Local verification

```bash
flutter clean
flutter pub get
flutter analyze --fatal-infos
flutter test
flutter build appbundle --release --obfuscate --split-debug-info=build/symbols
bash build_and_sign.sh
```

## Store artifact

Upload this artifact to Google Play:

```text
build/app/outputs/bundle/release/app-release.aab
```

## Sideload QA artifact

Use this artifact for final Android device smoke testing:

```text
build/app/outputs/flutter-apk/app-release-signed.apk
```

## Signature verification

```bash
apksigner verify --verbose build/app/outputs/flutter-apk/app-release-signed.apk
zipalign -c -v 4 build/app/outputs/flutter-apk/app-release-signed.apk
```

Expected APK signer output must include v1, v2, and v3 verification.
