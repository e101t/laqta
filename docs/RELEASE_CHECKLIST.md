# LAQTA Release Checklist

## Pre-Build

- Confirm production API is reachable.
- Confirm production database migrations are applied.
- Confirm Twilio Verify SMS sender/template is approved or sandbox test is intentional.
- Confirm MinIO is reachable and bucket exists.
- Confirm FCM service account is configured only for push notifications.
- Confirm Sentry DSN is configured.
- Confirm `.env` and secret files are ignored.

## Build

- `flutter pub get`
- `flutter analyze --fatal-infos`
- `flutter test`
- `flutter build apk --flavor production --release --split-per-abi`
- `flutter build appbundle --flavor production --release`
- Run backend tests and build.

## Security Scans

- Scan for Vonage/Nexmo references.
- Scan for Firebase Auth/Firestore/Functions/Storage runtime references.
- Scan for secrets and local endpoints.
- Verify backend Firebase Admin usage is FCM messaging only, except legacy migration tooling.

## Artifacts

- Store signed APK/AAB outside the source tree or in ignored release output.
- Store obfuscation debug symbols securely.
- Do not commit APK, AAB, keystore, symbols, or debug-info.

## Post-Release

- Monitor Sentry.
- Monitor API 5xx, auth failures, upload failures, and Twilio provider failures.
- Keep rollback tag and previous backend image available.

