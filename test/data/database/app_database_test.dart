import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gunwave/data/database/app_database.dart';

void main() {
  late AppDatabase database;

  setUp(() {
    database = AppDatabase.forTesting(NativeDatabase.memory());
  });

  tearDown(() async {
    await database.close();
  });

  test(
    'schema v1 supports character and ability CRUD with a valid relation',
    () async {
      expect(database.schemaVersion, 1);

      await database
          .into(database.abilities)
          .insert(
            AbilitiesCompanion.insert(
              id: 'quickstep',
              key: 'quickstep',
              name: 'Quickstep',
              description: 'Move quickly.',
              cooldownMs: 5000,
              durationMs: const Value(1000),
              parametersJson: const Value('{"speedMultiplier":1.5}'),
            ),
          );
      await database
          .into(database.characters)
          .insert(
            CharactersCompanion.insert(
              id: 'warrior_blue',
              name: 'Blue Warrior',
              filename: 'warrior_blue',
              price: 0,
              baseHp: 100,
              baseStr: 10,
              baseVit: 3,
              baseAgi: 4,
              abilityId: const Value('quickstep'),
            ),
          );

      final inserted = await database.select(database.characters).getSingle();
      expect(inserted.name, 'Blue Warrior');
      expect(inserted.abilityId, 'quickstep');

      await (database.update(database.characters)
            ..where((row) => row.id.equals('warrior_blue')))
          .write(const CharactersCompanion(baseHp: Value(101)));
      expect(
        (await database.select(database.characters).getSingle()).baseHp,
        101,
      );

      await (database.delete(
        database.characters,
      )..where((row) => row.id.equals('warrior_blue'))).go();
      expect(await database.select(database.characters).get(), isEmpty);
    },
  );

  test('settings and singleton player state support local CRUD', () async {
    await database
        .into(database.playerStates)
        .insert(
          PlayerStatesCompanion.insert(
            id: const Value(1),
            gold: 0,
            statusPoints: 0,
            selectedHeroId: const Value.absent(),
          ),
        );
    await database
        .into(database.settings)
        .insert(SettingsCompanion.insert(key: 'locale_mode', value: 'system'));

    await (database.update(database.playerStates)
          ..where((row) => row.id.equals(1)))
        .write(const PlayerStatesCompanion(gold: Value(25)));
    await (database.update(database.settings)
          ..where((row) => row.key.equals('locale_mode')))
        .write(const SettingsCompanion(value: Value('vi')));

    expect((await database.select(database.playerStates).getSingle()).gold, 25);
    expect((await database.select(database.settings).getSingle()).value, 'vi');

    await (database.delete(
      database.settings,
    )..where((row) => row.key.equals('locale_mode'))).go();
    expect(await database.select(database.settings).get(), isEmpty);
  });

  test('player state rejects IDs other than the singleton key', () async {
    await expectLater(
      database.into(database.playerStates).insert(
            PlayerStatesCompanion.insert(
              id: const Value(2),
              gold: 0,
              statusPoints: 0,
            ),
          ),
      throwsA(isA<Exception>()),
    );
  });

  test(
    'foreign keys reject characters that reference missing abilities',
    () async {
      await expectLater(
        database
            .into(database.characters)
            .insert(
              CharactersCompanion.insert(
                id: 'warrior_blue',
                name: 'Blue Warrior',
                filename: 'warrior_blue',
                price: 0,
                baseHp: 100,
                baseStr: 10,
                baseVit: 3,
                baseAgi: 4,
                abilityId: const Value('missing_ability'),
              ),
            ),
        throwsA(isA<Exception>()),
      );
    },
  );
}
