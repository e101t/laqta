# LAQTA Deep Linking Setup

## Android App Links

The app accepts these links:

- `https://laqta.app/profile/{username}`
- `https://laqta.app/post/{postId}`
- `https://laqta.app/chat/{roomId}`
- `https://laqta.app/explore`
- `laqta://profile/{username}`

## Backend Requirement

Serve this file from:

`https://laqta.app/.well-known/assetlinks.json`

Example structure:

```json
[
  {
    "relation": ["delegate_permission/common.handle_all_urls"],
    "target": {
      "namespace": "android_app",
      "package_name": "com.laqta.laqta",
      "sha256_cert_fingerprints": ["REPLACE_WITH_RELEASE_CERT_SHA256"]
    }
  }
]
```

## Local Test

```bash
adb shell am start -W -a android.intent.action.VIEW -d "https://laqta.app/post/test123" com.laqta.laqta
adb shell am start -W -a android.intent.action.VIEW -d "laqta://profile/ahmed" com.laqta.laqta
```

## Security Rules

- Unexpected query parameters are rejected.
- Path traversal (`../` or `%2e%2e`) is rejected.
- Invalid links are logged to `/api/v1/security/events`.

## Current Route Note

`/post/{postId}` resolves to the main feed until a dedicated post detail route is added to the existing router.
