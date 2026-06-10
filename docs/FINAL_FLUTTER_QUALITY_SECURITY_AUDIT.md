# LAQTA Flutter Quality and Security Audit

Date: 2026-06-05

## Commands Run

- `flutter analyze --fatal-infos`
- `flutter test`
- `dart fix --dry-run`
- `flutter pub outdated`
- `flutter test --coverage`
- `flutter build apk --flavor production --release`
- `flutter build appbundle --flavor production --release`
- `rg "core/mock|LaqtaMarketplaceData|mock_owner|looksLikePlaceholder|_mockFeedItems|_mockExploreData" lib test`
- `rg -n "print\(" lib -g "*.dart"`
- `rg -n "debugPrint\(" lib -g "*.dart"`
- `rg -n "password|secret|api_key" lib -g "*.dart"`
- `rg -n "print\(|debugPrint\(" lib -g "*.dart"`
- `rg -n "http://" lib -g "*.dart"`
- `rg -n "TODO|FIXME" lib -g "*.dart"`
- `rg -n "test|mock|dummy" lib -g "*.dart"`

## Results

| Check | Result |
| --- | --- |
| Flutter analyze | PASS, no issues |
| Dart fix dry-run | PASS, nothing to fix |
| Flutter tests | PASS, 151/151 |
| Flutter coverage command | PASS |
| APK build | PASS |
| AAB build | PASS |
| `print(` scan | 0 matches |
| `debugPrint(` scan | 0 matches |
| Runtime marketplace mock scan | 0 matches in `lib/` and `test/` |
| TODO/FIXME scan | 0 matches |
| Insecure production HTTP | No production release issue found |
| Hardcoded credentials | No hardcoded secret value found |

## Coverage

Coverage was generated at `coverage/lcov.info`.

- Files in LCOV: 384
- Files with covered lines: 158
- File coverage: 41.15%
- Lines hit: 3721
- Lines found: 20737
- Line coverage: 17.94%

Target coverage of 85% is not met. This is a quality target, not a build blocker.

## Build Size

- APK: `build/app/outputs/flutter-apk/app-production-release.apk`
- APK size: approximately 97.3 MiB
- AAB: `build/app/outputs/bundle/productionRelease/app-production-release.aab`
- AAB size: approximately 73.0 MiB

Latest release copies:

- APK: `C:\Users\Devil\Desktop\LAQTA_release_backup\LAQTA-production-release.apk`
- APK SHA-256: `677F5479C9E2FEE2FBA20080AFAA014523ECA9BE02E4DE1B00FF4AB70362D470`
- AAB: `C:\Users\Devil\Desktop\LAQTA_release_backup\LAQTA-production-release.aab`
- AAB SHA-256: `AEA75A17D1658D2DA6AE7E667B02523E0A63065A1DC0BE25D0AB443496C29AF5`

The APK is under 100 MiB when measured the same way Flutter reports size. It is slightly above 100,000,000 bytes if using strict decimal bytes.

## Security Scan Notes

The credential keyword scan finds legitimate auth code references such as `password` field names, controller names, request body keys, and redaction rules. No literal secret value was found in `lib/`.

The HTTP scan finds development-only local endpoints:

- `lib/core/config/env/dev_config.dart`
- `lib/core/services/backend_config.dart`

Production uses `https://api.laqta.cloud`.

## Performance Notes

Latest measured startup evidence:

- Android Activity cold launch: 1548ms
- Previous Flutter startup trace: first frame 2037ms
- Target cold start under 3 seconds: PASS

The DevTools UI recording was not exported in this run. CLI startup trace and Android `am start -W` were used as measurable evidence.

## Remaining Quality Gaps

1. Coverage is below the 85% target.
2. Several dependencies have newer available versions. No automated upgrade was applied because this can introduce release risk without a dedicated compatibility pass.

## Runtime Mock Cleanup

Marketplace runtime mock fallbacks were removed from:

- `lib/features/dashboard/presentation/screens/customer_dashboard_screen.dart`
- `lib/features/explore/presentation/screens/explore_screen.dart`
- `lib/features/venues/presentation/screens/venues_list_screen.dart`
- `lib/features/venues/presentation/screens/venue_details_screen.dart`
- `lib/features/locations/presentation/screens/photo_location_details_screen.dart`
- `lib/features/photographer/presentation/screens/photographer_profile_screen.dart`
- `lib/features/monetization/presentation/screens/subscription_plans_screen.dart`
- `lib/features/monetization/presentation/screens/sponsored_ad_screen.dart`

The old marketplace mock data file was moved out of runtime code:

- `legacy/flutter_mock_archive/laqta_marketplace_data.dart`

## Decision

Build quality and baseline security checks pass.

Strict quality certification is PARTIAL until coverage and mock fallback paths are addressed.
