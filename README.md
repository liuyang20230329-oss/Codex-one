# 37°

Branch: `2026.3.27`

Version: `0.5.0-dev.1+2026032901`

This repository now contains the `37°` mobile app starter with a branded app
shell, an expanded trust-oriented account system, and a text chat MVP. The
current scope covers sign-in, sign-up, profile basics, phone verification,
identity submission, face and avatar ownership status, and seeded text
conversations for on-device testing.

## What is included

- Sign-in screen
- Sign-up screen
- Form validation
- Auth state management
- Signed-in app shell
- Sign-out flow
- Firebase bootstrap flow
- Demo fallback when Firebase is not configured
- 37° brand identity and app naming
- Account center with profile editing
- Phone verification flow with demo code delivery
- Identity verification submission flow
- Face verification state flow for avatar ownership
- Profile completion progress and trust hints
- Text chat MVP with seeded threads and message composer
- Phone-verification gate for private chats with system-chat fallback
- Local persistence for demo accounts and chat history
- Concierge system messages that react to profile and verification changes
- Basic auth tests
- Account verification tests
- Chat controller tests

## Current behavior

- If `lib/firebase_options.dart` still contains placeholder values, the app runs
  in demo auth mode.
- If you replace it with real FlutterFire output, the app automatically switches
  to Firebase email/password auth.
- Phone verification currently shows a demo code inside the app so the end-to-end
  UX can be tested before an SMS provider is added.
- Identity verification and face verification currently simulate approval logic
  inside the app while keeping the real workflow boundaries ready for a future
  compliance backend.
- Demo accounts, account progress, and chat threads now survive app restarts on
  the same device.

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
    core/widgets/
    core/theme/
    features/account/
    features/auth/
    features/chat/
    features/home/
test/
  auth_controller_test.dart
  account_verification_test.dart
  chat_controller_test.dart
```

## How to finish Firebase setup

1. Install Flutter and FlutterFire CLI.
2. Enable Email/Password sign-in in Firebase Authentication.
3. Run `flutter create .`
4. Run `flutterfire configure`
5. Run `flutter pub get`
6. Run `flutter test`
7. Run `flutter analyze`
8. Run `flutter run`

`flutterfire configure` will overwrite `lib/firebase_options.dart` with your
real Firebase project values.

## Recommended Android package command

To keep Android packages smaller than the debug universal APK, use:

```powershell
.\scripts\build-android-release.ps1
```

The script will:

- run `flutter pub get`
- run `flutter analyze`
- run `flutter test`
- build `release` APKs with `--split-per-abi`
- tree-shake icons
- copy timestamped APKs into [`build/app/outputs/flutter-apk`](/D:/Codex/build/app/outputs/flutter-apk)

If you only want to rebuild packages quickly, you can skip checks:

```powershell
.\scripts\build-android-release.ps1 -SkipAnalyze -SkipTest
```
