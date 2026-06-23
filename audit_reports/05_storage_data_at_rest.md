# Agent 5 — Storage & Data-at-Rest Audit (LAQTA Flutter App)

Scope: lib/ source review only (no app execution). Storage mechanisms found in use:
`flutter_secure_storage` (pubspec.yaml:43, `^10.3.0`), `shared_preferences`
(pubspec.yaml, `^2.2.2`). `sqflite` appears only as a **transitive** dependency in
pubspec.lock (lines 1045-1081, pulled in by some plugin) — no direct
`package:sqflite` import or `openDatabase(...)` call exists anywhere under `lib/`
(`grep -rln "package:sqflite\|openDatabase\|Database(" lib/` → empty). **Hive is not
used at all** (not in pubspec.yaml, no imports). Chat is backed by Firestore
remote sources (`lib/features/chat/data/datasources/firestore_chat_remote_data_source.dart`)
with no local persistent chat database found. File-based storage is limited to
transient media (images/video) being compressed/uploaded and then deleted
(`lib/core/media/media_upload_service.dart:219` — `File(path).delete()`); no
sensitive data is written to arbitrary files.

---

## RE-CONFIRMATION: Tokens correctly use flutter_secure_storage

`lib/core/auth/token_manager.dart:32-37,185-205,216-220` — access token, refresh
token, userId, and both expiry timestamps are written/read/deleted exclusively
through `FlutterSecureStorage` (`_secureStorage.write/read/delete`). No
contradicting evidence found. Locked claim stands closed.

---

## Findings

### HIGH — NEW: Legacy plaintext JWT/userId keys still actively read and migrated from SharedPreferences
**File/line:** `lib/core/auth/token_manager.dart:246-262` (`_migrateLegacyTokenIfNeeded`),
constants at `lib/core/constants/app_constants.dart:208-209`
(`keyBackendJwt = 'backendJwt'`, `keyBackendUserId = 'backendUserId'`).

Every call to `getAccessToken()`, `getRefreshToken()`, `getUserId()`, and
`readSnapshot()` first calls `_migrateLegacyTokenIfNeeded()`, which reads
`prefs.getString(AppConstants.keyBackendJwt)` and
`prefs.getString(AppConstants.keyBackendUserId)` — i.e. the code still expects a
JWT and user id to potentially exist in **plain, unencrypted SharedPreferences**
(`token_manager.dart:252-261`). On a successful `saveTokens()` call
(`token_manager.dart:207-210`) and on `clear()` (`token_manager.dart:222-228`) these
two legacy keys are removed, so in steady state they should be empty — but the
migration code path being live means: (a) this is evidence the app previously
stored the live JWT and user id in plaintext shared_preferences pre-migration,
and (b) any code path that still writes to `keyBackendJwt`/`keyBackendUserId`
(e.g. an older app version, a different login path, or a regression) would
silently leave the access token sitting in plaintext SharedPreferences
(world-readable on rooted devices / via ADB backup on non-secure builds).
Recommend deleting the legacy migration path entirely once confirmed no
production users remain on pre-migration app versions, since its continued
presence is a standing plaintext-token risk surface.

### HIGH — NEW: Logout does not perform a full wipe; a dedicated `wipeAll()` exists but is never called
**File/line:** `lib/core/storage/secure_storage_manager.dart:56-66` defines
`wipeAll()` which deletes **all** secure-storage entries (`_secureStorage.deleteAll()`)
and all non-allowlisted SharedPreferences keys. `grep -rn "wipeAll" lib/` shows
this method has **zero callers** anywhere in the codebase.

The actual logout flow (`lib/features/auth/data/datasources/backend_auth_remote_data_source.dart:148-167`,
`signOut()`) instead calls only:
- `_sessionService.clear()` → `TokenManager.clear()` (`token_manager.dart:215-229`):
  deletes 5 secure-storage keys (`laqta.accessToken`, `laqta.refreshToken`,
  `laqta.userId`, `laqta.accessTokenExpiresAt`, `laqta.refreshTokenExpiresAt`) and
  removes 2 legacy SharedPreferences keys (`keyBackendJwt`, `keyBackendUserId`).
- `CacheInterceptor().clearUserCache()` (`cache_interceptor.dart:50` →
  `response_cache.dart:69-75`): removes only SharedPreferences keys prefixed
  `laqta_response_cache_v1:` (cached GET response bodies for `/users/me`,
  `/users/{username}`, `/timeline/*`, `/category`, see policy list below).
- `SecureStorageManager.instance.clearMemoryTier()` (`secure_storage_manager.dart:42-44`):
  clears an **in-memory** `Map`, irrelevant to disk persistence.

Data NOT cleared by logout (persists on disk after sign-out, see MEDIUM findings
below for exact keys): profile-completion/role/blocked cache in
`app_router.dart`, language/theme/notification prefs, recent search history,
analytics event queue, photographer availability cache, feature-flags cache.
None of these are auth tokens, but the profile-role/completed/blocked cache
ties a userId to account state and is the most sensitive of the leftovers (see
next finding). Recommend calling `SecureStorageManager.instance.wipeAll()` (or
equivalent full-prefs clear, preserving only `allowedPreferenceKeys`) from the
sign-out path instead of/in addition to the narrow `clear()`+`clearUserCache()`.

### MEDIUM — NEW: Profile completion/role/blocked-status cache (includes userId) survives logout until next route evaluation, not cleared at sign-out time
**File/line:** `lib/app/router/app_router.dart:684-717`
(`_readPersistedProfileStatus`, `_persistProfileStatus`,
`_clearPersistedProfileStatus`); keys defined at
`lib/core/constants/app_constants.dart:210-213`
(`keyProfileCacheUserId`, `keyProfileCacheCompleted`, `keyProfileCacheRole`,
`keyProfileCacheBlocked`).

`_persistProfileStatus` writes the user's `userId`, profile-completed flag,
account `role` (e.g. "photographer"/"client"), and `isBlocked` flag to plain
SharedPreferences (`app_router.dart:705-708`). `_clearPersistedProfileStatus`
(`app_router.dart:711-717`) does exist and is called at `app_router.dart:559`,
but only reactively, inside the router's redirect-decision logic, when it next
detects `!hasValidBackendSession`. It is **not called directly from the
sign-out flow** (`backend_auth_remote_data_source.dart:148-167`) — it only
fires the next time `_redirectLogic` runs (e.g. on the next app navigation/
rebuild after logout). In practice this is usually immediate since logout
triggers a redirect to the auth screen, but there is a window where stale
`userId`/`role`/`isBlocked` data for the just-logged-out account remains on
disk in plaintext, readable by another local process or backup extraction,
until that redirect executes. Also read independently and with the same lag
characteristics at `lib/app/main_app_screen.dart:103-113` (`_readCachedRole`).
Low severity because it requires local device/backup access and the role
string itself is not deeply sensitive, but the persisted `userId` plus role/
blocked-status is account-identifying PII sitting in unencrypted storage.
Recommend calling `AppRouter._clearPersistedProfileStatus()` (or exposing an
equivalent) directly from the sign-out path so it is removed synchronously at
logout rather than relying on a subsequent redirect pass.

### MEDIUM — NEW: Cached API response bodies for `/users/me` and `/users/{username}` stored in plaintext SharedPreferences (cleared on logout, but readable while session is "live" and for a brief window per TTL)
**File/line:** `lib/core/network/cache/response_cache.dart:42-79` (`ResponseCache`,
prefix `'laqta_response_cache_v1:'`), policy list at
`lib/core/network/cache/cache_policy.dart:16-24` —
`/users/me` (5 min TTL), `/users/{username}` (10 min TTL), `/timeline/home`,
`/timeline/explores`, `/category`, `/app/version`, `/config/features`.
Written via `lib/core/network/cache/cache_interceptor.dart:31-48` (`write()`),
called from `lib/core/services/backend_api_client.dart:179`.

The full JSON response body of `/users/me` (current user's profile — typically
includes name, username, phone/email depending on backend schema, role,
profile-completion state, blocked-status, etc., per
`AuthUserDto.fromBackendJson` usage) is stored **unencrypted** in
SharedPreferences under key
`laqta_response_cache_v1:GET /users/me?` for up to 5 minutes, and other users'
public profiles (`/users/{username}`) for up to 10 minutes. This is correctly
purged on logout via `CacheInterceptor().clearUserCache()`
(`backend_auth_remote_data_source.dart:164`), so the "shared device, next user
logs in cleanly" scenario is covered for this specific cache. Residual risk is
limited to: (a) the TTL window while a session is still active (acceptable —
session is the same user), and (b) any crash/force-kill of the app between
login and a manual logout (i.e. the user never explicitly logs out) leaving
this plaintext profile cache on disk indefinitely — there is no app-restart or
periodic cache expiry sweep observed beyond the `isFresh` TTL check, and stale
entries are only deleted lazily (on next `get()` for that exact key, or at
explicit logout). Rated MEDIUM rather than HIGH because (1) it requires local
filesystem/backup access, (2) `clearUserCache()` does correctly fire on the
primary logout path, (3) payment/card data is explicitly excluded by design
elsewhere.

### LOW — NEW: Dead-code `RequestQueue` would persist full HTTP headers (including Authorization bearer tokens) and request bodies of failed offline writes to plaintext SharedPreferences if ever wired up
**File/line:** `lib/core/network/connectivity/request_queue.dart:9-41`
(`QueuedWriteRequest.toJson()` serializes `headers` verbatim) and
`:60-75` (`enqueue`/persisted via `prefs.setString(_storageKey, ...)`,
key `'laqta_write_request_queue_v1'`, `:53`).

This class explicitly excludes `/payment` and `/stripe` paths
(`_isPaymentRequest`, `:171-174`) showing payment-awareness was considered, but
it makes no attempt to strip the `Authorization` header or auth token from
`request.headers` before persisting — so any queued POST/PUT/PATCH would write
the bearer access token plus the full request body (which could include
profile edits, booking details, etc.) to plaintext SharedPreferences.
Verified via `grep -rn "RequestQueue" lib/` that `RequestQueue` is
**never instantiated** anywhere in the app (only its own class/constructor
definition matches) — it is currently dead code with zero exploitability. Flag
this now so that if/when offline write-queueing is wired into
`BackendApiClient`, the headers must be redacted (or the queue itself moved to
`flutter_secure_storage`) before going live.

### LOW — INFO: Non-sensitive caches left on shared devices after logout (expected behavior, listed for completeness)
The following SharedPreferences keys are not auth-tied and are reasonable to
leave (session-independent UI prefs), but are listed because the audit was
asked to trace "everything that lingers":
- `language` / `theme` / `reduceMotion` / `notificationsEnabled` —
  `lib/core/storage/secure_storage_manager.dart:10-16` (explicit allowlist),
  also written directly in `lib/core/providers/locale_provider.dart:24`,
  `lib/core/providers/theme_provider.dart:25`,
  `lib/features/settings/presentation/screens/settings_screen.dart:41-42,202`.
  Device-level UI prefs, not user-PII. Acceptable to persist across accounts.
- `recent_searches` — `lib/features/search/presentation/screens/search_screen.dart:54,66`.
  Stores the local user's free-text search queries in plaintext, not
  cleared on logout. Could reveal search intent/interests to the next user
  of a shared device. Recommend clearing on logout if search terms can be
  personally revealing (e.g. searching photographers by name/location).
- `laqta_analytics_queue_v1` — `lib/core/analytics/analytics_service.dart:11,67-72`.
  Buffers outbound analytics events; explicitly sanitizes out
  `name/phone/email/token/password/authorization/payment/card` fields before
  queueing (`analytics_service.dart:75-92`), and is keyed by an anonymous
  device id (`DeviceBinder`), not the user id, so low PII risk even though
  unencrypted and not cleared on logout.
- `laqta_feature_flags_v1` — `lib/core/config/feature_flags.dart:73,127`.
  Remote-config flags only, no user data.
- Photographer per-device availability cache (key in
  `lib/features/photographer/presentation/screens/availability_screen.dart`,
  `_prefsKey`, written at `:108-109`) — weekly schedule template, not
  PII, not cleared on logout. Low impact.

### INFO — No SQL/Hive database present despite sqflite appearing in pubspec.lock
`pubspec.lock:1045-1081` lists `sqflite`/`sqflite_android`/`sqflite_common`/
`sqflite_darwin`/`sqflite_platform_interface` as resolved packages, but
`pubspec.yaml` has no direct `sqflite:` dependency line and no file under
`lib/` imports `package:sqflite` or calls `openDatabase`. This is a transitive
dependency (likely pulled in by another plugin's dependency graph) and is not
itself a finding — included here only so the next auditor doesn't have to
re-derive this when they see `sqflite` in the lockfile.

---

## Summary Table

| # | Severity | Status | Area | File:line |
|---|----------|--------|------|-----------|
| 1 | HIGH | NEW | Legacy plaintext JWT/userId migration path still live | token_manager.dart:246-262; app_constants.dart:208-209 |
| 2 | HIGH | NEW | `wipeAll()` full-wipe method exists but is never called at logout | secure_storage_manager.dart:56-66; backend_auth_remote_data_source.dart:148-167 |
| 3 | MEDIUM | NEW | Profile cache (userId/role/blocked) not cleared synchronously at logout | app_router.dart:684-717,559; main_app_screen.dart:103-113 |
| 4 | MEDIUM | NEW | `/users/me` & `/users/{username}` response bodies cached in plaintext prefs (cleared on logout, but persists if app is killed before logout) | response_cache.dart:42-79; cache_policy.dart:16-24; cache_interceptor.dart:31-48 |
| 5 | LOW | NEW | Dead-code RequestQueue would leak Authorization headers if ever activated | request_queue.dart:9-41,60-75,171-174 |
| 6 | LOW | INFO | Misc non-sensitive prefs (language/theme/recent_searches/analytics queue/feature flags/availability cache) persist post-logout | various, see list above |
| 7 | INFO | — | sqflite is a transitive-only dependency; no DB in use | pubspec.lock:1045-1081 |
| — | — | RE-CONFIRMED | Tokens correctly stored exclusively via flutter_secure_storage | token_manager.dart:32-37,185-205,216-220 |

No payment/card data (CVV, last4, billing address) was found persisted anywhere
in local storage — `request_queue.dart` explicitly filters `/payment` and
`/stripe` paths, and no other SharedPreferences/file-cache site references
card or billing fields.
