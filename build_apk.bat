@echo off
cd /d "%~dp0"
call flutter pub get
if errorlevel 1 goto end
call flutter build apk --release --dart-define-from-file=author.json
if errorlevel 1 goto end
echo APK: build\app\outputs\flutter-apk\app-release.apk
:end
pause
