import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gunwave/data/data_sources/remote/character_remote_data_source.dart';
import 'package:gunwave/data/models/character_model.dart';

final characterRepoProvider = Provider<CharacterRepository>((ref) {
  return CharacterRepository(ref.read(characterRemoteProvider));
});

class CharacterRepository {
  CharacterRepository(this._characterRemote);

  final CharacterRemoteDataSource _characterRemote;

  List<CharacterModel> characters = [];
  List<CharacterModel> ownedCharacters = [];

  Future<List<CharacterModel>> getCharacters() async {
    characters = await _characterRemote.getCharacters();
    return characters;
  }

  Future<List<CharacterModel>> getOwnedCharacters(String userId) async {
    ownedCharacters = await _characterRemote.getOwnedCharacters(userId);
    return ownedCharacters;
  }

  Future<List<CharacterModel>> getUnownedCharacters(String userId) async {
    return await _characterRemote.getUnownedCharacters(userId);
  }

  /// Fetches one owned character and replaces its cached immutable snapshot.
  Future<CharacterModel?> getOwnedCharacter(
    String userId,
    String characterId,
  ) async {
    final character = await _characterRemote.getOwnedCharacter(
      userId,
      characterId,
    );
    if (character != null) {
      final index = ownedCharacters.indexWhere(
        (char) => char.id == character.id,
      );
      if (index >= 0) {
        ownedCharacters[index] = character;
      }
    }
    return character;
  }

  Future<bool> updateAttr(String id, CharacterAttr attr) async {
    final updated = await _characterRemote.updateAttr(id, attr);
    if (updated) {
      final index = ownedCharacters.indexWhere(
        (character) => character.id == id,
      );
      if (index >= 0) {
        final current = ownedCharacters[index];
        final next = switch (attr) {
          CharacterAttr.hp => current.copyWith(hp: current.hp + 1),
          CharacterAttr.str => current.copyWith(str: current.str + 1),
          CharacterAttr.vit => current.copyWith(vit: current.vit + 1),
          CharacterAttr.agi => current.copyWith(agi: current.agi + 1),
        };
        ownedCharacters[index] = next.copyWith(sp: current.sp - 1);
      }
    }
    return updated;
  }

  Future<bool> resetAttr(String id) async {
    return await _characterRemote.resetAttr(id);
  }

  Future<bool> buyCharacter(String characterId) async {
    return await _characterRemote.buyCharacter(characterId);
  }
}
