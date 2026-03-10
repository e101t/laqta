# luqta

LAQTA is a Flutter mobile app for connecting customers with photographers in Iraq.

Supported app targets in this repository:

- Android
- iOS

## Environment Setup (Firebase)

This app requires Firebase config files that are intentionally not committed:

- `android/app/google-services.json`
- `ios/Runner/GoogleService-Info.plist`

Generate/update them using FlutterFire:

1) `dart pub global activate flutterfire_cli`
2) `flutterfire configure`

Make sure `lib/firebase_options.dart` stays in sync with your Firebase project.
