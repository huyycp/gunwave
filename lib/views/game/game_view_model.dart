import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gunwave/data/constants/app_gesture.dart';
import 'package:gunwave/repositories/gesture_recognizer_repo.dart';
import 'package:gunwave/widgets/base/base_view_model.dart';

final gameViewModel = ChangeNotifierProvider.autoDispose<GameViewModel>((ref) {
  return GameViewModel();
});

class GameViewModel extends BaseViewModel {
  GestureRecognizerRepo? _gestureRecognizerRepo;
  StreamSubscription<String>? _gestureSubscription;
  String? gesture;

  Future<void> startGestureRecognition() async {
    _gestureRecognizerRepo ??= ref.read(gestureRecognizerRepoProvider);
    await _gestureSubscription?.cancel();
    _gestureSubscription = _gestureRecognizerRepo?.gestureStream.listen((
      value,
    ) {
      gesture = value;
    });

    try {
      await _gestureRecognizerRepo?.startGestureRecognition();
    } catch (_) {
      gesture = AppGesture.Unknown.name;
      await _gestureSubscription?.cancel();
      _gestureSubscription = null;
      rethrow;
    }
  }

  Future<void> stopGestureRecognition() async {
    gesture = AppGesture.Unknown.name;
    await _gestureSubscription?.cancel();
    _gestureSubscription = null;
    await _gestureRecognizerRepo?.stopGestureRecognition();
  }
}
