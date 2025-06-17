import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gunwave/data/constants/app_gesture.dart';
import 'package:gunwave/repositories/gesture_recognizer_repo.dart';
import 'package:gunwave/repositories/rank_repository.dart';
import 'package:gunwave/widgets/base/base_view_model.dart';

final gameViewModel = ChangeNotifierProvider.autoDispose<GameViewModel>((ref) {
  return GameViewModel();
});

class GameViewModel extends BaseViewModel {

  late final GestureRecognizerRepo _gestureRecognizerRepo = ref.read(gestureRecognizerRepoProvider);
  late final RankRepository rankRepo = ref.read(rankRepoProvider);

  StreamSubscription<String>? _gestureSubscription;
  String? gesture;

  bool isShowQuizBtnVisible = false;
  bool isQuizVisible = false;

  int currentQuizIndex = 0;
  Map<int, ({int failAttempts, bool isCorrect})> quizResult = {};

  final ValueNotifier<int> timeRemaining = ValueNotifier<int>(0);
  Timer? _timer;

  /// gesture recognition
  Future<void> startGestureRecognition() async {
    await _gestureRecognizerRepo.startGestureRecognition();
    _gestureSubscription = _gestureRecognizerRepo.gestureStream.listen((gesture) {
      // Handle the recognized gesture
      if (isShowQuizBtnVisible) {
        this.gesture = AppGesture.Unknown.name;
      } else {
        this.gesture = gesture;
      }
      // notifyListeners();
      debugPrint("Gesture recognized: $gesture");
    });
  }

  Future<void> stopGestureRecognition() async {
    await _gestureRecognizerRepo.stopGestureRecognition();
    await _gestureSubscription?.cancel();
  }
  ///
  
  /// Quiz management
  void setShowQuizBtnVisible(bool visible) {
    isShowQuizBtnVisible = visible;
    notifyListeners();
  }

  void toggleQuizVisible() {
    isQuizVisible = !isQuizVisible;
    notifyListeners();
  }

  void setNextQuiz() {
    currentQuizIndex++;
    notifyListeners();
  }

  void onQuizAnswered(bool isCorrect) {
    quizResult[currentQuizIndex] = (
      failAttempts: (quizResult[currentQuizIndex]?.failAttempts ?? 0) + (isCorrect ? 0 : 1),
      isCorrect: isCorrect,
    );
  }
  ///

  /// Timer management
  void initializeTimer(int initialTime) {
    timeRemaining.value = initialTime;
  }

  void startTimer(Function() onTimeExpired) {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (timeRemaining.value > 0) {
        timeRemaining.value--;
      } else {
        _timer?.cancel();
        onTimeExpired();
      }
    });
  }

  void decreaseTime(int seconds) {
    timeRemaining.value = timeRemaining.value - seconds;
    if (timeRemaining.value < 0) timeRemaining.value = 0;
  }

  void stopTimer() {
    _timer?.cancel();
  }
  ///

  @override
  void dispose() {
    _timer?.cancel();
    timeRemaining.dispose();
    super.dispose();
  }
}