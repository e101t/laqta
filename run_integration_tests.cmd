@echo off
setlocal

set "DEVICE_ID=%~1"
if "%DEVICE_ID%"=="" set "DEVICE_ID=emulator-5554"

set "REPO_DIR=%~dp0"
if "%REPO_DIR:~-1%"=="\" set "REPO_DIR=%REPO_DIR:~0,-1%"

subst X: /d >nul 2>&1
subst X: "%REPO_DIR%"
if errorlevel 1 (
  echo Failed to map X: to "%REPO_DIR%"
  exit /b 1
)

pushd X:
if exist ".tools\flutter\bin\flutter.bat" (
  set "FLUTTER=.tools\flutter\bin\flutter.bat"
) else (
  set "FLUTTER=flutter"
)

call "%FLUTTER%" test integration_test\app_flow_test.dart -d "%DEVICE_ID%"
if errorlevel 1 goto :cleanup

call "%FLUTTER%" test integration_test\booking_flow_test.dart -d "%DEVICE_ID%"

:cleanup
set "EXIT_CODE=%ERRORLEVEL%"
popd
subst X: /d >nul 2>&1
exit /b %EXIT_CODE%
