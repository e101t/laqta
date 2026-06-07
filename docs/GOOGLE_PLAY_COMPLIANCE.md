# Google Play Compliance - LAQTA

## Category
- App, not game.
- Photography / Lifestyle / Events marketplace.

## Permission Justification
- Camera: profile/story/reel/chat media capture.
- Photos/Media: select user media for uploads.
- Notifications: chat, booking, campaign, and activity updates.
- Internet: API, FCM, MinIO signed URLs, Stripe.
- Location if enabled: nearby venues and photographers only.

## Data Safety Draft
Collected data:
- Name and account identifiers.
- Phone/email if provided.
- Photos/videos and user-generated content.
- Messages and booking details.
- Approximate location if user chooses location features.
- Payment handled by Stripe; card data is not stored by LAQTA app.
- App activity and analytics events without PII.
- Device identifiers for security and abuse prevention.

## User Content Moderation
- Reports endpoint and in-app report entry points.
- Blocking endpoints.
- Admin moderation queue and content policy.

## Account Deletion
- In-app deletion path and support email policy.
- Policy document: `docs/legal/DELETE_ACCOUNT_POLICY_AR.md`.

## Ads Declaration
- Sponsored placements exist and must be marked clearly.

## Payments
- Real-world services/bookings may use Stripe depending on Google Play policy.
- Digital subscriptions must be reviewed for Google Play Billing requirement before public rollout.

## Target Audience
- General adult users.
- Not directed at children.
