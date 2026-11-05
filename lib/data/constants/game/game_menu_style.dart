import 'package:gunwave/data/constants/game/game_color.dart';

/// Asset and animation measurements shared by the Flame menu scenes.
abstract final class GameMenuStyle {
  static const homeHubMaxWidth = 1600.0;
  static const homeHubMaxHeight = 900.0;
  static const homeHubWidthRatio = 0.94;
  static const homeHubHeightRatio = 0.88;
  static const homeHubPanelHeightRatio = 0.84;
  static const homeHubHeroWidthRatio = 0.98;
  static const homeHubHeroHeightRatio = 0.88;
  static const homeHubHeroCenterYRatio = 0.45;
  static const homeHubHeroNameCenterYRatio = 0.90;
  static const loadoutMaxWidth = 1600.0;
  static const loadoutMaxHeight = 900.0;
  static const loadoutWidthRatio = 0.94;
  static const loadoutHeightRatio = 0.90;
  static const loadoutHeroColumnRatio = 0.44;
  static const loadoutPreviewWidthRatio = 0.76;
  static const loadoutPreviewHeightRatio = 0.78;
  static const loadoutPreviewCenterYRatio = 0.52;
  static const shopMaxWidth = 1600.0;
  static const shopMaxHeight = 900.0;
  static const shopWidthRatio = 0.95;
  static const shopHeightRatio = 0.92;
  static const shopPreviewWidthRatio = 0.56;
  static const shopPreviewHeightRatio = 0.56;
  static const shopPreviewCenterYRatio = 0.28;
  static const shopNameCenterYRatio = 0.64;
  static const shopActionCenterYRatio = 0.85;
  static const shopActionHeightRatio = 0.28;
  static const settingsMaxHeight = 900.0;
  static const briefingMaxWidth = 1600.0;
  static const briefingMaxHeight = 900.0;
  static const briefingWidthRatio = 0.96;
  static const briefingHeightRatio = 0.92;
  static const backgroundZoomScale = 1.45;
  // forest.png's visible island is centered at x=1312 of its 3200px canvas.
  static const backgroundMapContentCenterXRatio = 0.41;
  static const spriteFrameSize = 192.0;
  static const heroIdleFrameCount = 6;
  static const monsterIdleFrameCount = 7;
  static const previewFrameDuration = 0.08;
  static const backdropColor = GameColors.primary;
  static const inkColor = GameColors.primary;
  static const lightInkColor = GameColors.uiText;
}
