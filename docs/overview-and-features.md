# Overview and features

## What Gunwave is

Gunwave is a landscape, pixel-art action game. A player signs in, selects a room and character, chooses a control mode, and completes a timed stage. Rooms provide the map and quiz content used for a run. The app stores account, character, room, and ranking data in Supabase; the game itself runs locally in the Flutter Flame engine.

## Player features

- **Email and password sign-in:** authenticates through Supabase Auth and loads the matching application profile from `users`. There is currently no sign-up screen.
- **Room selection:** browse available rooms, select a character, and choose how to control the stage.
- **Room creation:** create a room with a selected map, privacy setting, and quiz questions. Room creation and quiz association are handled together by the Supabase `create_room_with_quizzes` function.
- **My rooms:** view rooms associated with the signed-in user.
- **Character collection:** view available and owned characters, buy characters with in-game gold, and manage character attributes.
- **Timed stages:** play a Tiled map with a character, monsters, obstacles, traps, and checkpoints. Reaching the end of the quiz sequence or losing the character completes the stage.
- **Quiz gameplay:** answer room questions during a run. Incorrect answers reduce the remaining time; correct answers advance the quiz.
- **Three control modes:**
  - **Joystick:** on-screen movement and attack controls.
  - **Keyboard:** arrow keys or `WASD` move; `J` attacks.
  - **Gesture:** MediaPipe recognizes hand gestures using the device camera.
- **Rankings:** submit completed run results and view rankings filtered by room or user.

## Gesture controls

The recognized gestures map to game controls as follows:

| Gesture | Control |
|---|---|
| `Pointing_Up` | Move right |
| `Victory` | Move left |
| `Thumb_Up` | Move up |
| `Thumb_Down` | Move down |
| `Closed_Fist` | Attack |
| `Open_Palm`, `ILoveYou`, or `Unknown` | Stop movement and attack |

Gesture control needs camera permission. Gesture inference runs in native platform code and sends recognized labels to Flutter.

## Game content

Maps are authored as Tiled `.tmx` files under `assets/tiles/`. The stage loader reads object layers for spawn points and collisions. Character, monster, building, effect, and interface art is stored under `assets/images/`.

The available rooms, maps, characters, user profiles, and rankings depend on the configured Supabase database and its data. The repository does not include a complete initial database schema or a complete content seed.
