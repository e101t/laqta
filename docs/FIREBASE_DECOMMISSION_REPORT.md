# LAQTA Firebase Decommission Report

## Final Firebase Policy

Firebase is allowed only for Firebase Cloud Messaging.

Allowed Flutter packages:

- `firebase_core`
- `firebase_messaging`
- `firebase_core_platform_interface` as a transitive/platform interface dependency.

Allowed backend usage:

- `firebase-admin` messaging only through `admin.messaging()`.

Not allowed in runtime:

- Firebase legacy authentication
- Firestore
- Firebase Storage
- Cloud Functions client/runtime
- Firebase Analytics
- Firebase Crashlytics when Sentry is the selected monitor

## Flutter Runtime Status

The Flutter runtime scan shows only FCM-related imports:

- `lib/main.dart` initializes Firebase for FCM.
- `lib/features/notifications/data/fcm_service.dart` handles token and message routing.
- `lib/core/services/backend_notification_sync_service.dart` registers FCM tokens with the backend.
- `lib/core/services/notification_navigation_service.dart` routes notification payloads.
- `lib/features/notifications/presentation/widgets/in_app_notification_banner.dart` renders foreground notification UI.

No the legacy Firebase login plugin, `cloud_firestore`, `cloud_functions`, or `firebase_storage` package remains in `pubspec.yaml`.

## Firestore-Named Flutter Files

Remaining `firestore_*` Dart files are runtime-referenced compatibility/data-source files. They do not import `cloud_firestore`; they use the backend/legacy compatibility layer. They were not moved during this pass because moving them would break active imports.

Classification:

- A. Runtime referenced: all remaining `lib/**/firestore_*.dart`, `lib/core/security/secure_firestore.dart`, and `lib/core/utils/firestore_parsers.dart`.
- B. Dead legacy files: none proven in this pass.
- C. Documentation/examples: no Firestore example code found in runtime folders.

Required follow-up:

- Rename these files in a future non-release cleanup from `firestore_*` to `backend_*` or `legacy_store_*` after updating all imports and tests.
- Do not perform that rename during release hardening unless a build or scan fails.

## Backend Runtime Status

Backend runtime code keeps Firebase Admin only for FCM messaging. No runtime `admin.auth`, `verifyIdToken`, Firestore, or Firebase Storage usage was found under `backend/src`.

## Legacy Backend Scripts

Legacy migration tools were moved out of active script paths to:

- `C:\Users\Devil\Desktop\backend\archive\firebase_migration_completed\firebase-legacy-admin.ts`
- `C:\Users\Devil\Desktop\backend\archive\firebase_migration_completed\media-migration\`

They are not imported by `backend/src` runtime code. They are excluded from production Docker deployment by `.dockerignore` and the production Dockerfile does not copy them into the runtime image.

Reason retained in archive instead of deleting:

- They are useful for historical audit and rollback investigation.
- They are no longer part of runtime deployment.
- The final Docker runtime image excludes `archive/`.

Release decision impact:

- Not a runtime blocker because deployment excludes archived legacy scripts.
- Operational risk remains only if someone manually runs archive tools against production.

## Decommission Summary

Removed from runtime:

- Firebase legacy authentication
- Firestore
- Cloud Functions
- Firebase Storage

Remaining:

- Firebase Core and Messaging for FCM only.
- Firebase Admin messaging for backend push delivery only.
- Archived/non-runtime legacy migration tooling.
