import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gunwave/utils/exception/app_exception.dart';
import 'package:gunwave/widgets/base/base_view_model.dart';

final homeViewModel = ChangeNotifierProvider.autoDispose<HomeViewModel>(
  (ref) => HomeViewModel(),
);

class HomeViewModel extends BaseViewModel {
  bool isLoginFormVisible = false;

  void showLoginForm() {
    isLoginFormVisible = true;
    notifyListeners();
  }

  void showAuthOptions() {
    isLoginFormVisible = false;
    notifyListeners();
  }

  Future<bool> continueAsGuest() async {
    try {
      final repository = userRepo;
      await repository.signInAsGuest();
      return repository.appUser != null;
    } catch (error, stackTrace) {
      AppException.log(
        runtimeType,
        error,
        stackTrace,
        function: 'continueAsGuest',
      );
      return false;
    } finally {
      if (view?.mounted ?? false) notifyListeners();
    }
  }

  void onLoginComplete(bool succeeded) {
    if (succeeded) {
      isLoginFormVisible = false;
    }
    notifyListeners();
  }
}
