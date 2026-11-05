import 'dart:math' as math;
import 'dart:ui' show Rect;

import 'package:flame/components.dart';
import 'package:flame/text.dart';
import 'package:gunwave/data/constants/game/game_button.dart';
import 'package:gunwave/data/constants/game/game_hud_style.dart';
import 'package:gunwave/data/constants/game/game_ui.dart';
import 'package:gunwave/data/models/campaign_stage_model.dart';
import 'package:gunwave/theme/app_typography.dart';
import 'package:gunwave/views/game/ui/components/asset_button_component.dart';
import 'package:gunwave/views/game/ui/components/asset_panel_component.dart';
import 'package:gunwave/views/rpg_ui/rpg_menu_models.dart';
import 'package:gunwave/views/rpg_ui/scenes/rpg_menu_scene.dart';

/// Stage selection map; each node represents a complete map/stage, not a round.
class CampaignMapScene extends RpgMenuScene {
  CampaignMapScene({
    required super.snapshot,
    required super.labels,
    required super.actions,
    required super.safeAreaInsets,
    required super.onNavigate,
  });

  late final AssetPanelComponent _headerPanel;
  late final TextComponent<SpriteFontRenderer> _title;
  late final AssetButtonComponent _backButton;
  final List<_StageNode> _nodes = [];
  final List<_StageConnection> _connections = [];
  late TextComponent<SpriteFontRenderer> _emptyText;

  @override
  Future<void> loadScene() async {
    _headerPanel = addPanel(Vector2.all(1));
    _title = addText(labels.campaign, fontSize: AppTypography.rpgTitleSize);
    _backButton = await addButton(
      labels.back,
      actions.onBack,
      buttonSize: Vector2(150, 58),
      anchor: Anchor.topLeft,
    );
    _emptyText = addText(
      labels.loading,
      fontSize: AppTypography.rpgBodySize,
      light: true,
    );

    for (final stage in snapshot.stages) {
      final labelPanel = addPanel(Vector2.all(1));
      final button = await addButton(
        '${stage.order}',
        () {
          actions.onSelectStage(stage.id);
          onNavigate(RpgMenuPage.stageBriefing);
        },
        buttonSize: Vector2(92, 92),
        assetSize: GameButtonSize.large,
        enabled: snapshot.isStageUnlocked(stage),
      );
      final title = addText(
        labels.stageNumber(stage.order),
        fontSize: AppTypography.rpgBodySmallSize,
      );
      final status = addText(
        _stageStatus(stage),
        fontSize: AppTypography.rpgCaptionSize,
      );
      _nodes.add(_StageNode(stage, button, title, status, labelPanel));
    }
    if (_nodes.length > 1) {
      final image = await game.images.load(GameUiAssets.stageRoutePointer.path);
      for (var index = 0; index < _nodes.length - 1; index++) {
        final component = SpriteComponent(
          sprite: Sprite(image),
          size: Vector2.all(28),
          anchor: Anchor.center,
          priority: -20,
        );
        add(component);
        _connections.add(_StageConnection(index, component));
      }
    }
    _emptyText.text = snapshot.stages.isEmpty && !snapshot.isLoading
        ? labels.noCampaignStages
        : '';
  }

  @override
  void layoutScene() {
    // Alternate stage nodes by 12% of the viewport so the route stays visible
    // between the map artwork and each node's status label.
    final bounds = contentBounds;
    final scale = uiScale;
    final headerWidth = math.min(
      bounds.width - GameHudStyle.edge * 2,
      1200 * scale,
    );
    _headerPanel
      ..size = Vector2(headerWidth, 72 * scale)
      ..position = Vector2(
        bounds.center.dx - headerWidth / 2,
        bounds.top + 12 * scale,
      );
    _title.position = Vector2(bounds.center.dx, bounds.top + 48 * scale);
    _backButton
      ..size = Vector2(150 * scale, 58 * scale)
      ..position = Vector2(bounds.left + 12 * scale, bounds.top + 12 * scale);
    final nodeCount = _nodes.length;
    final labelWidth = math.min(
      nodeCount > 1
          ? math.min(
              148 * scale,
              (bounds.width - 136 * scale) / (nodeCount - 1) * 0.92,
            )
          : 180 * scale,
      bounds.width * 0.35,
    );
    final horizontalInset = math.max(68 * scale, labelWidth / 2 + 8 * scale);
    final usableWidth = math.max(0.0, bounds.width - horizontalInset * 2);
    for (var index = 0; index < nodeCount; index++) {
      final node = _nodes[index];
      final point = _stagePosition(index, nodeCount, bounds, usableWidth);
      node.button
        ..size = Vector2(92 * scale, 92 * scale)
        ..position = point;
      node.labelPanel
        ..size = Vector2(labelWidth, 56 * scale)
        ..position = Vector2(point.x - labelWidth / 2, point.y + 56 * scale);
      node.title.position = Vector2(point.x, point.y + 72 * scale);
      node.status.position = Vector2(point.x, point.y + 102 * scale);
    }
    for (final connection in _connections) {
      final start = _stagePosition(
        connection.startIndex,
        nodeCount,
        bounds,
        usableWidth,
      );
      final end = _stagePosition(
        connection.startIndex + 1,
        nodeCount,
        bounds,
        usableWidth,
      );
      connection.component
        ..position = (start + end) / 2
        ..angle = math.atan2(end.y - start.y, end.x - start.x);
    }
    _emptyText.position = Vector2(bounds.center.dx, bounds.center.dy);
  }

  Vector2 _stagePosition(
    int index,
    int count,
    Rect bounds,
    double usableWidth,
  ) {
    final inset = (bounds.width - usableWidth) / 2;
    final x = count == 1
        ? bounds.center.dx
        : bounds.left + inset + usableWidth * index / (count - 1);
    final sway = index.isEven ? -0.12 : 0.12;
    return Vector2(x, bounds.center.dy + bounds.height * sway);
  }

  String _stageStatus(CampaignStageModel stage) {
    if (snapshot.isStageCleared(stage)) return labels.cleared;
    if (snapshot.isStageUnlocked(stage)) return labels.available;
    return labels.locked;
  }
}

class _StageNode {
  const _StageNode(
    this.stage,
    this.button,
    this.title,
    this.status,
    this.labelPanel,
  );

  final CampaignStageModel stage;
  final AssetButtonComponent button;
  final TextComponent<SpriteFontRenderer> title;
  final TextComponent<SpriteFontRenderer> status;
  final AssetPanelComponent labelPanel;
}

class _StageConnection {
  const _StageConnection(this.startIndex, this.component);

  final int startIndex;
  final SpriteComponent component;
}
