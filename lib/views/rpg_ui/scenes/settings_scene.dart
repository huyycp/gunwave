import 'dart:math' as math;

import 'package:flame/components.dart';
import 'package:flame/text.dart';
import 'package:gunwave/data/constants/game/game_hud_style.dart';
import 'package:gunwave/localization/app_locale_mode.dart';
import 'package:gunwave/views/game/ui/components/asset_button_component.dart';
import 'package:gunwave/views/game/ui/components/asset_panel_component.dart';
import 'package:gunwave/views/rpg_ui/scenes/rpg_menu_scene.dart';

/// Asset-rendered settings scene for the persisted app language preference.
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
  late final AssetButtonComponent _backButton;
  late final List<AssetButtonComponent> _localeButtons;

  @override
  Future<void> loadScene() async {
    _panel = addPanel(Vector2.all(1));
    _title = addText(labels.settings, scale: 1.15);
    _languageLabel = addText(labels.language, scale: 0.8);
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
  }

  @override
  void layoutScene() {
    // Keep the language choices in a centered, narrow panel with room for the
    // landscape back target below the three options.
    final bounds = contentBounds;
    final scale = uiScale;
    final panelWidth = math.min(
      bounds.width - GameHudStyle.edge * 4,
      700 * scale,
    );
    final panelHeight = math.min(
      bounds.height - GameHudStyle.edge * 4,
      460 * scale,
    );
    final left = bounds.center.dx - panelWidth / 2;
    final top = bounds.center.dy - panelHeight / 2;
    _panel
      ..size = Vector2(panelWidth, panelHeight)
      ..position = Vector2(left, top);
    _title.position = Vector2(bounds.center.dx, top + 48 * scale);
    _languageLabel.position = Vector2(bounds.center.dx, top + 128 * scale);
    _backButton
      ..size = Vector2(150 * scale, 56 * scale)
      ..position = Vector2(left + 100 * scale, top + panelHeight - 24 * scale)
      ..anchor = Anchor.bottomCenter;
    final availableHeight = panelHeight - 174 * scale;
    final buttonHeight = math.min(64 * scale, availableHeight / 3);
    for (var index = 0; index < _localeButtons.length; index++) {
      _localeButtons[index]
        ..size = Vector2(
          math.min(232 * scale, panelWidth - 56 * scale),
          buttonHeight,
        )
        ..position = Vector2(
          bounds.center.dx,
          top + (188 + index * 76) * scale,
        );
    }
  }
}
