import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gunwave/data/data_sources/remote/user_remote_data_source.dart';
import 'package:gunwave/data/models/room_model.dart';
import 'package:gunwave/data/models/user_model.dart';
import 'package:gunwave/utils/logger/app_logger.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final userRepoProvider = Provider<UserRepository>((ref) {
  return UserRepository(ref.read(userRemoteProvider));
});

class UserRepository {
  UserRepository(this._userRemote);

  final UserRemoteDataSource _userRemote;
  late final _logger = AppLogger(runtimeType);

  User? get user => _userRemote.auth.currentUser;
  UserModel? appUser;
  Future<void>? _guestSignIn;

  Future<void> signInWithEmail(String email, String password) async {
    _logger.info('signInWithEmail', 'Starting email sign-in.');
    await _userRemote.signInWithEmail(email, password);
    if (user != null) {
      await getAppUser();
    }
  }

  /// Shares an in-flight sign-in so rapid taps cannot create competing sessions.
  Future<void> signInAsGuest() =>
      _guestSignIn ??= _signInAsGuest().whenComplete(() => _guestSignIn = null);

  Future<void> _signInAsGuest() async {
    _logger.info('signInAsGuest', 'Starting anonymous sign-in.');
    appUser = null;
    await _userRemote.signInAnonymously();
    try {
      await getAppUser();
      if (appUser == null) {
        throw StateError('Guest profile was not created.');
      }
      _logger.info('signInAsGuest', 'Guest session ready.');
    } catch (_) {
      await _userRemote.signOut();
      rethrow;
    }
  }

  Future<void> getAppUser() async {
    final currentUser = user;
    if (currentUser == null) return;
    var profile = await _userRemote.getAppUser(currentUser.id);
    if (profile == null && currentUser.isAnonymous) {
      _logger.warning(
        'getAppUser',
        'Anonymous profile is missing; creating a guest profile.',
      );
      profile = await _userRemote.createGuestProfile(currentUser.id);
    }
    if (profile == null) {
      throw StateError('Application profile was not found.');
    }
    appUser = profile;
    _logger.info('getAppUser', 'Application profile ready.');
  }

  Future<List<RoomModel>> getMyRooms() async {
    if (appUser == null) return [];
    return _userRemote.getRoomsByUser(appUser!.id);
  }
}
