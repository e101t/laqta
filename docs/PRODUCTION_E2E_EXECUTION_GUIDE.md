# LAQTA Production E2E Execution Guide

Date: 2026-05-31

Use this checklist for manual production E2E. Do not mark PASS without endpoint status, app evidence, and log/screenshot evidence where applicable.

## Test Prerequisites

- Latest production Android APK installed.
- Approved Iraq test phone number.
- Ability to receive SMS OTP.
- Customer test account.
- Photographer test account.
- Admin/super-admin account.
- Test image file and test video file.
- Backend log access for request IDs and FCM token verification.
- No production data mutation outside test accounts.

## Checklist

| # | Step | Endpoint(s) | Expected Result | Required Evidence | Pass/Fail |
|---:|---|---|---|---|---|
| 1 | User registration | `POST /api/v1/auth/send-otp` | 200/201-style safe success payload with `requestId`; SMS OTP delivered. | API status, request ID, screenshot of OTP screen, backend audit log without OTP value. | `[ ] PASS / [ ] FAIL` |
| 2 | OTP verification | `POST /api/v1/auth/verify-otp` | 200 with `accessToken`, `refreshToken`, `user`. | API status, app navigates past OTP, token storage verified as secure storage. | `[ ] PASS / [ ] FAIL` |
| 3 | Login | `POST /api/v1/auth/verify-otp` or existing login endpoint | User lands on home screen. | Screenshot of home, backend auth success log. | `[ ] PASS / [ ] FAIL` |
| 4 | Profile update | `PATCH /api/v1/users/me` | 200 with updated user/profile payload. | API status, screenshot of updated field, backend log request ID. | `[ ] PASS / [ ] FAIL` |
| 5 | Media upload | `POST /api/v1/media/upload-url`, `POST /api/v1/media/complete`, `GET /api/v1/media/:mediaId/content` | Upload URL issued, completion succeeds, content renders through backend URL. | API statuses, media ID, screenshot of rendered image. | `[ ] PASS / [ ] FAIL` |
| 6 | Story creation | `POST /api/v1/stories` | 201 story created with media reference. | API status, story visible in app, backend story row/log. | `[ ] PASS / [ ] FAIL` |
| 7 | Venue browsing | `GET /api/v1/venues`, `GET /api/v1/venues/:id` | 200 JSON, app opens venue details. | API status, screenshot of list/detail. | `[ ] PASS / [ ] FAIL` |
| 8 | Photographer browsing | `GET /api/v1/explore`, user/profile endpoints as used by app | 200 JSON, photographer profile opens. | API status, screenshot of profile. | `[ ] PASS / [ ] FAIL` |
| 9 | Booking/request creation | `POST /api/v1/requests` or `POST /api/v1/bookings` | 201 request/booking created for test account. | API status, created ID, screenshot of confirmation. | `[ ] PASS / [ ] FAIL` |
| 10 | Chat messaging | `POST /api/v1/chat/rooms`, `POST /api/v1/chat/messages`, `GET /api/v1/chat/messages` | Room opens, message sends, message renders once. | API statuses, room ID, screenshot of message. | `[ ] PASS / [ ] FAIL` |
| 11 | Push notification receipt | `POST /api/v1/users/fcm-token`, backend FCM send path | FCM token registered and notification received/routed. | Backend log, device notification screenshot, tap routing screenshot. | `[ ] PASS / [ ] FAIL` |
| 12 | Verification submission | `POST /api/v1/verification/submit` | 201 pending verification for photographer. | API status, verification ID, photographer app screenshot. | `[ ] PASS / [ ] FAIL` |
| 13 | Admin login | `POST /api/v1/auth/verify-otp` or admin login path | Admin JWT issued; admin route access allowed. | API status, admin user role evidence, do not print token. | `[ ] PASS / [ ] FAIL` |
| 14 | Admin review | `GET /api/v1/admin/verification/pending` | 200 pending list includes test verification. | API status, pending verification ID. | `[ ] PASS / [ ] FAIL` |
| 15 | Admin approval/rejection | `POST /api/v1/admin/verification/:id/approve` or `/reject` | 200 verification status updated and audit log written. | API status, audit log, app badge/rejection reason evidence. | `[ ] PASS / [ ] FAIL` |
| 16 | Report submission | `POST /api/v1/reports` | 201 report created. | API status, report ID, confirmation screenshot. | `[ ] PASS / [ ] FAIL` |
| 17 | Moderation action | `GET /api/v1/admin/moderation/reports`, `POST /api/v1/admin/moderation/reports/:id/action` | 200 action applied, audit log written. | API status, moderation action ID/log. | `[ ] PASS / [ ] FAIL` |
| 18 | Logout/login persistence | `POST /api/v1/auth/logout`, app restart, session restore | Tokens cleared, app returns to auth; relogin works. | API status, secure storage check, restart screenshots. | `[ ] PASS / [ ] FAIL` |

## Public Production Smoke Baseline

| Endpoint | Current Status |
|---|---:|
| `GET /api/v1/health` | 200 |
| `GET /api/v1/ready` | 200 |
| `GET /api/v1/ops/health` | 200 |
| `GET /api/v1/config/launch` | 200 |
| `GET /api/v1/explore` | 200 |
| `GET /api/v1/venues` | 200 |
| `GET /api/v1/locations` | 200 |
| `GET /api/v1/subscriptions/plans` | 200 |
| `GET /api/v1/users/me` without JWT | 401 |
| `GET /api/v1/admin/overview` without JWT | 401 |

## Notes

- `GET /api/v1/timeline/explores` returns 404; the active route is `GET /api/v1/explore`.
- Never paste access tokens, refresh tokens, OTP values, or raw phone numbers into reports.

