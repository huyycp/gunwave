import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gunwave/data/data_sources/remote/api/supabase_api.dart';
import 'package:gunwave/data/models/character_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final characterRemoteProvider = Provider<CharacterRemoteDataSource>((ref) {
  return CharacterRemoteDataSource(ref.read(supabaseApiProvider));
});

class CharacterRemoteDataSource {
  CharacterRemoteDataSource(this._supabaseApi);

  final SupabaseApi _supabaseApi;

  SupabaseClient get client => _supabaseApi.supabase;

  final charactersTable = 'characters';
  final usersCharactersTable = 'users_characters';

  Future<List<CharacterModel>> getCharacters() async {
    final response = await client
        .from(charactersTable)
        .select()
        .order('price', ascending: true);
    debugPrint("Characters: $response");
    return response.map((json) {
      return CharacterModel.fromJson(json);
    }).toList();
  }

  Future<List<CharacterModel>> getOwnedCharacters(String userId) async {
    final response = await client
        .from(usersCharactersTable)
        .select('characters(*)')
        .eq('user_id', userId);
    
    debugPrint("Owned characters: $response");
    return response.map((json) {
      return CharacterModel.fromJson(json['characters']);
    }).toList();
  }

  Future<List<CharacterModel>> getUnownedCharacters(String userId) async {
    // First, get the list of character IDs that the user owns
    final ownedCharacters = await client
        .from(usersCharactersTable)
        .select('character_id')
        .eq('user_id', userId);
    
    // Extract the character IDs from the result
    final ownedCharacterIds = ownedCharacters
        .map((item) => item['character_id'])
        .toList();
    
    // Now, query for characters that are not in the list of owned character IDs
    final response = await client
        .from(charactersTable)
        .select()
        .not('id', 'in', ownedCharacterIds);
    
    debugPrint("Unowned characters: $response");
    return response.map((json) {
      return CharacterModel.fromJson(json);
    }).toList();
  }

  Future<bool> updateAttr(String id, CharacterAttr attr) async {
    final result = await client.rpc('update_character_status', params: {
      'character_id': id,
      'attr': attr.name,
    });

    debugPrint("Update character attr: $result");
    return result;
  }

  Future<bool> resetAttr(String id) async {
    final result = await client.rpc('reset_character_status', params: {
      'character_id': id,
    });

    debugPrint("Reset character attr: $result");
    return result;
  }

  Future<bool> buyCharacter(String characterId) async {
    final result = await client.rpc('purchase_character', params: {
      'character_id': characterId,
    });

    debugPrint("Buy character $characterId: $result");
    return result;
  }

}