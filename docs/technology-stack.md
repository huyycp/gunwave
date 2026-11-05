# Technology stack

| Area | Technology | Use in Gunwave |
|---|---|---|
| App language and UI | Dart, Flutter | Cross-platform app screens, widgets, and platform integration. FVM pins Flutter 3.47.4; the SDK constraint is Dart `>=3.13.0 <4.0.0`. |
| Game engine | Flame | Real-time game loop, camera, components, input, and rendering. |
| Map loading | `flame_tiled`, Tiled maps | Loads `.tmx` maps and object layers for spawns and collision geometry. |
| State management | Riverpod, `ChangeNotifier` | Provides dependencies and screen-level view state. |
| Navigation | GoRouter | Defines app routes for splash, Home, Campaign Map, character loadout, Shop, and Settings. |
| Local database | Drift, SQLite | Versioned relational game catalog, player progress, balances, hero ownership/upgrades, and app settings. |
| Legacy settings migration | `shared_preferences` | Reads and clears the prior locale key once; new app and game data use Drift. |
| Android gesture capture | CameraX | Captures camera frames on Android. The app's Android minimum SDK is 24. |
| iOS gesture capture | AVFoundation | Captures camera sample buffers on iOS. |
| Hand gesture inference | MediaPipe Tasks Vision | Runs the packaged gesture-recognition model on native camera frames. Android declares `tasks-vision:0.10.14`; iOS uses the MediaPipe Tasks Vision dependency in the Xcode project. |
| Art and content | PNG assets, Tiled `.tmx` files, bundled JSON | Pixel-art visuals, effects, playable maps, and campaign definitions. |
| Tests and analysis | Flutter Test, Dart analyzer, `flutter_lints` | Unit/widget logic checks and static analysis. |

## Key runtime boundaries

- Flutter owns screens, navigation, the local campaign/shop flow, and app state.
- Flame owns the active game world and its component updates.
- Drift owns structured catalog, campaign, player, and settings data on the
  device; the app has no account or backend requirement.
- Native Android and iOS code own camera capture and hand gesture inference.

See [architecture](architecture.md) for the local data flows and
[project structure](project-structure.md) for source locations.
