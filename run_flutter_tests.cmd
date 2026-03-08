@echo off
setlocal

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
  call ".tools\flutter\bin\flutter.bat" test %*
) else (
  call flutter test %*
)
set "EXIT_CODE=%ERRORLEVEL%"
popd

subst X: /d >nul 2>&1
exit /b %EXIT_CODE%
