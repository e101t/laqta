# LAQTA Secret Rotation Plan

This document lists active credentials by purpose and rotation order. Values must stay in environment variables, provider consoles, CI secrets, or server secret stores only. Do not commit real values.

## Scope

- Flutter Android production build configuration.
- Backend deployment under `C:\Users\Devil\Desktop\backend`.
- Docker Compose production environment.
- FCM-only Firebase configuration.
- Android release signing material.

## Active Secrets And Rotation Order

| Secret | Where Used | Rotation Priority | Production Impact | Safe Rotation Order |
|---|---|---:|---|---|
| `TWILIO_ACCOUNT_SID` | Backend OTP service env, production compose/env | High | OTP send may fail if wrong SID/token pair is deployed. | Create/confirm new Twilio credential pair, update production env, restart API, test `POST /api/v1/auth/send-otp`, then revoke old credential. |
| `TWILIO_AUTH_TOKEN` | Backend OTP service env only | Critical | Login/signup OTP is unavailable during bad rotation. | Add new token in provider console, update VPS env, restart API, test OTP, revoke old token. |
| `TWILIO_SMS_FROM` | Backend OTP service env | Medium | OTP delivery fails if sender is not approved or sandbox join is missing. | Verify approved sender, update env, test with known phone, monitor provider delivery logs. |
| `TWILIO_VERIFY_SERVICE_SID` | Backend OTP template env if template messaging is enabled | Medium | Template OTP messages fail if content SID is invalid. | Create approved template, update env, test OTP, monitor provider errors. |
| `JWT_SECRET` | Backend JWT signing/verification env | Critical | Existing sessions become invalid if rotated immediately. | Deploy support for accepting previous secret only during short migration window if required, rotate signing secret, force session refresh/re-login, then remove old secret. |
| `JWT_ISSUER` / `JWT_AUDIENCE` | Backend JWT validation env, Flutter validator config | High | Token validation fails if values do not match app/backend. | Confirm production values, deploy backend and app with matching constants, test login/refresh. |
| `DATABASE_URL` | Backend Prisma/PostgreSQL runtime and migration commands | Critical | API cannot start or persist data if invalid. | Create new DB password/user, grant privileges, update env, run health checks, revoke old DB password. |
| `POSTGRES_PASSWORD` | Docker/local database deployment | Critical | DB containers may fail or reject API connections. | Rotate database password, update dependent `DATABASE_URL`, restart services in controlled window. |
| `MINIO_ACCESS_KEY` | Backend media upload/storage services | Critical | Uploads and signed media URLs fail if invalid. | Create replacement access key, update backend env, restart API, test upload-url/complete and media read, revoke old key. |
| `MINIO_SECRET_KEY` | Backend media upload/storage services | Critical | Uploads and signed media URLs fail if invalid. | Rotate with `MINIO_ACCESS_KEY`; never rotate one side alone. |
| `MINIO_ENDPOINT` / `MINIO_BUCKET` | Backend storage configuration | High | Uploads/read URLs fail if endpoint or bucket is wrong. | Validate bucket exists, update env, test media lifecycle, monitor failed uploads. |
| `SENTRY_DSN` | Flutter and backend monitoring env/dart-define | Medium | Error monitoring fails or sends to wrong project. | Create new DSN/project if needed, update env/CI, deploy, verify event ingestion, disable old DSN. |
| `STRIPE_SECRET_KEY` | Backend payment server only if payments enabled | Critical | Payment creation/webhooks fail if invalid; never place in Flutter. | Create restricted key, update backend env, test PaymentIntent creation and webhook, revoke old key. |
| `STRIPE_WEBHOOK_SECRET` | Backend webhook verification env | Critical | Webhooks are rejected if mismatched. | Add new endpoint/secret or rotate webhook secret, update env, replay/test webhook, remove old secret. |
| `STRIPE_PUBLISHABLE_KEY` | Flutter build-time config | Medium | Client payment UI fails if wrong environment key is used. | Update dart-define/CI secret, rebuild app, test payment initialization. |
| Firebase service account JSON | Backend FCM sender only, mounted from `backend/secrets/` | High | Push notifications fail if invalid; do not use for Auth/Firestore/Storage. | Create FCM-only service account key, update mounted JSON, restart API, send test FCM, delete old key. |
| `google-services.json` | Android FCM token generation | Medium | FCM token generation may fail if project config is wrong. Not treated as a private secret, but keep controlled. | Regenerate from Firebase console if project changes, keep out of public repos, rebuild app, verify FCM token registration. |
| Android release keystore | `android/keystore/*.jks`, CI release secrets | Critical | Compromised signing key requires Play App Signing key-reset process. | If exposed, initiate Play key reset, generate new upload key, update CI/local keystore, verify v1/v2/v3 signing. |
| Keystore passwords/aliases | Release scripts and CI secrets | Critical | Build signing fails or signing key can be abused if exposed. | Rotate upload key/passwords, update CI secrets, run signed build verification, remove old credentials. |
| Google Maps API key | Flutter/Android manifest or dart-define if maps are enabled | High | Maps fail or key abuse can generate costs. | Restrict key to package/SHA, rotate in Google Cloud, rebuild app if embedded, monitor usage. |

## Immediate Rotation Priority

1. Rotate any credential that was ever pasted into chat, screenshots, terminal history, or logs.
2. Rotate OTP provider token and JWT secret before public launch.
3. Rotate MinIO and database credentials if the VPS was rebuilt or shared during setup.
4. Rotate Stripe and Firebase service account keys if they were present in any copied archive.
5. Confirm Android upload key is not tracked in Git and is stored only in local/CI secret storage.

## Verification Commands

Run these without printing secret values:

```powershell
git ls-files .env .env.* android/keystore secrets
rg "sk_live|sk_test|minio.*secret|password=" lib android C:\Users\Devil\Desktop\backend\src
```

Expected:

- Real `.env` files are not tracked.
- Keystore and service-account JSON files are not tracked.
- Secret scans return zero runtime leaks, except placeholder/example documentation.

