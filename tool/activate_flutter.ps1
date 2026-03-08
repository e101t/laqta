$ErrorActionPreference = 'Stop'

# Local Flutter SDK for this repo (no global install needed).
$flutterRoot = Join-Path $PSScriptRoot '..\.tools\flutter' | Resolve-Path -ErrorAction SilentlyContinue
if (-not $flutterRoot) {
  Write-Host "Flutter not found at .tools/flutter"
  Write-Host "Expected: $PSScriptRoot\\..\\.tools\\flutter"
  Write-Host "If you already downloaded Flutter SDK zip, run: tool\\unpack_flutter.ps1"
  exit 1
}

$flutterBin = Join-Path $flutterRoot 'bin'
$dartSdkBin = Join-Path $flutterRoot 'bin\\cache\\dart-sdk\\bin'

$env:PATH = "$flutterBin;$dartSdkBin;$env:PATH"

Write-Host "Activated Flutter for this terminal:"
Write-Host "  flutter: $flutterBin"
Write-Host "  dart:    $dartSdkBin (will exist after first Flutter run)"

