import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gunwave/data/data_sources/local/campaign_content_data_source.dart';
import 'package:gunwave/data/data_sources/local/character_local_data_source.dart';
import 'package:gunwave/data/data_sources/local/local_game_data_seeder.dart';
import 'package:gunwave/data/database/app_database.dart';
import 'package:gunwave/data/models/character_model.dart';
import 'package:gunwave/repositories/character_repository.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late AppDatabase database;
  late CharacterRepository repository;

  setUp(() async {
    database = AppDatabase.forTesting(NativeDatabase.memory());
    await LocalGameDataSeeder(
      database,
      contentDataSource: AssetCampaignContentDataSource(),
    ).seed();
    repository = CharacterRepository(CharacterLocalDataSource(database));
    await _insertHero(database, id: 'hero_red', price: 40);
    await _insertHero(database, id: 'hero_yellow', price: 40);
  });

  tearDown(() async {
    await database.close();
  });

  test(
    'catalog and owned-character reads preserve ability and stat data',
    () async {
      await database
          .into(database.abilities)
          .insert(
            AbilitiesCompanion.insert(
              id: 'quickstep',
              key: 'quickstep',
              name: 'Quickstep',
              description: 'Dash forward.',
              cooldownMs: 2500,
              parametersJson: const Value('{"dashTiles":3}'),
            ),
          );
      await (database.update(database.characters)
            ..where((row) => row.id.equals('hero_red')))
          .write(const CharactersCompanion(abilityId: Value('quickstep')));

      final catalog = await repository.getCharacters();
      final starter = await repository.getOwnedCharacter(
        'local_starter_warrior_blue',
      );

      expect(catalog.map((hero) => hero.price), [0, 40, 40]);
      expect(catalog[1].ability?.key, 'quickstep');
      expect(catalog[1].ability?.parameters, {'dashTiles': 3});
      expect(starter?.hp, 100);
      expect(starter?.filename, 'warrior_blue');
    },
  );

  test('purchase debits local gold and grants one owned character', () async {
    await _setGold(database, 50);

    expect(await repository.buyCharacter('hero_red'), isTrue);
    expect(await repository.getGoldBalance(), 10);
    expect(await repository.buyCharacter('hero_red'), isFalse);
    expect(await repository.getOwnedCharacters(), hasLength(2));
  });

  test('purchase rejects insufficient gold without changing state', () async {
    await _setGold(database, 39);

    expect(await repository.buyCharacter('hero_red'), isFalse);
    expect(await repository.getGoldBalance(), 39);
    expect(await repository.getOwnedCharacters(), hasLength(1));
  });

  test('concurrent purchases cannot duplicate or overspend', () async {
    await _setGold(database, 40);

    final results = await Future.wait([
      repository.buyCharacter('hero_red'),
      repository.buyCharacter('hero_yellow'),
    ]);

    expect(results.where((purchased) => purchased), hasLength(1));
    expect(await repository.getGoldBalance(), 0);
    expect(await repository.getOwnedCharacters(), hasLength(2));
  });

  test('stat upgrade spends one point and reset restores base stats', () async {
    await (database.update(
          database.playerCharacters,
        )..where((row) => row.characterId.equals('local_starter_warrior_blue')))
        .write(const PlayerCharactersCompanion(statusPoints: Value(2)));

    expect(
      await repository.updateAttr(
        'local_starter_warrior_blue',
        CharacterAttr.hp,
      ),
      isTrue,
    );
    expect(
      await repository.updateAttr(
        'local_starter_warrior_blue',
        CharacterAttr.str,
      ),
      isTrue,
    );
    expect(
      await repository.updateAttr(
        'local_starter_warrior_blue',
        CharacterAttr.str,
      ),
      isFalse,
    );

    final upgraded = await repository.getOwnedCharacter(
      'local_starter_warrior_blue',
    );
    expect(upgraded?.hp, 101);
    expect(upgraded?.str, 11);
    expect(upgraded?.sp, 0);

    expect(await repository.resetAttr('local_starter_warrior_blue'), isTrue);
    final reset = await repository.getOwnedCharacter(
      'local_starter_warrior_blue',
    );
    expect(reset?.hp, 100);
    expect(reset?.str, 10);
    expect(reset?.sp, 2);
  });
}

Future<void> _insertHero(
  AppDatabase database, {
  required String id,
  required int price,
}) => database
    .into(database.characters)
    .insert(
      CharactersCompanion.insert(
        id: id,
        name: id,
        filename: 'warrior_red',
        price: price,
        baseHp: 90,
        baseStr: 8,
        baseVit: 2,
        baseAgi: 3,
      ),
    );

Future<void> _setGold(AppDatabase database, int gold) async {
  await (database.update(database.playerStates)
        ..where((row) => row.id.equals(1)))
      .write(PlayerStatesCompanion(gold: Value(gold)));
}
