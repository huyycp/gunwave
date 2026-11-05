import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gunwave/data/data_sources/remote/character_remote_data_source.dart';
import 'package:gunwave/data/data_sources/remote/user_remote_data_source.dart';
import 'package:gunwave/data/models/character_model.dart';
import 'package:gunwave/data/models/user_model.dart';
import 'package:gunwave/repositories/character_repository.dart';
import 'package:gunwave/repositories/user_repository.dart';
import 'package:gunwave/views/shop/shop_view_model.dart';

void main() {
  test(
    'ShopViewModel loads and purchases without an attached BaseView',
    () async {
      const character = CharacterModel(
        id: 'hero_red',
        name: 'Red Warrior',
        filename: 'warrior_red',
        price: 40,
      );
      const ownedCharacter = CharacterModel(
        id: 'hero_blue',
        name: 'Blue Warrior',
      );
      final repository = CharacterRepository(
        _CharacterRemoteStub(
          characters: [character],
          ownedCharacters: [ownedCharacter],
        ),
      );
      final userRepository = UserRepository(_UserRemoteStub())
        ..appUser = const UserModel(id: 'guest-1', gold: 100);
      final container = ProviderContainer(
        overrides: [
          characterRepoProvider.overrideWithValue(repository),
          userRepoProvider.overrideWithValue(userRepository),
        ],
      );
      addTearDown(container.dispose);

      final shop = container.read(shopViewModel);
      await shop.getCharacters();

      expect(shop.characters, [character]);
      expect(shop.ownedCharacters, [ownedCharacter]);
      expect(shop.isLoading, isFalse);
      expect(shop.userBalance, 100);

      await shop.buyCharacter(character);
      expect(shop.userBalance, 60);
      expect(shop.ownedCharacters, contains(character));
    },
  );
}

class _CharacterRemoteStub implements CharacterRemoteDataSource {
  _CharacterRemoteStub({
    required this.characters,
    required this.ownedCharacters,
  });

  final List<CharacterModel> characters;
  final List<CharacterModel> ownedCharacters;

  @override
  Future<List<CharacterModel>> getCharacters() async => characters;

  @override
  Future<List<CharacterModel>> getOwnedCharacters(String userId) async =>
      ownedCharacters;

  @override
  Future<bool> buyCharacter(String characterId) async => true;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _UserRemoteStub implements UserRemoteDataSource {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
