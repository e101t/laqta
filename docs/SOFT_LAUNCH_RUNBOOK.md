# LAQTA Soft Launch Runbook

## Scope
- City: Baghdad only.
- Photographers: 20.
- Users: 50.
- Platform: Android only.

## Pre-launch Checklist
- Backend deployed with latest migrations.
- `/api/v1/config/launch` returns Baghdad-only controls.
- Waitlist endpoint works.
- Sentry DSNs configured.
- `/api/v1/ops/health` green.
- PostgreSQL and MinIO backups scheduled.
- Moderation report/block endpoints verified.
- Privacy, terms, delete account, and content policy available.

## Day 0
1. Enable soft launch config.
2. Invite first 5 photographers.
3. Verify uploads, chat, bookings, campaigns, and notifications.
4. Monitor Sentry and ops health every 30 minutes.

## First 24 Hours
Track:
- installs
- signups
- verified photographers
- uploaded reels
- booking starts
- booking submissions
- chat starts
- media upload failure rate
- crash-free sessions
- API 5xx count

## First 7 Days
- Review conversion funnel.
- Review reports and blocked users.
- Approve/reject photographer verification requests.
- Expand only if crash-free sessions and upload success remain healthy.

## Rollback
- Disable risky features through `/api/v1/config/features`.
- Pause campaigns.
- Freeze photographer onboarding.
- Restore from latest verified backups if data corruption occurs.

## Abuse Reports
1. Review `/api/v1/admin/moderation/reports`.
2. Apply action through `/api/v1/admin/moderation/reports/:id/action`.
3. Document severe abuse internally.

## Payment Issues
- Verify Stripe dashboard and backend payment logs.
- Pause payments through feature flags if webhook failures occur.

## Backup Restore
Follow `docs/BACKUP_AND_RESTORE.md`.

## Emergency Contacts
- Product owner: TBD
- Backend engineer: TBD
- Trust & Safety reviewer: TBD
- Infrastructure owner: TBD
