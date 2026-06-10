# LAQTA Performance Baseline

## Startup Target

Target: first login/home content in under 2000 ms on a Pixel 4a-class Android device.

## Implemented Now

- Startup is wrapped in `runZonedGuarded` so startup exceptions do not strand the process silently.
- Non-critical services remain deferred after `runApp()`.
- FCM, remote flags, RASP health, notification navigation, and deep links initialize in guarded deferred tasks.
- Network connectivity checks are async and never block first frame.

## Measurement Command

```bash
flutter run --profile --flavor production --dart-define=FLAVOR=prod
```

Record startup in Flutter DevTools Performance tab.

## Build Size Notes

- Production release workflow builds with obfuscation and split debug info.
- Asset-wide PNG to WebP conversion is intentionally not automated in this patch because it changes visual assets and could break the locked pixel-perfect UI. Convert and verify screen-by-screen in a separate visual-asset pass.
- ABI splits are not enabled here to avoid breaking the verified APK artifact path/signing flow. If direct APK distribution becomes primary, add ABI splits and update release scripts together.

## Media Performance Foundation

- `LaqtaMediaCacheManager` centralizes MinIO image cache behavior.
- `VideoVisibilityController` tracks visible videos and active playback decisions.
- Existing screens can adopt these without changing layout.
