$ErrorActionPreference = 'Stop'

# Clears proxy env vars for the current terminal session.
# Your machine currently has these set to http://127.0.0.1:9 which breaks downloads.

$vars = @(
  'HTTP_PROXY',
  'HTTPS_PROXY',
  'ALL_PROXY',
  'NO_PROXY',
  'http_proxy',
  'https_proxy',
  'all_proxy',
  'no_proxy',
  'GIT_HTTP_PROXY',
  'GIT_HTTPS_PROXY'
)

foreach ($v in $vars) {
  if (Test-Path "Env:$v") {
    Remove-Item "Env:$v" -ErrorAction SilentlyContinue
  }
}

Write-Host "Cleared proxy env vars for this session."
Write-Host "If you need it permanently, remove them from Windows Environment Variables."

