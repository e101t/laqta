# LAQTA Legacy Code Policy

## Definition

Legacy code is code retained only for migration, audit, or historical cleanup. It must not be imported by the Flutter runtime or backend API runtime unless explicitly documented.

## Current Legacy Categories

- Firebase/Firestore/Storage migration tooling.
- Old Firebase rules/functions retained for historical reference.
- Old generated QA reports and screenshots are not legacy code and should not remain in the repository.

## Rules

- Runtime auth must use Twilio Verify SMS OTP and backend JWT sessions.
- Runtime storage must use backend media APIs and MinIO.
- Runtime notifications may use Firebase only for FCM.
- Legacy migration tools must be run manually, with production credentials provided out of band.
- Legacy tools must never introduce Firebase Auth, Firestore, Cloud Functions, or Firebase Storage back into production runtime.

## Recommended Follow-Up

- Backend Firebase media migration scripts are isolated under `scripts/legacy/`.
- Remove Flutter Firestore-named datasource files once compile-time references are proven unused or replaced by backend API datasources.
