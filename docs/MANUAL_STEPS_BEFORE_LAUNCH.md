# LAQTA Manual Steps Before Launch

Date: 2026-05-31

## A) Secret Rotation Checklist

Do not paste real secrets into chat, logs, screenshots, commits, or issue trackers. Rotate one provider at a time and verify before moving to the next.

### Twilio Verify SMS OTP

- Where to rotate: Twilio Console -> Account -> API keys/auth token.
- VPS env to update:
  - `TWILIO_ACCOUNT_SID`
  - `TWILIO_AUTH_TOKEN`
  - `TWILIO_SMS_FROM`
  - `TWILIO_VERIFY_SERVICE_SID` if using approved templates.
- Restart:
  ```bash
  docker compose up -d --build api
  ```
- Verify:
  ```bash
  curl -s -X POST https://api.laqta.cloud/api/v1/auth/send-otp \
    -H "Content-Type: application/json" \
    -d '{"phone":"07XXXXXXXXX"}'
  ```
- Expected: safe success JSON with `requestId`, and SMS OTP received.

### JWT Secret

- Where to rotate: production API environment only.
- Generate:
  ```bash
  node -e "console.log(require('crypto').randomBytes(64).toString('hex'))"
  ```
- VPS env to update:
  - `JWT_SECRET`
  - confirm `JWT_ISSUER=api.laqta.cloud`
  - confirm `JWT_AUDIENCE=laqta-app`
- Restart:
  ```bash
  docker compose up -d --build api
  ```
- Verify:
  ```bash
  curl -s https://api.laqta.cloud/api/v1/ready
  ```
- Expected: `200`, then login/refresh/logout E2E passes. Existing sessions may be invalidated.

### PostgreSQL Password

- Where to rotate: PostgreSQL user/password on the VPS or managed DB console.
- VPS env to update:
  - `DATABASE_URL`
  - `POSTGRES_PASSWORD` if using Docker-managed Postgres.
- Restart:
  ```bash
  docker compose up -d db api
  ```
- Verify:
  ```bash
  docker compose exec api npx prisma migrate status
  curl -s https://api.laqta.cloud/api/v1/ready
  ```
- Expected: migrations clean and readiness `200`.

### MinIO Access/Secret Keys

- Where to rotate: MinIO console or service credentials.
- VPS env to update:
  - `MINIO_ACCESS_KEY`
  - `MINIO_SECRET_KEY`
  - confirm `MINIO_BUCKET`
  - confirm internal/public endpoint settings.
- Restart:
  ```bash
  docker compose up -d --build api
  ```
- Verify:
  - Login to Android app.
  - Upload profile image or story.
  - Confirm `/api/v1/media/upload-url` and `/api/v1/media/complete` succeed.
  - Open returned `/api/v1/media/{mediaId}/content` URL.

### Stripe Keys

- Where to rotate: Stripe Dashboard -> Developers -> API keys and Webhooks.
- VPS env to update:
  - Stripe secret key.
  - Stripe webhook secret.
- Flutter config:
  - Publishable key only, if used at build/runtime.
- Restart:
  ```bash
  docker compose up -d --build api
  ```
- Verify:
  - Create PaymentIntent from backend.
  - Send/replay a Stripe webhook.
  - Confirm backend accepts webhook signature.

## B) Android E2E Checklist

Use latest production APK and a safe test account. Record request IDs and screenshots where possible. Release builds intentionally block screenshots on sensitive screens through `FLAG_SECURE`, so use backend logs and visible confirmation where screenshots are unavailable.

- [ ] 1. Install APK
  ```bash
  adb install -r app-arm64-v8a-production-release.apk
  ```
  Expected: install succeeds.

- [ ] 2. Launch app
  ```bash
  adb shell monkey -p com.laqta.laqta -c android.intent.category.LAUNCHER 1
  ```
  Expected: LAQTA opens.

- [ ] 3. Login OTP
  - Enter Iraqi phone number.
  - Send OTP.
  - Expected: SMS OTP received and `/api/v1/auth/send-otp` succeeds.

- [ ] 4. Verify OTP
  - Enter OTP.
  - Expected: `/api/v1/auth/verify-otp` returns access/refresh tokens and app enters home.

- [ ] 5. Avatar upload
  - Select/capture image.
  - Expected: `/api/v1/media/upload-url` and `/api/v1/media/complete` succeed; avatar renders.

- [ ] 6. Story upload
  - Create story with image.
  - Expected: story appears and backend returns created story.

- [ ] 7. Feed/Home
  - Scroll feed/reels.
  - Expected: no crash, no endless loader, smooth enough for QA.

- [ ] 8. Explore
  - Open Explore, venues, locations, photographer profile.
  - Expected: `/api/v1/explore`, `/api/v1/venues`, `/api/v1/locations` return data and screens open.

- [ ] 9. Logout
  - Logout from app.
  - Expected: `/api/v1/auth/logout` succeeds where available; secure tokens are cleared.

- [ ] 10. Session restore
  - Force close and reopen.
  - Expected: logged-out state remains after logout; logged-in state restores before logout.

## C) Google Play Internal Testing

1. Open Google Play Console:
   - `https://play.google.com/console`
2. Create or open the LAQTA app.
3. Confirm package:
   - `com.laqta.laqta`
4. Go to Testing -> Internal testing.
5. Create a new release.
6. Upload:
   - `app-production-release.aab`
7. Fill release notes in Arabic and English.
8. Add testers:
   - Email list or Google Group.
9. Complete metadata:
   - App name.
   - Short description.
   - Full description.
   - App icon 512x512.
   - At least 2 phone screenshots.
   - Feature graphic if required.
10. Add policy URLs:
   - Privacy Policy URL.
   - Terms URL if available.
   - Delete Account Policy URL or support process.
11. Complete Data Safety:
   - Account data.
   - Phone/email.
   - Photos/videos.
   - Messages/user-generated content.
   - App activity/analytics.
   - Device identifiers/security logs.
   - Payment info handled by Stripe, not stored directly.
12. Complete Content and Ads declarations:
   - User-generated content: yes.
   - Reporting/blocking/moderation: yes.
   - Sponsored placements: yes, if campaigns are enabled.
13. Submit Internal testing release.
14. Install from tester link and run Android E2E checklist above.

