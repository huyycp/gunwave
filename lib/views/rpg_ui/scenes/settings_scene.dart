import 'dart:math' as math;

import 'package:flame/components.dart';
import 'package:flame/text.dart';
import 'package:gunwave/data/constants/game/game_hud_style.dart';
import 'package:gunwave/data/constants/game/game_play_mode.dart';
import 'package:gunwave/localization/app_locale_mode.dart';
import 'package:gunwave/theme/app_typography.dart';
import 'package:gunwave/views/game/ui/components/asset_button_component.dart';
import 'package:gunwave/views/game/ui/components/asset_panel_component.dart';
import 'package:gunwave/views/rpg_ui/scenes/rpg_menu_scene.dart';

/// Asset-rendered settings scene for language and game input preferences.
class SettingsScene extends RpgMenuScene {
  SettingsScene({
    required super.snapshot,
    required super.labels,
    required super.actions,
    required super.safeAreaInsets,
    required super.onNavigate,
  });

  late final AssetPanelComponent _panel;
  late final TextComponent<SpriteFontRenderer> _title;
  late final TextComponent<SpriteFontRenderer> _languageLabel;
  late final TextComponent<SpriteFontRenderer> _gameControlsLabel;
  late final AssetButtonComponent _backButton;
  late final List<AssetButtonComponent> _localeButtons;
  late final List<AssetButtonComponent> _playModeButtons;

  @override
  Future<void> loadScene() async {
    _panel = addPanel(Vector2.all(1));
    _title = addText(labels.settings, fontSize: AppTypography.rpgTitleSize);
    _languageLabel = addText(
      labels.language,
      fontSize: AppTypography.rpgBodySize,
    );
    _gameControlsLabel = addText(
      labels.gameControls,
      fontSize: AppTypography.rpgBodySize,
    );
    _backButton = await addButton(
      labels.back,
      actions.onBack,
      buttonSize: Vector2(150, 56),
    );
    final modes = [
      (AppLocaleMode.system, labels.deviceLanguage),
      (AppLocaleMode.english, labels.english),
      (AppLocaleMode.vietnamese, labels.vietnamese),
    ];
    _localeButtons = [
      for (final (mode, title) in modes)
        await addButton(
          title,
          () => actions.onSelectLocale(mode),
          buttonSize: Vector2(232, 64),
          enabled: snapshot.localeMode != mode,
        ),
    ];
    final playModes = [
      (GamePlayMode.joystick, labels.joystick),
      (GamePlayMode.keyboard, labels.keyboard),
      (GamePlayMode.gesture, labels.gesture),
    ];
    _playModeButtons = [
      for (final (mode, title) in playModes)
        await addButton(
          snapshot.selectedPlayMode == mode ? '[x] $title' : title,
          () => actions.onSelectPlayMode(mode),
          buttonSize: Vector2(200, 56),
        ),
    ];
  }

  @override
  void layoutScene() {
    // Keep both preference rows and the back target visible at compact sizes.
    final bounds = contentBounds;
    final scale = uiScale;
    final panelWidth = math.min(
      bounds.width - GameHudStyle.edge * 4,
      1200 * scale,
    );
    final panelHeight = math.min(
      bounds.height - GameHudStyle.edge * 4,
      700 * scale,
    );
    final left = bounds.center.dx - panelWidth / 2;
    final top = bounds.center.dy - panelHeight / 2;
    _panel
      ..size = Vector2(panelWidth, panelHeight)
      ..position = Vector2(left, top);
    _title.position = Vector2(bounds.center.dx, top + panelHeight * 0.1);
    _languageLabel.position = Vector2(
      bounds.center.dx,
      top + panelHeight * 0.22,
    );
    _gameControlsLabel.position = Vector2(
      bounds.center.dx,
      top + panelHeight * 0.54,
    );
    _backButton
      ..size = Vector2(150 * scale, 56 * scale)
      ..position = Vector2(bounds.center.dx, top + panelHeight - 20 * scale)
      ..anchor = Anchor.bottomCenter;
    const buttonGap = 8.0;
    final buttonWidth = math.min(
      200 * scale,
      (panelWidth - 32 * scale - buttonGap * 2) / 3,
    );
    final buttonHeight = math.min(56 * scale, panelHeight * 0.14);
    _layoutButtonRow(
      _localeButtons,
      centerX: bounds.center.dx,
      y: top + panelHeight * 0.34,
      width: buttonWidth,
      height: buttonHeight,
      gap: buttonGap,
    );
    _layoutButtonRow(
      _playModeButtons,
      centerX: bounds.center.dx,
      y: top + panelHeight * 0.66,
      width: buttonWidth,
      height: buttonHeight,
      gap: buttonGap,
    );
  }

  void _layoutButtonRow(
    List<AssetButtonComponent> buttons, {
    required double centerX,
    required double y,
    required double width,
    required double height,
    required double gap,
  }) {
    for (var index = 0; index < buttons.length; index++) {
      buttons[index]
        ..size = Vector2(width, height)
        ..position = Vector2(
          centerX + (index - (buttons.length - 1) / 2) * (width + gap),
          y,
        );
    }
  }
}
