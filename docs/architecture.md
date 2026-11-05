# Architecture and data flow

Gunwave uses a feature-oriented Flutter structure with presentation,
repository, and data-source responsibilities. App state uses Riverpod providers
and `ChangeNotifier` view models.

## Flutter application flow

```text
Flutter host/view
    ↓ reads and watches
Riverpod provider + ChangeNotifier view model
    ↓ calls
Feature repository
    ↓ delegates to
Local or remote data source
    ↓
Platform API or Supabase
```

- Views in `lib/views/` host a screen and forward user actions.
- View models own screen state and coordinate asynchronous operations.
- Repositories expose feature operations and delegate persistence or platform
  access to data sources.
- Data sources connect to local storage, Supabase, or native gesture
  recognition.

Repositories are intentionally thin in several features; the data layer is
not a separate Dart package.

## RPG menus and campaign data flow

```text
Local stages.json
    ↓ CampaignContentDataSource / CampaignRepository
RpgMenuHost snapshots + callbacks
    ↓ GameWidget host
Flame menu scenes → selected stage and hero
    ↓
GameView → Gunwave → Stage + RoundDirector
    ↓
Tiled map + local enemy catalog → Flame combat HUD and results
    ↓
CampaignProgressRepository → SharedPreferencesAsync
```

- `assets/data/campaign/stages.json` is the source for stage order, rounds,
  encounter groups, enemy stats, unlock rules, and rewards.
- `CampaignRepository` validates campaign references without Supabase room or
  remote map data.
- `Stage` resolves the stage map key to the local `GameMaps` catalog, loads the
  Tiled map once, validates named spawn markers, and creates the world
  components.
- `RoundDirector` advances configured encounters and emits one stage result.
- `CampaignProgressRepository` stores completed stages, selected hero, and
  campaign-earned balances locally. Completion mutations are serialized and
  first-clear rewards are idempotent.
- The visible Home Hub, Campaign Map, Stage Briefing, Loadout, Shop, Settings,
  combat HUD, pause menu, and results are Flame components using local sprites
  and the shared bitmap font. Flutter hosts Flame through `GameWidget` and
  provides non-visual application state and callbacks.
- Input mode selection is rendered in Flame Settings and held by
  `RpgMenuHost` for its current lifetime. A new menu host defaults to joystick.

## Typography

`AppTypography` is the shared source for sizes and line-height rhythm. Use the
12 / 14 / 16 / 18 / 24 / 32 logical-pixel scale: captions are 12, compact
controls 14, supporting text 14, body text 16 or 18, screen titles 24, and
display headings 32. Keep primary body and form text at 16 or larger with a
1.5 line height; reserve 12 for short captions and secondary status labels.
Headings use a 1.2 line height.

Flutter's shared `BaseTextTheme` uses Roboto for readable body and form text.
`AppTypography.pixelStyle` centralizes Press Start 2P for the few legacy
Flutter surfaces that use pixel lettering. Flame RPG labels use the original
5×7 bitmap atlas in `assets/images/ui/fonts/`, with a 14-pixel base and English
and Vietnamese glyphs. `AppTypography.bitmapScale` maps semantic sizes to the
atlas and keeps text at least 12 logical pixels tall when a compact viewport
reduces surrounding UI. Buttons use 14-pixel labels by default.

Font review: [UI/UX Pro Max typography guidance](https://github.com/nextlevelbuilder/ui-ux-pro-max-skill/blob/main/src/ui-ux-pro-max/templates/base/quick-reference.md)
recommends a consistent 12 / 14 / 16 / 18 / 24 / 32 scale, 16-pixel body text,
and 1.5 body line height. [VT323](https://github.com/google/fonts/blob/main/ofl/vt323/METADATA.pb)
is an OFL-licensed monospace pixel candidate with an explicit Vietnamese
subset. [Pixelify Sans](https://github.com/google/fonts/blob/main/ofl/pixelifysans/METADATA.pb)
is an OFL display face, but its metadata does not list Vietnamese. Keep the
existing atlas: it already matches the game, covers the required languages,
and avoids adding a font dependency or importing another visual style.

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

## Supabase backend

`SupabaseApi` initializes the client from `SUPABASE_URL` and
`SUPABASE_ANON_KEY` loaded by `BuildConfig` from the selected environment file.
The current app still uses Supabase Auth and account-backed character/shop
operations. Solo campaign content and progress are local, but Home currently
requires Supabase guest sign-in before it opens the RPG menus; cold-start
offline access is not guaranteed.

Room creation, quiz gameplay, and ranking entry points have been retired from
the client. The checked-in Supabase files do not provide a complete base
schema, so room/rank database objects and the `update-ranks` Edge Function are
preserved pending review of the deployed schema, old-client compatibility, and
data retention needs. A backend intended for a fresh install still needs its
base schema and content provisioned separately. Keep privileged service-role
credentials on trusted backend infrastructure; the Flutter app should use
only a client-safe anon/publishable key.

## Environment selection

`lib/main_dev.dart` calls `startApp(BuildEnv.dev)` and loads `dev.env`;
`lib/main_prod.dart` selects `prod.env`. These are Dart entrypoints, not
Android product flavors. The selected file must exist because both environment
files are declared as Flutter assets in `pubspec.yaml`.
