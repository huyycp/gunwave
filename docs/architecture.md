# Architecture and data flow

Gunwave uses a feature-oriented Flutter structure with presentation, repository, and data-source responsibilities. The app is not implemented with BLoC: screen state is handled by Riverpod providers and `ChangeNotifier` view models.

## Flutter application flow

```text
View / widget
    ↓ reads and watches
Riverpod provider + ChangeNotifier view model
    ↓ calls
Feature repository
    ↓ delegates to
Local or remote data source
    ↓
Platform API or Supabase
```

- **Views** in `lib/views/` render screens and send user actions to view models.
- **View models** own screen state and coordinate asynchronous operations.
- **Repositories** expose feature operations to view models and delegate persistence or platform access.
- **Data sources** implement the integrations: Supabase for remote data and a Flutter method channel for native gesture recognition.
- **Models and request DTOs** represent loaded entities and serialized operation inputs.

Repositories are intentionally thin in several features; the data layer is not a separate Dart package.

## Game runtime

`GameView` hosts `Gunwave` inside Flame's `GameWidget`. `Gunwave` loads a `Stage`, and the stage loads the selected Tiled map and creates runtime components for the character, monsters, traps, buildings, and collision objects.

Static collision rectangles are inserted into a uniform `CollisionGrid`. Moving entities query nearby cells, then `AabbMovement` resolves horizontal and vertical movement separately against candidate rectangles. This limits collision checks to nearby map geometry instead of scanning every collision object for every move.

Room quiz data is displayed by Flutter UI over the Flame game. The game timer, quiz progress, and submitted run state are coordinated by `GameViewModel` and `GameView`.

## Gesture data flow

```text
Flutter game view model
    ↕ MethodChannel: gesture_recognizer
Android CameraX / iOS AVFoundation
    ↓ camera frames
Native MediaPipe Gesture Recognizer
    ↓ recognized label
Flutter gesture stream → GestureControls → character movement/attack
```

The native service owns camera capture and inference. Android uses CameraX and MediaPipe on a native executor; iOS uses AVFoundation sample buffers and MediaPipe live-stream recognition. Flutter receives gesture labels and maps them to movement and attack state. Frames are not sent through a Dart isolate, which would require crossing the platform boundary with image data.

The game view starts recognition when gesture mode begins and stops it when the view is disposed. Camera access requires operating-system permission.

## Supabase backend

`SupabaseApi` initializes the client from `SUPABASE_URL` and `SUPABASE_ANON_KEY` loaded by `BuildConfig` from the selected environment file. Remote data sources use Supabase Auth and database queries for users, rooms, maps, characters, and rankings.

Room creation calls the database function `create_room_with_quizzes`, which validates the authenticated creator and map, then inserts the room and its quizzes in one transaction. Ranking submissions go through the `update-ranks` Edge Function; it validates the authenticated user, room, character ownership, and score inputs before saving a rank.

The checked-in Supabase files do not define the complete base schema or all game content tables. A backend intended for a fresh install needs that schema and content provisioned separately, in addition to applying the checked-in migration and deploying the Edge Function. Keep privileged service-role credentials on trusted backend infrastructure; the Flutter app should use only a client-safe anon/publishable key.

## Environment selection

`lib/main_dev.dart` calls `startApp(BuildEnv.dev)` and loads `dev.env`; `lib/main_prod.dart` selects `prod.env`. These are Dart entrypoints, not Android product flavors. The selected file must exist because both environment files are declared as Flutter assets in `pubspec.yaml`.
