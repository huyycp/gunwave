import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gunwave/data/data_sources/remote/api/supabase_api.dart';
import 'package:gunwave/data/models/room_model.dart';
import 'package:gunwave/data/models/user_model.dart';
import 'package:gunwave/utils/logger/app_logger.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final userRemoteProvider = Provider<UserRemoteDataSource>((ref) {
  return UserRemoteDataSource(ref.read(supabaseApiProvider));
});

class UserRemoteDataSource {
  UserRemoteDataSource(this._supabaseApi);

  final SupabaseApi _supabaseApi;
  late final _logger = AppLogger(runtimeType);

  GoTrueClient get auth => _supabaseApi.supabase.auth;
  SupabaseClient get client => _supabaseApi.supabase;

  Future<AuthResponse> signInWithEmail(String email, String password) async {
    return await auth.signInWithPassword(email: email, password: password);
  }

  Future<AuthResponse> signInAnonymously() async {
    return await auth.signInAnonymously();
  }

  Future<void> signOut() => auth.signOut();

  final usersTable = 'users';

  Future<UserModel?> getAppUser(String authId) async {
    final response = await client
        .from(usersTable)
        .select('*')
        .eq('auth_id', authId)
        .maybeSingle();
    _logger.info(
        'getAppUser',
        response == null
            ? 'Application profile not found.'
            : 'Application profile loaded.');
    return response == null ? null : UserModel.fromJson(response);
  }

  /// Creates the application profile missing from a new anonymous Auth session.
  /// Gold and the profile ID use database defaults, just like normal profiles.
  Future<UserModel> createGuestProfile(String authId) async {
    final response = await client
        .from(usersTable)
        .insert({'auth_id': authId, 'name': 'Guest'})
        .select()
        .single();
    _logger.info('createGuestProfile', 'Guest profile created.');
    return UserModel.fromJson(response);
  }

  Future<List<RoomModel>> getRoomsByUser(String userId) async {
    final response = await client
        .from('rooms')
        .select('*, maps(*), users(*), quizzes(*)')
        .eq('user_id', userId)
        .order('created_at', ascending: false);
    _logger.info('getRoomsByUser', 'Loaded ${response.length} rooms.');
    return List<RoomModel>.from(
        response.map((json) => RoomModel.fromJson(json)));
  }
}
