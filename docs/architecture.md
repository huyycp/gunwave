# Architecture and data flow

Gunwave uses a feature-oriented Flutter structure with presentation,
repository, and data-source responsibilities. Riverpod provides dependencies
and `ChangeNotifier` view state. SQLite through Drift is the persistence layer
for structured game content, player progress, and app settings.

## Startup

```text
main_dev.dart / main_prod.dart
    ↓
AppDatabase opens and migrates the Drift schema
    ↓
LocalAppInitializer seeds bundled campaign data and migrates the old locale
    ↓
ProviderScope injects the database
    ↓
Flutter routes → Flame RPG menus and game
```

The bundled content and settings migration finish before `runApp`, so screens
never need a network session or account bootstrap. Both Dart entrypoints use
the same startup path.

## RPG menus and campaign data flow

```text
assets/data/campaign/stages.json
    ↓ LocalGameDataSeeder
Drift campaign/catalog tables
    ↓ CampaignRepository / CharacterRepository
RpgMenuHost snapshots + callbacks
    ↓ GameWidget host
Flame menu scenes → selected stage and hero
    ↓
GameView → Gunwave → Stage + RoundDirector
    ↓
Tiled map + local enemy catalog → Flame combat HUD and results
    ↓
CampaignProgressRepository → Drift player state and stage clears
```

- `assets/data/campaign/stages.json` is the source for stage order, rounds,
  encounter groups, enemy stats, unlock rules, and rewards.
- `LocalGameDataSeeder` validates and transactionally refreshes static campaign
  rows. Re-running it preserves balances, owned heroes, upgrades, and stage
  clears.
- `CampaignRepository` reads normalized stages, monsters, encounters, and
  rewards from Drift and validates references to bundled maps and sprites.
- `Stage` resolves the stage map key to the local `GameMaps` catalog, loads the
  Tiled map once, validates named spawn markers, and creates world components.
- `RoundDirector` advances configured encounters and emits one stage result.
- `CampaignProgressRepository` writes stage clears and first-clear rewards in
  a transaction. A unique clear row prevents replaying a stage from awarding
  gold or status points twice.
- `PlayerStates.gold` is the single local wallet used by campaign rewards and
  Shop purchases. Owned hero stats and per-hero points are stored separately in
  `PlayerCharacters`.
- The visible Home Hub, Campaign Map, Stage Briefing, Loadout, Shop, Settings,
  combat HUD, pause menu, and results are Flame components using local sprites
  and the shared bitmap font. Flutter hosts Flame through `GameWidget` and
  provides non-visual application state and callbacks.
- Input mode selection is rendered in Flame Settings and held by `RpgMenuHost`
  for its current lifetime. A new menu host defaults to joystick.

## Local database

`lib/data/database/app_database.dart` owns the versioned Drift schema. Static
definitions are normalized into `Abilities`, `Characters`, `Stages`,
`Monsters`, `StageMonsters`, `StageRounds`, `RoundEncounters`, and `StageRewards`.
Mutable local state uses `PlayerStates`, `PlayerCharacters`, and
`CampaignStageClears`. The `Settings` table stores the app language mode, while
`AppMetadata` records one-time migrations.

The current schema is version 1. Future schema changes must increment
`schemaVersion`, add a Drift migration, update the schema snapshot, and exercise
the migration with an in-memory database test. Table definitions and snapshots
live under `lib/data/database/` and `drift_schemas/`.

The old `app_locale_mode` SharedPreferences key is imported once into `Settings`
and then removed. The old serialized `campaign_progress_v1` value is discarded
so the requested local save starts empty. The `shared_preferences` package is
used only for this one-time compatibility migration; new settings and all game
progress use Drift.

The eight-character and eight-ability catalog is bundled as normalized JSON in
`assets/data/catalog/`; the source CSV exports are in `seeds/`. Startup
validates sprite filenames and ability references, then upserts static catalog
rows before ensuring the local starter is owned. Catalog-only updates do not
change the Drift schema version. Existing saves migrate the temporary starter
ID to the exported Adept Warrior and retain invested stat upgrades, balances,
and campaign clears.

## Typography

Flutter uses the Material 3 `TextTheme` supplied by `ThemeData`; choose styles
by their shared `display`, `headline`, `title`, `body`, and `label` roles rather
than by screen or feature. This keeps forms, buttons, menus, and future
features on one type scale and lets Material provide platform and locale
geometry.

`AppTypography` mirrors the Material 3 size and line-height roles for Flame's
bitmap text, where Flutter `TextStyle`s cannot render the atlas. Its bitmap
scaler maps those roles to the original 5×7 font in
`assets/images/ui/fonts/`, using a 14-pixel source and a 12-pixel minimum for
compact layouts. `AppTypography.pixelStyle` centralizes Press Start 2P for the
few Flutter surfaces that need pixel lettering; use it as an accent rather
than as the app's body font.

Font review: [Material 3 typography roles and readability guidance](https://m3.material.io/styles/typography/applying-type)
defines the shared type scale and its line-height guidance. [VT323](https://github.com/google/fonts/blob/main/ofl/vt323/METADATA.pb)
is an OFL-licensed monospace pixel candidate with an explicit Vietnamese
subset. [Pixelify Sans](https://github.com/google/fonts/blob/main/ofl/pixelifysans/METADATA.pb)
is an OFL display face, but its metadata does not list Vietnamese. Keep the
existing atlas: it already matches the game and covers the required languages.

## Game runtime and inputs

`GameView` hosts `Gunwave` inside Flame's `GameWidget`. `Gunwave` mounts a
`Stage`, the player, local enemies, abilities, and the asset-rendered HUD.
Tiled object layers provide spawn points and collision geometry.

Static collision rectangles are inserted into a uniform `CollisionGrid`.
Moving entities query nearby cells, then `AabbMovement` resolves horizontal
and vertical movement separately against candidate rectangles. This limits
collision checks to nearby map geometry instead of scanning every collision
object for every move.

Joystick, keyboard, and gesture modes drive the same character movement and
attack actions. Keyboard input uses the game focus node. Gesture control starts
and stops native recognition with the campaign view lifecycle. The solo stage
does not use room countdowns, quiz overlays, or quiz-derived failure rules.

```text
Flutter GameViewModel
    ↕ MethodChannel: gesture_recognizer
Android CameraX / iOS AVFoundation
    ↓ camera frames
Native MediaPipe Gesture Recognizer
    ↓ recognized label
Flutter gesture stream → GestureControls → character movement/attack
```

The native service owns camera capture and inference. Android uses CameraX and
MediaPipe on a native executor; iOS uses AVFoundation sample buffers and
MediaPipe live-stream recognition. Flutter receives gesture labels and maps
them to movement and attack state. Frames are not sent through a Dart isolate,
which would require crossing the platform boundary with image data.

## Asset storage

- `assets/images/` contains runtime sprite PNGs and their editable Aseprite
  files.
- `assets/images/ui/` contains shared frames, buttons, icons, pointers, and the
  generated bitmap font.
- `assets/tiles/` contains Tiled maps.
- `assets/data/campaign/` contains local stage definitions.
- There is no separate source-pack archive or version manifest. Keep imported
  runtime art in the existing folders, avoid storing distributable source-pack
  archives in the app, and document each addition's source, revision, and
  license in the project asset audit.

Tiled `.tmx` maps, tilesets, and image assets stay packaged files. Drift stores
their stable IDs, map keys, and gameplay relationships; it does not store image
or map bytes.
