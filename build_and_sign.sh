#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$ROOT_DIR"

KEY_PROPERTIES="android/key.properties"
if [[ ! -f "$KEY_PROPERTIES" ]]; then
  echo "Missing $KEY_PROPERTIES" >&2
  exit 1
fi

read_property() {
  local key="$1"
  grep -E "^${key}=" "$KEY_PROPERTIES" | tail -n 1 | sed "s/^${key}=//" | sed 's/\r$//'
}

storeFile="$(read_property storeFile)"
storePassword="$(read_property storePassword)"
keyAlias="$(read_property keyAlias)"
keyPassword="$(read_property keyPassword)"

if [[ -z "${storeFile:-}" || -z "${storePassword:-}" || -z "${keyAlias:-}" || -z "${keyPassword:-}" ]]; then
  echo "android/key.properties must define storeFile, storePassword, keyAlias, and keyPassword" >&2
  exit 1
fi

KEYSTORE_PATH="android/${storeFile#../}"
if [[ ! -f "$KEYSTORE_PATH" ]]; then
  KEYSTORE_PATH="$storeFile"
fi
if [[ ! -f "$KEYSTORE_PATH" ]]; then
  echo "Keystore not found: $storeFile" >&2
  exit 1
fi

SDK_ROOT="${ANDROID_HOME:-${ANDROID_SDK_ROOT:-}}"
if [[ -z "$SDK_ROOT" ]]; then
  echo "ANDROID_HOME or ANDROID_SDK_ROOT is required" >&2
  exit 1
fi
if command -v cygpath >/dev/null 2>&1; then
  SDK_ROOT="$(cygpath -u "$SDK_ROOT")"
fi

BUILD_TOOLS_DIR="$(find "$SDK_ROOT/build-tools" -maxdepth 1 -mindepth 1 -type d | sort -V | tail -n 1)"
ZIPALIGN="$BUILD_TOOLS_DIR/zipalign"
APKSIGNER="$BUILD_TOOLS_DIR/apksigner"
if [[ ! -f "$ZIPALIGN" && -f "$BUILD_TOOLS_DIR/zipalign.exe" ]]; then
  ZIPALIGN="$BUILD_TOOLS_DIR/zipalign.exe"
fi
if [[ ! -f "$APKSIGNER" && -f "$BUILD_TOOLS_DIR/apksigner.bat" ]]; then
  APKSIGNER="$BUILD_TOOLS_DIR/apksigner.bat"
fi

RELEASE_APK_ABI="${RELEASE_APK_ABI:-arm64-v8a}"
UNALIGNED_APK="build/app/outputs/flutter-apk/app-${RELEASE_APK_ABI}-production-release.apk"
ALIGNED_APK="build/app/outputs/flutter-apk/app-${RELEASE_APK_ABI}-production-release-aligned.apk"
SIGNED_APK="build/app/outputs/flutter-apk/app-${RELEASE_APK_ABI}-production-release-signed.apk"

flutter build apk --release \
  --flavor production \
  --split-per-abi \
  --obfuscate \
  --split-debug-info=build/debug-info \
  --dart-define=FLAVOR=prod \
  --dart-define=BACKEND_BASE_URL="${API_BASE_URL:-https://api.laqta.cloud}"
if [[ -z "$UNALIGNED_APK" || ! -f "$UNALIGNED_APK" ]]; then
  echo "Release APK was not produced for ABI: $RELEASE_APK_ABI" >&2
  exit 1
fi
rm -f "$ALIGNED_APK" "$SIGNED_APK"
"$ZIPALIGN" -p -f -v 4 "$UNALIGNED_APK" "$ALIGNED_APK"
"$APKSIGNER" sign \
  --min-sdk-version 23 \
  --ks "$KEYSTORE_PATH" \
  --ks-key-alias "$keyAlias" \
  --ks-pass "pass:$storePassword" \
  --key-pass "pass:$keyPassword" \
  --v1-signing-enabled true \
  --v2-signing-enabled true \
  --v3-signing-enabled true \
  --out "$SIGNED_APK" \
  "$ALIGNED_APK"
"$APKSIGNER" verify --verbose --min-sdk-version 23 "$SIGNED_APK"
"$ZIPALIGN" -c -v 4 "$SIGNED_APK"

echo "Signed APK: $SIGNED_APK"
