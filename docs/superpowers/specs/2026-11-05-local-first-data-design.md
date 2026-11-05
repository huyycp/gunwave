# Local-first game data design

## Goal

Remove the app's Supabase runtime and account requirement. Store mutable game
state in a versioned local SQLite database managed by Drift. Keep shipped game
content available offline and preserve the existing RPG campaign.

## Agreed scope

- The app has no sign-in, guest account, remote profile, or account identifier.
- New local player state starts with zero gold, zero campaign clears, and no
  imported cloud inventory or upgrades. First database setup grants the
  bundled Adept Warrior so the player can start a stage.
- Static game data that does not belong to a player is retained: stages,
  monsters, rounds, encounters, rewards, map references, and bundled visual
  assets.
- Tiled `.tmx` maps, tilesets, sprites, sound, and other binary assets stay in
  Flutter assets. SQLite stores their stable keys/paths, not their bytes.
- Campaign reward gold and Shop spending use one local gold balance so a fresh
  offline game can earn and spend gold. Status-point rewards remain represented
  in campaign progress; this migration does not redesign the existing stat
  upgrade rules.
- Preserve a saved locale preference when migrating it from legacy
  SharedPreferences. Do not import campaign clears, balances, inventory, or
  upgrades from the old serialized progress or Supabase account.
- The repository's `supabase/seed.sql` was empty. The user supplied sanitized
  static `characters_rows.csv` and `abilities_rows.csv` exports under `seeds/`;
  the app bundles normalized JSON derived from those exports. Do not add
  account-owned data to the catalog.
- Remove local Supabase client, auth UI, SDK/config, Edge Function artifacts,
  connection smoke test, and obsolete documentation. Do not delete or alter
  the hosted Supabase project or its remote data.

## Storage choice

Use Drift over SQLite. Drift provides typed tables and queries, transactions
for purchases/rewards, versioned schema migrations, and in-memory database
tests. SharedPreferences can store isolated key/value settings but cannot
provide relational constraints, atomic multi-row updates, or the migration and
CRUD coverage requested here. The app currently targets iOS/Android and can
use `drift_flutter` for its persistent application-support database.

## Local schema

Static content tables:

- `abilities`: ID, stable key, localized display fields, cooldown/duration,
  and parameters stored as JSON text.
- `characters`: ID, name, sprite filename, price, base stats, optional ability
  foreign key.
- `stages`: ID, order, name, map key, optional preceding-stage requirement.
- `monsters`: ID, name, sprite filename, combat stats, score.
- `stage_monsters`: stage-to-monster membership.
- `stage_rounds`: stage ID, round number, and boss flag.
- `round_encounters`: round ID, monster ID, Tiled spawn marker, count, and
  encounter order.
- `stage_rewards`: stage ID, reward type, amount, and reward order.

Local mutable state:

- `player_state`: singleton row with shared local gold, campaign status points,
  and selected hero ID.
- `owned_characters`: catalog character ID plus per-player upgraded stats and
  status points. This is local device state, not an account/profile table.
- `campaign_stage_clears`: stage ID and first-clear timestamp.
- `settings`: key/value settings including the locale mode.
- `app_metadata`: one-time legacy-settings migration marker.

All player mutations (purchase, upgrade/reset, clear/reward) use SQLite
transactions. Foreign keys and unique constraints enforce catalog links,
singleton rows, and one ownership/clear row per key.

## Content seeding and startup

On startup, open the app database and apply Drift schema migrations before
rendering the app. Seed or refresh bundled Stage 1 content from
`assets/data/campaign/stages.json` and the hero/ability catalog from
`assets/data/catalog/` transactionally, preserving any player state. Create
the zero-balance local state and grant the Adept Warrior only when ownership
is empty. Catalog updates upsert static definitions without replacing
player-owned rows. Existing local saves migrate the temporary starter ID to
the catalog ID while retaining invested upgrades.

The campaign repository reads stage/monster/round/reward models from Drift;
the Tiled map loader continues resolving `mapKey` through the existing local
map and asset catalogs. The locale controller reads/writes `settings` through
the same database. Legacy serialized campaign progress is intentionally not
imported because the requested new local player state is empty.

## Migration and failure behavior

- The first Drift schema is version 1. Future table changes increment
  `schemaVersion` and use Drift migrations; tests open the in-memory database
  and exercise the generated schema/migration path.
- No Supabase data import is performed. Old remote data remains untouched on
  the hosted service. Removing the app integration does not delete that data.
- Legacy locale is imported once; invalid or unavailable preference values
  fall back to system locale. The marker is written in the same successful
  database initialization so a failed seed can safely retry.
- Content validation errors fail initialization with the offending asset or
  key reported; game state mutations are rolled back on failure.

## Verification

Required automated coverage includes Drift CRUD, idempotent content seeding,
first-start state, local purchase/upgrade/reset transactions, campaign clear
and one-time reward persistence, locale persistence/legacy migration, and
startup without environment files or authentication. Run focused tests, the
full Flutter test suite, static analysis, and a final diff review.

## Catalog export

The sanitized CSV exports are kept under `seeds/`; normalized runtime assets
are `assets/data/catalog/characters.json` and `abilities.json`. They contain
static identifiers, names, sprite filenames, prices, stats, ability links,
cooldowns, durations, and parameter objects. They contain no user IDs,
account balances, or ownership.
