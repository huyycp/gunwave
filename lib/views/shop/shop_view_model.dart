import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gunwave/data/models/character_model.dart';
import 'package:gunwave/repositories/character_repository.dart';
import 'package:gunwave/utils/exception/app_exception.dart';
import 'package:gunwave/widgets/base/base_view_model.dart';

final shopViewModel = ChangeNotifierProvider<ShopViewModel>(
  (ref) => ShopViewModel(ref)
);

class ShopViewModel extends BaseViewModel {
  ShopViewModel(ChangeNotifierProviderRef ref) {
    _characterRepo = ref.read(characterRepoProvider);
  }

  late final CharacterRepository _characterRepo;

  List<CharacterModel> characters = [];
  List<CharacterModel> ownedCharacters = [];

  bool isLoading = true;

  int get userBalance => userRepo.appUser?.gold ?? 0;

  Future<void> getCharacters() async {
    try {
      if (userRepo.appUser == null) return;
      characters = await _characterRepo.getCharacters();
      ownedCharacters = await _characterRepo.getOwnedCharacters(userRepo.appUser!.id);
      notifyListeners();
    } catch (err, stack) {
      AppException.log(runtimeType, err, stack);
    } finally {
      setLoading(false);
    }
  }

  Future<void> buyCharacter(CharacterModel character) async {
    try {
      if (userRepo.appUser == null) return;
      view?.showFullScreenLoading();
      final result = await _characterRepo.buyCharacter(character.id);
      if (result) {
        ownedCharacters.add(character);
        userRepo.appUser?.gold -= character.price;
      }
    } catch (err, stack) {
      AppException.log(runtimeType, err, stack);
    } finally {
      userRepo.getAppUser();
      notifyListeners();
      view?.hideFullScreenLoading();
    }
  }

  // Property that returns a function to check character ownership
  get isCharacterOwned => (String characterId) => 
    ownedCharacters.any((element) => element.id == characterId);

  void setLoading(bool loading) {
    isLoading = loading;
    notifyListeners();
  }
}