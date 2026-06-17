# LAQTA Post-Ready Hardening Report

Date: 2026-06-12

Status: Android remains ready for Google Play Closed Testing. Nothing in this report blocks closed testing unless a critical regression is found later.

## 1. Executive Summary

- Android closed testing status: continue.
- Flutter tests after this pass: 173/173 passing.
- Flutter coverage improved from 17.83% to 19.83% with real DTO tests.
- Backend validation passed: Prisma validate/generate/migrate status, tests 83/83, build.
- Production smoke passed: `/health` 200, `/ready` 200, `/users/me` 401 without token.
- Production admin no-token checks returned 401 for sampled admin routes.
- Safe production load smoke passed with 0 errors at low concurrency.
- npm audit still reports 8 moderate findings from `firebase-admin` transitive Google Cloud dependencies; no safe minor/patch fix is available.
- iOS is not release-ready and remains separate from Android closed testing.

## 2. Coverage Status

Before:

- Lines hit: 3736
- Lines found: 20958
- Coverage: 17.83%

After:

- Lines hit: 4156
- Lines found: 20958
- Coverage: 19.83%

Tests added:

- `test/features/chat/chat_dto_test.dart`
- `test/features/booking/booking_dto_test.dart`
- `test/features/marketplace/marketplace_dtos_test.dart`

Covered areas added:

- Chat preview DTO parsing and serialization.
- Chat message DTO media/document metadata.
- Booking nested payment/location/deliverables/timeline DTO behavior.
- Marketplace photographer, venue, feed, subscription, campaign DTO mapping.

Remaining low-coverage areas:

- Large presentation screens such as chat room, profile, booking details, photographer profile, requests, admin dashboards.
- Full UI state permutations.
- Role matrix UI assertions.
- End-to-end integration tests with authenticated API fixtures.

Coverage recommendation:

- Short-term 30% requires focused widget tests for the highest-use screens.
- Medium-term 50% requires repository/data-source mocking and authenticated flow fixtures.
- Long-term 80% requires integration tests and a device crawler harness.

## 3. npm Audit Status

Command:

```bash
npm audit --omit=dev
```

Current result:

- Moderate: 8
- High: 0
- Critical: 0

Affected chain:

- `firebase-admin@13.10.0`
- `@google-cloud/firestore@7.11.6`
- `google-gax@4.6.1`
- `@google-cloud/storage@7.19.0`
- `gaxios@6.7.1`
- `retry-request`
- `teeny-request`
- `uuid`

Runtime impact:

- `firebase-admin` is retained only for FCM messaging.
- Firestore/Auth/Storage runtime features are not used by LAQTA.
- The vulnerable transitive packages are pulled by the Firebase Admin SDK, not direct LAQTA app logic.

Fix availability:

- npm proposes `firebase-admin@14.0.0`, which is a semver-major update.
- No safe minor/patch update was available in the current dependency range.

Decision:

- Accepted risk for Closed Testing.
- Do not force major upgrade immediately before closed testing.

Future mitigation:

- Test `firebase-admin@14.x` on a branch after closed testing starts.
- If transitive findings persist or major upgrade risk is high, replace Firebase Admin SDK usage with a minimal direct FCM HTTP v1 client.

## 4. A-Z UI Crawler Result

Status: partial, not complete.

Verified manually in the current production APK session:

- Login with existing user password flow.
- Home.
- Notifications button and empty state.
- Chat list.
- Chat room.
- Message send.
- Profile.
- Portfolio display.
- Settings.
- Logout.
- Reopen after logout with Arabic language preserved.

Result:

- No FATAL EXCEPTION.
- No ANR.
- No E/flutter.

Not fully crawled:

- Registration OTP flow.
- Forgot/reset password OTP flow.
- Every menu item/dialog/bottom sheet.
- Admin sub-screens beyond smoke checks.
- Error-state forced paths.
- All role-specific screens.

Recommendation:

- Build a dedicated UI crawler or integration-test harness before public release.
- Do not block closed testing on this item because the main authenticated smoke path passed.

## 5. Role Matrix Result

Status: partial.

Production no-token API checks:

- `/api/v1/users/me` -> 401
- `/api/v1/admin/users` -> 401
- `/api/v1/admin/reports` -> 401
- `/api/v1/admin/moderation/reports` -> 401

Not completed:

- Guest vs customer vs photographer vs admin vs super_admin authenticated matrix.
- Direct route attempts for every role.
- Admin permission granularity tests with real tokens.

Required for completion:

- Dedicated test accounts for every role.
- Non-production/staging test data where possible.
- Scripted API matrix that stores only status codes, never tokens.

## 6. Load Test Result

Tool used:

- Node.js HTTPS inline script, no new dependency installed.

Scope:

- Production safe GET-only smoke.
- Endpoints: `/api/v1/health`, `/api/v1/ready`.
- Concurrency: 5.
- Duration: 30 seconds.
- Total requests: 2145.
- OK: 2145.
- Errors: 0.
- Error rate: 0.
- p50: 67 ms.
- p95: 85 ms.
- p99: 94 ms.

Verdict:

- Safe for Closed Testing on health/ready paths.
- This is not a full stress test of authenticated writes, chat, media, or database-heavy endpoints.

## 7. iOS Readiness Plan

Status: not ready, audit only.

Observed:

- `ios/Runner/Info.plist` exists.
- `ios/Runner/GoogleService-Info.plist` exists.
- Bundle identifier appears as `com.laqta.laqta`.
- Automatic code signing is configured in the Xcode project.

Missing or needs configuration:

- `ios/Runner/Runner.entitlements` is missing.
- `ios/Runner/PrivacyInfo.xcprivacy` is missing.
- `DEVELOPMENT_TEAM` was not found in the Xcode project scan.
- APNs/push notification entitlement not verified.
- App Store signing and archive not verified.
- iOS store assets not verified.

Recommendation:

- Keep iOS outside Android closed testing.
- Add entitlements, privacy manifest, Apple team ID, APNs configuration, and run an Xcode archive when iOS work is explicitly prioritized.

## 8. Bugs Found

- No new critical runtime bug was found during this pass.
- Coverage gap remains a quality risk, not a closed-testing blocker.
- npm audit moderate chain remains accepted risk for closed testing.

## 9. Bugs Fixed

- No production behavior was changed.
- Added meaningful test coverage for DTO mapping:
  - chat DTOs
  - booking DTOs
  - marketplace DTOs

## 10. Remaining Risks

- Full A-Z UI crawler is incomplete.
- Full authenticated role matrix is incomplete.
- Load testing did not cover write-heavy or authenticated flows.
- npm audit moderate findings remain until Firebase Admin major upgrade or FCM HTTP v1 replacement.
- iOS is not release-ready.
- Closed testing still requires 12 testers and 14 days of feedback.

## 11. Final Recommendation

CONTINUE CLOSED TESTING

Reason:

- Android closed testing readiness remains intact.
- No critical issue was found.
- The remaining items are post-ready hardening and public-release preparation tasks.
