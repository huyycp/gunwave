// Drift's column checks intentionally reference their own getters.
// ignore_for_file: recursive_getters

import 'package:drift/drift.dart';
import 'package:gunwave/data/database/catalog_tables.dart';
import 'package:gunwave/data/database/campaign_tables.dart';

class PlayerStates extends Table {
  IntColumn get id => integer().customConstraint('NOT NULL CHECK (id = 1)')();

  IntColumn get gold => integer().check(gold.isBiggerOrEqualValue(0))();

  IntColumn get statusPoints => integer()
      .named('status_points')
      .check(statusPoints.isBiggerOrEqualValue(0))();

  TextColumn get selectedHeroId =>
      text().nullable().named('selected_hero_id')();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

class PlayerCharacters extends Table {
  TextColumn get characterId => text()
      .named('character_id')
      .references(Characters, #id, onDelete: KeyAction.restrict)();

  IntColumn get hp => integer()();

  IntColumn get strength => integer().named('str')();

  IntColumn get vitality => integer().named('vit')();

  IntColumn get agility => integer().named('agi')();

  IntColumn get statusPoints => integer()
      .named('status_points')
      .check(statusPoints.isBiggerOrEqualValue(0))();

  IntColumn get acquiredAt => integer().named('acquired_at')();

  @override
  Set<Column<Object>> get primaryKey => {characterId};
}

class CampaignStageClears extends Table {
  TextColumn get stageId => text()
      .named('stage_id')
      .references(Stages, #id, onDelete: KeyAction.restrict)();

  IntColumn get completedAt => integer().named('completed_at')();

  @override
  Set<Column<Object>> get primaryKey => {stageId};
}

class Settings extends Table {
  TextColumn get key => text()();

  TextColumn get value => text()();

  @override
  Set<Column<Object>> get primaryKey => {key};
}

class AppMetadata extends Table {
  TextColumn get key => text()();

  TextColumn get value => text()();

  @override
  Set<Column<Object>> get primaryKey => {key};
}
