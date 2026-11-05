# Local-first data migration Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Replace the remote-account data path with a Drift-backed offline RPG database and remove all Supabase runtime/account requirements.

**Architecture:** Drift is the single store for mutable player state, catalog rows, structured campaign content, and app settings. A local content seeder imports the bundled campaign JSON and catalog assets; repositories keep models and business transactions out of Flame scenes. Existing Tiled maps and image assets remain packaged files. Startup opens/migrates/seeds SQLite before `runApp`.

**Tech Stack:** Flutter 3.47.4, Dart 3.13, `drift` 2.35.3, `drift_dev` 2.35.2, `drift_flutter` 0.3.1, Riverpod, `flutter_test`, `NativeDatabase.memory()`.

**Spec:** `docs/superpowers/specs/2026-11-05-local-first-data-design.md`

## Global Constraints

- No Supabase Auth, guest identity, remote game data, or account requirement.
- New player balances, owned heroes, upgrades, and campaign clears start empty; bootstrap only grants the bundled starter needed to play.
- Keep static campaign and monster content, Tiled maps, sprites, and assets local and usable offline.
- Use one local gold balance for campaign rewards and Shop purchases; initialize it to zero.
- Use the supplied sanitized CSV exports in `seeds/` as the catalog source and normalize them into bundled JSON assets. Do not add account-owned data.
- Do not modify/delete hosted Supabase data; remove only this app's local integration and obsolete checked-in artifacts.
- Preserve ignored developer-local `dev.env`, `prod.env`, and Supabase CLI cache files; startup and asset manifests no longer read or bundle them.
- Preserve the saved locale where available; do not import old game progress/account data.
- Keep repositories as the database boundary and preserve existing Freezed domain models and Riverpod conventions.

## Review Focus

- A purchase racing another write or repeated tap cannot overspend or duplicate ownership; cover with transactional tests.
- Stage completion repeated after app restart cannot grant gold twice; cover with persistent in-memory DB tests.
- Partial seed failure cannot leave missing rounds/rewards or corrupt player state; cover transaction rollback and idempotent seeding.
- Empty/missing remote catalog cannot crash startup or require a network; cover first-start with starter-only content.
- Invalid legacy locale or absent legacy preferences must not block DB startup; cover fallback and one-time migration.

---

### Task 1: Define and create the Drift schema

**Files:**
- Create: `lib/data/database/app_database.dart`
- Create: `lib/data/database/catalog_tables.dart`
- Create: `lib/data/database/campaign_tables.dart`
- Create: `lib/data/database/player_tables.dart`
- Create: `test/data/database/app_database_test.dart`
- Modify: `pubspec.yaml`, `pubspec.lock`

**Interfaces:**
- Produces `AppDatabase()`, `AppDatabase.forTesting(QueryExecutor)`, `appDatabaseProvider`, and schema version 1.
- `catalog_tables.dart` defines abilities and characters; `campaign_tables.dart` defines stages, monsters, stage-monster links, rounds, encounters, and rewards; `player_tables.dart` defines singleton player state, owned characters, stage clears, settings, and app metadata.

- [x] Add tests for in-memory open, CRUD on representative catalog/state/settings tables, foreign-key constraints, and singleton/unique constraints.
- [x] Run `fvm flutter test --no-pub test/data/database/app_database_test.dart --reporter expanded`; the new tests failed to compile before the schema implementation.
- [x] Add `drift: ^2.35.3`, `drift_flutter: ^0.3.1`, and `drift_dev: ^2.35.2`, define schema version 1 and test constructor, and generate Drift code with `fvm dart run build_runner build`.
- [x] Configure `build.yaml` for `app_database.dart`, `drift_schemas/`, and `test/data/database/migrations/`; run `fvm dart run drift_dev make-migrations` to generate the v1 schema snapshot. Future schema versions will generate step-by-step migrations and migration tests.
- [x] Run focused database tests, `fvm dart format`, and `fvm dart analyze lib/data/database test/data/database`.
- [x] Commit `feat: add local Drift database schema` (`992d020`).

### Task 2: Seed bundled content and create local repositories

**Files:**
- Create: local content seeder/data source and character/player-state database repositories under `lib/data/` and `lib/repositories/`.
- Modify: `lib/repositories/campaign_repository.dart`, `lib/repositories/campaign_progress_repository.dart`, `lib/data/data_sources/local/campaign_content_data_source.dart`, and local models only as needed.
- Test: database seeding, campaign repository, campaign progress repository, and character repository tests.

**Interfaces:**
- Campaign reads continue returning `CampaignStageModel`, `MonsterModel`, `StageRoundModel`, and `RewardModel`.
- Character repository exposes catalog/owned/unowned reads, transactional buy, stat upgrade, and reset without a user ID.
- Campaign completion and Shop purchase share the local gold field and are transaction-safe/idempotent.

- [x] Add failing tests for seeding the five-round Stage 1 catalog twice, starter ownership on a fresh DB, catalog reads, and first-clear reward uniqueness.
- [x] Add failing CRUD/transaction tests for buy, insufficient gold, duplicate buy, upgrade with no points, reset, and campaign persistence after reopening the in-memory store.
- [x] Implement normalized seed writes from `stages.json`, plus starter seed and database repository methods; leave catalog JSON import ready for the user's export without fabricating rows.
- [x] Preserve model validation and use transactions/constraints for atomic behavior.
- [x] Run focused data/repository tests (25 passed), formatting, and targeted analysis (clean).
- [x] Commit `feat: persist RPG content and progress locally` (`88d93ed`).

### Task 3: Move app settings and startup to Drift

**Files:**
- Modify: `lib/localization/app_locale_controller.dart`, `lib/main_prod.dart`, `lib/main_dev.dart`, `lib/app.dart` as needed.
- Remove: `lib/build_config.dart` once all references are gone.
- Modify tests: locale persistence, startup/bootstrap tests.

- [x] Add tests for locale read/write through Drift, one-time legacy locale import, and invalid values falling back to system locale.
- [x] Initialize the database, bundled seeds, legacy settings migration, and locale before `runApp`; inject the opened DB into Riverpod and close it with provider disposal.
- [x] Stop loading `.env` and requiring Supabase values at app launch; dev/prod entrypoints now share local startup.
- [x] Remove ongoing `shared_preferences` reads/writes; retain the package only for one-time import and removal of legacy preference keys.
- [x] Run focused startup/locale tests (23 passed across startup, locale, Home, and RPG UI) and full library/test analysis (clean).
- [x] Commit `refactor: bootstrap the app from local storage` (`d421f24`).

### Task 4: Remove auth and convert RPG screens to local repositories

**Files:**
- Modify: Home/splash views and view models, base view-model dependencies, RPG menu host/models/scenes, Shop and character/attribute controllers.
- Remove: Supabase user/character data sources, user repository/model, login widget, account-specific localization keys, and obsolete auth tests.
- Test: Home, menu host, shop, character/loadout, and database repository interaction.

- [x] Add UI tests proving Home opens the RPG hub directly and auth/guest controls are absent.
- [x] Route Shop reads, purchase, upgrade, reset, and hero selection through local repositories with no user ID.
- [x] Remove account-only Shop copy and checks; keep the bundled starter available while the external catalog export is pending.
- [x] Run focused UI and repository suites; targeted analysis is clean.
- [x] Commit `feat: remove account requirement from RPG flows` (`075bc12`).

### Task 5: Remove Supabase dependencies and obsolete references

**Files:**
- Modify: `pubspec.yaml`, `README.md`, `docs/architecture.md`, `docs/technology-stack.md`, `docs/project-structure.md`, feature docs, and relevant tests.
- Remove: tracked files under `lib/data/data_sources/remote/` and `supabase/`, the Supabase smoke test, tracked env template, and dead auth/account files once `rg` confirms no runtime references. Keep ignored local credential/cache files untouched.

- [x] Run the Supabase/auth reference search across code, tests, package files, README, and docs; inspect the remaining historical statements.
- [x] Remove `supabase_flutter`, `flutter_dotenv`, and unused auth/room dependencies; update the asset manifest and lockfile.
- [x] Remove tracked local Supabase migrations, function/config files, and the opt-in connection test without calling hosted Supabase or touching remote data. Existing ignored local credentials and CLI cache remain unmodified and are not loaded or bundled.
- [x] Update docs with Drift schema, startup/seed flow, local-only behavior, and map/art asset boundary.
- [x] Run full `fvm flutter test --no-pub --reporter expanded` (142 passed), `fvm dart analyze lib test` (clean), `git diff --check` (clean), and review the final diff.
- [x] Commit `refactor: remove Supabase from the app`.

### Task 6: Integrate the supplied character and ability catalog

**Files:**
- Create/update: `assets/data/catalog/characters.json`, `assets/data/catalog/abilities.json`, `CharacterCatalogDataSource`, the starter identity migration, and seed tests.
- Test: full catalog round-trip, asset references, relationships, idempotent update.

- [x] Validate the supplied exports contain only static character/ability fields, all 8 sprite names map to local character assets, and all 8 keys are supported by the game.
- [x] Normalize the CSV exports to bundled JSON and seed them on startup with upserts; migrate the temporary starter ID while preserving balances, clears, unspent points, and upgrades.
- [x] Add assertions for sprite mappings, ability links, runtime ability parameters, catalog idempotency, and a readable broken-link failure.
- [x] Run catalog/seeder/repository tests, full suite (145 passed), `fvm dart analyze lib test` (clean), `git diff --check` (clean), and final diff review.
- [x] Commit `feat: seed the local hero and ability catalog`.

## Pre-flight

- Shared interfaces: Task 1 defines `AppDatabase`/tables consumed by Tasks 2–6; Task 2 defines repository methods consumed by Tasks 3–4; Task 6 supplies the seed assets consumed by Task 2's importer. Keep interfaces stable and reconcile if codegen requires naming changes.
- The user supplied sanitized `characters_rows.csv` and `abilities_rows.csv` in `seeds/`. JSON catalog assets are derived from those source exports. The Drift schema remains version 1 because the existing tables already match the export fields.
