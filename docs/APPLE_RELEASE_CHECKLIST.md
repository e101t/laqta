# LAQTA Apple Release Checklist

Date: 2026-05-31

## Sources

- Apple App Store Connect screenshot specifications: https://developer.apple.com/help/app-store-connect/reference/screenshot-specifications/
- Apple App privacy details: https://developer.apple.com/app-store/app-privacy-details/
- Apple Xcode capabilities guidance: https://developer.apple.com/documentation/xcode/adding-capabilities-to-your-app
- Apple certificate overview: https://developer.apple.com/help/account/certificates/certificates-overview/

## Current iOS Audit

| Item | Status | Evidence |
|---|---|---|
| iOS project exists | PASS | `ios/Runner.xcodeproj`, `ios/Runner.xcworkspace`, `ios/Runner/Info.plist` exist |
| Bundle identifier | PASS | `PRODUCT_BUNDLE_IDENTIFIER = com.laqta.laqta` |
| Display name | PASS | `CFBundleDisplayName = LAQTA` |
| Firebase iOS config | PARTIAL | `ios/Runner/GoogleService-Info.plist` exists and bundle id matches `com.laqta.laqta` |
| Push notification entitlement | FAIL | `ios/Runner/Runner.entitlements` is missing |
| APNs capability | FAIL | No `aps-environment` entitlement found |
| Apple signing team | FAIL | `DEVELOPMENT_TEAM` is not configured in `project.pbxproj` |
| Code signing style | PARTIAL | Test target uses Automatic; Runner target does not show complete signing team/profile config |
| CocoaPods config | FAIL | `ios/Podfile` is missing |
| iOS release build verification | UNVERIFIED | Cannot run `flutter build ipa` on Windows |
| App icon asset catalog | PASS | `ios/Runner/Assets.xcassets/AppIcon.appiconset` includes iOS marketing icon |
| Camera/photo usage strings | PASS | `NSCameraUsageDescription`, `NSPhotoLibraryUsageDescription`, `NSPhotoLibraryAddUsageDescription` exist |
| Production API endpoint | PASS | Android/Flutter production API uses `https://api.laqta.cloud`; production health check returned 200 |
| App Store screenshots | UNVERIFIED | No App Store Connect screenshot set was validated locally |
| Privacy labels | NEEDS ACTION | Must be filled in App Store Connect for account, phone, media, chat, analytics, security logs, payments via Stripe, FCM |

## Blocking Items For Apple Release

1. Add and configure `ios/Podfile`.
2. Configure Apple Developer Team ID and signing in Xcode.
3. Add `Runner.entitlements` with Push Notifications capability if iOS FCM/APNs is required.
4. Upload/configure APNs key or certificate in Firebase for iOS FCM.
5. Run `flutter build ipa --release` on macOS.
6. Validate archive upload through Xcode Organizer or `xcrun altool`/Transporter.
7. Prepare App Store screenshots according to current App Store Connect required device classes.
8. Complete App Privacy details in App Store Connect.

## Recommended iOS Release Commands On macOS

```bash
flutter clean
flutter pub get
cd ios
pod install
cd ..
flutter build ipa --release --dart-define=FLAVOR=prod
```

## Apple Release Status

NOT READY

Reason: missing Podfile, missing APNs entitlement, missing signing team/profile configuration, and no macOS IPA build verification.

