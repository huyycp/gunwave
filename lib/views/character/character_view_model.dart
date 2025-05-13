import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gunwave/data/models/character_model.dart';
import 'package:gunwave/repositories/character_repository.dart';
import 'package:gunwave/utils/exception/app_exception.dart';
import 'package:gunwave/widgets/base/base_view_model.dart';

final characterViewModel = ChangeNotifierProvider<CharacterViewModel>(
  (ref) => CharacterViewModel(ref),
);

class CharacterViewModel extends BaseViewModel {
  CharacterViewModel(ChangeNotifierProviderRef ref) {
    _characterRepo = ref.read(characterRepoProvider);
  }

  late final CharacterRepository _characterRepo;

  List<CharacterModel> get characters => _characterRepo.ownedCharacters;
  int selectedCharacterIndex = 0;

  bool isLoading = true;
  
  Future<void> getCharacters() async {
    try {
      if (userRepo.appUser == null) return;
      await _characterRepo.getOwnedCharacters(userRepo.appUser!.id);
    } catch (err, stack) {
      AppException.log(runtimeType, err, stack);
    } finally {
      setLoading(false);
    }
  }

  void onCharacterSelected(int index) {
    if (index < 0 || index >= characters.length) return;
    selectedCharacterIndex = index;
    debugPrint("Character selected: ${characters[index].name}");
    notifyListeners(); 
  }

  void setLoading(bool loading) {
    isLoading = loading;
    notifyListeners();
  }
}