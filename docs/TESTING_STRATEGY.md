# LAQTA Testing Strategy

## Required Before Release

- Backend: `npm run prisma:validate`
- Backend: `npm run prisma:generate`
- Backend: `npx prisma migrate status`
- Backend: `npm test`
- Backend: `npm run build`
- Flutter: `flutter analyze --fatal-infos`
- Flutter: `flutter test`
- Flutter: `flutter build apk --flavor production --release --split-per-abi`
- Flutter: `flutter build appbundle --flavor production --release`

## Tests To Keep

- Auth, Twilio OTP, phone normalization, JWT/session, refresh rotation, logout/revoke.
- Media upload, media ownership, MIME/size validation.
- Security/RASP/network/signing/storage tests.
- Critical Flutter auth/session/widget tests.
- Backend API contract and route authorization tests.

## Tests To Remove Or Quarantine

- Vonage/Nexmo tests.
- Firebase Auth tests.
- Firestore fallback tests that assert runtime behavior.
- Temporary debug tests that depend on local device state.

## Manual Android QA

- Launch app from fresh install.
- Select Arabic.
- Send Twilio Verify SMS OTP to an Iraqi phone.
- Verify OTP and reach home.
- Upload avatar, portfolio image, story, reel video, and chat media.
- Send chat text message.
- Logout and verify secure storage/session cleanup.
- Reopen app and verify session state.

