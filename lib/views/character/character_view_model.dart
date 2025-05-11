import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gunwave/data/models/character_model.dart';
import 'package:gunwave/utils/exception/app_exception.dart';
import 'package:gunwave/widgets/base/base_view_model.dart';

final characterViewModel = ChangeNotifierProvider<CharacterViewModel>(
  (ref) => CharacterViewModel(),
);

class CharacterViewModel extends BaseViewModel {
  List<CharacterModel> characters = [];
  int selectedCharacterIndex = 0;

  bool isLoading = true;
  
  Future<void> getCharacters() async {
    try {
      await Future.delayed(const Duration(milliseconds: 100), () {
        characters = userRepo.appUser?.characters ?? [];
        setLoading(false);
      });
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

  void setLoading(bool loading) {
    isLoading = loading;
    notifyListeners();
  }
}