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

  bool isLoading = true;

  Future<void> getCharacters() async {
    try {
      if (userRepo.appUser == null) return;
      characters = await _characterRepo.getUnownedCharacters(userRepo.appUser!.id);
      notifyListeners();
    } catch (err, stack) {
      AppException.log(runtimeType, err, stack);
    } finally {
      setLoading(false);
    }
  }

  void setLoading(bool loading) {
    isLoading = loading;
    notifyListeners();
  }
}