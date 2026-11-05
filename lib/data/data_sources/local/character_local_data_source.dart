import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gunwave/data/database/app_database.dart';
import 'package:gunwave/data/models/ability_model.dart';
import 'package:gunwave/data/models/character_model.dart';

final characterLocalDataSourceProvider = Provider<CharacterLocalDataSource>(
  (ref) => CharacterLocalDataSource(ref.read(appDatabaseProvider)),
);

/// Reads the hero catalog and performs player-character transactions in SQLite.
class CharacterLocalDataSource {
  const CharacterLocalDataSource(this._database);

  final AppDatabase _database;

  Future<List<CharacterModel>> getCharacters() async {
    final rows =
        await (_database.select(_database.characters).join([
              leftOuterJoin(
                _database.abilities,
                _database.abilities.id.equalsExp(
                  _database.characters.abilityId,
                ),
              ),
            ])..orderBy([
              OrderingTerm.asc(_database.characters.price),
              OrderingTerm.asc(_database.characters.id),
            ]))
            .get();
    return rows
        .map(
          (row) => _toModel(
            row.readTable(_database.characters),
            row.readTableOrNull(_database.abilities),
          ),
        )
        .toList(growable: false);
  }

  Future<List<CharacterModel>> getOwnedCharacters() async {
    final rows =
        await (_database.select(_database.playerCharacters).join([
              innerJoin(
                _database.characters,
                _database.characters.id.equalsExp(
                  _database.playerCharacters.characterId,
                ),
              ),
              leftOuterJoin(
                _database.abilities,
                _database.abilities.id.equalsExp(
                  _database.characters.abilityId,
                ),
              ),
            ])..orderBy([
              OrderingTerm.asc(_database.playerCharacters.acquiredAt),
              OrderingTerm.asc(_database.characters.id),
            ]))
            .get();
    return rows
        .map(
          (row) => _toModel(
            row.readTable(_database.characters),
            row.readTableOrNull(_database.abilities),
            owned: row.readTable(_database.playerCharacters),
          ),
        )
        .toList(growable: false);
  }

  Future<List<CharacterModel>> getUnownedCharacters() async {
    final ownedIds = (await _database.select(_database.playerCharacters).get())
        .map((character) => character.characterId)
        .toSet();
    return (await getCharacters())
        .where((character) => !ownedIds.contains(character.id))
        .toList(growable: false);
  }

  Future<CharacterModel?> getOwnedCharacter(String characterId) async {
    for (final character in await getOwnedCharacters()) {
      if (character.id == characterId) return character;
    }
    return null;
  }

  Future<int> getGoldBalance() async {
    final state = await (_database.select(
      _database.playerStates,
    )..where((row) => row.id.equals(1))).getSingleOrNull();
    return state?.gold ?? 0;
  }

  Future<bool> buyCharacter(
    String characterId,
  ) => _database.transaction(() async {
    final character = await (_database.select(
      _database.characters,
    )..where((row) => row.id.equals(characterId))).getSingleOrNull();
    final player = await (_database.select(
      _database.playerStates,
    )..where((row) => row.id.equals(1))).getSingleOrNull();
    if (character == null || player == null || player.gold < character.price) {
      return false;
    }

    final owned = await (_database.select(
      _database.playerCharacters,
    )..where((row) => row.characterId.equals(characterId))).getSingleOrNull();
    if (owned != null) return false;

    await (_database.update(
      _database.playerStates,
    )..where((row) => row.id.equals(1))).write(
      PlayerStatesCompanion(gold: Value(player.gold - character.price)),
    );
    await _database
        .into(_database.playerCharacters)
        .insert(
          PlayerCharactersCompanion.insert(
            characterId: character.id,
            hp: character.baseHp,
            strength: character.baseStr,
            vitality: character.baseVit,
            agility: character.baseAgi,
            statusPoints: 0,
            acquiredAt: DateTime.now().millisecondsSinceEpoch,
          ),
        );
    return true;
  });

  Future<bool> updateAttr(String characterId, CharacterAttr attr) =>
      _database.transaction(() async {
        final character =
            await (_database.select(_database.playerCharacters)
                  ..where((row) => row.characterId.equals(characterId)))
                .getSingleOrNull();
        if (character == null || character.statusPoints < 1) return false;

        final updated = switch (attr) {
          CharacterAttr.hp => character.copyWith(
            hp: character.hp + 1,
            statusPoints: character.statusPoints - 1,
          ),
          CharacterAttr.str => character.copyWith(
            strength: character.strength + 1,
            statusPoints: character.statusPoints - 1,
          ),
          CharacterAttr.vit => character.copyWith(
            vitality: character.vitality + 1,
            statusPoints: character.statusPoints - 1,
          ),
          CharacterAttr.agi => character.copyWith(
            agility: character.agility + 1,
            statusPoints: character.statusPoints - 1,
          ),
        };
        await _database.update(_database.playerCharacters).replace(updated);
        return true;
      });

  Future<bool> resetAttr(String characterId) => _database.transaction(() async {
    final character = await (_database.select(
      _database.playerCharacters,
    )..where((row) => row.characterId.equals(characterId))).getSingleOrNull();
    final catalog = await (_database.select(
      _database.characters,
    )..where((row) => row.id.equals(characterId))).getSingleOrNull();
    if (character == null || catalog == null) return false;

    final refundedPoints =
        character.statusPoints +
        character.hp -
        catalog.baseHp +
        character.strength -
        catalog.baseStr +
        character.vitality -
        catalog.baseVit +
        character.agility -
        catalog.baseAgi;
    await _database
        .update(_database.playerCharacters)
        .replace(
          character.copyWith(
            hp: catalog.baseHp,
            strength: catalog.baseStr,
            vitality: catalog.baseVit,
            agility: catalog.baseAgi,
            statusPoints: refundedPoints,
          ),
        );
    return true;
  });

  CharacterModel _toModel(
    Character row,
    Ability? abilityRow, {
    PlayerCharacter? owned,
  }) => CharacterModel(
    id: row.id,
    name: row.name,
    filename: row.filename,
    price: row.price,
    hp: owned?.hp ?? row.baseHp,
    str: owned?.strength ?? row.baseStr,
    vit: owned?.vitality ?? row.baseVit,
    agi: owned?.agility ?? row.baseAgi,
    sp: owned?.statusPoints ?? 0,
    abilityId: row.abilityId,
    ability: abilityRow == null ? null : _toAbilityModel(abilityRow),
  );

  AbilityModel _toAbilityModel(Ability row) {
    final parameters = jsonDecode(row.parametersJson);
    if (parameters is! Map<String, dynamic>) {
      throw FormatException(
        'Ability "${row.id}" parameters must be a JSON object.',
      );
    }
    return AbilityModel(
      id: row.id,
      key: row.key,
      name: row.name,
      description: row.description,
      cooldownMs: row.cooldownMs,
      durationMs: row.durationMs,
      parameters: parameters,
    );
  }
}
