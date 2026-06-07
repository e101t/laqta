# Play Store Data Safety - LAQTA

## Data collected

| Category | Data | Purpose | Shared |
|---|---|---|---|
| Personal info | Name, phone, email, city, profile role | Account, marketplace identity, bookings | No |
| Photos and videos | Avatar, portfolio, stories, reels, chat and delivery media | User-generated marketplace/content features | No |
| App activity | Bookings, messages, campaign actions, subscription selections | Core app functionality, fraud prevention, support | No |
| Device or other IDs | FCM token, install fingerprint hash, Play Integrity token | Push notifications, abuse prevention, account safety | No |
| Financial info | Payment intent metadata and transaction references | Payments through Stripe/backend | Processed by Stripe/backend only |
| Location | Venue/location selection and map interaction data | Marketplace discovery and booking context | No |

## Security practices

- Data is encrypted in transit using HTTPS.
- Backend API calls use JWT authorization.
- Access tokens are stored with Android secure storage.
- Media uploads use backend-issued presigned URLs and do not expose MinIO credentials.
- Stripe secret keys are backend-only; Flutter uses publishable keys only.
- Play Integrity/App Check are used for abuse prevention.

## Android permissions

| Permission | Reason |
|---|---|
| `INTERNET` | Required for backend APIs, Firebase Messaging, Stripe, and Maps. |
| `POST_NOTIFICATIONS` | Required on Android 13+ for push notification display. |

The app uses Android Photo Picker/Image Picker flows and does not require broad external storage permissions in the production manifest.
