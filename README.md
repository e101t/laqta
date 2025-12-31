# luqta

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

## Environment Setup (Firebase)

This app requires Firebase config files that are intentionally not committed:

- `android/app/google-services.json`
- `ios/Runner/GoogleService-Info.plist`

Generate/update them using FlutterFire:

1) `dart pub global activate flutterfire_cli`
2) `flutterfire configure`

Make sure `lib/firebase_options.dart` stays in sync with your Firebase project.
