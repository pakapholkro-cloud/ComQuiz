@echo off
cd /d "%~dp0"
where flutter >nul 2>&1
if errorlevel 1 (
  echo Flutter not found. Install Flutter and add flutter\bin to PATH first.
  pause
  exit /b 1
)
call flutter pub get
if errorlevel 1 goto end
call flutter run -d chrome --dart-define-from-file=author.json
:end
pause
