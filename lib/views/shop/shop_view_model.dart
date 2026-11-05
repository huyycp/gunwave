import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gunwave/data/models/character_model.dart';
import 'package:gunwave/repositories/character_repository.dart';
import 'package:gunwave/repositories/user_repository.dart';
import 'package:gunwave/utils/exception/app_exception.dart';
import 'package:gunwave/widgets/base/base_view_model.dart';

final shopViewModel = ChangeNotifierProvider<ShopViewModel>(
  (ref) => ShopViewModel(ref),
);

class ShopViewModel extends BaseViewModel {
  ShopViewModel(ChangeNotifierProviderRef ref) {
    _characterRepo = ref.read(characterRepoProvider);
    _userRepository = ref.read(userRepoProvider);
  }

  late final CharacterRepository _characterRepo;
  late final UserRepository _userRepository;

  List<CharacterModel> characters = [];
  List<CharacterModel> ownedCharacters = [];

  bool isLoading = true;
  bool hasLoadError = false;

  int get userBalance => _userRepository.appUser?.gold ?? 0;

  Future<void> getCharacters() async {
    try {
      final user = _userRepository.appUser;
      if (user == null) return;
      characters = await _characterRepo.getCharacters();
      ownedCharacters = await _characterRepo.getOwnedCharacters(user.id);
      debugPrint("Characters loaded: ${characters.map((e) => e.toJson())}");
      debugPrint(
        "Owned characters loaded: ${ownedCharacters.map((e) => e.toJson())}",
      );
      notifyListeners();
    } catch (err, stack) {
      hasLoadError = true;
      AppException.log(runtimeType, err, stack, function: 'getCharacters');
    } finally {
      setLoading(false);
    }
  }

  /// Purchases [character] and immediately updates the local gold snapshot.
  Future<void> buyCharacter(CharacterModel character) async {
    try {
      final user = _userRepository.appUser;
      if (user == null) return;
      view?.showFullScreenLoading();
      final result = await _characterRepo.buyCharacter(character.id);
      if (result) {
        ownedCharacters.add(character);
        _userRepository.appUser = user.copyWith(
          gold: user.gold - character.price,
        );
      }
    } catch (err, stack) {
      AppException.log(runtimeType, err, stack, function: 'buyCharacter');
    } finally {
      notifyListeners();
      view?.hideFullScreenLoading();
    }
  }

  // Property that returns a function to check character ownership
  bool Function(String) get isCharacterOwned =>
      (String characterId) =>
          ownedCharacters.any((element) => element.id == characterId);

  void setLoading(bool loading) {
    isLoading = loading;
    notifyListeners();
  }
}
