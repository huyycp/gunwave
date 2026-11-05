# Repository structure

## Top-level folders

| Path | Responsibility |
|---|---|
| `lib/` | Flutter application, game logic, state, models, data access, themes, and routes. |
| `assets/images/` | Pixel-art characters, monsters, terrain, effects, interface elements, and other game art. |
| `assets/tiles/` | Tiled maps (`.tmx`) and tileset resources used to build stages. |
| `assets/data/campaign/` | Bundled local stage, round, encounter, enemy, and reward definitions. |
| `android/` | Android application setup and native CameraX/MediaPipe gesture recognition. |
| `ios/` | iOS application setup and native AVFoundation/MediaPipe gesture recognition. |
| `lib/data/database/` | Drift database definition and table groups. |
| `drift_schemas/` | Versioned Drift schema snapshots used for migration tests. |
| `test/` | Database, repository, game-control, Flame component, and widget tests. |
| `docs/` | Project overview, feature list, architecture, technology, and structure guides. |

## Important `lib/` areas

| Path | Contents |
|---|---|
| `lib/main_dev.dart`, `lib/main_prod.dart` | Entrypoints using the same local-first database bootstrap. |
| `lib/app.dart`, `lib/routes.dart` | App widget, theme hookup, and GoRouter route definitions. |
| `lib/views/` | Feature screens and state: Home, campaign, character, Shop, game, and Settings. |
| `lib/views/game/` | Flame game setup, combat UI, stage components, gesture-to-control mapping, and collision helpers. |
| `lib/data/models/` | Domain/data models used by repositories and presentation. |
| `lib/data/database/` | Drift schema, catalog tables, campaign tables, and player/settings tables. |
| `lib/data/data_sources/local/` | Drift-backed content/progress access, startup seeding, locale migration, and native gesture bridge. |
| `lib/repositories/` | Campaign, player progress, character, and gesture operations. |
| `lib/theme/`, `lib/widgets/` | Shared styling and reusable Flutter UI components. |
| `lib/data/constants/` | App and game constants, asset references, and gameplay enums. |

## Native gesture files

- Android: `android/app/src/main/kotlin/com/huyvowkm/gunwave/`
- iOS: `ios/Runner/Services/`

Both platforms expose gesture start/stop and gesture results through the
Flutter method channel named `gesture_recognizer`.

## Local data files

- `assets/data/campaign/stages.json` defines the bundled campaign and combat
  encounters. The app seeds it into Drift before showing the first screen.
- `assets/data/catalog/characters.json` and `abilities.json` hold the bundled
  Shop catalog. Their sanitized CSV source exports live in `seeds/`; startup
  validates references and refreshes static rows without replacing player data.
- `lib/data/database/app_database.dart` owns the SQLite database and schema
  version. Update its migration and `drift_schemas/` snapshot when the schema
  changes.
- `lib/data/data_sources/local/local_game_data_seeder.dart` imports static
  campaign, monster, hero, and ability content and grants the catalog starter
  without overwriting local progress.
- `lib/data/data_sources/local/legacy_preferences_migrator.dart` imports only
  the old app language choice and removes the old serialized campaign save.
Tiled maps and image assets remain files under `assets/`; SQLite contains only
their keys and structured gameplay data.
