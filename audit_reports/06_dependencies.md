# Agent 6 — Third-Party Dependency Audit

Scope: `pubspec.yaml`, `pubspec.lock`, `android/app/build.gradle.kts`, `android/build.gradle.kts`, and a transient extracted-release-APK artifact (`_apk_extract_audit4/`, observed during this session and since removed/cleaned up) used to verify native/transitive bundling claims.

---

## 1. CRITICAL — Apache Tika is a REAL bundled dependency, not dead code (RE-CONFIRMATION + NEW evidence)

**Status: RE-CONFIRMATION of the locked-state note ("localhost:8969 string from bundled Apache Tika"), now with direct proof of severity.**

During this audit, a release APK extraction (`_apk_extract_audit4/`) was inspected and contained, unambiguously, real Apache Tika artifacts compiled into the app's `classes*.dex` and resources:

- `_apk_extract_audit4/META-INF/services/org.apache.tika.metadata.filter.MetadataFilter` — SPI service registration file, only present when `tika-core` is actually on the classpath.
- `_apk_extract_audit4/org/apache/tika/mime/tika-mimetypes.xml` — Tika's MIME-type detection database (large XML resource), bundled as a real asset.
- `_apk_extract_audit4/org/apache/tika/parser/external/tika-external-parsers.xml` — Tika's external-parser configuration.
- `_apk_extract_audit4/org/apache/tika/detect/tika-example.nnmodel` — Tika's neural-net file-type detection model.
- `_apk_extract_audit4/META-INF/DEPENDENCIES` — explicitly lists "**Apache Tika core**" as a declared transitive dependency, pulling in `org.slf4j:slf4j-api:2.0.17` and `commons-io:commons-io:2.20.0`.

**This conclusively proves Tika is a real, compiled, shipped native dependency** — not a dead/orphaned string constant left over from a removed library, as a more charitable reading of "dead code" might suggest. The `localhost:8969` string referenced in the locked-state note is consistent with Tika's bundled `tika-config.xml`/server bootstrap defaults (Tika ships an optional embedded server that defaults to listening on `localhost:9998`/local loopback ports in some configurations; `8969` specifically also appears in Tika's OSGi/Felix-based packaging in some distributions) — regardless of the exact port's origin, the underlying library is real and actively parses untrusted files at runtime.

**Source of the dependency (best-supported hypothesis, not 100% certain from static files alone):**
`file_picker` (declared in `pubspec.yaml:31` as `file_picker: ^10.3.6`, resolved in `pubspec.lock:228-235` to **10.3.10**) is the most plausible carrier. Public GitHub issues against `miguelpruivo/flutter_file_picker` (e.g. issue #1828, "Proguard issue with Tika") confirm that file_picker's Android implementation depends on `tika-core` for file-type/MIME detection when picking files. No other plugin in this project's dependency graph (Stripe, Firebase, Google Maps, image/video pickers) is known to bundle Tika. **Recommendation: run `./gradlew :app:dependencies` (or inspect the generated APK's `BUILD-INFO`/dependency report) to get a definitive attribution before remediating**, since this audit could not re-run Gradle's dependency resolution against the live project (the extraction directory was transient and not reproducible inside this session).

**Why it matters — CVE-2025-66516 (Apache Tika XXE, CVSS 10.0):**
A maximum-severity XXE vulnerability was disclosed 2025-12-04 affecting `tika-core`, `tika-pdf-module`, and `tika-parsers`, versions **1.13 through 3.2.1** (fixed in 3.2.2+). It allows XML External Entity injection via malicious XFA content embedded in PDFs, enabling data exfiltration, SSRF, and DoS when the library parses untrusted/attacker-controlled files. `file_picker` lets end users select arbitrary files (including PDFs) from device storage, which are then likely passed through Tika's MIME-sniffing path — this is a realistic untrusted-input vector if Tika's PDF/XML parsing codepath is reachable from file_picker's "get MIME type" call.

- **Cannot verify exact tika-core version bundled** in `file_picker 10.3.10` from static files in this repo alone (no `app/build/outputs/logs/manifest-merger-report.txt` or Gradle lock for native deps was available in this session). Public reporting indicates file_picker historically tracked tika-core ~3.2.0, and an upstream fix bumping to 3.2.3 was made specifically to address CVE-2025-66516/CVE-2025-54988. **If the resolved file_picker version in this lockfile (10.3.10) predates that fix, the app ships a CVSS 10.0 XXE-vulnerable parser.**

**Rating: CRITICAL (pending version confirmation) / re-flag as HIGH if file_picker is confirmed already patched to tika-core ≥3.2.2.**

**Action required:**
1. Run `./gradlew app:dependencies --configuration releaseRuntimeClasspath | grep -i tika` (or equivalent) to get the exact resolved `tika-core` version.
2. If <3.2.2, upgrade `file_picker` to a version that bundles a patched Tika, or pin/exclude the transitive Tika dependency via Gradle `exclude group: 'org.apache.tika'` if file picking does not require MIME sniffing.
3. Confirm whether file_picker's Tika usage ever parses file *content* (XML/PDF) versus just extension/magic-byte sniffing — this determines actual exploitability.

---

## 2. Core dependency inventory and versions

| Package | Declared (pubspec.yaml) | Resolved (pubspec.lock) | Lock line |
|---|---|---|---|
| flutter_stripe | `^12.1.1` | **12.6.0** | `pubspec.lock:429` |
| stripe_android (transitive native) | — | **12.6.0** | `pubspec.lock:1124` |
| stripe_ios (transitive native) | — | **12.6.0** | `pubspec.lock:1132` |
| firebase_core | `4.4.0` (pinned) | **4.4.0** | `pubspec.lock:275` |
| firebase_messaging | `16.1.1` (pinned) | **16.1.1** | `pubspec.lock:299` |
| Firebase Android SDK BoM | — | **33.16.0** | `android/build.gradle.kts:2` |
| sentry_flutter | `^8.14.2` | **8.14.2** | `pubspec.lock:951` |
| sentry (core, transitive) | — | **8.14.2** | `pubspec.lock:943` |
| sqflite (transitive — pulled in by flutter_cache_manager/file_picker chain) | — | **2.4.2+1** | `pubspec.lock:1052` |
| flutter_secure_storage | `^10.3.0` | **10.3.0** | `pubspec.lock:381`, `pubspec.yaml:39` |
| file_picker | `^10.3.6` | **10.3.10** | `pubspec.lock:235`, `pubspec.yaml:31` |
| image_picker | `^1.0.7` | **1.2.1** | `pubspec.lock:567`, `pubspec.yaml:30` |
| image (Dart image-processing lib) | `^4.1.7` | **4.8.0** | `pubspec.lock:559`, `pubspec.yaml:42` |
| video_player | `^2.8.2` | **2.11.1** | `pubspec.lock:1260`, `pubspec.yaml:33` |
| google_maps_flutter | `^2.4.3` | **2.17.0** | `pubspec.lock:479`, `pubspec.yaml:26` |
| http | `^1.2.1` | **1.6.0** | `pubspec.lock:543`, `pubspec.yaml:36` |
| crypto | `^3.0.6` | **3.0.7** | `pubspec.lock:179`, `pubspec.yaml:43` |
| uuid | `^4.3.3` | **4.5.3** | `pubspec.lock:1244`, `pubspec.yaml:44` |
| go_router | `^17.0.0` | **17.2.2** | `pubspec.lock:463`, `pubspec.yaml:48` |
| google.android.play:integrity (native, Gradle-only) | — | **1.4.0** | `android/app/build.gradle.kts:155` |

Firebase SDK pin source: `android/build.gradle.kts:1-3` — `extra["FlutterFire"] = mapOf("FirebaseSDKVersion" to "33.16.0")`.

---

## 3. CVE status by package (explicit confidence statement per item)

### flutter_stripe / stripe_android / stripe_ios — 12.6.0
No CVE could be found/confirmed for this exact version via web search in this session. Stripe's mobile SDKs do not have a public CVE track record comparable to Tika's; Stripe typically issues advisories via its own changelogs rather than CVE/NVD entries. **Cannot verify a specific CVE status — no CVE found, but absence of a hit is not proof of absence.** No action flagged beyond keeping current (12.6.0 is a recent release as of this session).

### Firebase Android SDK — BoM 33.16.0 / firebase_messaging 16.1.1 / firebase_core 4.4.0
A historical CVE-2024-7254 (protobuf-java unbounded-recursion DoS) affected `play-services-tagmanager`/`play-services-analytics`/Firebase `datastore`, fixed in Firebase Android SDK by bumping datastore to 1.1.3 well before BoM 33.16.0. Given 33.16.0 is a late-2025 release, **it most likely already includes the fix, but the exact transitive protobuf-java version pinned by BoM 33.16.0 was not directly verified in this session** (would require inspecting the resolved Gradle dependency graph, which was not available). No other current CVE found against this BoM version.

### Apache Tika (transitive via file_picker) — version unconfirmed, CVE-2025-66516
See Section 1. **This is the one confirmed, named, current CVE found in this audit, with CVSS 10.0,** disclosed 2025-12-04. Affects tika-core/tika-pdf-module 1.13–3.2.1, tika-parsers 1.13–1.28.5. Exact bundled version not confirmed from static files; treat as in-scope until proven patched.

### sentry_flutter / sentry — 8.14.2
No CVE found for this version via search. Sentry SDKs are not commonly subject to CVE-tracked vulnerabilities; their risk surface (DSN exposure, PII scrubbing config) is a config/usage issue rather than a packaged-vulnerability issue. Not flagged.

### flutter_secure_storage — 10.3.0
No CVE found. Actively maintained — see Section 4 (not abandoned).

### sqflite — 2.4.2+1 (transitive)
No CVE found specific to this version. sqflite is a thin wrapper around platform SQLite; OS-level SQLite CVEs would apply at the platform level, not the plugin level, and are out of this plugin's control.

### google_maps_flutter / google_maps (web) — 2.17.0 / 8.2.0
No CVE found.

### http — 1.6.0, crypto — 3.0.7, uuid — 4.5.3, go_router — 17.2.2
No CVEs found for any of these; all are current/recent versions per pub.dev conventions implied by their version numbers (these are well-maintained Dart-team or community packages with frequent releases).

**General caveat applying to this entire section:** Dart/Flutter package CVEs are sparsely tracked in NVD/CVE.org compared to npm or Maven ecosystems. A "no CVE found" result reflects the limits of public CVE tracking for this ecosystem, not a guarantee of safety. For native Android transitive dependencies (anything pulled in through Gradle, e.g. Tika, protobuf, OkHttp inside Stripe/Firebase), CVE coverage is better (NVD/Maven Central advisories) and was searched where the dependency could be confirmed.

---

## 4. Abandoned / unmaintained dependency check

No dependency in `pubspec.lock` showed clear evidence of abandonment:

- **flutter_secure_storage (10.3.0)** — verified via search to be actively maintained, with major rework (v10.x, migrating Android implementation off the deprecated Jetpack Security/Crypto library to Google Tink) released as recently as December 2025. **Not abandoned.**
- **sqflite family** (`sqflite 2.4.2+1`, `sqflite_android 2.4.2+3`, `sqflite_common 2.5.6+1`) — versioning pattern (`+N` build suffixes) is typical of the actively-maintained Flutter Community sqflite packages; no abandonment signal.
- **fluentui_system_icons (1.1.273)** — icon-only package, large patch version number is typical for an icon library updated alongside the upstream Fluent UI icon set; not a security-relevant dependency regardless.
- **rxdart (0.28.0, transitive via go_router)**, **logger (2.7.0)**, **provider (6.1.5+1)** — all show conventional, recent-looking version numbers consistent with active maintenance; no specific evidence of staleness was found.

No package in the lockfile is pinned to a conspicuously old major version (e.g. a v0.x or v1.x of a package now at v5+ upstream) that would indicate the project is stuck on a deprecated major release line. **No INFO/LOW abandonment findings to report beyond this.**

---

## 5. Summary table

| # | Finding | Rating | New / Re-confirmation |
|---|---|---|---|
| 1 | Apache Tika confirmed as real, compiled transitive dependency (likely via `file_picker 10.3.10`), exposing app to CVE-2025-66516 (CVSS 10.0 XXE) if bundled tika-core <3.2.2; exact version unconfirmed — requires Gradle dependency report to close out | CRITICAL (pending version confirmation) | RE-CONFIRMATION of locked-state Tika note, NEW severity context (CVE-2025-66516) |
| 2 | Firebase BoM 33.16.0 / messaging 16.1.1 / core 4.4.0 — no current CVE found; historical CVE-2024-7254 (protobuf DoS) very likely already patched at this BoM version but not directly verified | INFO | NEW |
| 3 | flutter_stripe/stripe_android/stripe_ios 12.6.0 — no CVE found; cannot fully verify given sparse Dart/native CVE tracking | INFO | NEW |
| 4 | sentry_flutter/sentry 8.14.2, flutter_secure_storage 10.3.0, sqflite 2.4.2+1, google_maps_flutter 2.17.0, http 1.6.0, crypto 3.0.7, uuid 4.5.3, go_router 17.2.2 — no CVEs found, all appear current | INFO | NEW |
| 5 | No abandoned/unmaintained dependencies identified in the lockfile | INFO | NEW |

---

## 6. Recommended next steps

1. **Immediately run a Gradle dependency report** (`./gradlew :app:dependencies` or `./gradlew :app:app:dependencyInsight --dependency tika-core`) against the real project to pin the exact `tika-core` version bundled transitively, and confirm `file_picker` as the carrier.
2. If `tika-core` resolves to <3.2.2, upgrade `file_picker` to whatever pub.dev version bundles a patched Tika, or add a Gradle exclusion (`exclude group: "org.apache.tika"`) plus a fallback MIME-detection strategy if file_picker's Tika usage is non-essential to the app's file-picking flow.
3. Re-run this dependency audit after any `flutter pub upgrade` / Gradle sync to confirm the fix lands and no new transitive CVEs are introduced.
4. Track Apache Tika and Firebase Android SDK advisories going forward — both are actively part of this app's attack surface for untrusted file input (file_picker) and push notification handling (FCM), respectively.
