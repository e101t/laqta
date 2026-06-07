# Firebase Migration Tracker

## Services intentionally retained

| Firebase service | Status | Reason |
|---|---|---|
| Firebase Cloud Messaging | Kept | Push notifications. |
| Firebase App Check | Kept | Abuse prevention for mobile clients. |

## Services being removed from active product paths

| Service | Current replacement | Status |
|---|---|---|
| Firebase Storage | Backend media API + MinIO presigned uploads | Replaced for production media flows. |
| Cloud Functions payments | Backend Stripe API wrapper | Flutter dependency path replaced; backend endpoint parity must be verified before enabling live payments. |
| Firestore chat/deliveries/reels/stories/profile | Backend API data sources/hybrid adapters exist | Hybrid/legacy files still exist and require final per-feature removal once backend parity is confirmed. |
| Firebase Auth | Backend JWT session after Firebase exchange | Custom OTP/JWT-only login requires backend endpoint parity before Firebase Auth can be removed. |

## Remaining migration risk

The codebase still contains legacy Firestore/Cloud Functions files for inactive or hybrid features. They are tracked here so removal can be completed feature-by-feature without breaking current production flows.
