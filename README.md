# Gunwave

Gunwave is a landscape pixel action RPG built with Flutter and Flame. Play a
solo campaign across local maps, rounds, and boss encounters with joystick,
keyboard, or camera-based hand gesture controls.

## Project documentation

- [Overview and features](docs/overview-and-features.md)
- [Repository structure](docs/project-structure.md)
- [Architecture and data flow](docs/architecture.md)
- [Technology stack](docs/technology-stack.md)
- [Character abilities](docs/character-abilities.md)

## Requirements

- FVM. The project pins Flutter 3.47.4 (Dart 3.13.3) in `.fvmrc`.
- Android Studio and an Android device/emulator, or Xcode and an iOS device/simulator.

No account, environment file, backend project, or network connection is required
to start a new game.

## Set up

1. Clone the repository and enter it:

   ```sh
   git clone https://github.com/huyycp/gunwave.git
   cd gunwave
   ```

2. Install the pinned Flutter SDK and project dependencies:

   ```sh
   fvm install
   fvm flutter pub get
   ```

3. Generate localizations and model/database sources:

   ```sh
   fvm flutter gen-l10n
   fvm dart run build_runner build
   ```

## Run

Development and production entrypoints use the same local-first bootstrap:
open the Drift database, apply schema migrations, seed bundled game content,
migrate the saved language preference once, and then run the app.

```sh
# Development entrypoint
fvm flutter run -t lib/main_dev.dart

# Production entrypoint
fvm flutter run -t lib/main_prod.dart
```

To target a connected device, add `-d <device-id>`. List available devices with
`fvm flutter devices`.

The app locks to landscape. Gesture control requires camera permission; allow it
when prompted by the operating system.

## Local data

Game definitions and player state are stored on the device in SQLite through
Drift. A new local save starts with zero gold, no cleared stages, and the
bundled Blue Warrior so the campaign is playable immediately. Stage 1, its
monsters, five rounds, and boss are seeded from `assets/data/campaign/`.
Tiled maps, sprites, and other binary art remain packaged assets.

The previous Supabase account, inventory, upgrades, and campaign progress are
not imported. The app does not connect to or modify any hosted Supabase project.
The legacy saved language choice is imported once; the old serialized campaign
progress is discarded. The shop's full hero and ability catalog is awaiting a
sanitized JSON export, so only the bundled starter is currently available.

## Verify and build

```sh
fvm flutter test
fvm dart analyze lib test

# Android debug APK
fvm flutter build apk --debug -t lib/main_dev.dart

# iOS simulator app
fvm flutter build ios --simulator -t lib/main_dev.dart
```
