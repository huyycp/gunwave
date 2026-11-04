import 'package:flame/components.dart';
import 'package:flame/events.dart';

/// Full-screen invisible blocker for touch controls beneath a Flame menu.
class TapShieldComponent extends PositionComponent
    with TapCallbacks, DragCallbacks {
  TapShieldComponent({super.priority = 1});
}
