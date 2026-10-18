import 'package:flutter_test/flutter_test.dart';
import 'package:gunwave/data/data_sources/remote/character_remote_data_source.dart';
import 'package:gunwave/data/models/character_model.dart';
import 'package:gunwave/repositories/character_repository.dart';

void main() {
  test('successful upgrade replaces the cached immutable character', () async {
    final remote = CharacterRemoteStub();
    final repository = CharacterRepository(remote);
    const original = CharacterModel(id: 'hero', hp: 100, sp: 2);
    repository.ownedCharacters = [original];
    expect(await repository.updateAttr('hero', CharacterAttr.hp), isTrue);
    expect(repository.ownedCharacters.single.hp, 101);
    expect(repository.ownedCharacters.single.sp, 1);
    expect(original.hp, 100);
    remote.success = false;
    expect(await repository.updateAttr('hero', CharacterAttr.str), isFalse);
    expect(repository.ownedCharacters.single.sp, 1);
  });
}

class CharacterRemoteStub implements CharacterRemoteDataSource {
  bool success = true;
  @override
  Future<bool> updateAttr(String id, CharacterAttr attr) async => success;
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
