# Repository structure

## Top-level folders

| Path | Responsibility |
|---|---|
| `lib/` | Flutter application, game logic, state, models, data access, themes, and routes. |
| `assets/images/` | Pixel-art characters, monsters, terrain, effects, interface elements, and other game art. |
| `assets/tiles/` | Tiled maps (`.tmx`) and tileset resources used to build stages. |
| `android/` | Android application setup and native CameraX/MediaPipe gesture recognition. |
| `ios/` | iOS application setup and native AVFoundation/MediaPipe gesture recognition. |
| `supabase/` | Supabase CLI configuration, database migration, seed placeholder, and Edge Function source. |
| `test/` | Flutter tests for game controls, collision helpers, and data models. |
| `docs/` | Project overview, feature list, architecture, technology, and this structure guide. |

## Important `lib/` areas

| Path | Contents |
|---|---|
| `lib/main_dev.dart`, `lib/main_prod.dart` | Entrypoints that select the development or production environment. |
| `lib/app.dart`, `lib/routes.dart` | App widget, theme hookup, and GoRouter route definitions. |
| `lib/views/` | Feature screens and their view models: home, rooms, character, shop, game, and rankings. |
| `lib/views/game/` | Flame game setup, gameplay UI, stage components, gesture-to-control mapping, and collision helpers. |
| `lib/data/models/` | Domain/data models used by the UI and remote sources. |
| `lib/data/dtos/` | Request objects sent to remote operations. |
| `lib/data/data_sources/local/` | Platform bridge for native gesture recognition. |
| `lib/data/data_sources/remote/` | Supabase-backed user, room, map, character, and ranking access. |
| `lib/repositories/` | Feature-facing wrappers around data sources. |
| `lib/theme/`, `lib/widgets/` | Shared styling and reusable UI components. |
| `lib/data/constants/` | App and game constants, asset references, and gameplay enums. |

## Native gesture files

- Android: `android/app/src/main/kotlin/com/huyvowkm/gunwave/`
- iOS: `ios/Runner/Services/`

Both platforms expose gesture start/stop and gesture results through the Flutter method channel named `gesture_recognizer`.

## Backend files

- `supabase/config.toml`: local Supabase CLI project configuration (`project_id = "gunwave"`).
- `supabase/migrations/`: versioned database changes. The current migration adds atomic room-and-quiz creation.
- `supabase/functions/update-ranks/`: ranking submission Edge Function and its score validation logic.
- `supabase/seed.sql`: currently empty; it does not define an application dataset.
