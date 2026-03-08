$ErrorActionPreference = 'Stop'

# Installs Flutter SDK locally into this repo at .tools/flutter (Windows).
# Run with: powershell -ExecutionPolicy Bypass -File tool\install_flutter.ps1

$root = (Join-Path $PSScriptRoot '..') | Resolve-Path
$toolsDir = Join-Path $root '.tools'
$flutterDir = Join-Path $toolsDir 'flutter'
$zipPath = Join-Path $toolsDir 'flutter.zip'

New-Item -ItemType Directory -Force -Path $toolsDir | Out-Null

if (Test-Path $flutterDir) {
  Write-Host "Flutter already exists at: $flutterDir"
  Write-Host "If you want to reinstall, delete that folder first."
  exit 0
}

# Clear broken proxy env vars for this process (common devbox issue).
$proxyVars = @(
  'HTTP_PROXY', 'HTTPS_PROXY', 'ALL_PROXY', 'NO_PROXY',
  'http_proxy', 'https_proxy', 'all_proxy', 'no_proxy',
  'GIT_HTTP_PROXY', 'GIT_HTTPS_PROXY'
)
foreach ($v in $proxyVars) { Remove-Item "Env:$v" -ErrorAction SilentlyContinue }

[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

$metaUrl = 'https://storage.googleapis.com/flutter_infra_release/releases/releases_windows.json'
Write-Host "Fetching Flutter release metadata..."
$r = Invoke-RestMethod $metaUrl

$hash = $r.current_release.stable
$rel = $r.releases | Where-Object { $_.hash -eq $hash } | Select-Object -First 1
if (-not $rel) { throw "Could not find stable release in metadata." }

$url = ($r.base_url + '/' + $rel.archive)
Write-Host "Latest stable: $($rel.version)"
Write-Host "Downloading: $url"

Invoke-WebRequest -Uri $url -OutFile $zipPath -UseBasicParsing

Write-Host "Unpacking..."
Expand-Archive -Path $zipPath -DestinationPath $toolsDir -Force
Remove-Item $zipPath -Force

if (-not (Test-Path $flutterDir)) {
  throw "Unpack finished but '$flutterDir' not found. Check archive structure."
}

Write-Host "Flutter installed at: $flutterDir"
Write-Host "Next: run 'powershell -ExecutionPolicy Bypass -File tool\\activate_flutter.ps1' then 'flutter doctor'."

