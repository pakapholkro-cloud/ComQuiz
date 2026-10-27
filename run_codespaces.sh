#!/usr/bin/env bash
set -e
cd "$(dirname "$0")"
flutter pub get
flutter run -d web-server --web-hostname 0.0.0.0 --web-port 8080 --dart-define-from-file=author.json
