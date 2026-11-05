import 'dart:math' as math;

import 'package:flame/components.dart';
import 'package:flame/text.dart';
import 'package:gunwave/data/constants/game/game_button.dart';
import 'package:gunwave/data/constants/game/game_menu_style.dart';
import 'package:gunwave/theme/app_typography.dart';
import 'package:gunwave/views/game/ui/components/asset_button_component.dart';
import 'package:gunwave/views/game/ui/components/asset_panel_component.dart';
import 'package:gunwave/views/rpg_ui/rpg_menu_models.dart';
import 'package:gunwave/views/rpg_ui/scenes/rpg_menu_scene.dart';

/// Compact campaign hub with the current hero and clear primary action.
class HomeHubScene extends RpgMenuScene {
  HomeHubScene({
    required super.snapshot,
    required super.labels,
    required super.actions,
    required super.safeAreaInsets,
    required super.onNavigate,
    this.showBackButton = false,
  });

  final bool showBackButton;

  late final AssetPanelComponent _heroPanel;
  late final AssetPanelComponent _campaignPanel;
  late final TextComponent<SpriteFontRenderer> _title;
  late final TextComponent<SpriteFontRenderer> _heroName;
  late final TextComponent<SpriteFontRenderer> _stageName;
  late final TextComponent<SpriteFontRenderer> _stageNumber;
  late final TextComponent<SpriteFontRenderer> _roundSummary;
  late final TextComponent<SpriteFontRenderer> _goldLabel;
  late final TextComponent<SpriteFontRenderer> _goldValue;
  late final TextComponent<SpriteFontRenderer> _statusPointsLabel;
  late final TextComponent<SpriteFontRenderer> _statusPointsValue;
  late final AssetButtonComponent _continueButton;
  late final AssetButtonComponent _loadoutButton;
  late final AssetButtonComponent _shopButton;
  late final AssetButtonComponent _settingsButton;
  late final AssetButtonComponent? _backButton;
  SpriteAnimationComponent? _heroPreview;

  @override
  Future<void> loadScene() async {
    _heroPanel = addPanel(Vector2.all(1));
    _campaignPanel = addPanel(Vector2.all(1));
    _title = addText(
      labels.campaign,
      fontSize: AppTypography.headlineSmallSize,
      anchor: Anchor.centerLeft,
      light: true,
    );
    _heroName = addText(
      snapshot.selectedHero?.name ??
          (snapshot.isLoading ? labels.loading : labels.noCharacters),
      fontSize: AppTypography.titleMediumSize,
    );
    final stage = snapshot.selectedStage;
    _stageName = addText(
      stage == null
          ? (snapshot.isLoading ? labels.loading : labels.noCampaignStages)
          : _stageNameFor(stage),
      fontSize: AppTypography.titleLargeSize,
    );
    _stageNumber = addText(
      stage == null ? '' : labels.stageNumber(stage.order),
      fontSize: AppTypography.titleMediumSize,
    );
    _roundSummary = addText(
      stage == null
          ? ''
          : '${labels.roundsCount(stage.rounds.length)}  |  ${labels.boss}',
      fontSize: AppTypography.titleMediumSize,
    );
    _goldLabel = addText(
      labels.gold,
      fontSize: AppTypography.titleMediumSize,
      light: true,
    );
    _goldValue = addText(
      snapshot.campaignGold.toString(),
      fontSize: AppTypography.titleMediumSize,
      light: true,
    );
    _statusPointsLabel = addText(
      labels.statusPoints,
      fontSize: AppTypography.titleMediumSize,
      light: true,
    );
    _statusPointsValue = addText(
      snapshot.campaignStatusPoints.toString(),
      fontSize: AppTypography.titleMediumSize,
      light: true,
    );
    _heroPreview = await loadHeroPreview(
      snapshot.selectedHero,
      size: Vector2.all(192),
    );
    _continueButton = await addButton(
      labels.continueCampaign,
      () => onNavigate(RpgMenuPage.campaignMap),
      buttonSize: Vector2(236, 68),
      assetSize: GameButtonSize.large,
    );
    _loadoutButton = await addButton(
      labels.heroLoadout,
      () => onNavigate(RpgMenuPage.heroLoadout),
      buttonSize: Vector2(188, 58),
    );
    _shopButton = await addButton(
      labels.shop,
      () => onNavigate(RpgMenuPage.shop),
      buttonSize: Vector2(156, 58),
    );
    _settingsButton = await addButton(
      labels.settings,
      () => onNavigate(RpgMenuPage.settings),
      buttonSize: Vector2(156, 58),
    );
    _backButton = showBackButton
        ? await addButton(
            labels.back,
            actions.onBack,
            buttonSize: Vector2(136, 54),
            anchor: Anchor.topLeft,
          )
        : null;
  }

  @override
  void layoutScene() {
    // Keep hero art in a 39% column, campaign details in the remaining space,
    // and the main actions below the panels. Currency and settings stay above.
    final bounds = contentBounds;
    final scale = uiScale;
    final cardWidth = math.min(
      bounds.width * GameMenuStyle.homeHubWidthRatio,
      GameMenuStyle.homeHubMaxWidth * scale,
    );
    final cardHeight = math.min(
      bounds.height * GameMenuStyle.homeHubHeightRatio,
      GameMenuStyle.homeHubMaxHeight * scale,
    );
    final left = bounds.center.dx - cardWidth / 2;
    final top = bounds.center.dy - cardHeight / 2;
    final gap = 8 * scale;
    final leftWidth = cardWidth * 0.39;
    final rightWidth = cardWidth - leftWidth - gap;
    final panelTop = top + 36 * scale;
    final heroPanelHeight = cardHeight * GameMenuStyle.homeHubPanelHeightRatio;
    _heroPanel
      ..size = Vector2(leftWidth, heroPanelHeight)
      ..position = Vector2(left, panelTop);
    _campaignPanel
      ..size = Vector2(rightWidth, heroPanelHeight)
      ..position = Vector2(left + leftWidth + gap, panelTop);
    _title.position = Vector2(
      left + (showBackButton ? 160 : 12) * scale,
      bounds.top + 28 * scale,
    );
    _heroName.position = Vector2(
      left + leftWidth / 2,
      panelTop + heroPanelHeight - 18 * scale,
    );
    _stageNumber.position = Vector2(
      left + leftWidth + gap + rightWidth / 2,
      panelTop + heroPanelHeight * 0.25,
    );
    _stageName.position = Vector2(
      left + leftWidth + gap + rightWidth / 2,
      panelTop + heroPanelHeight * 0.49,
    );
    _roundSummary.position = Vector2(
      left + leftWidth + gap + rightWidth / 2,
      panelTop + heroPanelHeight * 0.73,
    );
    final headerY = bounds.top + 28 * scale;
    final counterGap = 8 * scale;
    final sectionGap = 24 * scale;
    final statusWidth =
        _statusPointsLabel.width * _statusPointsLabel.scale.x +
        _statusPointsValue.width * _statusPointsValue.scale.x +
        counterGap;
    final goldWidth =
        _goldLabel.width * _goldLabel.scale.x +
        _goldValue.width * _goldValue.scale.x +
        counterGap;
    final settingsWidth = 136 * scale;
    final settingsCenterX = bounds.right - 12 * scale - settingsWidth / 2;
    final counterLeft =
        _title.position.x + _title.width * _title.scale.x + 16 * scale;
    final counterRight = settingsCenterX - settingsWidth / 2 - 12 * scale;
    final counterGroupWidth = statusWidth + sectionGap + goldWidth;
    final counterGroupLeft =
        (counterLeft + counterRight - counterGroupWidth) / 2;
    _statusPointsLabel.position = Vector2(
      counterGroupLeft +
          _statusPointsLabel.width * _statusPointsLabel.scale.x / 2,
      headerY,
    );
    _statusPointsValue.position = Vector2(
      counterGroupLeft +
          _statusPointsLabel.width * _statusPointsLabel.scale.x +
          counterGap +
          _statusPointsValue.width * _statusPointsValue.scale.x / 2,
      headerY,
    );
    _goldLabel.position = Vector2(
      counterGroupLeft +
          statusWidth +
          sectionGap +
          _goldLabel.width * _goldLabel.scale.x / 2,
      headerY,
    );
    _goldValue.position = Vector2(
      counterGroupLeft +
          statusWidth +
          sectionGap +
          _goldLabel.width * _goldLabel.scale.x +
          counterGap +
          _goldValue.width * _goldValue.scale.x / 2,
      headerY,
    );
    final hero = _heroPreview;
    if (hero != null) {
      hero
        ..size = Vector2.all(
          math.min(
            leftWidth * GameMenuStyle.homeHubHeroWidthRatio,
            heroPanelHeight * GameMenuStyle.homeHubHeroHeightRatio,
          ),
        )
        ..position = Vector2(
          left + leftWidth / 2,
          panelTop + heroPanelHeight * GameMenuStyle.homeHubHeroCenterYRatio,
        );
    }
    final actionY = bounds.bottom - 12 * scale;
    _continueButton
      ..size = Vector2(236 * scale, 68 * scale)
      ..position = Vector2(left + cardWidth * 0.81, actionY)
      ..anchor = Anchor.bottomCenter;
    _loadoutButton
      ..size = Vector2(188 * scale, 58 * scale)
      ..position = Vector2(left + cardWidth * 0.18, actionY)
      ..anchor = Anchor.bottomCenter;
    _shopButton
      ..size = Vector2(156 * scale, 58 * scale)
      ..position = Vector2(left + cardWidth * 0.49, actionY)
      ..anchor = Anchor.bottomCenter;
    _settingsButton
      ..size = Vector2(136 * scale, 52 * scale)
      ..position = Vector2(settingsCenterX, headerY);
    final backButton = _backButton;
    if (backButton != null) {
      backButton
        ..size = Vector2(136 * scale, 54 * scale)
        ..position = Vector2(bounds.left + 12 * scale, bounds.top + 12 * scale);
    }
  }

  String _stageNameFor(stage) =>
      stage.id == 'stage_1' ? labels.forestOutskirts : stage.name;
}
