import 'package:gunwave/data/constants/game/game_color.dart';
import 'package:gunwave/data/constants/game/game_hud_style.dart';

/// Asset and animation measurements shared by the Flame menu scenes.
abstract final class GameMenuStyle {
  static const panelBorderInset = GameHudStyle.panelBorderInset;
  static const homeHubMaxWidth = 1600.0;
  static const homeHubMaxHeight = 900.0;
  static const homeHubWidthRatio = 0.94;
  static const homeHubHeightRatio = 0.70;
  static const homeHubPanelHeightRatio = 0.82;
  static const loadoutMaxWidth = 1600.0;
  static const loadoutMaxHeight = 900.0;
  static const loadoutWidthRatio = 0.94;
  static const loadoutHeightRatio = 0.90;
  static const shopMaxWidth = 1600.0;
  static const shopMaxHeight = 900.0;
  static const shopWidthRatio = 0.95;
  static const shopHeightRatio = 0.92;
  static const briefingMaxWidth = 1600.0;
  static const briefingMaxHeight = 900.0;
  static const briefingWidthRatio = 0.96;
  static const briefingHeightRatio = 0.84;
  static const spriteFrameSize = 192.0;
  static const heroIdleFrameCount = 6;
  static const monsterIdleFrameCount = 7;
  static const previewFrameDuration = 0.08;
  static const backdropColor = GameColors.primary;
  static const inkColor = GameColors.primary;
  static const lightInkColor = GameColors.uiText;
}
