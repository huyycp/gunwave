# Gunwave Whole-App Pixel UI Design

**Status:** Draft for review
**Date:** 2026-10-26

## Approved brief

Gunwave is a landscape pixel-art action game with English and Vietnamese localization. Players sign in, choose a room and character, select a control mode, and play a timed stage that uses room quiz content. This change gives all production screens one deliberate pixel-art visual system while preserving the current routes, data flows, and game behavior.

The user approved:

- A full pixel-art treatment, including data-heavy screens.
- A shared theme and phased application across all production routes.
- A readable pixel typeface for localized UI, scalable text, and touch targets of at least 48 dp.
- A palette based on the existing game art: parchment, ink, teal, red actions, and gold rewards.

The existing uncommitted gameplay HUD work is part of the implementation baseline and must be retained and aligned with the shared system.

## Design research

- The Skills.sh listing reports roughly 1M installs for Anthropic's `frontend-design`, whose listed implementation targets are HTML/CSS/JS, React, and Vue. Its useful contribution here is choosing a distinctive, product-specific visual direction instead of applying generic templates: [frontend-design](https://www.skills.sh/anthropics/skills/frontend-design).
- The Flutter-compatible `ui-ux-pro-max` listing reports roughly 416K installs and covers Flutter, mobile interaction, responsive layout, accessibility, and design-system guidance: [ui-ux-pro-max](https://www.skills.sh/nextlevelbuilder/ui-ux-pro-max-skill/ui-ux-pro-max).
- Google Fonts metadata lists a Vietnamese subset for VT323, while Press Start 2P's metadata lists Latin subsets without Vietnamese. VT323 will therefore be the localized pixel UI face; Press Start 2P is reserved for the non-localized English wordmark: [VT323 metadata](https://github.com/google/fonts/blob/main/ofl/vt323/METADATA.pb), [Press Start 2P metadata](https://github.com/google/fonts/blob/main/ofl/pressstart2p/METADATA.pb).
- Flutter's accessibility guidance calls for readable layouts at larger text scales, sufficient contrast, and minimum interactive targets of 48 dp: [UI design and styling](https://docs.flutter.dev/ui/accessibility/ui-design-and-styling). Flutter's adaptive guidance also distinguishes fitting the available space from remaining usable in it: [adaptive and responsive design](https://docs.flutter.dev/ui/adaptive-responsive).

These sources guide the implementation; web-specific patterns and unrelated palette presets will not be copied into the Flutter app.

## Visual system

### Palette and surfaces

Use the existing assets as the palette source of truth:

- **Canvas:** the muted teal already used by the pixel backgrounds.
- **Panel:** parchment textures from `assets/images/ui/banners/`.
- **Ink:** the existing dark navy `GameColors.primary` and the dark outlines in the sprite assets.
- **Primary action:** the red pixel button assets under `assets/images/ui/buttons/`.
- **Reward accent:** the existing gold/currency art and a matching theme token.
- **Secondary states:** existing blue and yellow sprite families where the action hierarchy calls for them.

Replace the competing purple primary palette in `lib/theme/app_colors.dart` with named roles from this pixel palette. Error, warning, success, disabled, focus, selected, and pressed states must remain distinguishable and must not rely on color alone.

During token definition, sample representative colors from the checked-in art. If an exact sampled color misses the text-contrast targets below, use the nearest palette-compatible tone that meets the target; keep the sprite artwork itself unchanged.

Keep pixel edges crisp with nearest-neighbor filtering. Use the existing frame assets for repeated panels and button states, preserving their corners when scaled. Avoid blurred glass, soft generic cards, gradients, and default Material surfaces where a pixel component already exists.

### Typography

- Use **VT323** as the primary UI face for all localized English and Vietnamese text, including questions, descriptions, labels, and data. Bundle the font and its OFL license with the app so rendering does not depend on a runtime font download.
- Use **Press Start 2P** only for the static English wordmark. Do not use it for localized content because its Google Fonts metadata does not list a Vietnamese subset.
- Define named display, heading, body, label, and numeric styles in the existing theme layer. Keep pixel type throughout, with larger sizes and line heights for longer copy.
- Allow Flutter text scaling. Labels and paragraphs wrap naturally; essential text must not be clipped or silently truncated.

### Component treatment

Use the existing project widgets as the shared UI foundation:

- `GameButton` for sprite-backed actions with consistent enabled, hover, pressed, disabled, and focus states.
- `AppButton` for action variants and icons, styled from the same pixel tokens and assets.
- `AppTextFormField` for pixel-framed forms, validation, focus, and error states.
- `AppListTile` for room, quiz, rank, and settings rows with the same text and panel tokens.
- Existing banner assets for framed panels; add a small shared panel primitive only where repeated compositions cannot be expressed by these widgets cleanly.

All standard Material controls that remain (for example switches, progress indicators, dialogs, and snack bars) must receive explicit pixel-theme styling. Keep the current Riverpod, view-model, routing, and Flame architecture; this work is a presentation change.

## Production route coverage

1. **Splash, authentication, and home:** establish the shared backdrop, logo treatment, account state, primary Play action, and consistent access to shop, characters, rooms, and settings.
2. **Room discovery and play setup:** style room previews, character selection, and control-mode selection with clear selected/disabled states.
3. **My rooms and room creation:** use the same panels and form controls for room cards, map selection, privacy, quiz editing, validation, and submission states. Long content remains scrollable.
4. **Character collection and shop:** present character previews, stats, ownership, price, and purchase actions with consistent hierarchy.
5. **Rankings and settings:** use legible pixel rows and stable columns for ranks, plus the shared language selector and empty, loading, and error states.
6. **Gameplay HUD and overlays:** keep the Flame game world visually separate from its Flutter overlays while matching the shared palette and controls. Include ability and health HUDs, quiz UI, exit confirmation, stage result, and rank-submission states. Retain the current pixel joystick, attack button, health bars, and hit feedback work.

The developer-only test recognizer is not a production route and is outside this redesign.

## Layout, accessibility, and localization

- Preserve landscape-first play while adapting menus and panels to available height and width, including resized windows and tablets.
- Keep important content inside safe areas. Use constraints and scroll views instead of fixed sizes that clip on short landscape screens.
- Provide at least 48 dp interactive targets, visible focus feedback, meaningful semantics for icon-only controls, and keyboard access where existing flows support it.
- Target at least 4.5:1 contrast for normal text and 3:1 for large text. Pair status colors with text, icons, or shape changes.
- Validate both English and Vietnamese strings, including diacritics, longer translated labels, and increased system text scaling.
- Preserve loading, empty, error, disabled, selected, and success states on each screen; keep action feedback consistent.

## Phased implementation

1. Build the shared palette, typography, spacing, border, and state tokens in the existing theme layer. Bundle VT323 with its license.
2. Align reusable buttons, panels, list rows, forms, dialogs, and standard Material controls to those tokens.
3. Apply the system to splash/auth/home and room discovery, setup, creation, and management.
4. Apply it to character collection, shop, rankings, and settings.
5. Align gameplay HUD, quiz, and result/exit overlays without changing combat or quiz behavior.
6. Review every production route for consistency, localization, text scaling, contrast, touch size, and layout at narrow and standard landscape constraints.

## Acceptance criteria

- Every production route uses the approved pixel-art palette, type system, sprite treatment, and component states.
- No production UI retains the old purple primary as a competing brand color; status colors remain semantic and accessible.
- All localized UI uses the bundled Vietnamese-capable VT323 face; Press Start 2P appears only on the static English wordmark.
- Long and translated strings wrap, enlarged text remains usable, and no primary action or essential label is clipped.
- Interactive controls meet the 48 dp target and expose visible states and semantics.
- Loading, empty, error, disabled, selected, and success states have a consistent pixel treatment.
- Existing navigation, account/room/shop/rank data behavior, keyboard/gesture/touch controls, and game mechanics remain unchanged.
- The existing gameplay HUD changes are preserved and aligned to the shared theme rather than reverted.

## Risks and mitigations

- **Pixel typography can become dense in Vietnamese.** Use VT323, provide generous type sizes and line heights, wrap translated strings, and check the largest supported text scale.
- **Textured panels can reduce contrast.** Keep text on stable parchment or teal surfaces with the ink token; avoid placing paragraph copy over detailed art.
- **Landscape layouts can clip in resized windows.** Use constraints, scrollable content, and a narrow-landscape review pass instead of fixed-position assumptions.
- **Sprite scaling can blur or distort borders.** Use nearest-neighbor rendering and center-sliced framing where the asset structure allows it.
- **Existing widget APIs contain overlapping button systems.** Style both from one token source first; only consolidate APIs if implementation shows duplication that cannot be removed without broad behavior changes.
