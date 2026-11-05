import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gunwave/data/data_sources/local/character_local_data_source.dart';
import 'package:gunwave/data/models/character_model.dart';

final characterRepoProvider = Provider<CharacterRepository>((ref) {
  return CharacterRepository(ref.read(characterLocalDataSourceProvider));
});

/// Exposes the local hero catalog, ownership, and stat mutations.
class CharacterRepository {
  CharacterRepository(this._localDataSource);

  final CharacterLocalDataSource _localDataSource;

  List<CharacterModel> characters = [];
  List<CharacterModel> ownedCharacters = [];

  Future<List<CharacterModel>> getCharacters() async {
    characters = await _localDataSource.getCharacters();
    return characters;
  }

  Future<List<CharacterModel>> getOwnedCharacters() async {
    ownedCharacters = await _localDataSource.getOwnedCharacters();
    return ownedCharacters;
  }

  Future<List<CharacterModel>> getUnownedCharacters() =>
      _localDataSource.getUnownedCharacters();

  Future<CharacterModel?> getOwnedCharacter(String characterId) async {
    final character = await _localDataSource.getOwnedCharacter(characterId);
    if (character != null) {
      final index = ownedCharacters.indexWhere(
        (item) => item.id == characterId,
      );
      if (index >= 0) ownedCharacters[index] = character;
    }
    return character;
  }

  Future<int> getGoldBalance() => _localDataSource.getGoldBalance();

  Future<bool> updateAttr(String id, CharacterAttr attr) async {
    final updated = await _localDataSource.updateAttr(id, attr);
    if (updated) await getOwnedCharacters();
    return updated;
  }

  Future<bool> resetAttr(String id) async {
    final reset = await _localDataSource.resetAttr(id);
    if (reset) await getOwnedCharacters();
    return reset;
  }

  Future<bool> buyCharacter(String characterId) async {
    final bought = await _localDataSource.buyCharacter(characterId);
    if (bought) await getOwnedCharacters();
    return bought;
  }
}
