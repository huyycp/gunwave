// Drift's column checks intentionally reference their own getters.
// ignore_for_file: recursive_getters

import 'package:drift/drift.dart';

class Abilities extends Table {
  TextColumn get id => text()();

  TextColumn get key => text().unique()();

  TextColumn get name => text()();

  TextColumn get description => text()();

  IntColumn get cooldownMs => integer().named('cooldown_ms')();

  IntColumn get durationMs => integer().nullable().named('duration_ms')();

  TextColumn get parametersJson =>
      text().named('parameters_json').withDefault(const Constant('{}'))();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

class Characters extends Table {
  TextColumn get id => text()();

  TextColumn get name => text()();

  TextColumn get filename => text()();

  IntColumn get price => integer().check(price.isBiggerOrEqualValue(0))();

  IntColumn get baseHp => integer().named('base_hp')();

  IntColumn get baseStr => integer().named('base_str')();

  IntColumn get baseVit => integer().named('base_vit')();

  IntColumn get baseAgi => integer().named('base_agi')();

  TextColumn get abilityId => text()
      .nullable()
      .named('ability_id')
      .references(Abilities, #id, onDelete: KeyAction.setNull)();

  @override
  Set<Column<Object>> get primaryKey => {id};
}
