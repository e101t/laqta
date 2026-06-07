# LAQTA Architecture Audit

## Scope

This audit is intentionally non-invasive because UI, security, and navigation architecture are locked for this phase.

## Confirmed Patterns

- Feature-first structure is present across core domains.
- Backend access is centralized through `BackendApiClient` and feature repositories.
- Security-critical services remain isolated under `lib/core/security/`, `lib/core/auth/`, and `lib/core/network/pinning/`.
- New cross-cutting utilities are isolated under `lib/core/`.

## Added Foundations

- Global error boundary.
- Connectivity/offline handling.
- Generic pagination widget.
- Force update gate.
- Deep link handler.
- FCM foreground banner and routing foundation.
- Feature flags and remote config cache.
- Environment-aware logging.
- Cache policy/response cache.
- UX empty/error/shimmer widgets.

## Deferred Non-Safe Changes

These require feature-by-feature migration to avoid breaking locked UI and live flows:

- Replacing every screen's API state with Bloc/Cubit.
- Moving every hardcoded string into l10n/constants.
- Replacing every full-screen loader with shimmer.
- Converting all PNG assets to WebP.
- Enabling APK ABI splits and changing release artifact paths.
