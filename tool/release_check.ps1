param(
  [switch]$SkipBuild
)

$ErrorActionPreference = "Stop"

Write-Host "Running Flutter release checks..."

if (-not (Test-Path "android/key.properties")) {
  Write-Warning "Missing android/key.properties (release keystore config)."
}

if (-not (Test-Path "android/app/google-services.json")) {
  Write-Warning "Missing android/app/google-services.json (Firebase config)."
}

if (Test-Path "ios/Runner/Info.plist") {
  $plist = Get-Content "ios/Runner/Info.plist"
  if ($plist -notmatch "NSCameraUsageDescription") {
    Write-Warning "Info.plist missing NSCameraUsageDescription."
  }
  if ($plist -notmatch "NSPhotoLibraryUsageDescription") {
    Write-Warning "Info.plist missing NSPhotoLibraryUsageDescription."
  }
  if ($plist -notmatch "NSPhotoLibraryAddUsageDescription") {
    Write-Warning "Info.plist missing NSPhotoLibraryAddUsageDescription."
  }
} else {
  Write-Host "iOS folder not found. Skipping iOS checks."
}

flutter --version
flutter pub get
flutter analyze

if (-not $SkipBuild) {
  flutter build apk --release
  flutter build appbundle --release
}

Write-Host "Release checks complete."
