import 'dart:async';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';

class CollisionComponent extends PositionComponent {
  CollisionComponent({
    super.position,
    super.size,
    this.isPlatform = false,
  });

  final bool isPlatform;

  @override
  FutureOr<void> onLoad() {
    add(RectangleHitbox());
    return super.onLoad();
  }
}