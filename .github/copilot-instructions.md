# LAQTA Codebase Guide for AI Agents

## Project Snapshot

LAQTA is a Flutter + Firebase photography marketplace. The current codebase is organized by feature and follows a pragmatic clean-architecture split:
- `domain/` for entities, repository contracts, and use cases
- `data/` for Firebase/local data sources, DTOs, mappers, and repository implementations
- `presentation/` for screens, providers, and UI widgets
- `*_dependencies.dart` files for static dependency wiring and test overrides

## Current Architecture Rules

1. Use feature dependencies, not concrete repositories.
   - Example: `ProfileDependencies.getUserProfile()`
   - Avoid importing implementation classes directly into screens.

2. Use `Result<T>` for fallible operations.
   - Domain and data layers return `Result.success(...)` / `Result.failure(...)`.
   - Do not rely on uncaught exceptions for flow control.

3. Keep routing centralized.
   - Main router: `lib/app/router/app_router.dart`
   - Route constants: `lib/app/router/routes.dart`
   - Role-aware shell: `lib/app/main_app_screen.dart`

4. Global app state is in `lib/main.dart`.
   - Theme and locale use `Provider`.
   - Shared feature-level state should be added deliberately, not ad hoc.

5. Localization lives under `lib/core/localization/`.
   - `AppLocalizations`
   - `ar_translations.dart`
   - `en_translations.dart`

## Core Feature Groups

- Auth and profile setup
- Requests, offers, bookings, deliveries, disputes, downloads
- Customer, photographer, and admin app shells
- Chat, notifications, search, settings, analytics
- Explore, stories, reels, store, payments, availability

## Testing Workflow

Use the repo-local wrappers on Windows when possible:

```powershell
cmd /c run_flutter_tests.cmd
cmd /c run_integration_tests.cmd emulator-5554
cmd /c run_functions_tests.cmd
```

Verified locally on 2026-03-08:
- `flutter analyze`
- Flutter widget/unit tests
- Firebase rules/function tests
- Android emulator integration tests

## Firebase Notes

- Firebase is initialized in `lib/main.dart`.
- Emulator support is wired for Auth, Firestore, and Storage.
- Rules live in `firestore.rules` and `storage.rules`.
- Function tests live under `functions/test/`.

## Current Practical Guidance

- Prefer extending existing feature modules over reviving deleted legacy wrappers.
- Treat `lib/screens/` and `lib/ui/` as compatibility shims only when still referenced.
- Keep platform-specific changes grouped with the feature or dependency that requires them.
- If a change touches router, main shell, auth flow, or role handling, validate with both widget tests and emulator integration tests.
