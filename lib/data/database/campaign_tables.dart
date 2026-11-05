import 'package:drift/drift.dart';

class Stages extends Table {
  TextColumn get id => text()();

  IntColumn get stageOrder => integer().named('stage_order').unique()();

  TextColumn get name => text()();

  TextColumn get mapKey => text().named('map_key')();

  TextColumn get unlockRequirementStageId => text()
      .nullable()
      .named('unlock_requirement_stage_id')
      .references(Stages, #id, onDelete: KeyAction.setNull)();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

class Monsters extends Table {
  TextColumn get id => text()();

  TextColumn get name => text()();

  TextColumn get filename => text()();

  IntColumn get hp => integer()();

  IntColumn get strength => integer().named('str')();

  IntColumn get vitality => integer().named('vit')();

  IntColumn get agility => integer().named('agi')();

  IntColumn get score => integer()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

class StageMonsters extends Table {
  TextColumn get stageId => text()
      .named('stage_id')
      .references(Stages, #id, onDelete: KeyAction.cascade)();

  TextColumn get monsterId => text()
      .named('monster_id')
      .references(Monsters, #id, onDelete: KeyAction.cascade)();

  @override
  Set<Column<Object>> get primaryKey => {stageId, monsterId};
}

class StageRounds extends Table {
  TextColumn get id => text()();

  TextColumn get stageId => text()
      .named('stage_id')
      .references(Stages, #id, onDelete: KeyAction.cascade)();

  IntColumn get roundNumber => integer().named('round_number')();

  BoolColumn get isBoss => boolean().named('is_boss')();

  @override
  Set<Column<Object>> get primaryKey => {id};

  @override
  List<Set<Column<Object>>> get uniqueKeys => [
    {stageId, roundNumber},
  ];
}

class RoundEncounters extends Table {
  TextColumn get roundId => text()
      .named('round_id')
      .references(StageRounds, #id, onDelete: KeyAction.cascade)();

  IntColumn get encounterOrder => integer().named('encounter_order')();

  TextColumn get monsterId => text()
      .named('monster_id')
      .references(Monsters, #id, onDelete: KeyAction.restrict)();

  TextColumn get spawnMarker => text().named('spawn_marker')();

  IntColumn get count => integer()();

  @override
  Set<Column<Object>> get primaryKey => {roundId, encounterOrder};
}

class StageRewards extends Table {
  TextColumn get stageId => text()
      .named('stage_id')
      .references(Stages, #id, onDelete: KeyAction.cascade)();

  IntColumn get rewardOrder => integer().named('reward_order')();

  TextColumn get type => text()();

  IntColumn get amount => integer()();

  @override
  Set<Column<Object>> get primaryKey => {stageId, rewardOrder};
}
