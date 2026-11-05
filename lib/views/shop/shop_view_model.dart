import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gunwave/data/models/character_model.dart';
import 'package:gunwave/repositories/character_repository.dart';
import 'package:gunwave/utils/exception/app_exception.dart';
import 'package:gunwave/widgets/base/base_view_model.dart';

final shopViewModel = ChangeNotifierProvider<ShopViewModel>(
  (ref) => ShopViewModel(ref),
);

class ShopViewModel extends BaseViewModel {
  ShopViewModel(ChangeNotifierProviderRef ref) {
    _characterRepo = ref.read(characterRepoProvider);
  }

  late final CharacterRepository _characterRepo;

  List<CharacterModel> characters = [];
  List<CharacterModel> ownedCharacters = [];
  int goldBalance = 0;

  bool isLoading = true;
  bool hasLoadError = false;

  Future<void> getCharacters() async {
    try {
      characters = await _characterRepo.getCharacters();
      ownedCharacters = await _characterRepo.getOwnedCharacters();
      goldBalance = await _characterRepo.getGoldBalance();
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
      view?.showFullScreenLoading();
      final result = await _characterRepo.buyCharacter(character.id);
      if (result) {
        ownedCharacters = _characterRepo.ownedCharacters;
        goldBalance = await _characterRepo.getGoldBalance();
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
