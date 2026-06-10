# LAQTA Secret Handling

## Rules

- Never commit `.env`, private keys, service account JSON, keystores, APK signing keys, Sentry DSNs, Twilio tokens, Stripe secrets, JWT secrets, database URLs, or MinIO private keys.
- Never paste real secrets into chat, issue trackers, screenshots, logs, docs, or tests.
- `.env.example` and `.env.production.example` may include variable names and placeholders only.
- Production secrets must live in the VPS environment, Docker secret store, CI secret store, or provider secret manager.

## Required Production Secrets

- `DATABASE_URL`
- `JWT_SECRET`
- `JWT_ISSUER`
- `JWT_AUDIENCE`
- `TWILIO_ACCOUNT_SID`
- `TWILIO_AUTH_TOKEN`
- `TWILIO_SMS_FROM`
- `TWILIO_VERIFY_SERVICE_SID` when approved templates are used
- `MINIO_ACCESS_KEY`
- `MINIO_SECRET_KEY`
- `SENTRY_DSN`
- Stripe backend secrets if payment endpoints are enabled
- Firebase service account credentials for FCM only

## Rotation Recommendation

- Rotate any secret that has been exposed outside the server or local ignored `.env`.
- Rotate Twilio, JWT, MinIO, Stripe, Firebase service account, and database credentials before public launch if they were ever shared in chat or screenshots.

## Verification

- Run secret scans before every release.
- Review scan findings manually because docs and tests may include safe placeholders.

