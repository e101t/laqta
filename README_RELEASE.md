# Release Guide (Non-UI)

This repo ships Flutter + Firebase. This guide focuses on secure, non-UI
release steps and Firebase deploys.

## Prerequisites
- Flutter (stable) + Dart SDK (matches `pubspec.yaml`).
- Firebase CLI (`firebase`) and FlutterFire CLI (`flutterfire`).
- Android SDK + Java 17 for Android releases.
- macOS + Xcode for iOS release builds.

## Secrets and Local Files (do not commit)
- `android/key.properties` (release keystore config).
- Android keystore file (`.jks`).
- `android/app/google-services.json`.
- `ios/Runner/GoogleService-Info.plist`.
- Any server keys (Stripe secret key, service accounts).

## Firebase Project Setup
1) Login and select project:
   - `firebase login`
   - `firebase use <project-id>`
2) Generate Firebase config (no secrets in git):
   - `flutterfire configure`
3) App Check:
   - Enable Play Integrity (Android) and DeviceCheck (iOS) in Firebase console.
   - Add debug tokens for local dev only.
   - Enforce App Check for Firestore + Storage before production.

## Admin Setup (Choose One)
Default in rules: **Option A (Custom Claims)**.

Option A: Custom Claims (default)
- Use Admin SDK to set `admin=true` for a user:
  - `admin.auth().setCustomUserClaims(uid, { admin: true })`

Option B: Admins Collection
- Create `admins/{uid}` in Firestore via Admin SDK/console.
- Switch `isAdmin()` in `firestore.rules` to `adminByDoc()`.

## Deploy Firebase Rules
- `firebase deploy --only firestore:rules,storage`
- If Firestore asks for indexes, create them and re-deploy.

## Android Release
1) Generate a keystore (example):
   - `keytool -genkeypair -v -keystore <path>.jks -keyalg RSA -keysize 2048 -validity 10000 -alias <alias>`
2) Create `android/key.properties` with your values.
3) Build:
   - `flutter pub get`
   - `flutter analyze`
   - `flutter build appbundle --release`
   - `flutter build apk --release` (optional)

Artifacts:
- `build/app/outputs/bundle/release/app-release.aab`
- `build/app/outputs/flutter-apk/app-release.apk`

## iOS Release (macOS only)
- `flutter build ios --release --no-codesign`
- Open `ios/Runner.xcworkspace` in Xcode for signing and archive.

Required Info.plist keys (user-visible strings):
- `NSCameraUsageDescription`
- `NSPhotoLibraryUsageDescription`
- `NSPhotoLibraryAddUsageDescription`

## Payments (Stripe)
- Create PaymentIntents on the LAQTA backend API.
- Never create or confirm PaymentIntents with secret keys on device.
- Update booking payment status server-side after Stripe webhooks succeed.

Backend setup:
1) Configure Stripe server credentials in the backend production environment.
2) Confirm webhook signing secret is configured on the backend.
3) Deploy/restart the backend API and verify payment endpoints.

App config (build-time):
- `--dart-define=ENABLE_PAYMENTS=true`
- `--dart-define=STRIPE_PUBLISHABLE_KEY=pk_live_...`

## Smoke Check
Use the release helper script:
- `tool/release_check.ps1`

## Notes
- Keep `firestore.rules` deployed with deny-by-default defaults.
- Review and update `AppConstants.stripePublishableKey` for production.
