import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gunwave/build_config.dart';
import 'package:gunwave/data/data_sources/remote/api/supabase_api.dart';
import 'package:gunwave/data/dtos/req/update_rank_req.dart';
import 'package:gunwave/data/models/rank_model.dart';
import 'package:gunwave/data/models/room_model.dart';
import 'package:gunwave/data/models/user_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final userRemoteProvider = Provider<UserRemoteDataSource>((ref) {
  return UserRemoteDataSource(ref.read(supabaseApiProvider));
});

class UserRemoteDataSource {
  UserRemoteDataSource(this._supabaseApi);

  final SupabaseApi _supabaseApi;

  GoTrueClient get auth => _supabaseApi.supabase.auth;
  SupabaseClient get client => _supabaseApi.supabase;

  Future<AuthResponse> signInWithEmail(String email, String password) async {
    return await auth.signInWithPassword(email: email, password: password);
  }

  final usersTable = 'users';

  Future<UserModel?> getAppUser(String authId) async {
    final response = await client
      .from(usersTable)
      .select('*')
      .eq('auth_id', authId)
      .single();
    debugPrint("User: $response");
    return UserModel.fromJson(response);
  }

  Future<List<RoomModel>> getRoomsByUser(String userId) async {
    final response = await client
      .from('rooms')
      .select('*, maps(*), users(*), quizzes(*)')
      .eq('user_id', userId)
      .order('created_at', ascending: false);
    debugPrint("User Rooms: $response");
    return List<RoomModel>.from(response.map((json) => RoomModel.fromJson(json)));
  }
} 