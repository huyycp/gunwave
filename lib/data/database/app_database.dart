import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gunwave/data/database/campaign_tables.dart';
import 'package:gunwave/data/database/catalog_tables.dart';
import 'package:gunwave/data/database/player_tables.dart';

part 'app_database.g.dart';

@DriftDatabase(
  tables: [
    Abilities,
    Characters,
    Stages,
    Monsters,
    StageMonsters,
    StageRounds,
    RoundEncounters,
    StageRewards,
    PlayerStates,
    PlayerCharacters,
    CampaignStageClears,
    Settings,
    AppMetadata,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(driftDatabase(name: 'gunwave'));

  AppDatabase.forTesting(QueryExecutor executor) : super(executor);

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (migrator) => migrator.createAll(),
    onUpgrade: (migrator, from, to) async {
      throw StateError(
        'Missing local database migration from schema $from to $to.',
      );
    },
    beforeOpen: (_) async {
      await customStatement('PRAGMA foreign_keys = ON');
    },
  );
}

final appDatabaseProvider = Provider<AppDatabase>((ref) {
  final database = AppDatabase();
  ref.onDispose(database.close);
  return database;
});
