@echo off
setlocal

set "DEVICE_ID=%~1"
if "%DEVICE_ID%"=="" set "DEVICE_ID=emulator-5554"

set "REPO_DIR=%~dp0"
if "%REPO_DIR:~-1%"=="\" set "REPO_DIR=%REPO_DIR:~0,-1%"
set "WORK_DIR="
set "LINK_DIR="

for %%I in ("%REPO_DIR%") do set "WORK_DIR=%%~fsI"
if not defined WORK_DIR set "WORK_DIR=%REPO_DIR%"

echo %WORK_DIR%| find " " >nul
if not errorlevel 1 (
  set "LINK_DIR=%TEMP%\laqta_repo_no_spaces"
  if exist "%LINK_DIR%" rmdir "%LINK_DIR%" >nul 2>&1
  mklink /J "%LINK_DIR%" "%REPO_DIR%" >nul
  if errorlevel 1 (
    echo Failed to prepare a no-spaces path for "%REPO_DIR%"
    exit /b 1
  )
  set "WORK_DIR=%LINK_DIR%"
)

pushd "%WORK_DIR%"
if exist ".tools\flutter\bin\flutter.bat" (
  set "FLUTTER=.tools\flutter\bin\flutter.bat"
) else (
  set "FLUTTER=flutter"
)

set "ADB=adb"
if exist "%LOCALAPPDATA%\Android\Sdk\platform-tools\adb.exe" (
  set "ADB=%LOCALAPPDATA%\Android\Sdk\platform-tools\adb.exe"
)

call "%ADB%" -s "%DEVICE_ID%" uninstall com.laqta.laqta >nul 2>&1

call "%FLUTTER%" test integration_test\app_flow_test.dart -d "%DEVICE_ID%"
if errorlevel 1 goto :cleanup

call "%FLUTTER%" test integration_test\booking_flow_test.dart -d "%DEVICE_ID%"

:cleanup
set "EXIT_CODE=%ERRORLEVEL%"
popd
if defined LINK_DIR rmdir "%LINK_DIR%" >nul 2>&1
exit /b %EXIT_CODE%
