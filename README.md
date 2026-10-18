# Gunwave

Gunwave is a landscape pixel action game built with Flutter and Flame. Players choose a room and character, select a control mode, then fight through a timed stage on that room's map. The game supports joystick, keyboard, and camera-based hand gesture controls.

## Project documentation

- [Overview and features](docs/overview-and-features.md)
- [Repository structure](docs/project-structure.md)
- [Architecture and data flow](docs/architecture.md)
- [Technology stack](docs/technology-stack.md)

## Requirements

- Flutter SDK with Dart 3 or later (`pubspec.yaml` requires Dart `>=3.0.0 <4.0.0`).
- Android Studio and an Android device/emulator, or Xcode and an iOS device/simulator.
- A configured Supabase project for sign-in and remote game data.

## Set up

1. Clone the repository and enter it:

   ```sh
   git clone https://github.com/huyycp/gunwave.git
   cd gunwave
   ```

2. Install Flutter dependencies:

   ```sh
   flutter pub get
   ```

3. Create the environment files required by Flutter assets:

   ```sh
   cp .env_example dev.env
   cp .env_example prod.env
   ```

   Set `SUPABASE_URL` and `SUPABASE_ANON_KEY` in each file. Use the URL and client-safe anon/publishable key from your Supabase project. Do not put a service-role key in the app. The environment files are ignored by Git.

4. Make sure the Supabase project has the database tables and game data Gunwave expects. The repository includes a migration for the `create_room_with_quizzes` database function and an `update-ranks` Edge Function, but does not include a complete initial database schema. See [architecture and data flow](docs/architecture.md#supabase-backend) for the current backend boundary.

5. Sign in with an existing Supabase email/password account that has a matching application profile in the `users` table. The app currently provides sign-in, not an account registration flow.

## Run

Development and production are selected by Dart entrypoint files rather than Flutter `--flavor` configurations:

```sh
# Development (loads dev.env)
flutter run -t lib/main_dev.dart

# Production (loads prod.env)
flutter run -t lib/main_prod.dart
```

To target a particular connected device, add `-d <device-id>`. List available devices with `flutter devices`.

The app locks to landscape. Gesture control requires camera permission; allow it when prompted by the operating system.

## Verify and build

```sh
flutter test
dart analyze lib test

# Android debug APK
flutter build apk --debug -t lib/main_dev.dart

# iOS simulator app
flutter build ios --simulator -t lib/main_dev.dart
```

## Backend tools

The Supabase CLI is only needed when changing or deploying backend resources. From the repository root, link the intended Supabase project before applying migrations or deploying the Edge Function:

```sh
supabase link --project-ref <project-ref>
supabase db push
supabase functions deploy update-ranks
```

Confirm the target project before running these commands. The app itself uses the configured Supabase URL and anon/publishable key from its selected environment file.
