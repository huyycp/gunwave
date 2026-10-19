# Technology stack

| Area | Technology | Use in Gunwave |
|---|---|---|
| App language and UI | Dart, Flutter | Cross-platform app screens, widgets, and platform integration. FVM pins Flutter 3.47.4; the SDK constraint is Dart `>=3.13.0 <4.0.0`. |
| Game engine | Flame | Real-time game loop, camera, components, input, and rendering. |
| Map loading | `flame_tiled`, Tiled maps | Loads `.tmx` maps and their object layers for spawns and collision geometry. |
| State management | Riverpod, `ChangeNotifier` | Provides dependencies and screen-level view model state. |
| Navigation | GoRouter | Defines app routes for splash, home, rooms, characters, shop, rankings, and settings. |
| Backend client | `supabase_flutter` | Supabase Auth, database access, and Edge Function calls. |
| Environment values | `flutter_dotenv` | Loads `dev.env` or `prod.env` at startup. |
| Android gesture capture | CameraX | Captures camera frames on Android. The app's Android minimum SDK is 24. |
| iOS gesture capture | AVFoundation | Captures camera sample buffers on iOS. |
| Hand gesture inference | MediaPipe Tasks Vision | Runs the packaged gesture-recognition model on native camera frames. Android declares `tasks-vision:0.10.14`; iOS uses the MediaPipe Tasks Vision dependency in the Xcode project. |
| Ranking validation | Supabase Edge Functions, Deno, `@supabase/supabase-js` | Authenticates ranking submissions, validates score inputs, and stores results. |
| Art and content | PNG assets, Tiled `.tmx` files | Pixel-art visuals, effects, and playable maps. |
| Tests and analysis | Flutter Test, Dart analyzer, `flutter_lints` | Unit/widget-level logic checks and static analysis. |

## Key runtime boundaries

- Flutter owns screens, navigation, room and character workflows, and game UI.
- Flame owns the active game world and its component updates.
- Native Android and iOS code own camera capture and hand gesture inference.
- Supabase owns authentication and shared remote game data; ranking score validation is performed in the Edge Function.

See [architecture](architecture.md) for the data flows and [project structure](project-structure.md) for the corresponding source locations.
