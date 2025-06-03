import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gunwave/data/data_sources/remote/api/supabase_api.dart';
import 'package:gunwave/data/dtos/req/create_room_req.dart';
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
  final quizzesTable = 'quizzes';
  final roomsQuizzesTable = 'rooms_quizzes';

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

  Future<void> createRoom(CreateRoomReq req) async {
    final room = await client
      .from(roomsTable)
      .insert(req.toJson()).select().single();

    final quizzesJson = await client
      .from(quizzesTable)
      .insert(req.quizzes.map((quiz) => quiz.toJson()).toList()).select();
    
    await client.from(roomsQuizzesTable).insert(
      quizzesJson.map((quiz) {
        return {
          'room_id': room['id'],
          'quiz_id': quiz['id'],
        };
      }).toList(),
    );
  }
}