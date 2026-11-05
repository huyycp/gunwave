# Overview and features

## What Gunwave is

Gunwave is a landscape, pixel-art action RPG with a solo campaign. Flutter hosts
the app and Flame game; Flame components render the RPG menus, combat HUD,
controls, dialogs, and results.

## Player features

- **Account access:** sign in with email and password through Supabase Auth.
  There is no sign-up screen.
- **Campaign:** choose a stage from the Campaign Map, review its rounds, choose a
  hero, then play through the stage and its boss encounter. Stage 1 uses one
  Tiled map and has five rounds, ending with a boss in Round 5.
- **Hero collection:** view owned characters, buy characters, and manage hero
  attributes through the existing account-backed character shop.
- **Campaign progress:** completed stage IDs, selected hero, and first-clear
  campaign rewards are saved locally with shared preferences. Progress resets
  if app data is cleared or the app is reinstalled. Campaign content and saves
  are local, but the current Home flow still requires Supabase guest sign-in
  before opening the RPG menus, so cold-start offline access is not guaranteed.
- **Shop balance:** the existing Shop continues to use online account gold and
  remote character ownership. Local campaign rewards are kept separate from
  that balance.
- **Control modes:** choose joystick, keyboard, or gesture controls in the
  asset-rendered Settings scene. Joystick is the default for a new menu session.
- **Settings:** choose the app language and the input mode for campaign runs.

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

- Campaign stage, round, encounter, enemy, and reward definitions are local
  JSON under `assets/data/campaign/`.
- Tiled `.tmx` files under `assets/tiles/` provide map geometry, collisions,
  and named spawn markers. Stage round order and encounter composition are not
  stored in Tiled.
- Runtime sprites and their editable Aseprite sources are stored under
  `assets/images/`; the shared UI art and bitmap font live under
  `assets/images/ui/`.
- The checked-in monster catalog currently contains barrel, TNT, and torch
  families in four palette variants. New Tiny Swords Enemy Pack sprites are
  not present yet. Review source, license, frame layout, and target size before
  adding any updated pack art.
- The repository has no separate Tiny Swords source archive or asset-version
  manifest. Keep approved runtime sprites in the existing asset tree and record
  their source, pack revision, and license when new artwork is added.

## Retired client features

Room creation, room browsing, quiz gameplay, and quiz-derived rankings have
been removed from the solo client. Related Supabase tables and the rank Edge
Function remain in the repository for compatibility until their deployed
schema and retention requirements are reviewed.
