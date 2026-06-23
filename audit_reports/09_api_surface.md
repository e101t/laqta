# Agent 9 — API Surface & Backend Contract Audit

Scope: Inventory of every backend API route referenced by the LAQTA Flutter app, cross-checked between
(a) unobfuscated Dart source under `lib/` and (b) string-scan of the shipped release binary
`build/app/outputs/apk/production/release/app-production-arm64-v8a-release.apk`
(libapp.so AOT snapshot + classes*.dex). Read-only audit; no files modified except this report.

## Method

1. Located the network layer: `lib/core/services/backend_api_client.dart` (generic `get/post/patch/delete/uploadFile`)
   and `lib/core/services/backend_config.dart` (`BackendConfig.apiUri` builds `"$baseUrl/api/v1$path"`).
2. Grepped every call site of `_apiClient.(get|post|patch|delete)` / `_backendApi.*` / `BackendConfig.apiUri(...)`
   across `lib/**` to extract literal path strings (see file:line citations below).
3. Extracted the production APK:
   `unzip -o app-production-arm64-v8a-release.apk -d /tmp/apk_extract`
4. String-scanned the AOT binary for route-shaped literals:
   `python3 -c "import re; data=open('lib/arm64-v8a/libapp.so','rb').read(); ... regex for /api, http(s)://, multi-segment paths"`
   → 159 candidate strings, saved and reviewed in full (see "Binary cross-check" below).
5. String-scanned `classes.dex`..`classes4.dex` for admin/debug/internal/staging/seed/localhost-shaped literals,
   filtering out false positives from `kotlin/jvm/internal/...`, `androidx/...`, `java/...` package-path noise.

## Base URL / Host Configuration

- Production base host (shipped default, `lib/core/config/app_config.dart:28-31`):
  ```
  static const String productionApiBaseUrl = String.fromEnvironment(
    'BACKEND_BASE_URL',
    defaultValue: 'https://api.laqta.cloud',
  );
  ```
  Confirmed present verbatim in `libapp.so` string scan (line 133 of extracted strings: `https://api.laqta.cloud`).
- All authenticated REST calls are prefixed `/api/v1` by `BackendConfig.apiUri()` (`lib/core/services/backend_config.dart:46-49`).
- Debug/dev fallbacks (`http://127.0.0.1:4000`, `http://10.0.2.2:4000`) only apply when `!kReleaseMode`
  (`lib/core/services/backend_config.dart:16-31`) — these are compiled out of the release path by the `kReleaseMode`
  check and were **not** found as literal strings in the release `libapp.so` scan (only the loopback octets
  `'127'`,`'0'`,`'0'`,`'1'` would appear as a `.join('.')` call, which is a runtime-only branch never taken in
  release builds; no `127.0.0.1` or `10.0.2.2` literal was found in libapp.so — they only showed up inside Stripe SDK
  strings in classes3.dex, see below). INFO only, not a flaw.
- No staging host literal (e.g. `staging.laqta...`) was found anywhere in the binary scan.

## Route Inventory by Domain

### Auth (`lib/features/auth/data/datasources/backend_auth_remote_data_source.dart`)
| Route | Method | Source |
|---|---|---|
| `/auth/login` | POST | line 58 |
| `/auth/register/start` | POST | line 78 |
| `/auth/register/complete` | POST | line 103 |
| `/auth/password/forgot` | POST | line 119 |
| `/auth/password/reset` | POST | line 135 |
| `/auth/logout` | POST | line 155 |
| `/auth/refresh` | POST | `lib/core/services/backend_api_client.dart:305` |
| `/users/me` | GET | line 34 (also used for profile fetch) |

All confirmed present in `libapp.so` string scan (`/auth/login`, `/auth/logout`, `/auth/password/forgot`,
`/auth/password/reset`, `/auth/refresh`, `/auth/register/complete`, `/auth/register/start`).

### Payments (`lib/features/payment/data/stripe_service.dart`)
| Route | Method | Source |
|---|---|---|
| `/payments/payment-intents` | POST | line 20 |
| `/payments/payment-intents/confirm` | POST | line 39 |

Marked "sensitive" (extra request signing) by `backend_api_client.dart:368` (`/payments` prefix check).
Normal Stripe payment-intent flow; no issue.

### Chat (`lib/features/chat/data/datasources/api_chat_remote_data_source.dart`)
| Route | Method | Source |
|---|---|---|
| `/chat/rooms?limit=…` | GET | line 19-20 |
| `/chat/rooms/{id}` | GET/DELETE | lines 27-28, 229, 234 |
| `/chat/rooms?bookingId=…` | GET | line 40-41 |
| `/chat/rooms` | POST (create / create-direct) | lines 56-57, 70-71 |
| `/chat/rooms/{id}/preview` | PATCH | line 216-217 |
| `/chat/messages?roomId=…` | GET | lines 84-85, 111-112 |
| `/chat/messages/last?roomId=…` | GET | line 92-93 |
| `/chat/messages` | POST | line 174-175 |
| `/chat/reads` | POST | line 202-203 |

All confirmed in binary scan (`/chat/:id`, `/chat/messages`, `/chat/messages/last?roomId=`,
`/chat/messages?roomId=`, `/chat/reads`, `/chat/rooms`, `/chat/rooms/`, `/chat/rooms?bookingId=`,
`/chat/rooms?limit=50`).

### Bookings / Marketplace / Venues / Campaigns / Subscriptions
(`lib/features/marketplace/data/datasources/api_marketplace_remote_data_source.dart`)
| Route | Method | Source |
|---|---|---|
| `/explore/feed` | GET (unauthorized) | line 17-20 |
| `/explore/marketplace` | GET (unauthorized) | line 34-37 |
| `/explore/photographers/{id}` | GET (unauthorized) | line 45-48 |
| `/venues` | GET (unauthorized) | line 63-66 |
| `/venues/{id}` | GET (unauthorized) | line 77-80 |
| `/venues/{id}/bookings` | POST | line 240-243 |
| `/locations` | GET (unauthorized) | line 90-93 |
| `/locations/{id}` | GET (unauthorized) | line 104-107 |
| `/subscriptions/plans` | GET (unauthorized) | line 113-116 |
| `/subscriptions/me` | GET | line 123 |
| `/subscriptions/subscribe` | POST | line 144 |
| `/campaigns` | POST/GET | lines 169-170, 199-200 |
| `/campaigns/{id}` | GET | line 208 |
| `/campaigns/{id}/submit` | POST | line 189 |

Binary scan corroborates with templated forms: `/booking/:id`, `/campaigns/`, `/campaigns/:id/analytics`,
`/explore/feed`, `/explore/marketplace`, `/explore/photographers/`, `/locations/`, `/locations/:id`,
`/photographer/:id`, `/subscriptions/me`, `/subscriptions/plans`, `/subscriptions/subscribe`, `/venues/`,
`/venues/:id`, `/venues/:id/book`.

Note: `/campaigns/:id/analytics` appears in the binary route template table but no corresponding Dart call site
was found in the data-source files reviewed — likely a route the backend exposes that this client build doesn't
yet call (dead/forward-compat route reference baked into a route-table string constant somewhere, or future
feature). LOW / INFO — not itself a vulnerability, just noted as an asymmetry between client usage and what the
binary's string table suggests the backend schema supports.

Deliveries (`lib/features/deliveries/data/datasources/api_deliveries_remote_data_source.dart`):
| Route | Method | Source |
|---|---|---|
| `/deliveries?bookingId=…` | GET | line 19-21 |
| `/deliveries` | POST | line 32 |

Disputes (`lib/features/disputes/data/datasources/api_disputes_remote_data_source.dart`): all methods
`throw _unsupported()` (lines 13-35) — **no live route**, feature stub only. INFO.

Requests (`lib/features/requests/data/datasources/api_requests_remote_data_source.dart`):
| Route | Method | Source |
|---|---|---|
| `/requests/my` | GET | line 15 |
| `/requests/{id}` | GET | line 29 |
| `/requests` | POST | line 35 |

Binary confirms: `/requests/`, `/requests/:id`, `/requests/:id/offer`, `/requests/create`, `/requests/my`.
(`/requests/:id/offer` and `/requests/create` appear in the binary's route templates but were not found called
directly in this Dart datasource file — same "schema vs. used" pattern as campaigns/analytics above. INFO.)

### Profile / User (`lib/features/profile/data/datasources/api_profile_remote_data_source.dart`,
`lib/core/services/backend_user_profile_service.dart`, `lib/core/trust_safety/reporting_service.dart`)
| Route | Method | Source |
|---|---|---|
| `/users/me` | GET/PATCH | profile ds lines 26, 45; `backend_user_profile_service.dart:15` |
| `/users/public?ids=…` | GET | profile ds line 31; chat ds line 131-132 |
| `/users/{id}/block` | POST/DELETE | `reporting_service.dart:29,33` |
| `/users/fcm-token` | POST/DELETE | `backend_notification_sync_service.dart:71-72,93` |
| `/reports` | POST | `reporting_service.dart:16-17` |
| `/verification/me` | GET | `verification_service.dart:36` |
| `/verification/submit` | POST | `verification_service.dart:52-53` |

Binary confirms `/users/`, `/users/fcm-token`, `/users/me`, `/users/public?ids=`, `/users/username/`,
`/users/{username}`, `/verification/me`, `/verification/submit`.

Note: `/users/username/` and `/users/{username}` appear as binary string-table entries but no Dart call site
using a username-keyed user lookup route was found in the reviewed source — same forward/extra-schema pattern.
INFO, not flagged as a vulnerability (no evidence this is a privileged/unauthenticated lookup; most likely a
username-availability-check or profile-by-username route not present in the current build's reachable code, or
used by a part of the codebase not exercised by this grep, e.g. deep-link resolution).

### Notifications
(`lib/features/notifications/data/datasources/backend_notifications_remote_data_source.dart`,
`lib/core/services/backend_notification_sync_service.dart`)
| Route | Method | Source |
|---|---|---|
| `/notifications/me` | GET | line 14 |
| `/notifications` | POST | line 26-27 |
| `/notifications/{id}/read` | PATCH | line 42 |
| `/notifications/read-all` | PATCH | line 50-51 |
| `/notifications/{id}` | DELETE | line 58 |
| `/notifications/devices` | POST | `backend_notification_sync_service.dart:77-78` |

Binary confirms `/notifications/`, `/notifications/devices`, `/notifications/me`, `/notifications/read-all`.

### Other / Platform (not domain-specific business routes)
| Route | Method | Source | Purpose |
|---|---|---|---|
| `/config/launch` | GET (unauthorized) | `lib/core/launch/launch_config_service.dart:16` | app launch config/remote flags |
| `/config/features` | GET | `lib/core/config/feature_flags.dart:93` | feature flags |
| `/waitlist` | POST (unauthorized) | `lib/core/launch/launch_config_service.dart:41` | pre-launch waitlist signup form |
| `/app/version` | GET | `lib/core/update/force_update_service.dart:79` | forced update check |
| `/health` | GET | `lib/core/network/connectivity/connectivity_service.dart:89`; `lib/core/network/pinning/certificate_pinner.dart:97` | connectivity/cert-pinning health probe |
| `/security/pins` | GET | `lib/core/network/pinning/certificate_pinner.dart:67` | dynamic cert-pin refresh |
| `/security/events` | POST | `lib/core/security/monitoring/security_event_logger.dart:46` | client → backend security telemetry |
| `/security/play-integrity/verify` | POST (unauthorized) | `lib/core/security/integrity_checker.dart:64-65`, default path from `app_config.dart:90-93` | Play Integrity attestation verification |
| `/analytics/events` | POST (unauthorized) | `lib/core/analytics/analytics_service.dart:53-54` | client analytics event batching |
| `/media/upload-url` | POST | `lib/core/media/media_upload_service.dart:44` | presigned upload URL issuance |
| `/media/complete` | POST | `lib/core/media/media_upload_service.dart:74` | finalize upload |
| `/media/{id}` | GET/DELETE | `lib/core/services/backend_media_service.dart:72,98` | media metadata/delete |

All of the above are normal client-support endpoints (health check, feature flags, forced update, analytics
ingestion, attestation, presigned upload) — not admin/internal/debug tooling. None of these require elevated
privilege beyond what an ordinary mobile client needs.

### Stories / Reels
| Route | Method | Source |
|---|---|---|
| `/stories?limit=…` | GET | `lib/core/services/story_service.dart:21` |
| `/stories/{id}/views` | POST | `lib/core/services/story_service.dart:63` |
| `/stories` | POST | `lib/features/story/data/datasources/api_story_remote_data_source.dart:18` |
| `/reels?limit=…` | GET | `lib/features/reels/data/datasources/api_reels_remote_data_source.dart:20-21` |
| `/reels` | POST | line 35 |
| `/reels/{id}/counters` | POST | line 44-45 |
| `/reels/{id}/comments` | GET/POST | lines 67, 80-81 |

## Binary Cross-Check Summary

Command used:
```
python3 -c "
import re
data = open('lib/arm64-v8a/libapp.so','rb').read()
strs = set()
for m in re.finditer(rb'[\x20-\x7e]{6,}', data):
    s = m.group().decode()
    if ('/api/' in s or s.startswith('/v1') or s.startswith('/v2') or
        'http://' in s or 'https://' in s or s.count('/') >= 2):
        strs.add(s)
"
```
159 candidate strings extracted; manually reviewed in full. Of these, all path-shaped strings matched routes
already identified from the Dart source (see tables above) — no additional, unexplained routes were found in
the binary that don't trace back to a Dart call site or a known route template. The only network host literal
present is `https://api.laqta.cloud`. The only other URL-shaped strings are: Flutter SDK doc links
(`https://api.flutter.dev/...`, `https://docs.flutter.dev/...`), `https://www.google.com/maps/search/?api=1&query=`
(maps deep link, benign), and root-detection filesystem paths (`/system/bin/su`, `/data/local/busybox`, etc. —
these are root/jailbreak-detection signature paths in `lib/core/security/rasp/root_detector.dart:11-26`, not API
routes).

Command used for DEX scan (admin/debug/internal/staging/seed/localhost patterns, after filtering Kotlin/Java/
AndroidX package-path false positives such as `kotlin/jvm/internal/...`):
```
python3 -c "
import re
pat = re.compile(r'(staging\.|/admin/|/_internal/|/debug/|/_test|/seed|localhost|10\.0\.2\.2|...)')
for fname in ['classes.dex','classes2.dex','classes3.dex','classes4.dex','lib/arm64-v8a/libapp.so']:
    data = open(fname,'rb').read()
    for m in re.finditer(rb'[\x20-\x7e]{6,}', data):
        s = m.group().decode(); low = s.lower()
        if 'kotlin/jvm/internal' in low or 'java/' in low or 'androidx' in low: continue
        if pat.search(low): print(fname, '::', s)
"
```
Result: only 10 matches, all attributable to the third-party **Stripe Android SDK** (`com/stripe/android/
financialconnections/debug/DebugConfiguration*` class names, and `http://10.0.2.2:8969/stream` /
`http://localhost:8969/stream` — confirmed by surrounding string-table context in `classes3.dex` to be Stripe's
Financial Connections emulator/debug streaming relay, a known shipped constant in Stripe's SDK, not a LAQTA
backend endpoint). No LAQTA-authored admin/debug/internal/staging/seed/test route or host was found in either
binary.

## Findings

### INFO-1: No debug/admin/internal/staging endpoints found in production binary
Severity: **INFO**
Every route extracted from both the Dart source and the shipped `libapp.so`/DEX matches a normal consumer-app
REST surface (auth, payments, chat, bookings/venues, profile, notifications, media, analytics, security
telemetry). No `/admin`, `/internal`, `/debug`, `/_test`, `/seed`, staging-host, or raw-DB-access-shaped route
was found anywhere in the release artifact. The 10 debug-pattern hits in the DEX scan all belong to the
bundled Stripe SDK's own debug/emulator class names and emulator-relay URL constants, not to LAQTA's backend
contract — this is normal third-party SDK content and ships in virtually all apps using Stripe Financial
Connections; it does not expose anything about LAQTA's backend.

### LOW-1: Route templates referenced in binary string table with no matching call site in reviewed Dart source
Severity: **LOW** (informational asymmetry, not a vulnerability)
The following route-shaped strings appear in `libapp.so`'s string table but were not found invoked from any
`_apiClient.*`/`BackendConfig.apiUri` call site in the `lib/` source actually reviewed:
`/campaigns/:id/analytics`, `/requests/:id/offer`, `/requests/create`, `/users/username/`, `/users/{username}`.
These are most plausibly: (a) route templates baked into a shared backend-route-constants table that aren't all
exercised by every client build, (b) future/staged features, or (c) routes called from a code path this grep
pattern didn't match (e.g., different client wrapper). None of them look like privileged/admin routes by name —
they read as ordinary CRUD/analytics/offer routes for the same domains already documented above. Recommend the
backend team confirm these routes still enforce the same per-user authorization as their sibling routes (e.g.
`/campaigns/:id/analytics` should be scoped to the campaign owner, not globally readable), since they are
reachable hosts even if this particular client build doesn't call them today.

### INFO-2: `/security/*` and `/config/*` routes are legitimate client-support endpoints, not admin backdoors
Severity: **INFO**
`/security/events`, `/security/pins`, `/security/play-integrity/verify`, `/config/launch`, `/config/features`
might superficially look "internal" by name, but all are standard mobile client-support endpoints (telemetry
ingestion, dynamic certificate-pin rotation, device attestation verification, remote feature flags / launch
config) called by ordinary unauthenticated or session-authenticated client code
(`lib/core/security/monitoring/security_event_logger.dart`, `lib/core/network/pinning/certificate_pinner.dart`,
`lib/core/security/integrity_checker.dart`, `lib/core/launch/launch_config_service.dart`,
`lib/core/config/feature_flags.dart`). Not flagged as a vulnerability.

## Conclusion

No CRITICAL, HIGH, or MEDIUM findings. The app's API surface — as extracted from both the unobfuscated Dart
source and the shipped release binary — consists entirely of conventional REST routes for auth, payments
(Stripe), chat, bookings/venues/marketplace/campaigns, profile/user, notifications, media, and ordinary
client-support functions (health check, forced update, feature flags, security telemetry, certificate pinning,
Play Integrity attestation). No debug, internal-admin, staging-only, or seed/test-data route was found shipping
in the production binary. One LOW item is noted: a handful of route templates appear in the binary's string
table without a corresponding call site in the reviewed client code, which the backend team should confirm are
still properly authorization-scoped server-side even though unused by this client build.
