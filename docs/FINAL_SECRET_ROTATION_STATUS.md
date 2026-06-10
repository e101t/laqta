# LAQTA Final Secret Rotation Status

Date: 2026-05-31

Rule applied: no credential is marked rotated unless provider-side evidence exists. No secret values are printed.

## Status Table

| Credential Area | Status | Evidence Source | Required Action | Risk Level |
|---|---|---|---|---|
| Twilio | NOT VERIFIED | Local code expects Twilio Verify SMS OTP env vars; no Twilio Console rotation receipt, timestamp, or post-rotation OTP evidence was available. | Rotate `TWILIO_AUTH_TOKEN` in Twilio Console, update production env, restart API, verify `POST /api/v1/auth/send-otp` sends OTP. | HIGH |
| JWT secrets | NOT VERIFIED | Backend uses JWT env config; no production secret version/timestamp or controlled session invalidation evidence was available. | Generate new high-entropy JWT secret, update production env, restart API, force/revalidate sessions, verify login/refresh/logout. | HIGH |
| PostgreSQL passwords | NOT VERIFIED | Prisma local status passed previously; no DB password rotation record or production DB user audit evidence was available. | Rotate DB password/user, update `DATABASE_URL`, run `npx prisma migrate status`, verify `/api/v1/ready`. | HIGH |
| MinIO access/secret keys | NOT VERIFIED | Backend media code expects MinIO credentials; no MinIO credential rotation proof or upload-after-rotation evidence was available. | Create/rotate MinIO access keys, update backend env, restart API, verify upload-url/complete/content. | HIGH |
| Stripe keys | NOT VERIFIED | Stripe keys are not leaked in runtime scans; no Stripe Dashboard rotation or webhook secret update evidence was available. | Rotate backend Stripe secret/webhook keys, update env, run test PaymentIntent/webhook verification. | HIGH |
| Firebase service account credentials | NOT VERIFIED | Firebase Admin runtime is FCM-only; no Firebase service account key rotation proof or post-rotation FCM send evidence was available. | Create new service account key for FCM, update production secret mount/env, send test push, revoke old key. | MEDIUM |
| Android signing credentials | NOT VERIFIED | Keystore was not reported as tracked in Git; no exposure confirmation or rotation proof was available. | Rotate Android upload key only if exposure is confirmed; update CI/local signing secrets and verify signing. | MEDIUM |

## Local Evidence Collected

| Check | Result |
|---|---|
| Runtime Firebase Auth/Firestore/Functions/Storage scan | 0 matches |
| Runtime secret scan for Stripe/MinIO/password patterns | 0 matches |
| Flutter debug logging scan | 0 matches |
| Production health endpoint | 200 |
| Production ready endpoint | 200 |

## Verification Required After Rotation

- `GET https://api.laqta.cloud/api/v1/health` returns 200.
- `GET https://api.laqta.cloud/api/v1/ready` returns 200.
- OTP send and verify work with a live test phone.
- Media upload flow works after MinIO key rotation.
- Stripe payment intent and webhook verification work after Stripe key rotation.
- FCM token registration and test notification work after Firebase service account rotation.
- Admin login/authorization remains valid after JWT rotation.

## Conclusion

Secret rotation status: NOT VERIFIED.

Launch impact: production launch should not be certified until provider-side rotation is completed or a signed operational waiver is accepted.

