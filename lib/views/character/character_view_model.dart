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

  List<CharacterModel> characters = [];
  int selectedCharacterIndex = 0;

  Future<void> getCharacters() async {
    try {
      characters = await _characterRepo.getCharacters(userRepo.appUser?.id);
      notifyListeners();
    } catch (err, stack) {
      AppException.log(runtimeType, err, stack);
    }
  }

  void onCharacterSelected(int index) {
    if (index < 0 || index >= characters.length) return;
    selectedCharacterIndex = index;
    debugPrint("Character selected: ${characters[index].name}");
    notifyListeners(); 
  }
}