import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gunwave/data/data_sources/remote/user_remote_data_source.dart';
import 'package:gunwave/data/models/user_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final userRepoProvider = Provider<UserRepository>((ref) {
  return UserRepository(ref.read(userRemoteProvider));
});

class UserRepository {
  UserRepository(this._userRemote);

  final UserRemoteDataSource _userRemote;

  User? get user => _userRemote.auth.currentUser;
  UserModel? appUser;

  Future<void> signInWithEmail(String email, String password) async {
    await _userRemote.signInWithEmail(email, password);
    debugPrint("User: $user");
    if (user != null) {
      await getAppUser();
    }
  }

  Future<void> getAppUser() async {
    if (user == null) return;
    appUser = await _userRemote.getAppUser(user!.id);
    debugPrint("App User: ${appUser?.toJson()}");
  }
}