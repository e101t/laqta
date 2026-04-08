param(
  [switch]$SkipBuild,
  [switch]$SkipTests
)

$ErrorActionPreference = "Stop"

function Get-ShortPath {
  param(
    [Parameter(Mandatory = $true)]
    [string]$Path
  )

  $fsi = New-Object -ComObject Scripting.FileSystemObject
  if (Test-Path -LiteralPath $Path -PathType Container) {
    return $fsi.GetFolder($Path).ShortPath.Trim()
  }
  if (Test-Path -LiteralPath $Path -PathType Leaf) {
    return $fsi.GetFile($Path).ShortPath.Trim()
  }
  throw "Path not found: $Path"
}

function Format-CmdArgument {
  param(
    [Parameter(Mandatory = $true)]
    [string]$Value
  )

  if ($Value -notmatch '[\s"]') {
    return $Value
  }

  return '"' + ($Value -replace '"', '\"') + '"'
}

function Invoke-InWorkDir {
  param(
    [Parameter(Mandatory = $true)]
    [string]$WorkDir,
    [Parameter(Mandatory = $true)]
    [string]$FilePath,
    [string[]]$Arguments = @()
  )

  $formattedFile = Format-CmdArgument -Value $FilePath
  $formattedArgs = @($Arguments | ForEach-Object { Format-CmdArgument -Value $_ })
  $cmdLine = @(
    "pushd `"$WorkDir`"",
    "call $formattedFile $($formattedArgs -join ' ')",
    "set EXITCODE=%ERRORLEVEL%",
    "popd",
    "exit /b %EXITCODE%"
  ) -join " && "

  cmd /d /c $cmdLine
  if ($LASTEXITCODE -ne 0) {
    throw "Command failed in ${WorkDir}: $FilePath $($Arguments -join ' ')"
  }
}

$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$repoDir = Split-Path -Parent $scriptDir
$workDir = $repoDir
$linkDir = $null
$flutterCmd = Join-Path $repoDir ".tools\flutter\bin\flutter.bat"

try {
  $shortPath = Get-ShortPath -Path $repoDir
  if ($shortPath -and ($shortPath -notmatch '\s')) {
    $workDir = $shortPath
  }
} catch {
  Write-Warning "Could not resolve short path for '$repoDir'. Falling back to junction if needed."
}

if ($workDir -match '\s') {
  $linkDir = Join-Path $env:TEMP "laqta_repo_no_spaces_release"
  if (Test-Path $linkDir) {
    Remove-Item -LiteralPath $linkDir -Force -Recurse
  }

  Write-Host "Preparing no-spaces workspace at $linkDir"
  cmd /c "mklink /J `"$linkDir`" `"$repoDir`"" | Out-Null
  if ($LASTEXITCODE -ne 0 -or -not (Test-Path $linkDir)) {
    throw "Failed to prepare no-spaces workspace."
  }
  $workDir = $linkDir
}

if (-not (Test-Path $flutterCmd)) {
  $flutterCmd = "flutter"
} else {
  try {
    $shortFlutterCmd = Get-ShortPath -Path $flutterCmd
    if ($shortFlutterCmd -and ($shortFlutterCmd -notmatch '\s')) {
      $flutterCmd = $shortFlutterCmd
    }
  } catch {
    Write-Warning "Could not resolve short path for Flutter binary '$flutterCmd'."
  }
}

Write-Host "Running Flutter release checks from $workDir"

if (-not (Test-Path (Join-Path $repoDir "android/key.properties"))) {
  Write-Warning "Missing android/key.properties (release keystore config)."
}

if (-not (Test-Path (Join-Path $repoDir "android/app/google-services.json"))) {
  Write-Warning "Missing android/app/google-services.json (Firebase config)."
}

if (Test-Path (Join-Path $repoDir "ios/Runner/Info.plist")) {
  $plist = Get-Content (Join-Path $repoDir "ios/Runner/Info.plist") -Raw
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

Invoke-InWorkDir -WorkDir $workDir -FilePath $flutterCmd -Arguments @("--version")
Invoke-InWorkDir -WorkDir $workDir -FilePath $flutterCmd -Arguments @("pub", "get")
Invoke-InWorkDir -WorkDir $workDir -FilePath $flutterCmd -Arguments @("analyze")

if (-not $SkipTests) {
  Invoke-InWorkDir -WorkDir $workDir -FilePath $flutterCmd -Arguments @("test")
}

if (-not $SkipBuild) {
  Invoke-InWorkDir -WorkDir $workDir -FilePath $flutterCmd -Arguments @("build", "apk", "--release")
  Invoke-InWorkDir -WorkDir $workDir -FilePath $flutterCmd -Arguments @("build", "appbundle", "--release")
}

if ($linkDir -and (Test-Path $linkDir)) {
  Remove-Item -LiteralPath $linkDir -Force -Recurse
}

Write-Host "Release checks complete."
