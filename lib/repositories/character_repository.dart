import 'package:collection/collection.dart';
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
    ownedCharacters =  await _characterRemote.getOwnedCharacters(userId);
    return ownedCharacters;
  }

  Future<List<CharacterModel>> getUnownedCharacters(String userId) async {
    return await _characterRemote.getUnownedCharacters(userId);
  }

  Future<CharacterModel?> getOwnedCharacter(String userId, String characterId) async {
    final character = await _characterRemote.getOwnedCharacter(userId, characterId);
    if (character != null) {
      ownedCharacters.firstWhereOrNull((char) => char.id == character.id)
       ?..hp = character.hp
       ..str = character.str
       ..vit = character.vit
       ..agi = character.agi
       ..sp = character.sp;
    }
    return character;
  }

  Future<bool> updateAttr(String id, CharacterAttr attr) async {
    return await _characterRemote.updateAttr(id, attr);
  }

  Future<bool> resetAttr(String id) async {
    return await _characterRemote.resetAttr(id);
  }

  Future<bool> buyCharacter(String characterId) async {
    return await _characterRemote.buyCharacter(characterId);
  }
}