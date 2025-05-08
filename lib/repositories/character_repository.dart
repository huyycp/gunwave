import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gunwave/data/data_sources/remote/character_remote_data_source.dart';
import 'package:gunwave/data/models/character_model.dart';

final characterRepoProvider = Provider<CharacterRepository>((ref) {
  return CharacterRepository(ref.read(characterRemoteProvider));
});

class CharacterRepository {
  CharacterRepository(this._characterRemote);

  final CharacterRemoteDataSource _characterRemote;

  Future<List<CharacterModel>> getCharacters(String? userId) async {
    if (userId == null) return [];
    return await _characterRemote.getCharacters(userId);
  }

  Future<bool> updateAttr(String id, CharacterAttr attr) async {
    return await _characterRemote.updateAttr(id, attr);
  }

  Future<bool> resetAttr(String id) async {
    return await _characterRemote.resetAttr(id);
  }
}