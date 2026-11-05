import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:gunwave/data/database/app_database.dart';
import 'package:gunwave/data/data_sources/local/campaign_content_data_source.dart';
import 'package:gunwave/data/data_sources/local/character_catalog_data_source.dart';
import 'package:gunwave/data/data_sources/local/campaign_hero_catalog.dart';
import 'package:gunwave/data/models/campaign_stage_model.dart';
import 'package:gunwave/repositories/campaign_repository.dart';

/// Copies bundled static game definitions into SQLite without replacing player data.
class LocalGameDataSeeder {
  const LocalGameDataSeeder(
    this._database, {
    required this._contentDataSource,
    this._characterCatalogDataSource,
  });

  final AppDatabase _database;
  final CampaignContentDataSource _contentDataSource;
  final CharacterCatalogDataSource? _characterCatalogDataSource;

  Future<void> seed() async {
    final stages = await CampaignRepository(_contentDataSource).getStages();
    final catalog =
        await (_characterCatalogDataSource ?? AssetCharacterCatalogDataSource())
            .loadCatalog();
    final starter = catalog.characters.firstWhere(
      (character) => character.id == CampaignHeroCatalog.starterId,
      orElse: () => throw const CharacterCatalogException(
        'The local catalog does not include its configured starter hero.',
      ),
    );

    await _database.transaction(() async {
      for (final ability in catalog.abilities) {
        await _database
            .into(_database.abilities)
            .insertOnConflictUpdate(
              AbilitiesCompanion.insert(
                id: ability.id,
                key: ability.key,
                name: ability.name,
                description: ability.description,
                cooldownMs: ability.cooldownMs,
                durationMs: Value(ability.durationMs),
                parametersJson: Value(jsonEncode(ability.parameters)),
              ),
            );
      }
      for (final character in catalog.characters) {
        await _database
            .into(_database.characters)
            .insertOnConflictUpdate(
              CharactersCompanion.insert(
                id: character.id,
                name: character.name,
                filename: character.filename,
                price: character.price,
                baseHp: character.hp,
                baseStr: character.str,
                baseVit: character.vit,
                baseAgi: character.agi,
                abilityId: Value(character.abilityId),
              ),
            );
      }
      for (final stage in stages) {
        await _seedStage(stage);
      }
      await _migrateLegacyStarter(starter.id);
      await _seedStarterHero(starter.id);
    });
  }

  Future<void> _seedStage(CampaignStageModel stage) async {
    await _database
        .into(_database.stages)
        .insertOnConflictUpdate(
          StagesCompanion.insert(
            id: stage.id,
            stageOrder: stage.order,
            name: stage.name,
            mapKey: stage.mapKey,
            unlockRequirementStageId: Value(stage.unlockRequirementStageId),
          ),
        );

    for (final monster in stage.enemies) {
      await _database
          .into(_database.monsters)
          .insertOnConflictUpdate(
            MonstersCompanion.insert(
              id: monster.id,
              name: monster.name,
              filename: monster.filename,
              hp: monster.hp,
              strength: monster.str,
              vitality: monster.vit,
              agility: monster.agi,
              score: monster.score,
            ),
          );
      await _database
          .into(_database.stageMonsters)
          .insertOnConflictUpdate(
            StageMonstersCompanion.insert(
              stageId: stage.id,
              monsterId: monster.id,
            ),
          );
    }

    for (final round in stage.rounds) {
      await _database
          .into(_database.stageRounds)
          .insertOnConflictUpdate(
            StageRoundsCompanion.insert(
              id: round.id,
              stageId: stage.id,
              roundNumber: round.number,
              isBoss: round.isBoss,
            ),
          );
      for (var index = 0; index < round.encounters.length; index++) {
        final encounter = round.encounters[index];
        await _database
            .into(_database.roundEncounters)
            .insertOnConflictUpdate(
              RoundEncountersCompanion.insert(
                roundId: round.id,
                encounterOrder: index,
                monsterId: encounter.enemyId,
                spawnMarker: encounter.spawnMarker,
                count: encounter.count,
              ),
            );
      }
    }

    for (var index = 0; index < stage.rewards.length; index++) {
      final reward = stage.rewards[index];
      await _database
          .into(_database.stageRewards)
          .insertOnConflictUpdate(
            StageRewardsCompanion.insert(
              stageId: stage.id,
              rewardOrder: index,
              type: reward.type.name,
              amount: reward.amount,
            ),
          );
    }
  }

  Future<void> _migrateLegacyStarter(String starterId) async {
    const legacyId = CampaignHeroCatalog.legacyStarterId;
    final legacyOwned = await (_database.select(
      _database.playerCharacters,
    )..where((row) => row.characterId.equals(legacyId))).getSingleOrNull();
    if (legacyOwned != null) {
      final legacyCatalog = await (_database.select(
        _database.characters,
      )..where((row) => row.id.equals(legacyId))).getSingleOrNull();
      if (legacyCatalog == null) {
        throw StateError(
          'Cannot migrate the old starter because its catalog row is missing.',
        );
      }
      final starterCatalog = await (_database.select(
        _database.characters,
      )..where((row) => row.id.equals(starterId))).getSingle();
      final ownedStarter = await (_database.select(
        _database.playerCharacters,
      )..where((row) => row.characterId.equals(starterId))).getSingleOrNull();
      final hpUpgrades = _upgradeCount(legacyOwned.hp, legacyCatalog.baseHp);
      final strengthUpgrades = _upgradeCount(
        legacyOwned.strength,
        legacyCatalog.baseStr,
      );
      final vitalityUpgrades = _upgradeCount(
        legacyOwned.vitality,
        legacyCatalog.baseVit,
      );
      final agilityUpgrades = _upgradeCount(
        legacyOwned.agility,
        legacyCatalog.baseAgi,
      );

      if (ownedStarter == null) {
        await _database
            .into(_database.playerCharacters)
            .insert(
              PlayerCharactersCompanion.insert(
                characterId: starterId,
                hp: starterCatalog.baseHp + hpUpgrades,
                strength: starterCatalog.baseStr + strengthUpgrades,
                vitality: starterCatalog.baseVit + vitalityUpgrades,
                agility: starterCatalog.baseAgi + agilityUpgrades,
                statusPoints: legacyOwned.statusPoints,
                acquiredAt: legacyOwned.acquiredAt,
              ),
            );
      } else {
        await _database
            .update(_database.playerCharacters)
            .replace(
              ownedStarter.copyWith(
                hp: ownedStarter.hp + hpUpgrades,
                strength: ownedStarter.strength + strengthUpgrades,
                vitality: ownedStarter.vitality + vitalityUpgrades,
                agility: ownedStarter.agility + agilityUpgrades,
                statusPoints:
                    ownedStarter.statusPoints + legacyOwned.statusPoints,
                acquiredAt: ownedStarter.acquiredAt < legacyOwned.acquiredAt
                    ? ownedStarter.acquiredAt
                    : legacyOwned.acquiredAt,
              ),
            );
      }
      await (_database.delete(
        _database.playerCharacters,
      )..where((row) => row.characterId.equals(legacyId))).go();
    }

    await (_database.update(_database.playerStates)
          ..where((row) => row.selectedHeroId.equals(legacyId)))
        .write(PlayerStatesCompanion(selectedHeroId: Value(starterId)));
    await (_database.delete(
      _database.characters,
    )..where((row) => row.id.equals(legacyId))).go();
  }

  int _upgradeCount(int current, int base) =>
      current > base ? current - base : 0;

  Future<void> _seedStarterHero(String starterId) async {
    final starter = await (_database.select(
      _database.characters,
    )..where((row) => row.id.equals(starterId))).getSingle();
    await _database
        .into(_database.playerStates)
        .insert(
          PlayerStatesCompanion.insert(
            id: const Value(1),
            gold: 0,
            statusPoints: 0,
            selectedHeroId: Value(starterId),
          ),
          mode: InsertMode.insertOrIgnore,
        );

    final ownedCharacters = await _database
        .select(_database.playerCharacters)
        .get();
    if (ownedCharacters.isEmpty) {
      await _database
          .into(_database.playerCharacters)
          .insert(
            PlayerCharactersCompanion.insert(
              characterId: starter.id,
              hp: starter.baseHp,
              strength: starter.baseStr,
              vitality: starter.baseVit,
              agility: starter.baseAgi,
              statusPoints: 0,
              acquiredAt: DateTime.now().millisecondsSinceEpoch,
            ),
          );
    }

    final playerState = await _database
        .select(_database.playerStates)
        .getSingle();
    if (playerState.selectedHeroId == null ||
        playerState.selectedHeroId == CampaignHeroCatalog.legacyStarterId) {
      await (_database.update(_database.playerStates)
            ..where((row) => row.id.equals(1)))
          .write(PlayerStatesCompanion(selectedHeroId: Value(starterId)));
    }
  }
}
