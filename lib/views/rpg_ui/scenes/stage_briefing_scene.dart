import 'dart:math' as math;

import 'package:flame/components.dart';
import 'package:flame/text.dart';
import 'package:gunwave/data/constants/game/game_button.dart';
import 'package:gunwave/data/constants/game/game_menu_style.dart';
import 'package:gunwave/data/models/campaign_stage_model.dart';
import 'package:gunwave/data/models/reward_model.dart';
import 'package:gunwave/data/models/stage_round_model.dart';
import 'package:gunwave/theme/app_typography.dart';
import 'package:gunwave/views/game/ui/components/asset_button_component.dart';
import 'package:gunwave/views/game/ui/components/asset_panel_component.dart';
import 'package:gunwave/views/rpg_ui/rpg_menu_models.dart';
import 'package:gunwave/views/rpg_ui/scenes/rpg_menu_scene.dart';

/// Stage details with a five-round roadmap separate from campaign stage nodes.
class StageBriefingScene extends RpgMenuScene {
  StageBriefingScene({
    required super.snapshot,
    required super.labels,
    required super.actions,
    required super.safeAreaInsets,
    required super.onNavigate,
  });

  late final AssetPanelComponent _panel;
  late final TextComponent<SpriteFontRenderer> _stageTitle;
  late final TextComponent<SpriteFontRenderer> _stageName;
  late final TextComponent<SpriteFontRenderer> _mapName;
  late final TextComponent<SpriteFontRenderer> _bossName;
  late final TextComponent<SpriteFontRenderer> _rewardsTitle;
  late final List<TextComponent<SpriteFontRenderer>> _rewardLines;
  late final AssetButtonComponent _backButton;
  late final AssetButtonComponent _loadoutButton;
  final List<_RoundMarker> _roundMarkers = [];
  SpriteAnimationComponent? _bossPreview;

  CampaignStageModel? get _stage => snapshot.selectedStage;

  @override
  Future<void> loadScene() async {
    final stage = _stage;
    _panel = addPanel(Vector2.all(1));
    _stageTitle = addText(
      stage == null ? labels.loading : labels.stageNumber(stage.order),
      fontSize: AppTypography.captionSize,
    );
    _stageName = addText(
      stage == null ? '' : _stageNameFor(stage),
      fontSize: AppTypography.titleSize,
    );
    _mapName = addText(
      stage?.mapKey.toUpperCase() ?? '',
      fontSize: AppTypography.bodySmallSize,
    );
    StageRoundModel? bossRound;
    for (final round in stage?.rounds ?? const <StageRoundModel>[]) {
      if (round.isBoss) {
        bossRound = round;
        break;
      }
    }
    String? boss;
    for (final encounter in bossRound?.encounters ?? const []) {
      final enemy = stage?.enemyById(encounter.enemyId);
      if (enemy != null) {
        boss = enemy.name;
        _bossPreview = await loadMonsterPreview(enemy, size: Vector2.all(72));
        break;
      }
    }
    _bossName = addText(
      boss == null ? labels.boss : '${labels.boss}: $boss',
      fontSize: AppTypography.bodySmallSize,
    );
    _rewardsTitle = addText(labels.rewards, fontSize: AppTypography.bodySize);
    _rewardLines = [
      for (final reward in stage?.rewards ?? const <RewardModel>[])
        addText(_rewardLabel(reward), fontSize: AppTypography.bodySmallSize),
    ];
    if (stage != null) {
      for (final round in stage.rounds) {
        final marker = await addButton(
          '${round.number}',
          () {},
          buttonSize: Vector2(68, 68),
          assetSize: round.isBoss
              ? GameButtonSize.large
              : GameButtonSize.medium,
        );
        final detail = addText(
          round.isBoss ? labels.boss : labels.roundNumber(round.number),
          fontSize: AppTypography.captionSize,
        );
        _roundMarkers.add(_RoundMarker(round, marker, detail));
      }
    }
    _backButton = await addButton(
      labels.back,
      () => onNavigate(RpgMenuPage.campaignMap),
      buttonSize: Vector2(156, 58),
    );
    _loadoutButton = await addButton(
      labels.selectHero,
      () => onNavigate(RpgMenuPage.heroLoadout),
      buttonSize: Vector2(212, 64),
      assetSize: GameButtonSize.large,
      enabled: stage != null && snapshot.isStageUnlocked(stage),
    );
  }

  @override
  void layoutScene() {
    // Reserve room around the briefing panel for the map and action buttons.
    final bounds = contentBounds;
    final scale = uiScale;
    final panelWidth = math.min(
      bounds.width * GameMenuStyle.briefingWidthRatio,
      GameMenuStyle.briefingMaxWidth * scale,
    );
    final panelHeight = math.min(
      bounds.height * GameMenuStyle.briefingHeightRatio,
      GameMenuStyle.briefingMaxHeight * scale,
    );
    final left = bounds.center.dx - panelWidth / 2;
    final top = bounds.center.dy - panelHeight / 2;
    _panel
      ..size = Vector2(panelWidth, panelHeight)
      ..position = Vector2(left, top);
    _stageTitle.position = Vector2(bounds.center.dx, top + 24 * scale);
    _stageName.position = Vector2(bounds.center.dx, top + 60 * scale);
    _mapName.position = Vector2(bounds.center.dx, top + 80 * scale);
    final markersTop = top + panelHeight * 0.43;
    final markerCount = _roundMarkers.length;
    final markerGap = math.min(46 * scale, panelWidth * 0.08);
    final markerSize = math.min(68 * scale, 76 * scale);
    final rowWidth = markerCount == 0
        ? 0.0
        : markerCount * markerSize + (markerCount - 1) * markerGap;
    final startX = bounds.center.dx - rowWidth / 2 + markerSize / 2;
    for (var index = 0; index < markerCount; index++) {
      final marker = _roundMarkers[index];
      final x = startX + index * (markerSize + markerGap);
      marker.button
        ..size = Vector2.all(markerSize)
        ..position = Vector2(x, markersTop);
      marker.detail.position = Vector2(x, markersTop + markerSize * 0.78);
    }
    _bossName.position = Vector2(bounds.center.dx, top + panelHeight * 0.68);
    final bossPreview = _bossPreview;
    if (bossPreview != null) {
      bossPreview
        ..size = Vector2.all(64 * scale)
        ..position = Vector2(
          bounds.center.dx - 220 * scale,
          top + panelHeight * 0.68,
        );
    }
    _rewardsTitle.position = Vector2(
      bounds.center.dx,
      top + panelHeight * 0.77,
    );
    final rewardCount = _rewardLines.length;
    for (var index = 0; index < rewardCount; index++) {
      final itemWidth = panelWidth / math.max(1, rewardCount);
      _rewardLines[index].position = Vector2(
        left + itemWidth * (index + 0.5),
        top + panelHeight * 0.86,
      );
    }
    _backButton
      ..size = Vector2(156 * scale, 58 * scale)
      ..position = Vector2(left + 110 * scale, bounds.bottom - 6 * scale)
      ..anchor = Anchor.bottomCenter;
    _loadoutButton
      ..size = Vector2(212 * scale, 64 * scale)
      ..position = Vector2(
        left + panelWidth - 128 * scale,
        bounds.bottom - 6 * scale,
      )
      ..anchor = Anchor.bottomCenter;
  }

  String _rewardLabel(RewardModel reward) => switch (reward.type) {
    RewardType.gold => '${labels.gold}: ${reward.amount}',
    RewardType.sp => '${labels.statusPoints}: ${reward.amount}',
    RewardType.unknown => '${labels.rewards}: ${reward.amount}',
  };

  String _stageNameFor(CampaignStageModel stage) =>
      stage.id == 'stage_1' ? labels.forestOutskirts : stage.name;
}

class _RoundMarker {
  const _RoundMarker(this.round, this.button, this.detail);

  final StageRoundModel round;
  final AssetButtonComponent button;
  final TextComponent<SpriteFontRenderer> detail;
}
