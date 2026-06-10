# Tests

## Flutter (unit + widget)

From the repo root:

```bash
flutter test
```

If your Windows path contains spaces and `flutter test` fails due native-assets hooks,
use the helper script. It prefers the repo short-path and falls back to a
temporary no-spaces junction when needed:

```bash
run_flutter_tests.cmd
```

## Integration tests

From the repo root:

```bash
flutter test integration_test
```

On Windows, the two integration files are more reliable when run one by one on
the target device through the same no-spaces helper. Use:

```bash
run_integration_tests.cmd emulator-5554
```

## Cloud Functions + Rules tests (Firestore/Storage)

Requirements:
- Firebase CLI installed (`firebase --version`)
- Java (for emulators)

Install functions dev dependencies:

```bash
cd functions
npm install
```

Run rules tests against emulators:

```bash
run_functions_tests.cmd
```

The plain Node test suite (shared by the npm scripts) can be executed manually if needed:

```bash
cd functions
npm test
npm run test:functions
```

## Functions unit tests (payment validation)

```bash
cd functions
node --test test/payment_validation.test.js
```

## Notes

- iOS builds require Xcode + CocoaPods; run `flutter build ios --no-codesign` on macOS.
- If you run the app against emulators, set `USE_FIREBASE_EMULATORS=true` at build time.

## Deployment

After changing rules or storage configuration, deploy them with:

```bash
firebase deploy --only firestore,storage
```

If you deploy Cloud Functions later, include them as well:

```bash
firebase deploy --only functions,firestore,storage
```
