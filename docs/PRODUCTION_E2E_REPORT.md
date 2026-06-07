# LAQTA Production E2E Report

Date: 2026-05-31

## Environment

- API base URL: `https://api.laqta.cloud`
- Platform requested: production
- Full authenticated E2E status: BLOCKED

## Public Smoke Tests Executed

| Check | Endpoint | Status |
|---|---|---:|
| Health | `GET /api/v1/health` | 200 |
| Readiness | `GET /api/v1/ready` | 200 |
| Ops health | `GET /api/v1/ops/health` | 200 |
| Launch config | `GET /api/v1/config/launch` | 200 |
| Explore | `GET /api/v1/explore` | 200 |
| Venues | `GET /api/v1/venues` | 200 |
| Locations | `GET /api/v1/locations` | 200 |
| Subscription plans | `GET /api/v1/subscriptions/plans` | 200 |
| Protected user route without JWT | `GET /api/v1/users/me` | 401 |
| Protected admin route without JWT | `GET /api/v1/admin/overview` | 401 |

## Full Workflow Status

| Step | Endpoint(s) | Result | Response Code | Evidence / Reason |
|---|---|---|---:|---|
| 1. User registration | `POST /api/v1/auth/send-otp` | BLOCKED | N/A | Requires approved live test phone and OTP delivery consent. Not executed to avoid sending production OTP to an unconfirmed number. |
| 2. OTP verification | `POST /api/v1/auth/verify-otp` | BLOCKED | N/A | Requires fresh OTP code from step 1. |
| 3. Login | `POST /api/v1/auth/verify-otp` or `POST /api/v1/auth/login` | BLOCKED | N/A | Requires credentials/fresh OTP. |
| 4. Profile update | `PATCH /api/v1/users/me` | BLOCKED | N/A | Requires authenticated JWT. |
| 5. Image upload | `POST /api/v1/media/upload-url`, `POST /api/v1/media/complete` | BLOCKED | N/A | Requires authenticated JWT and test media file. |
| 6. Photographer discovery | `GET /api/v1/explore`, `GET /api/v1/venues`, `GET /api/v1/locations` | PASS | 200 | Public discovery endpoints returned JSON. |
| 7. Booking/request creation | `POST /api/v1/requests` | BLOCKED | N/A | Requires authenticated JWT and valid request payload. |
| 8. Chat messaging | `GET /api/v1/chat/rooms`, `POST /api/v1/chat/messages` | BLOCKED | N/A | Requires authenticated JWT and chat room. |
| 9. Notification delivery | `POST /api/v1/users/fcm-token`, FCM send path | BLOCKED | N/A | Requires authenticated user/device FCM token and backend log verification. |
| 10. Story creation | `POST /api/v1/stories` | BLOCKED | N/A | Requires authenticated JWT and media reference. |
| 11. Verification submission | `POST /api/v1/verification/submit` | BLOCKED | N/A | Requires photographer JWT. |
| 12. Admin review | `GET /api/v1/admin/verification/pending` | BLOCKED | N/A | Requires admin JWT. |
| 13. Admin approval/rejection | `POST /api/v1/admin/verification/:id/approve`, `POST /api/v1/admin/verification/:id/reject` | BLOCKED | N/A | Requires admin JWT and pending verification id. |
| 14. Reporting/moderation flow | `POST /api/v1/reports`, `POST /api/v1/admin/moderation/reports/:id/action` | BLOCKED | N/A | Requires user JWT, admin JWT, and target content. |
| 15. Logout/login persistence | `POST /api/v1/auth/logout`, app restart/session restore | BLOCKED | N/A | Requires authenticated session and device/emulator. |

## Endpoint Correction

`GET /api/v1/timeline/explores` returned 404. The production backend currently exposes explore at:

- `GET /api/v1/explore`

This is not an E2E blocker if Flutter uses `/api/v1/explore`, but any release script/documentation still referencing `/api/v1/timeline/explores` must be updated.

## Required To Complete E2E

1. Approved production test phone number.
2. Fresh OTP code during test window.
3. Customer test account.
4. Photographer test account.
5. Admin JWT or supervised admin login session.
6. Test image and video files.
7. Device/emulator with latest production APK installed.
8. Access to backend logs for FCM token registration and notification delivery evidence.

## E2E Decision

NOT COMPLETE

Reason: full authenticated workflow was not executed due missing live OTP/test-account/admin credentials and device evidence.

