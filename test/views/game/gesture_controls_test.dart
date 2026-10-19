import 'package:flutter_test/flutter_test.dart';
import 'package:gunwave/data/constants/app_gesture.dart';
import 'package:gunwave/views/game/gesture_controls.dart';

void main() {
  group('GestureControls', () {
    test('closed fist attacks without retaining prior movement', () {
      expect(
        GestureControls.fromGesture(AppGesture.Closed_Fist),
        const GestureControls(
          horizontalMovement: 0,
          verticalMovement: 0,
          attack: true,
        ),
      );
    });

    test('open palm and unknown clear movement and attack', () {
      for (final gesture in [AppGesture.Open_Palm, AppGesture.Unknown]) {
        expect(
          GestureControls.fromGesture(gesture),
          const GestureControls(
            horizontalMovement: 0,
            verticalMovement: 0,
            attack: false,
          ),
        );
      }
    });
  });
}
