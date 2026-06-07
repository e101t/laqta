# Firebase Remaining Usage

Firebase is allowed in LAQTA runtime only for push notifications.

## Kept

- `firebase_core`: initializes the default Firebase app required by FCM.
- `firebase_messaging`: generates FCM device tokens and receives foreground/background/terminated push notifications.
- Android `google-services` setup: required for FCM token generation.

## Removed From Auth Runtime

- Firebase Authentication is not used by Flutter auth flows.
- Firebase Phone Auth is not used.
- Firebase ID token exchange is not used.
- Startup routing uses backend JWT session state.

## Not Allowed For Runtime Source Of Truth

- Firebase Firestore is not the production source of truth.
- Firebase Storage is not used for media uploads.
- Firebase Functions are not used for auth or production business logic.
- Firebase Analytics and Crashlytics are not used; Sentry handles monitoring.

## Current Migration Note

Some legacy Firestore/Functions Dart files still exist in the mobile project and are tracked as a remaining blocker before declaring FCM-only completion. Backend runtime Firestore fallback has been removed; backend Firestore access remains only in legacy migration tooling.
