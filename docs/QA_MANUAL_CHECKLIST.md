# LAQTA Manual QA Checklist

## Auth

- Arabic onboarding appears on first install.
- Phone input accepts Iraqi `07xxxxxxxxx` format.
- OTP request returns success and a request ID.
- SMS OTP arrives.
- Wrong OTP shows safe Arabic error.
- Expired OTP shows safe Arabic error.
- Successful OTP logs in and stores backend JWT tokens securely.
- Logout revokes session and clears local tokens.

## Media

- Avatar upload completes.
- Portfolio upload completes.
- Story image upload publishes.
- Reel video picker returns a file and upload starts.
- Chat media upload completes.
- Failed upload shows a recoverable error, not an infinite loader.

## Marketplace

- Home, explore, venues, locations, subscriptions, campaigns, bookings, chat, notifications open without blank screens.
- Public endpoints render content without authentication where expected.
- Protected endpoints require JWT.

## Admin

- Admin endpoints require JWT and admin role/permissions.
- Non-admin users receive 403.
- Moderation, verification, analytics, and audit views are protected.

## Production Smoke

- `GET /api/v1/health` returns 200.
- `GET /api/v1/ready` returns 200.
- `GET /api/v1/explore` returns 200 JSON.
- `GET /api/v1/users/me` without JWT returns 401.
- `POST /api/v1/auth/send-otp` returns safe success/failure.

