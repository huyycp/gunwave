import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:gunwave/data/data_sources/remote/user_remote_data_source.dart';
import 'package:gunwave/data/models/user_model.dart';
import 'package:gunwave/repositories/user_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() {
  test('concurrent Guest requests share one sign-in and create the missing profile', () async {
    final remote = GuestRemoteStub();
    final repository = UserRepository(remote);
    final first = repository.signInAsGuest();
    final second = repository.signInAsGuest();
    expect(identical(first, second), isTrue);
    remote.signIn.complete(AuthResponse());
    await Future.wait([first, second]);
    expect(remote.signIns, 1);
    expect(remote.profilesCreated, 1);
    expect(repository.appUser?.id, 'profile');
  });

  test('failed guest profile creation signs out and allows a retry', () async {
    final remote = GuestRemoteStub()..failProfile = true;
    final repository = UserRepository(remote);
    final attempt = repository.signInAsGuest();
    remote.signIn.complete(AuthResponse());
    await expectLater(attempt, throwsStateError);
    expect(remote.signOuts, 1);
    expect(repository.appUser, isNull);
    remote.failProfile = false;
    await repository.signInAsGuest();
    expect(remote.signIns, 2);
    expect(repository.appUser?.id, 'profile');
  });
}

class GuestRemoteStub implements UserRemoteDataSource {
  final signIn = Completer<AuthResponse>();
  int signIns = 0;
  int profilesCreated = 0;
  int signOuts = 0;
  bool failProfile = false;
  @override
  GoTrueClient get auth => GuestAuthStub();
  @override
  Future<AuthResponse> signInAnonymously() {
    signIns++;
    return signIn.future;
  }

  @override
  Future<UserModel?> getAppUser(String authId) async => null;
  @override
  Future<UserModel> createGuestProfile(String authId) async {
    if (failProfile) throw StateError('Profile unavailable');
    profilesCreated++;
    return const UserModel(id: 'profile', authId: 'guest', name: 'Guest');
  }

  @override
  Future<void> signOut() async {
    signOuts++;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class GuestAuthStub implements GoTrueClient {
  @override
  User get currentUser => const User(
    id: 'guest',
    appMetadata: {},
    userMetadata: {},
    aud: 'authenticated',
    createdAt: '',
    isAnonymous: true,
  );
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
