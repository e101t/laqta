# Agent 11 — Independent Re-Verification of Phase 2 Orchestrator Actions

Scope: read-only re-derivation of the 7 claims in `audit_reports/10_orchestrator_actions.md` from
fresh evidence (current repo state + current build artifacts). No files were modified except this
report. Every claim below was independently re-checked; none were accepted on the orchestrator's
word alone.

---

## 1. Post-fix libapp.so hash (arm64-v8a)

**Verdict: CONFIRMED**

Extracted the arm64-v8a slice myself from the current build artifact and hashed it independently:

```
$ unzip -o "build/app/outputs/bundle/productionRelease/app-production-release.aab" \
    "base/lib/arm64-v8a/libapp.so" -d /tmp/aab_extract
$ sha256sum /tmp/aab_extract/base/lib/arm64-v8a/libapp.so
c47c0ab51f9ce90f43ab13efab4c9d264cc9bfdd976aac308153f6416eb8fea6 *base/lib/arm64-v8a/libapp.so
```

Got hash: `c47c0ab51f9ce90f43ab13efab4c9d264cc9bfdd976aac308153f6416eb8fea6`

Compared programmatically against both known-bad hashes:
- `9818c3a8b89135e2093a7abc3388da7f2c65278c01a8fc2854766f5772838b0` — no match
- `5706815d82d36e06479013865004d0dd92aedf25aa039b4b694a69b78530ae80` — no match (this string is
  also 65 hex chars, one too long for a SHA-256 digest, likely a transcription artifact in the
  task prompt — regardless, the computed hash is unambiguously different from it)

The literal prefix `c47c0ab5...` matches what the orchestrator reported. The `.aab` file's mtime
(`2026-06-23 06:58`) is today, consistent with a fresh rebuild rather than a stale artifact.
`git status` independently confirms the source files the orchestrator claims to have changed
(certificate_pinning.dart, backend_api_client.dart, request_signer.dart, release.yml,
backend_auth_remote_data_source.dart, etc.) are indeed all modified (`M`) relative to the last
commit, consistent with a from-source rebuild reflecting those fixes.

---

## 2. TLS pin fail-open fix in certificate_pinning.dart

**Verdict: CONFIRMED**

Read the live file (`lib/core/network/certificate_pinning.dart`, lines 106-127):

```dart
    } on CertificatePinningException catch (error) {
      lastFailure.value = error;
      rethrow;
    } on TimeoutException catch (error) {
      final failure = CertificatePinningException(
        host,
        'Pin verification timed out: $error',
      );
      lastFailure.value = failure;
      throw failure;
    } on SocketException catch (error) {
      final failure = CertificatePinningException(
        host,
        'Pin verification failed: $error',
      );
      lastFailure.value = failure;
      throw failure;
    } catch (error) {
      final failure = CertificatePinningException(host, error.toString());
      lastFailure.value = failure;
      throw failure;
    }
```

Both the `TimeoutException` and `SocketException` catch blocks construct a
`CertificatePinningException` and `throw` it — this fails closed. There is no remaining silent
`return`/`pass`-style swallow anywhere in `verifyHost`. The generic `catch (error)` fallback also
throws, so any other unexpected failure mode fails closed too. `PinnedHttpClient.send` (line 173)
calls `CertificatePinning.verifyHost(request.url)` unconditionally before delegating to the inner
HTTP client, so a thrown exception genuinely blocks the request.

---

## 3. Payment-retry idempotency: single requestId threaded through retries

**Verdict: CONFIRMED**

`lib/core/network/signing/request_signer.dart` (`buildHeaders`, lines 24-34):

```dart
  Future<Map<String, String>> buildHeaders({
    required String method,
    required Uri uri,
    String? body,
    String? accessToken,
    bool sensitive = false,
    String? requestId,
  }) async {
    final resolvedRequestId = (requestId == null || requestId.isEmpty)
        ? _uuid.v4()
        : requestId;
```

It only mints a new UUID if no `requestId` is supplied — otherwise it reuses the caller-supplied
one.

`lib/core/services/backend_api_client.dart`, `_send` (lines 134-228):

```dart
  Future<dynamic> _send({
    ...
    int rateLimitAttempt = 0,
    String? idempotencyRequestId,
  }) async {
    final requestId = idempotencyRequestId ?? const Uuid().v4();
    ...
    headers.addAll(
      await _requestSigner.buildHeaders(
        ...
        requestId: requestId,
      ),
    );
    ...
    if (response.statusCode == 429 && rateLimitAttempt < 3) {
      await Future<void>.delayed(_rateLimitDelay(rateLimitAttempt));
      return _send(
        ...
        rateLimitAttempt: rateLimitAttempt + 1,
        idempotencyRequestId: requestId,
      );
    }

    if (authorized && response.statusCode == 401 && retryOnUnauthorized) {
      final refreshed = await _refreshBackendSession();
      if (refreshed) {
        return _send(
          ...
          retryOnUnauthorized: false,
          idempotencyRequestId: requestId,
        );
      }
      await _sessionService.clear();
    }
```

`requestId` is generated once per logical call (first invocation, `idempotencyRequestId` is null),
then explicitly re-passed as `idempotencyRequestId: requestId` on both the 429 rate-limit retry
recursion and the 401 refresh-and-retry recursion. Each recursive `_send` call reuses the same
value rather than letting `buildHeaders` mint a fresh UUID. Genuinely threaded, not just claimed.

Note: `backend_api_client.dart` imports `package:laqta/core/network/request_signer.dart`, which is
confirmed to be a one-line re-export shim (`export 'package:laqta/core/network/signing/request_signer.dart';`)
pointing at the same file referenced in the orchestrator's claim — same code, different import path.

---

## 4. build/debug-info removed from public release artifact in release.yml

**Verdict: CONFIRMED**

Current `.github/workflows/release.yml`:

```yaml
      - uses: actions/upload-artifact@v4
        with:
          name: laqta-android-release
          path: |
            build/app/outputs/bundle/productionRelease/app-production-release.aab
            build/app/outputs/flutter-apk/app-release-signed.apk

      - name: Upload debug symbols (restricted, not attached to public release)
        uses: actions/upload-artifact@v4
        with:
          name: laqta-android-debug-symbols
          path: build/debug-info

  github_release:
    runs-on: ubuntu-latest
    needs: build_and_sign
    permissions:
      contents: write
    steps:
      - uses: actions/download-artifact@v4
        with:
          name: laqta-android-release
          path: release-artifacts
      - uses: softprops/action-gh-release@v2
        with:
          generate_release_notes: true
          files: release-artifacts/**
```

`build/debug-info` is uploaded under a separate artifact name (`laqta-android-debug-symbols`), and
the `github_release` job only downloads `laqta-android-release` (the .aab/.apk artifact) before
attaching `release-artifacts/**` to the GitHub release. The debug-info artifact is never
downloaded or referenced in `github_release`, so it cannot end up in the public release assets.

---

## 5. Tika CVE-2025-66516 — file_picker 10.3.10 already bundles patched Tika 3.2.3

**Verdict: CONFIRMED**

`pubspec.lock` confirms the exact resolved version:

```
  file_picker:
    dependency: "direct main"
    description:
      name: file_picker
      sha256: "57d9a1dd5063f85fa3107fb42d1faffda52fdc948cefd5fe5ea85267a5fc7343"
      url: "https://pub.dev"
    source: hosted
    version: "10.3.10"
```

Located the actual pub cache on this machine at
`C:\Users\Devil\AppData\Local\Pub\Cache\hosted\pub.dev\file_picker-10.3.10` and opened the real
`CHANGELOG.md`:

```
- Updated Tika library to resolve vulnerability CVE-2025-66516 and CVE-2025-54988 (Critical XXE vulnerability).
...
- Updated Apache Tika to 3.2.3 to address CVE-2025-66516 and CVE-2025-54988 (Critical XXE vulnerability).
```

Went one step further than the orchestrator's stated method and confirmed it at the build-config
level too — `android/build.gradle` inside the same cached package directory:

```
implementation "org.apache.tika:tika-core:3.2.3"
```

This is stronger evidence than the changelog alone: it is the literal dependency version that gets
compiled into the Android build, not just a release-notes claim. Patched Tika 3.2.3 is confirmed
bundled; the vulnerable <=3.2.1 line is not present in the resolved package.

---

## 6. Logout flow wipes all storage via SecureStorageManager.wipeAll()

**Verdict: CONFIRMED**

`lib/features/auth/data/datasources/backend_auth_remote_data_source.dart`, `signOut()`
(lines 148-167):

```dart
  @override
  Future<void> signOut() async {
    final refreshToken = await _sessionService.getRefreshToken();
    await BackendNotificationSyncService.instance.deleteCurrentDeviceToken();
    if (refreshToken != null && refreshToken.isNotEmpty) {
      try {
        await _apiClient.post(
          '/auth/logout',
          authorized: false,
          body: {'refreshToken': refreshToken},
        );
      } catch (_) {
        // Logout is local-first; backend revocation is best effort when offline.
      }
    }
    await _sessionService.clear();
    await CacheInterceptor().clearUserCache();
    await SecureStorageManager.instance.wipeAll();
    _cachedUser = null;
  }
```

`wipeAll()` is genuinely called (line 165). Grepped the whole file and the whole `lib/` tree for
`clearMemoryTier` — the only remaining occurrences are inside
`lib/core/storage/secure_storage_manager.dart` itself (the method definition, and an internal call
from within `wipeAll()` at line 57: `wipeAll()` calls `clearMemoryTier()` as a sub-step). No
narrower standalone `clearMemoryTier()` call remains in the auth datasource — `wipeAll()` is a
strict superset of the old behavior, not a replacement that drops functionality.

---

## 7. Legacy plaintext JWT migration path in token_manager.dart is read/delete-only

**Verdict: CONFIRMED**

Grepped the entire `lib/` tree (not just `token_manager.dart`) for every reference to the legacy
plaintext SharedPreferences keys (`AppConstants.keyBackendJwt`, `AppConstants.keyBackendUserId`):

```
lib/core/auth/token_manager.dart:209:    await prefs.remove(AppConstants.keyBackendJwt);
lib/core/auth/token_manager.dart:210:    await prefs.remove(AppConstants.keyBackendUserId);
lib/core/auth/token_manager.dart:224:      await prefs.remove(AppConstants.keyBackendJwt);
lib/core/auth/token_manager.dart:225:      await prefs.remove(AppConstants.keyBackendUserId);
lib/core/auth/token_manager.dart:253:    final legacyToken = prefs.getString(AppConstants.keyBackendJwt);
lib/core/auth/token_manager.dart:260:      userId: prefs.getString(AppConstants.keyBackendUserId),
lib/core/constants/app_constants.dart:208:  static const String keyBackendJwt = 'backendJwt';
lib/core/constants/app_constants.dart:209:  static const String keyBackendUserId = 'backendUserId';
lib/features/settings/presentation/screens/settings_screen.dart:195:    await prefs.remove(AppConstants.keyBackendJwt);
lib/features/settings/presentation/screens/settings_screen.dart:196:    await prefs.remove(AppConstants.keyBackendUserId);
```

Every single non-declaration reference across the whole codebase (not limited to
`token_manager.dart`) is either `.remove()` (delete) or `.getString()` (read). There is no
`.setString()` call anywhere writing plaintext token/userId data under these keys. The migration
path in `_migrateLegacyTokenIfNeeded()` (lines 246-262) reads the legacy plaintext value once and
immediately re-saves it into secure storage via `saveTokens(...)` — it never writes the plaintext
value back into `SharedPreferences`. This confirms the path is genuinely a one-way
read-then-delete/migrate flow with no live write vector reintroducing plaintext token storage.

---

## Bonus: independent flutter analyze re-run

**Verdict: CONFIRMED**

```
$ flutter analyze
Analyzing la s...
No issues found! (ran in 4.7s)
```

Ran fresh against the current working tree (Flutter 3.41.7 / Dart 3.11.5). No errors or warnings,
matching the orchestrator's claim.

---

## Summary

| # | Claim | Verdict |
|---|-------|---------|
| 1 | Post-fix libapp.so hash differs from known-bad hashes | CONFIRMED |
| 2 | TLS pin fail-open bug fixed (throws, fails closed) | CONFIRMED |
| 3 | Single requestId threaded through 429/401 retries | CONFIRMED |
| 4 | build/debug-info removed from public release artifact | CONFIRMED |
| 5 | file_picker 10.3.10 bundles patched Tika 3.2.3 | CONFIRMED |
| 6 | Logout now calls wipeAll() instead of clearMemoryTier() | CONFIRMED |
| 7 | Legacy plaintext JWT path is read/delete-only, no write | CONFIRMED |
| — | flutter analyze: no new issues | CONFIRMED |

All 7 claims plus the bonus static-analysis check were independently confirmed with fresh,
first-hand evidence (hashing the actual rebuilt artifact, reading live source files, reading the
actual pub-cache package contents, and re-running tooling). No contradictions found and no claims
required falling back to "could not verify."
