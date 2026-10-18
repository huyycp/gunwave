# Character abilities

Each character's `ability_id` points to a Supabase `abilities` row. The game reads the joined `abilities` definition; it does not infer abilities from a character's color. Missing/unknown/invalid definitions disable the Special control and emit a structured warning.

## Controls

- Keyboard: WASD/arrows move, J attacks, K activates the special ability once per press.
- Joystick and gesture: tap the ability icon above the attack button. Its cooldown appears directly on the button. Gesture mode also supports a touch attack fallback.
- Keyboard: compact ability icon, cooldown and **In use** status appear beside player HP. Instant casts show a brief status; caster buffs remain marked until expiry or charge consumption. Duration/charge details are omitted from the HUD.
- Player HP is a fixed numeric bar at the top left. Monster bars show current/max HP with upright text when sprites flip.
- The smaller keyboard guide sits near the safe bottom edge.
- Top-right Exit, Escape and system back open an exit confirmation. Combat and the stage timer pause; cancel resumes the stage.
- First Aid does not spend cooldown at full HP. Hex Seal does not spend cooldown without a living target in range.
- Casting is blocked before loading, during quizzes, after completion, when paused, and after death.

## Runtime

`AbilityRegistry` maps stable database keys to concrete `Ability` implementations. `AbilityController` owns cooldown and activation; `AbilityContext` supplies targeting/dash/projectile operations. `GameAbilityContext` connects these to Flame. `Combatant` provides shared damage and healing, while `StatusEffectController` tracks temporary modifiers without changing permanent stats.

The eight concrete abilities are immutable Freezed value classes with `copyWith` and value equality. Use `fromDefinition` to validate Supabase tuning values; serialization stays in `AbilityModel`. Mutable cooldown and status controllers remain separate. Regenerate ignored sources with `fvm dart run build_runner build` (Freezed 4 and Dart 3.13+, matching the FVM SDK).

All durations advance with simulation `dt`; no additional timers, network calls, or JSON parsing occur per frame. HUD listeners update when displayed seconds, charge count, or readiness changes. Same-key effects refresh instead of stacking. Death and stage exit remove effects.

| Key | Behavior |
| --- | --- |
| `bulwark` | Reduces monster and fire damage for `duration_ms`. |
| `power_break` | Multiplies the next `attack_count` normal swings, consuming one charge per swing. |
| `thunder_crash` | Damages monsters in `radius_tiles` and stuns them for `stun_ms`. |
| `rift_slash` | Launches a ranged slash; `pierces` controls whether it passes through monsters. Walls always stop it. |
| `first_aid` | Heals `heal_max_hp_fraction`, capped at maximum HP; does not revive dead actors. |
| `flame_brand` | Launches a projectile that stops at its first target or wall. |
| `quickstep` | Dashes `dash_tiles` in the last movement direction. Walls stop the dash and its immunity. |
| `hex_seal` | Slows the nearest living monster's movement and attack cadence. Legacy rows without `range_tiles` use four tiles. |

Projectiles use segment sweeps against target bounds and static walls, preventing tunneling and repeated hits against the same target. Damage immunity keeps collision detection active so checkpoints continue working.

## Visual feedback

| Ability | World feedback |
| --- | --- |
| Bulwark | Cyan shield outline follows the character for the shield's lifetime. |
| Power Break | Orange crossed blades and charge pips follow the character until charges run out. |
| Thunder Crash | Yellow lightning expands across its actual damage radius; stunned monsters show orbiting stars. |
| Rift Slash | Purple sweeping crescents and a crescent-shaped travelling projectile. |
| First Aid | Green healing crosses rise from the character. |
| Flame Brand | Orange flame burst followed by a flame-shaped bolt with a yellow core. |
| Quickstep | Blue speed streaks follow the dash and stop with its immunity. |
| Hex Seal | A pink rotating rune follows the affected monster throughout the slow. |

`AbilityVisualStyle` shares the stable key, palette, and HUD icon. `AbilityFeedback` draws lightweight Canvas geometry and follows the affected combatant. Active status visuals refresh without duplicating components. The game clock controls their animation and lifetime.

Casting while moving preserves movement input. Casting during an attack preserves its current animation and damage snapshot; Power Break applies from the next normal swing. K repeat events do not automatically recast. Touch controls use the same activation path.

## Damage feedback

Accepted hits spawn rising `-HP lost` text at the hit actor's world position: red for damage taken and yellow for damage dealt. Mitigation and overkill use actual HP lost; ignored hits do not spawn text. Text is independent of the actor, so a lethal hit remains visible after removal. `MoveEffect.by` and `RemoveEffect` animate and clear it after 0.7 seconds; a 32-number cap includes pending additions to bound crowded scenes. Monster HP labels cache text layout until HP changes.

Implementation reference: [Flame movement effects](https://docs.flame-engine.org/latest/flame/effects/move_effects.html) and [effect lifecycle](https://docs.flame-engine.org/latest/flame/effects/effects.html).

## Adding an ability

1. Add an `Ability` implementation under `lib/views/game/abilities/implementations/` and validate its parameters in the constructor.
2. Register its database key in `AbilityRegistry`.
3. Add its Supabase row and character link. Balance data changes use existing `cooldown_ms`, `duration_ms`, and JSONB `parameters` columns.
4. Test activation success/failure, cooldown, effect expiry, and any new targeting rule.

Parameter validation bounds damage multipliers to 10 and ranges to 50 tiles as safety limits for malformed configuration. Keep new mechanics within shared combat/status hooks where possible. Temporary buffs never alter the database's character stats.

`supabase/migrations/202610180002_allow_ability_catalog_reads.sql` grants authenticated players, including anonymous Auth users, read access to the ability catalog. It was applied to the development project through the Management API; rerunning the migration is safe. The CLI migration-history table was not modified by that API call.

## Verification

Run `fvm flutter test test/views/game/abilities`. The 59 focused tests cover all eight abilities, simultaneous W/J/K input, mid-swing charge semantics, key repeats, mitigation, healing caps, stun/slow expiry, cooldown blocking, dash wall collisions, swept projectile hits, eight distinct nonempty effect renders, effect follow/expiry, English/Vietnamese HUD interaction, numeric player HP updates, damage movement/removal/capping, lethal-hit values, and Escape dispatch. Device visuals and performance still require a manual smoke test.
