# Codex One

Branch: `2026.3.27`

Version: `0.1.0-dev.1+20260327`

This repository now contains a mobile auth starter for a social app. The
current scope focuses on a testable sign-in and sign-up flow, while leaving
room for future text chat, voice rooms, and video calling features.

## What is included

- Sign-in screen
- Sign-up screen
- Form validation
- Auth state management
- Signed-in home screen
- Sign-out flow
- Demo account
- Basic auth tests

Demo account:

- Email: `demo@codex.one`
- Password: `Password123!`

## Current structure

```text
lib/
  app.dart
  main.dart
  src/
    core/theme/
    features/auth/
    features/home/
test/
  auth_controller_test.dart
```

## How to run later

This machine does not have Flutter installed yet, so the repository does not
include generated `android/` and `ios/` folders. After Flutter is installed,
run:

```powershell
flutter create .
flutter pub get
flutter test
flutter run
```

`flutter create .` will generate the platform folders while keeping the
current `lib/` and `test/` code in place.
