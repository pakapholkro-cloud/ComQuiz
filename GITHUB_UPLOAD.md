# Uploading ComQuiz to GitHub (Public)

This is the **Flutter source project** for ComQuiz 1.1.0.
Generated `preview/` and `release/` files are intentionally excluded; the APK is submitted separately.

## Upload the project
1. On GitHub, create a new **Public** repository called `ComQuiz`. Do not initialize it with a README, license or .gitignore (those already exist here).
2. Extract `ComQuiz_GitHub_Source.zip` to a folder on your computer.
3. In the empty repository choose **uploading an existing file**. Drag all extracted files and folders **inside** the folder to GitHub; `.github/`, `android/`, `assets/`, `lib/`, `test/`, `web/`, `pubspec.yaml`, etc., must be at the repository root.
4. Click **Commit changes**. Verify the repo displays `lib/` and `pubspec.yaml` at its top level.
5. Paste the repository home URL `https://github.com/<your-account>/ComQuiz` into the course submission form.

## Build (requires Flutter SDK)
```bash
flutter pub get
flutter analyze
flutter test
flutter build apk --release --dart-define-from-file=author.json
```

The author.json in the original supplied ZIP still uses `Kan` and a blank student ID. Edit it locally before building your final APK, or use the GitHub Actions workflow inputs. If you do not want the student ID publicly visible, avoid committing it in author.json and provide it as a workflow input when building.

IMPORTANT: Uploading the `.zip` itself does *not* unpack its contents into a GitHub repository. Extract the archive first.
