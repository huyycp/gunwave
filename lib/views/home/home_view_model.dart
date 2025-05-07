import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gunwave/data/models/character_model.dart';
import 'package:gunwave/repositories/character_repository.dart';
import 'package:gunwave/repositories/user_repository.dart';
import 'package:gunwave/utils/exception/app_exception.dart';
import 'package:gunwave/widgets/base/base_view_model.dart';

final homeViewModel = ChangeNotifierProvider.autoDispose<HomeViewModel>(
  (ref) => HomeViewModel(
    ref.read(characterRepoProvider),
  ),
);

class HomeViewModel extends BaseViewModel {
  HomeViewModel(this._characterRepo);

  final CharacterRepository _characterRepo;

  List<CharacterModel> characters = [];

  bool isStatusBoardVisible = false;

  bool isLoginFormVisible = true;

  void toggleLoginForm() {
    isLoginFormVisible = !isLoginFormVisible;
    notifyListeners();
  }

  void toggleStatusBoard() {
    isStatusBoardVisible = !isStatusBoardVisible;
    notifyListeners();
  }

  Future<void> getCharacters() async {
    try {
      characters = await _characterRepo.getCharacters(userRepo.appUser?.id);
      notifyListeners();
    } catch (err, stack) {
      AppException.log(runtimeType, err, stack);
    }
  }
}