# Tinnitus Relief App

A Flutter-based tinnitus masking and relaxation app with offline bundled sound tracks, volume shaping, and session duration controls.

## Overview

This project provides a focused sound-therapy style experience:
- 12 bundled audio masking tracks (ocean, rain, storm, stream, crickets, wind, white noise)
- Interactive track list with play/pause visual states
- Vertical dot-based volume control
- Session duration control with finite hours (`1-10`) or infinite mode (`∞`)
- Glassmorphism-style timer and settings modals
- Legal documentation drafts for App Store / Play Store readiness

## Tech Stack

- Flutter (Dart SDK `^3.10.7`)
- `audioplayers` for audio playback
- `url_launcher` for opening FAQ/legal/review links
- Custom bundled font family: `Kallisto`

## Project Structure

```text
lib/
  main.dart                          # App entry point, theme, HomeScreen bootstrap
  screens/
    home_screen.dart                 # Main sound therapy player UI + audio/timer state
    login_screen.dart                # Auth UI (currently not launch route)
    signup_screen.dart               # Auth UI (currently not launch route)
    forgot_password_screen.dart      # Auth UI (currently not launch route)
  widgets/
    home_screen_header.dart
    track_list_widget.dart
    volume_bar.dart
    bottom_bar.dart
    timer_modal.dart
    settings_modal.dart
    ...

assets/
  audio/                             # All bundled masking audio files
  images/                            # Background and UI graphics
  fonts/                             # Kallisto font weights

legal/
  PRIVACY_POLICY.md
  TERMS_AND_CONDITIONS.md
  APP_STORE_CHECKLIST.md

test/
  widget_test.dart                   # Default Flutter starter test (currently outdated)
```

## Implemented Behavior

### Main player (`HomeScreen`)

- Uses a single looping `AudioPlayer` instance.
- Selecting a track starts playback of the matching local asset.
- Re-tapping current track toggles pause/resume.
- Track state coloring:
  - First app launch: all tracks neutral/dark
  - Playing track: green
  - Paused track: yellow with blink animation
- Track list supports manual scroll controls (`top` / `more`) in addition to touch scrolling.

### Duration and timer logic

- Bottom slider maps to `1..10` hours and `11 => ∞` (continuous).
- Finite duration starts a 1-second interval countdown and stops playback at zero.
- Infinite mode disables countdown (`Duration.zero`).
- `TimerModal` allows advanced duration/fade settings and returns values through `onSave`.

### Settings modal

`SettingsModal` provides:
- Active output device display (currently static text from parent)
- External links:
  - App store review pages (generic store URLs)
  - FAQ: `https://msiliverman.vercel.app/faq`
  - Privacy policy: `https://msiliverman.vercel.app/privacy-policy`
  - Terms: `https://msiliverman.vercel.app/terms-of-service`

### Auth screens present

`Login`, `Sign Up`, and `Forgot Password` screens are implemented with validation and simulated async flows, but app startup currently routes directly to `HomeScreen` (`main.dart`).

## Prerequisites

- Flutter SDK installed and on PATH
- Android Studio and/or Xcode setup for emulator/simulator targets

Check setup:

```bash
flutter doctor
```

## Getting Started

1. Install dependencies:

```bash
flutter pub get
```

2. Run the app:

```bash
flutter run
```

3. Run on specific target examples:

```bash
flutter run -d ios
flutter run -d android
```

## Assets and Configuration

Configured in `pubspec.yaml`:
- `assets/images/`
- `assets/audio/`
- `Kallisto` font family with thin/light/medium/bold/heavy weights

## Legal and Publishing Notes

The `legal/` folder includes strong draft documents and a checklist, but still contains placeholders (company name, email, address, jurisdiction, pricing model, etc.) that must be finalized before production release.

## Current Gaps / Known Issues

- `flutter test` currently cannot run in this environment because Flutter CLI is not installed.
- `test/widget_test.dart` is the default counter test and does not match the current app UI, so it will fail even in a configured Flutter environment.
- Auth screens are not wired as the startup flow.
- Some external settings links are generic placeholders for review/store destinations.
- `google_fonts` dependency is present in `pubspec.yaml` but not currently used in code.

## Suggested Next Steps

1. Wire app startup to auth/onboarding flow if required for MVP.
2. Replace legal placeholders and host finalized policy URLs.
3. Add real widget/integration tests for player, timer, and modal interactions.
4. Validate audio lifecycle behavior across app pause/resume/background states.

