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

  Future<List<CharacterModel>> getCharacters(String userId) async {
    final response = await client
        .from(charactersTable)
        .select()
        .eq('user_id', userId);
    debugPrint("Characters: $response");
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
}