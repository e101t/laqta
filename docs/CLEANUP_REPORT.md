# LAQTA Cleanup Report

Date: 2026-05-31

## Deleted Generated / QA Artifacts

- Removed root-level Android screenshots named `android_*.png`.
- Removed UIAutomator XML dumps named `android_*.xml`, `uidump*.xml`, `current*.xml`, `explore*.xml`, `venue*.xml`, and related final-state XML files.
- Removed temporary Flutter logs: `firebase-debug.log`, `firestore-debug.log`, `artifacts_mobile_run*.log`.
- Removed temporary helper file `pin_tmp.cs`.
- Removed Flutter generated folders `.dart_tool/` and `build/`.
- Removed backend generated folders `dist/`, `artifacts/`, and `runtime_logs/`.
- Removed backend local log `backend_server.log`.

## Kept

- Source code, tests, Prisma schema, Prisma migrations, seed files, legal docs, release docs, backup scripts, and production Docker files.
- Design references under `design_references/`.
- Firebase configuration files required for FCM are kept where needed.
- Local backend `.env` and `secrets/` are kept locally but ignored.

## Project Tree Notes

- No risky large-scale file moves were performed.
- Backend legacy media migration code is still under source control and documented as non-runtime legacy tooling.
- Flutter still contains legacy Firestore-named Dart files; package-level Firebase runtime dependencies are limited to FCM, but these files should be removed or quarantined in a separate focused migration pass if they are no longer compiled.

## Git Hygiene

- `.gitignore` was hardened in Flutter and backend projects.
- Mobile artifacts, logs, secret files, build outputs, QA dumps, and backup dumps are now ignored.

