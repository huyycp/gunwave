import 'dart:math';
import 'package:flame/game.dart';

double calculateAngle(Vector2 a, Vector2 b, Vector2 c) {
  final v1 = a - b;
  final v2 = c - b;
  
  final dot = v1.dot(v2);
  final cross = v1.x * v2.y - v1.y * v2.x;
  final lenProduct = v1.length * v2.length;
  
  if (lenProduct == 0) {
    return 0;
  }
  
  final cosTheta = (dot / lenProduct).clamp(-1.0, 1.0);
  final angleSize = acos(cosTheta); // always positive

  final sign = cross <= 0 ? 1.0 : -1.0;
  return angleSize * sign; // signed angle
}
