import 'package:gunwave/data/constants/game/game_hud_style.dart';

/// Asset and animation measurements shared by the Flame menu scenes.
abstract final class GameMenuStyle {
  static const panelBorderInset = GameHudStyle.panelBorderInset;
  static const homeHubMaxWidth = 900.0;
  static const homeHubMaxHeight = 500.0;
  static const homeHubWidthRatio = 0.82;
  static const homeHubHeightRatio = 0.56;
  static const homeHubPanelHeightRatio = 0.78;
  static const loadoutMaxWidth = 820.0;
  static const loadoutMaxHeight = 460.0;
  static const loadoutWidthRatio = 0.82;
  static const loadoutHeightRatio = 0.84;
  static const shopMaxWidth = 960.0;
  static const shopMaxHeight = 520.0;
  static const shopWidthRatio = 0.86;
  static const shopHeightRatio = 0.84;
  static const briefingMaxWidth = 980.0;
  static const briefingMaxHeight = 480.0;
  static const briefingWidthRatio = 0.9;
  static const briefingHeightRatio = 0.68;
  static const spriteFrameSize = 192.0;
  static const heroIdleFrameCount = 6;
  static const monsterIdleFrameCount = 7;
  static const previewFrameDuration = 0.08;
}
