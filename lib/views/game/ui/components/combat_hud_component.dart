import 'dart:math' as math;
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
import 'package:gunwave/views/game/ui/components/asset_progress_bar_component.dart';
import 'package:gunwave/views/game/ui/responsive_ui_layout.dart';

/// Read-only combat values displayed by the campaign HUD.
class CombatHudSnapshot {
  const CombatHudSnapshot({
    required this.playerHealth,
    required this.playerMaxHealth,
    required this.round,
    required this.roundCount,
    required this.abilityAvailable,
    required this.abilityStatus,
    this.bossHealth,
    this.bossMaxHealth,
  });

  final int playerHealth;
  final int playerMaxHealth;
  final int round;
  final int roundCount;
  final bool abilityAvailable;
  final String abilityStatus;
  final int? bossHealth;
  final int? bossMaxHealth;

  bool get hasBoss => bossMaxHealth != null && bossMaxHealth! > 0;
}

/// Asset-rendered campaign combat HUD. It only displays snapshots and forwards
/// player actions to its owner.
class CombatHudComponent extends PositionComponent {
  CombatHudComponent._(
    CampaignUiLabels labels,
    EdgeInsets safeAreaInsets, {
    required AssetPanelComponent healthPanel,
    required AssetPanelComponent roundPanel,
    required AssetPanelComponent bossPanel,
    required AssetPanelComponent noticePanel,
    required TextComponent<SpriteFontRenderer> healthText,
    required AssetProgressBarComponent healthBar,
    required TextComponent<SpriteFontRenderer> roundText,
    required TextComponent<SpriteFontRenderer> bossText,
    required TextComponent<SpriteFontRenderer> noticeText,
    required AssetProgressBarComponent bossBar,
    required AssetButtonComponent pauseButton,
    required AssetButtonComponent abilityButton,
    required TextComponent<SpriteFontRenderer> abilityStatus,
    required TextComponent<SpriteFontRenderer> keyboardGuide,
  }) : _labels = labels,
       _safeAreaInsets = safeAreaInsets,
       _healthPanel = healthPanel,
       _roundPanel = roundPanel,
       _bossPanel = bossPanel,
       _noticePanel = noticePanel,
       _healthText = healthText,
       _healthBar = healthBar,
       _roundText = roundText,
       _bossText = bossText,
       _noticeText = noticeText,
       _bossBar = bossBar,
       _pauseButton = pauseButton,
       _abilityButton = abilityButton,
       _abilityStatus = abilityStatus,
       _keyboardGuide = keyboardGuide,
       super(priority: 20) {
    addAll([
      healthPanel,
      roundPanel,
      bossPanel,
      noticePanel,
      healthText,
      healthBar,
      roundText,
      bossText,
      noticeText,
      bossBar,
      pauseButton,
      abilityButton,
      abilityStatus,
      keyboardGuide,
    ]);
  }

  static const double _healthPanelWidth = 258;
  static const double _healthPanelHeight = 72;
  static const double _roundPanelWidth = 190;
  static const double _roundPanelHeight = 64;
  static const double _bossPanelWidth = 280;
  static const double _bossPanelHeight = 58;
  static const double _noticePanelWidth = 320;
  static const double _noticePanelHeight = 54;
  static const double _noticeDurationSeconds = 4;
  static const double _abilityButtonWidth = 96;
  static const double _abilityButtonHeight = 58;
  static const double _pauseButtonSize = 48;

  final CampaignUiLabels _labels;
  final EdgeInsets _safeAreaInsets;
  final AssetPanelComponent _healthPanel;
  final AssetPanelComponent _roundPanel;
  final AssetPanelComponent _bossPanel;
  final AssetPanelComponent _noticePanel;
  final TextComponent<SpriteFontRenderer> _healthText;
  final AssetProgressBarComponent _healthBar;
  final TextComponent<SpriteFontRenderer> _roundText;
  final TextComponent<SpriteFontRenderer> _bossText;
  final TextComponent<SpriteFontRenderer> _noticeText;
  final AssetProgressBarComponent _bossBar;
  final AssetButtonComponent _pauseButton;
  final AssetButtonComponent _abilityButton;
  final TextComponent<SpriteFontRenderer> _abilityStatus;
  final TextComponent<SpriteFontRenderer> _keyboardGuide;

  /// Loads all local UI art and the bitmap font before adding the HUD.
  static Future<CombatHudComponent> load(
    Images images, {
    required CampaignUiLabels labels,
    required EdgeInsets safeAreaInsets,
    required bool showAbility,
    required bool showKeyboardGuide,
    required VoidCallback onPause,
    required VoidCallback onActivateAbility,
  }) async {
    final font = await UiBitmapFont.load(images);
    final panelSprite = await _loadSprite(images, GameUiAssets.panel.path);
    final frameSprite = await _loadSprite(
      images,
      GameUiAssets.progressFrame.path,
    );
    final backgroundSprite = await _loadSprite(
      images,
      GameUiAssets.progressBackground.path,
    );
    final fillSprite = await _loadSprite(
      images,
      GameUiAssets.progressFill.path,
    );

    final healthPanel = AssetPanelComponent(
      sprite: panelSprite,
      size: Vector2(_healthPanelWidth, _healthPanelHeight),
    );
    final roundPanel = AssetPanelComponent(
      sprite: panelSprite,
      size: Vector2(_roundPanelWidth, _roundPanelHeight),
    );
    final bossPanel = AssetPanelComponent(
      sprite: panelSprite,
      size: Vector2(_bossPanelWidth, _bossPanelHeight),
    )..isVisible = false;
    final noticePanel = AssetPanelComponent(
      sprite: panelSprite,
      size: Vector2(_noticePanelWidth, _noticePanelHeight),
    )..isVisible = false;
    final healthText = TextComponent<SpriteFontRenderer>(
      text: labels.health,
      textRenderer: font,
    );
    final healthBar = AssetProgressBarComponent(
      frameSprite: frameSprite,
      backgroundSprite: backgroundSprite,
      fillSprite: fillSprite,
      size: Vector2(_healthPanelWidth - 28, 20),
    );
    final roundText = TextComponent<SpriteFontRenderer>(
      text: labels.roundProgress(1, 1),
      textRenderer: font,
    );
    final bossText = TextComponent<SpriteFontRenderer>(
      text: '',
      textRenderer: font,
    );
    final noticeText = TextComponent<SpriteFontRenderer>(
      text: '',
      textRenderer: font,
      anchor: Anchor.center,
    );
    final bossBar = AssetProgressBarComponent(
      frameSprite: frameSprite,
      backgroundSprite: backgroundSprite,
      fillSprite: fillSprite,
      size: Vector2(_bossPanelWidth - 28, 17),
    );
    final pauseButton = await AssetButtonComponent.load(
      images,
      buttonSize: GameButtonSize.small,
      size: Vector2(_pauseButtonSize, _pauseButtonSize),
      label: '||',
      labelRenderer: font,
      onPressed: onPause,
    );
    final abilityButton =
        await AssetButtonComponent.load(
            images,
            buttonSize: GameButtonSize.medium,
            size: Vector2(_abilityButtonWidth, _abilityButtonHeight),
            label: labels.specialAbility,
            labelRenderer: font,
            onPressed: onActivateAbility,
          )
          ..isVisible = showAbility
          ..enabled = showAbility;
    final abilityStatus = TextComponent<SpriteFontRenderer>(
      text: showAbility ? labels.ready : '',
      textRenderer: font,
      anchor: Anchor.bottomCenter,
    );
    final keyboardGuide = TextComponent<SpriteFontRenderer>(
      text: showKeyboardGuide
          ? showAbility
                ? labels.keyboardAbilityGuide
                : labels.keyboardGuide
          : '',
      textRenderer: font,
      anchor: Anchor.center,
    );

    return CombatHudComponent._(
      labels,
      safeAreaInsets,
      healthPanel: healthPanel,
      roundPanel: roundPanel,
      bossPanel: bossPanel,
      noticePanel: noticePanel,
      healthText: healthText,
      healthBar: healthBar,
      roundText: roundText,
      bossText: bossText,
      noticeText: noticeText,
      bossBar: bossBar,
      pauseButton: pauseButton,
      abilityButton: abilityButton,
      abilityStatus: abilityStatus,
      keyboardGuide: keyboardGuide,
    );
  }

  CombatHudSnapshot? _snapshot;
  double _noticeRemaining = 0;

  /// Shows a short localized game notice in the Flame HUD.
  void showNotice(String message) {
    _noticeText.text = message;
    _noticeRemaining = _noticeDurationSeconds;
    _noticePanel.isVisible = message.isNotEmpty;
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (!_noticePanel.isVisible || !dt.isFinite || dt <= 0) return;
    _noticeRemaining = math.max(0, _noticeRemaining - dt).toDouble();
    if (_noticeRemaining == 0) {
      _noticePanel.isVisible = false;
      _noticeText.text = '';
    }
  }

  /// Applies current combat values without owning or mutating game state.
  void updateSnapshot(CombatHudSnapshot snapshot) {
    _snapshot = snapshot;
    _healthText.text =
        '${_labels.health} ${snapshot.playerHealth}/${snapshot.playerMaxHealth}';
    _healthBar.value = snapshot.playerMaxHealth <= 0
        ? 0
        : snapshot.playerHealth / snapshot.playerMaxHealth;
    _roundText.text = _labels.roundProgress(
      snapshot.round,
      snapshot.roundCount,
    );
    _bossPanel.isVisible = snapshot.hasBoss;
    _bossBar.isVisible = snapshot.hasBoss;
    if (snapshot.hasBoss) {
      _bossText.text = _labels.boss;
      _bossBar.value = snapshot.bossHealth! / snapshot.bossMaxHealth!;
    } else {
      _bossText.text = '';
    }
    _abilityButton.enabled = snapshot.abilityAvailable;
    _abilityStatus.text = _abilityButton.isVisible
        ? snapshot.abilityStatus
        : '';
  }

  CombatHudSnapshot? get snapshot => _snapshot;

  @override
  void onGameResize(Vector2 size) {
    super.onGameResize(size);
    this.size = size;
    _layout(size);
  }

  void _layout(Vector2 gameSize) {
    final layout = ResponsiveUiLayout(
      viewportSize: gameSize,
      safeAreaInsets: _safeAreaInsets,
    );
    final bounds = layout.contentBounds;
    const requiredWidth =
        _healthPanelWidth +
        _roundPanelWidth +
        GameHudStyle.gap +
        GameHudStyle.edge * 2;
    final widthScale = bounds.width / requiredWidth;
    final scale = math.min(layout.scale, widthScale);
    _pauseButton.responsiveTextScale = scale;
    _abilityButton.responsiveTextScale = scale;
    final edge = GameHudStyle.edge * scale;
    final top = bounds.top + edge;
    final left = bounds.left + edge;
    final right = bounds.right - edge;

    _healthPanel
      ..size.setValues(_healthPanelWidth * scale, _healthPanelHeight * scale)
      ..position.setValues(left, top);
    _healthText
      ..position.setValues(left + 12 * scale, top + 8 * scale)
      ..scale.setValues(
        AppTypography.bitmapScale(
          AppTypography.bodyMediumSize,
          responsiveScale: scale,
        ),
        AppTypography.bitmapScale(
          AppTypography.bodyMediumSize,
          responsiveScale: scale,
        ),
      );
    _healthBar
      ..size.setValues((_healthPanelWidth - 28) * scale, 20 * scale)
      ..position.setValues(left + 14 * scale, top + 42 * scale);

    final roundWidth = _roundPanelWidth * scale;
    _roundPanel
      ..size.setValues(roundWidth, _roundPanelHeight * scale)
      ..position.setValues(right - roundWidth, top);
    _roundText
      ..position.setValues(right - roundWidth + 12 * scale, top + 22 * scale)
      ..scale.setValues(
        AppTypography.bitmapScale(
          AppTypography.bodyMediumSize,
          responsiveScale: scale,
        ),
        AppTypography.bitmapScale(
          AppTypography.bodyMediumSize,
          responsiveScale: scale,
        ),
      );
    _pauseButton
      ..size = Vector2(_pauseButtonSize * scale, _pauseButtonSize * scale)
      ..position.setValues(
        right - _pauseButtonSize * scale - 7 * scale,
        top + 8 * scale,
      );

    final bossWidth = _bossPanelWidth * scale;
    final bossTop = top + _healthPanelHeight * scale + 5 * scale;
    _bossPanel
      ..size.setValues(bossWidth, _bossPanelHeight * scale)
      ..position.setValues((gameSize.x - bossWidth) / 2, bossTop);
    _bossText
      ..position.setValues(
        (gameSize.x - bossWidth) / 2 + 12 * scale,
        bossTop + 5 * scale,
      )
      ..scale.setValues(
        AppTypography.bitmapScale(
          AppTypography.bodyMediumSize,
          responsiveScale: scale,
        ),
        AppTypography.bitmapScale(
          AppTypography.bodyMediumSize,
          responsiveScale: scale,
        ),
      );
    _bossBar
      ..size.setValues((_bossPanelWidth - 28) * scale, 17 * scale)
      ..position.setValues(
        (gameSize.x - bossWidth) / 2 + 14 * scale,
        bossTop + 31 * scale,
      );

    final noticeWidth = math.min(
      _noticePanelWidth * scale,
      bounds.width - edge * 2,
    );
    final noticeLeft = (bounds.left + bounds.right - noticeWidth) / 2;
    final noticeTop = top + _healthPanelHeight * scale + 5 * scale;
    _noticePanel
      ..size.setValues(noticeWidth, _noticePanelHeight * scale)
      ..position.setValues(noticeLeft, noticeTop);
    _noticeText
      ..position.setValues(
        noticeLeft + noticeWidth / 2,
        noticeTop + _noticePanelHeight * scale / 2,
      )
      ..scale.setValues(
        AppTypography.bitmapScale(
          AppTypography.bodyLargeSize,
          responsiveScale: scale,
        ),
        AppTypography.bitmapScale(
          AppTypography.bodyLargeSize,
          responsiveScale: scale,
        ),
      );

    final abilityWidth = _abilityButtonWidth * scale;
    final abilityHeight = _abilityButtonHeight * scale;
    final abilityX =
        bounds.right - GameHudStyle.touchEdge * scale - abilityWidth;
    final abilityY =
        bounds.bottom -
        (GameHudStyle.touchEdge +
                GameHudStyle.touchAttackSize +
                GameHudStyle.touchControlGap) *
            scale -
        abilityHeight;
    _abilityButton
      ..size = Vector2(abilityWidth, abilityHeight)
      ..position.setValues(abilityX, abilityY);
    _abilityStatus
      ..position.setValues(abilityX + abilityWidth / 2, abilityY - 4 * scale)
      ..scale.setValues(
        AppTypography.bitmapScale(
          AppTypography.labelMediumSize,
          responsiveScale: scale,
        ),
        AppTypography.bitmapScale(
          AppTypography.labelMediumSize,
          responsiveScale: scale,
        ),
      );
    _keyboardGuide
      ..position.setValues(
        (bounds.left + bounds.right) / 2,
        bounds.bottom - 22 * scale,
      )
      ..scale.setValues(
        AppTypography.bitmapScale(
          AppTypography.labelMediumSize,
          responsiveScale: scale,
        ),
        AppTypography.bitmapScale(
          AppTypography.labelMediumSize,
          responsiveScale: scale,
        ),
      );
  }

  static Future<Sprite> _loadSprite(Images images, String path) async {
    final cachePath = path.startsWith(images.prefix)
        ? path.substring(images.prefix.length)
        : path;
    return Sprite(await images.load(cachePath));
  }
}
