$ErrorActionPreference = 'Stop'

$root = (Join-Path $PSScriptRoot '..') | Resolve-Path
$toolsDir = Join-Path $root '.tools'
$zip = Join-Path $toolsDir 'flutter.zip'
$dest = Join-Path $toolsDir 'flutter'

New-Item -ItemType Directory -Force -Path $toolsDir | Out-Null

if (Test-Path $dest) {
  Write-Host "Flutter already unpacked at: $dest"
  exit 0
}

if (-not (Test-Path $zip)) {
  Write-Host "Missing: $zip"
  Write-Host "Download Flutter SDK (Windows, stable) and save it exactly as '.tools\\flutter.zip'."
  exit 1
}

Write-Host "Unpacking Flutter zip..."
Expand-Archive -Path $zip -DestinationPath $toolsDir -Force

# Flutter archive contains a top-level folder named 'flutter'
if (-not (Test-Path $dest)) {
  Write-Host "Unpack finished, but .tools\\flutter wasn't found. Check the zip structure."
  exit 1
}

Write-Host "Done: $dest"

