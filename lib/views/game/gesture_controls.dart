import 'package:gunwave/data/constants/app_gesture.dart';

class GestureControls {
  const GestureControls({
    required this.horizontalMovement,
    required this.verticalMovement,
    required this.attack,
  });

  final int horizontalMovement;
  final int verticalMovement;
  final bool attack;

  factory GestureControls.fromGesture(AppGesture gesture) => switch (gesture) {
        AppGesture.Pointing_Up => const GestureControls(
            horizontalMovement: 1,
            verticalMovement: 0,
            attack: false,
          ),
        AppGesture.Victory => const GestureControls(
            horizontalMovement: -1,
            verticalMovement: 0,
            attack: false,
          ),
        AppGesture.Thumb_Up => const GestureControls(
            horizontalMovement: 0,
            verticalMovement: -1,
            attack: false,
          ),
        AppGesture.Thumb_Down => const GestureControls(
            horizontalMovement: 0,
            verticalMovement: 1,
            attack: false,
          ),
        AppGesture.Closed_Fist => const GestureControls(
            horizontalMovement: 0,
            verticalMovement: 0,
            attack: true,
          ),
        AppGesture.Open_Palm ||
        AppGesture.ILoveYou ||
        AppGesture.Unknown =>
          const GestureControls(
            horizontalMovement: 0,
            verticalMovement: 0,
            attack: false,
          ),
      };
}
