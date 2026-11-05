import 'dart:ui';

import 'package:flame/cache.dart';
import 'package:flame/components.dart';
import 'package:flame/text.dart';
import 'package:flutter/painting.dart' show EdgeInsets;
import 'package:gunwave/data/constants/game/game_button.dart';
import 'package:gunwave/data/constants/game/game_hud_style.dart';
import 'package:gunwave/data/constants/game/game_ui.dart';
import 'package:gunwave/theme/app_typography.dart';
import 'package:gunwave/views/game/ui/bitmap_font.dart';
import 'package:gunwave/views/game/ui/campaign_ui_labels.dart';
import 'package:gunwave/views/game/ui/components/asset_button_component.dart';
import 'package:gunwave/views/game/ui/components/asset_panel_component.dart';
import 'package:gunwave/views/game/ui/components/tap_shield_component.dart';
import 'package:gunwave/views/game/ui/responsive_ui_layout.dart';

/// Asset-rendered pause and exit-confirmation screen for solo campaign runs.
class PauseMenuComponent extends PositionComponent {
  PauseMenuComponent._({
    required this.safeAreaInsets,
    required RectangleComponent backdrop,
    required TapShieldComponent inputShield,
    required AssetPanelComponent panel,
    required TextComponent<SpriteFontRenderer> title,
    required TextComponent<SpriteFontRenderer> confirmation,
    required AssetButtonComponent resumeButton,
    required AssetButtonComponent exitButton,
  }) : _backdrop = backdrop,
       _inputShield = inputShield,
       _panel = panel,
       _title = title,
       _confirmation = confirmation,
       _resumeButton = resumeButton,
       _exitButton = exitButton,
       super(priority: 100) {
    addAll([
      backdrop,
      inputShield,
      panel,
      title,
      confirmation,
      resumeButton,
      exitButton,
    ]);
  }

  static const double _panelWidth = 440;
  static const double _panelHeight = 250;

  final EdgeInsets safeAreaInsets;
  final RectangleComponent _backdrop;
  final TapShieldComponent _inputShield;
  final AssetPanelComponent _panel;
  final TextComponent<SpriteFontRenderer> _title;
  final TextComponent<SpriteFontRenderer> _confirmation;
  final AssetButtonComponent _resumeButton;
  final AssetButtonComponent _exitButton;

  /// Loads panel art, button states, and bitmap text before mounting the menu.
  static Future<PauseMenuComponent> load(
    Images images, {
    required CampaignUiLabels labels,
    required EdgeInsets safeAreaInsets,
    required VoidCallback onResume,
    required VoidCallback onExitConfirmed,
  }) async {
    final font = await UiBitmapFont.load(images);
    final panelImage = await images.load(
      _cachePath(images, GameUiAssets.panel.path),
    );
    final backdrop = RectangleComponent(
      paint: Paint()..color = const Color(0xAA080C12),
      priority: -1,
    );
    final inputShield = TapShieldComponent(priority: 1);
    final panel = AssetPanelComponent(
      sprite: Sprite(panelImage),
      size: Vector2(_panelWidth, _panelHeight),
    );
    final title = TextComponent<SpriteFontRenderer>(
      text: labels.paused,
      textRenderer: font,
      anchor: Anchor.center,
    );
    final confirmation = TextComponent<SpriteFontRenderer>(
      text: labels.exitConfirmation,
      textRenderer: font,
      anchor: Anchor.center,
    );
    final resumeButton =
        await AssetButtonComponent.load(
            images,
            buttonSize: GameButtonSize.medium,
            size: Vector2(176, 64),
            label: labels.resume,
            labelRenderer: font,
            onPressed: onResume,
          )
          ..priority = 2;
    final exitButton =
        await AssetButtonComponent.load(
            images,
            buttonSize: GameButtonSize.medium,
            size: Vector2(176, 64),
            label: labels.exitStage,
            labelRenderer: font,
            onPressed: onExitConfirmed,
          )
          ..priority = 2;

    return PauseMenuComponent._(
      safeAreaInsets: safeAreaInsets,
      backdrop: backdrop,
      inputShield: inputShield,
      panel: panel,
      title: title,
      confirmation: confirmation,
      resumeButton: resumeButton,
      exitButton: exitButton,
    );
  }

  @override
  void onGameResize(Vector2 size) {
    super.onGameResize(size);
    this.size = size;
    final layout = ResponsiveUiLayout(
      viewportSize: size,
      safeAreaInsets: safeAreaInsets,
    );
    final bounds = layout.contentBounds;
    final scale = layout.scale;
    final panelWidth = (bounds.width - GameHudStyle.edge * 4)
        .clamp(0.0, _panelWidth * scale)
        .toDouble();
    final panelHeight = _panelHeight * scale;
    final panelLeft = bounds.left + (bounds.width - panelWidth) / 2;
    final panelTop = bounds.top + (bounds.height - panelHeight) / 2;
    _backdrop.size = size;
    _inputShield.size = size;
    _panel
      ..size.setValues(panelWidth, panelHeight)
      ..position.setValues(panelLeft, panelTop);
    _title
      ..position.setValues(
        (bounds.left + bounds.right) / 2,
        panelTop + 58 * scale,
      )
      ..scale.setValues(
        AppTypography.bitmapScale(
          AppTypography.titleSize,
          responsiveScale: scale,
        ),
        AppTypography.bitmapScale(
          AppTypography.titleSize,
          responsiveScale: scale,
        ),
      );
    _confirmation
      ..position.setValues(
        (bounds.left + bounds.right) / 2,
        panelTop + 112 * scale,
      )
      ..scale.setValues(
        AppTypography.bitmapScale(
          AppTypography.bodySize,
          responsiveScale: scale,
        ),
        AppTypography.bitmapScale(
          AppTypography.bodySize,
          responsiveScale: scale,
        ),
      );
    final buttonWidth = (panelWidth - 54 * scale) / 2;
    final buttonHeight = 60 * scale;
    final buttonY = panelTop + panelHeight - buttonHeight - 24 * scale;
    _resumeButton
      ..size.setValues(buttonWidth, buttonHeight)
      ..position.setValues(panelLeft + 18 * scale, buttonY);
    _exitButton
      ..size.setValues(buttonWidth, buttonHeight)
      ..position.setValues(
        panelLeft + panelWidth - buttonWidth - 18 * scale,
        buttonY,
      );
  }
}

String _cachePath(Images images, String assetPath) =>
    assetPath.startsWith(images.prefix)
    ? assetPath.substring(images.prefix.length)
    : assetPath;
