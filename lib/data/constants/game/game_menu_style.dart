import 'package:gunwave/data/constants/game/game_hud_style.dart';

/// Asset and animation measurements shared by the Flame menu scenes.
abstract final class GameMenuStyle {
  static const panelBorderInset = GameHudStyle.panelBorderInset;
  static const spriteFrameSize = 192.0;
  static const heroIdleFrameCount = 6;
  static const monsterIdleFrameCount = 7;
  static const previewFrameDuration = 0.08;
}
