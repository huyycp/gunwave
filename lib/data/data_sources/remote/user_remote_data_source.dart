import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gunwave/data/data_sources/remote/api/supabase_api.dart';
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
      .select('*, characters(*)')
      .eq('auth_id', authId)
      .single();
    debugPrint("User with characters: $response");
    return UserModel.fromJson(response);
  }
}