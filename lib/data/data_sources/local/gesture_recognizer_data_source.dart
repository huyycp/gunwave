import 'dart:async';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final recognizerLocalDataSource = Provider<GestureRecognizerDataSource>((ref) {
  return GestureRecognizerDataSource();
});

class GestureRecognizerDataSource {
  GestureRecognizerDataSource() {
    setMethodCallHandler();
  }

  late final MethodChannel channel = MethodChannel(recognizerChannel);

  final String recognizerChannel = 'gesture_recognizer';

  final String startGestureRecognitionMethod = 'startGestureRecognition';
  final String stopGestureRecognitionMethod = 'stopGestureRecognition';
  final String onGestureRecognized = 'onGestureRecognized';

  final _gestureStreamController = StreamController<String>.broadcast();
  Stream<String> get gestureStream => _gestureStreamController.stream;

  Future<void> startGestureRecognition() async {
    await channel.invokeMethod(startGestureRecognitionMethod);
  }

  Future<void> stopGestureRecognition() async {
    await channel.invokeMethod(stopGestureRecognitionMethod);
  }

  void setMethodCallHandler() {
    channel.setMethodCallHandler((call) async {
      if (call.method == onGestureRecognized) {
        final gesture = call.arguments as String;
        _gestureStreamController.add(gesture);
      }
    });
  }

  void dispose() {
    _gestureStreamController.close();
  }
}