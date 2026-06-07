# LAQTA Apple Release Gap Analysis

Date: 2026-05-31

## Apple References

- Screenshot specifications: https://developer.apple.com/help/app-store-connect/reference/screenshot-specifications/
- App privacy details: https://developer.apple.com/app-store/app-privacy-details/
- Privacy manifests: https://developer.apple.com/documentation/bundleresources/privacy-manifest-files
- Adding a privacy manifest: https://developer.apple.com/documentation/bundleresources/adding-a-privacy-manifest-to-your-app-or-third-party-sdk
- Third-party SDK requirements: https://developer.apple.com/support/third-party-SDK-requirements/
- Adding capabilities in Xcode: https://developer.apple.com/documentation/xcode/adding-capabilities-to-your-app

## Repository Audit

| Item | Classification | Evidence | Required Action |
|---|---|---|---|
| `ios/Podfile` | MISSING | No `ios/Podfile` found. | Generate/restore Podfile and run `pod install` on macOS. |
| `Runner.entitlements` | MISSING | No `ios/Runner/Runner.entitlements` found. | Add entitlements file through Xcode capabilities. |
| APNs capability | MISSING | No `aps-environment` entitlement found. | Enable Push Notifications capability for app target. |
| Push notifications capability | NEEDS CONFIGURATION | `firebase_messaging` exists; `GoogleService-Info.plist` exists; APNs entitlement missing. | Configure APNs key/cert in Firebase and Xcode capability. |
| `DEVELOPMENT_TEAM` | MISSING | `DEVELOPMENT_TEAM` not found in `project.pbxproj`. | Set Apple Developer Team ID in Xcode signing settings. |
| Bundle Identifier | READY | `PRODUCT_BUNDLE_IDENTIFIER = com.laqta.laqta`; iOS Firebase plist `BUNDLE_ID` also `com.laqta.laqta`. | Confirm same bundle exists in Apple Developer and App Store Connect. |
| Signing configuration | NEEDS CONFIGURATION | Runner target lacks complete team/profile config; tests show Automatic signing only for test target. | Configure signing team and provisioning profile/certificates. |
| App Store icon assets | READY | `AppIcon.appiconset` includes `1024x1024` ios-marketing icon and required iPhone/iPad sizes. | Validate with Xcode archive. |
| App Store screenshots | NEEDS CONFIGURATION | No App Store Connect screenshot set verified in repo. | Prepare screenshots for required device sizes in App Store Connect. |
| Privacy manifest requirements | MISSING | No `PrivacyInfo.xcprivacy` found under `ios/`; dependencies include SDKs such as `connectivity_plus` and `image_picker_ios` that are listed in Apple third-party SDK requirements. | Add valid privacy manifest and verify SDK manifests through Xcode report. |
| Privacy labels | NEEDS CONFIGURATION | Legal docs exist, but App Store Connect privacy form is not verifiable from repo. | Complete App Privacy details for account data, phone, media, messages, analytics, security logs, FCM, payments via Stripe. |
| iOS release build | NEEDS CONFIGURATION | Windows environment cannot run `flutter build ipa`; Podfile missing. | Build on macOS after signing/Pods setup. |
| Production API endpoints | READY | Production smoke checks return 200 for health/ready/explore/venues/locations/subscriptions. | Keep `https://api.laqta.cloud` for production. |

## Blocking Gaps

1. Missing `ios/Podfile`.
2. Missing `Runner.entitlements`.
3. Missing APNs capability.
4. Missing Apple Developer Team signing configuration.
5. Missing `PrivacyInfo.xcprivacy`.
6. iOS IPA build not verified on macOS.

## Apple Release Classification

Apple release status: NEEDS CONFIGURATION.

Apple release is not ready for App Store submission until the blocking gaps are fixed and an IPA archive upload is verified.

