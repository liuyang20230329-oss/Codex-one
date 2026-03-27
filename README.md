# Codex One

Branch: `2026.3.27`

Version: `0.2.0-dev.1+20260327`

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
- Firebase bootstrap flow
- Demo fallback when Firebase is not configured
- Basic auth tests

## Current auth behavior

- If `lib/firebase_options.dart` still contains placeholder values, the app runs
  in demo auth mode.
- If you replace it with real FlutterFire output, the app automatically switches
  to Firebase email/password auth.

Demo account:

- Email: `demo@codex.one`
- Password: `Password123!`

## Current structure

```text
lib/
  app.dart
  firebase_options.dart
  main.dart
  src/
    core/bootstrap/
    core/theme/
    features/auth/
    features/home/
test/
  auth_controller_test.dart
```

## How to finish Firebase setup

1. Install Flutter and FlutterFire CLI.
2. Enable Email/Password sign-in in Firebase Authentication.
3. Run `flutter create .`
4. Run `flutterfire configure`
5. Run `flutter pub get`
6. Run `flutter test`
7. Run `flutter run`

`flutterfire configure` will overwrite `lib/firebase_options.dart` with your
real Firebase project values.

## Recommended mobile run target

Use an Android emulator, an Android phone, or an iPhone simulator/device when
testing the Firebase version of this app.
