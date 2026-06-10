# LAQTA Ops Monitoring

## Scope
Soft launch monitoring covers Android app, Express API, PostgreSQL, MinIO, Firebase FCM, uploads, auth, campaigns, and payments.

## Sentry
- Flutter DSN: pass with `--dart-define=SENTRY_DSN=...`.
- Backend DSN: set `SENTRY_DSN` and optional `SENTRY_ENVIRONMENT`.
- PII policy: do not send tokens, passwords, payment data, raw phone numbers, or card data.

## Health Endpoints
- `GET /api/v1/health`: public liveness.
- `GET /api/v1/ready`: database readiness.
- `GET /api/v1/ops/health`: database, MinIO, Firebase config, queue, version, uptime.

## Alert Thresholds
- API 5xx > 5 in 5 minutes.
- Upload failures > 10 in 10 minutes.
- Database unavailable for any health check.
- MinIO unavailable for any health check.
- Payment webhook failure: immediate alert.
- Auth exchange failure spike: > 10 failures in 10 minutes.

## Logs
API latency log fields:
- requestId
- route
- method
- status
- durationMs

Upload failure log fields:
- userIdHash
- mediaType
- size
- reason
- endpoint

## Response Playbook
1. Check `/api/v1/ops/health`.
2. Check Sentry critical events.
3. Check API latency and 5xx logs.
4. If MinIO is down, pause uploads through feature flags.
5. If auth exchange spikes, pause onboarding and verify Firebase/backend credentials.
