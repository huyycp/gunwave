import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gunwave/widgets/base/base_view_model.dart';

final homeViewModel = ChangeNotifierProvider.autoDispose<HomeViewModel>(
  (ref) => HomeViewModel(),
);

class HomeViewModel extends BaseViewModel {

  bool isLoginFormVisible = true;

  void toggleLoginForm() {
    isLoginFormVisible = !isLoginFormVisible;
    notifyListeners();
  }
}