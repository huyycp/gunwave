# Overview and features

## What Gunwave is

Gunwave is a landscape, pixel-art action RPG with a solo campaign. Flutter hosts
the app and Flame game; Flame components render the RPG menus, combat HUD,
controls, dialogs, and results.

## Player features

- **Local play:** no sign-in, guest identity, or backend connection is required.
- **Campaign:** choose a stage from the Campaign Map, review its rounds, choose a
  hero, then fight through the stage and its boss. Stage 1 uses one Tiled map
  and five rounds, ending with a boss in Round 5.
- **Hero collection:** view locally owned heroes, buy catalog heroes with local
  gold, and manage owned hero attributes.
- **Campaign progress:** Drift stores stage clears, selected hero, local gold,
  status points, owned heroes, and upgrades on the device. Replaying a cleared
  stage does not award its first-clear rewards again.
- **New save:** starts with zero gold, zero status points, no cleared stages,
  and the bundled Blue Warrior as the playable starter. Clearing Stage 1 adds
  gold to the same wallet used by the Shop.
- **Shop catalog:** only the bundled starter is present until the sanitized
  character/ability JSON export is supplied. No hero stats, prices, or abilities
  are fabricated.
- **Control modes:** choose joystick, keyboard, or gesture controls in the
  asset-rendered Settings scene. Joystick is the default for a new menu session.
- **Settings:** choose the app language and the input mode for campaign runs.

The previous cloud account data is not imported or deleted. The app does not
connect to or modify the old hosted project. A saved language preference is
imported once from legacy local preferences; old serialized campaign progress
is intentionally discarded.

## Controls

- **Joystick:** on-screen movement and attack controls.
- **Keyboard:** arrow keys or `WASD` move; `J` attacks; `K` uses the special
  ability when available.
- **Gesture:** MediaPipe recognizes hand gestures using the device camera.

Gesture control needs camera permission. Gesture inference runs in native
platform code and sends recognized labels to Flutter.

| Gesture | Control |
|---|---|
| `Pointing_Up` | Move right |
| `Victory` | Move left |
| `Thumb_Up` | Move up |
| `Thumb_Down` | Move down |
| `Closed_Fist` | Attack |
| `Open_Palm`, `ILoveYou`, or `Unknown` | Stop movement |

## Game content and assets

- Campaign stage, round, encounter, monster, and reward definitions are local
  JSON under `assets/data/campaign/` and are copied into Drift at startup.
- Tiled `.tmx` files under `assets/tiles/` provide map geometry, collisions,
  and named spawn markers. Stage round order and encounter composition are not
  stored in Tiled.
- Runtime sprites and their editable Aseprite sources are stored under
  `assets/images/`; shared UI art and the bitmap font live under
  `assets/images/ui/`.
- The checked-in monster catalog currently contains barrel, TNT, and torch
  families in four palette variants. New Tiny Swords Enemy Pack sprites are
  not present yet. Review source, license, frame layout, and target size before
  adding updated pack art.
- The repository has no separate Tiny Swords source archive or asset-version
  manifest. Keep approved runtime sprites in the existing asset tree and record
  their source, pack revision, and license when new artwork is added.

## Retired client features

Room creation, room browsing, quiz gameplay, and quiz-derived rankings have
been removed from the client. The app now runs the local solo RPG flow only.
The local database does not import old account or quiz data.
