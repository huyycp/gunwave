import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gunwave/widgets/base/base_view_model.dart';

final splashViewModel = ChangeNotifierProvider.autoDispose<SplashViewModel>(
  (ref) => SplashViewModel()
);

class SplashViewModel extends BaseViewModel {
  Future<void> init(void Function() onDone) async {
    if (userRepo.user != null) {
      await userRepo.getAppUser();
    }
    onDone();
  }
}