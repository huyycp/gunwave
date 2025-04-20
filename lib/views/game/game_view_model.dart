import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gunwave/repositories/gesture_recognizer_repo.dart';
import 'package:gunwave/widgets/base/base_view_model.dart';

final gameViewModel = ChangeNotifierProvider<GameViewModel>((ref) {
  return GameViewModel();
});

class GameViewModel extends BaseViewModel {

  late final GestureRecognizerRepo _gestureRecognizerRepo = ref.read(gestureRecognizerRepoProvider);

  StreamSubscription<String>? _gestureSubscription;
  String? gesture;

  Future<void> startGestureRecognition() async {
    await _gestureRecognizerRepo.startGestureRecognition();
    _gestureSubscription = _gestureRecognizerRepo.gestureStream.listen((gesture) {
      // Handle the recognized gesture
      this.gesture = gesture;
      notifyListeners();
      print("Gesture recognized: $gesture");
    });
  }

  Future<void> stopGestureRecognition() async {
    await _gestureRecognizerRepo.stopGestureRecognition();
    await _gestureSubscription?.cancel();
  }
}