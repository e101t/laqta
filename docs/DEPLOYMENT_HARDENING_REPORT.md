# LAQTA Deployment Hardening Report

## Summary

Deployment hardening focuses on preventing secret leakage, keeping legacy tools out of runtime images, and ensuring production failures do not expose sensitive details.

## Repository Secret Hygiene

Observed controls:

- `.env` files are ignored.
- Backend `secrets/` directory is ignored.
- Android keystore directory is ignored.
- Build debug-info and release artifacts are ignored.
- Flutter secret scans did not show Stripe secret keys, MinIO secrets, or database passwords in `lib/`.

Tracked files verified in this pass:

- `.env` is not tracked.
- `backend/secrets/` is not tracked.
- Android keystore files are not tracked.
- Root Android `google-services.json` files were not reported as tracked by `git ls-files`.

## Docker Hardening

Changes applied:

- Backend `tsconfig.json` now builds runtime source and Prisma only, not tests.
- Backend `Dockerfile` no longer copies `test/` before `npm run build`.
- Backend `.dockerignore` excludes local env files, secrets, scripts, tests, docs, logs, build output, and archives from Docker build context.

Production image behavior:

- Final runtime image copies only `dist`, `node_modules`, `package*.json`, and `prisma`.
- Legacy scripts are not present in the runtime image.
- Secrets should be injected by environment variables or read-only mounts only.

## Environment Validation

Backend config includes production guards for:

- `DATABASE_URL` must not point to localhost in production.
- MinIO/internal object storage endpoints must not point to local development defaults in production.
- JWT issuer/audience/secret are required for secure session validation.

## Logging And Error Handling

Observed controls:

- Error handler avoids exposing stack traces in production.
- Prisma unique constraint details are sanitized in production responses.
- OTP and token flows should log audit events without raw OTP codes or raw tokens.
- Sentry is available for backend and Flutter monitoring.

Release requirement:

- Confirm production log aggregation redacts `Authorization`, cookies, OTP codes, JWTs, and payment metadata.

## Deployment Checklist

- Use production `.env` only on the VPS or secret manager.
- Run `npx prisma migrate deploy` on production before restart.
- Restart API with a clean process manager/container.
- Verify `GET /api/v1/health`.
- Verify `GET /api/v1/ready`.
- Verify protected routes return `401` without JWT.
- Verify OTP send through Twilio Verify SMS.
- Verify media upload URL and completion endpoints with authenticated user.

## Live Production Smoke Check

- `GET https://api.laqta.cloud/api/v1/health`: `200`
- `GET https://api.laqta.cloud/api/v1/admin/overview` without JWT: `401`
