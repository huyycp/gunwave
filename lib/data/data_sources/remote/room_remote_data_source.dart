import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gunwave/data/data_sources/remote/api/supabase_api.dart';
import 'package:gunwave/data/models/room_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final roomRemoteProvider = Provider<RoomRemoteDataSource>((ref) {
  return RoomRemoteDataSource(ref.read(supabaseApiProvider));
});

class RoomRemoteDataSource {
  RoomRemoteDataSource(this._supabaseApi);

  final SupabaseApi _supabaseApi;

  SupabaseClient get client => _supabaseApi.supabase;

  final roomsTable = 'rooms';

  Future<List<RoomModel>> getRooms() async {
    final response = await client
        .from(roomsTable)
        .select('''
          *, 
          maps(
            *, 
            monsters(*), 
            rewards(
              *, 
              maps_rewards(*)
            )
          ),
          users(*),
          quizzes(*)
        ''')
        .eq('private', false)
        .order('created_at', ascending: false);
    debugPrint("Rooms: $response");
    return List<RoomModel>.from(response.map((json) {
      return RoomModel.fromJson(json);
    }));
  }
}