import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gunwave/data/data_sources/local/gesture_recognizer_data_source.dart';

final gestureRecognizerRepoProvider = Provider<GestureRecognizerRepo>((ref) {
  return GestureRecognizerRepo(ref);
});

class GestureRecognizerRepo {
  GestureRecognizerRepo(ProviderRef ref) {
    _recognizerLocal = ref.read(recognizerLocalDataSource);
  }

  late final GestureRecognizerDataSource _recognizerLocal;

  Stream<String> get gestureStream => _recognizerLocal.gestureStream;

  Future<void> startGestureRecognition() async {
    await _recognizerLocal.startGestureRecognition();
  }

  Future<void> stopGestureRecognition() async {
    await _recognizerLocal.stopGestureRecognition();
  }
}