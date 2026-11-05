import 'dart:math' as math;

import 'package:flame/components.dart';
import 'package:flame/text.dart';
import 'package:gunwave/data/constants/game/game_button.dart';
import 'package:gunwave/data/constants/game/game_menu_style.dart';
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
    _title = addText(labels.campaign, scale: 1.35);
    _heroName = addText(
      snapshot.selectedHero?.name ??
          (snapshot.isLoading ? labels.loading : labels.noCharacters),
      scale: 0.9,
    );
    final stage = snapshot.selectedStage;
    _stageName = addText(
      stage == null
          ? (snapshot.isLoading ? labels.loading : labels.noCampaignStages)
          : _stageNameFor(stage),
      scale: 0.95,
    );
    _stageNumber = addText(
      stage == null ? '' : labels.stageNumber(stage.order),
      scale: 0.75,
    );
    _roundSummary = addText(
      stage == null
          ? ''
          : '${labels.roundsCount(stage.rounds.length)}  |  ${labels.boss}',
      scale: 0.75,
    );
    _goldLabel = addText(labels.gold, scale: 0.65);
    _goldValue = addText(snapshot.campaignGold.toString(), scale: 0.8);
    _statusPointsLabel = addText(labels.statusPoints, scale: 0.55);
    _statusPointsValue = addText(
      snapshot.campaignStatusPoints.toString(),
      scale: 0.8,
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
    final gap = 16 * scale;
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
    _title.position = Vector2(left + 12 * scale, top + 20 * scale);
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
    _goldLabel.position = Vector2(
      bounds.right - 190 * scale,
      bounds.top + 28 * scale,
    );
    _goldValue.position = Vector2(
      bounds.right - 116 * scale,
      bounds.top + 28 * scale,
    );
    _statusPointsLabel.position = Vector2(
      bounds.right - 364 * scale,
      bounds.top + 28 * scale,
    );
    _statusPointsValue.position = Vector2(
      bounds.right - 280 * scale,
      bounds.top + 28 * scale,
    );
    final hero = _heroPreview;
    if (hero != null) {
      hero
        ..size = Vector2.all(math.min(leftWidth * 0.58, heroPanelHeight * 0.56))
        ..position = Vector2(
          left + leftWidth / 2,
          panelTop + heroPanelHeight * 0.5,
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
      ..position = Vector2(
        bounds.right - 72 * scale,
        bounds.top + 12 * scale + 26 * scale,
      );
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
