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

/// Asset-rendered stage outcome. Reward application stays in the host/domain.
class StageResultComponent extends PositionComponent {
  StageResultComponent._({
    required this.isSuccess,
    required this.rewardLines,
    required this.progressMessage,
    required this.onContinue,
    required this.safeAreaInsets,
    required RectangleComponent backdrop,
    required TapShieldComponent inputShield,
    required AssetPanelComponent panel,
    required TextComponent<SpriteFontRenderer> title,
    required TextComponent<SpriteFontRenderer> rewardsHeader,
    required TextComponent<SpriteFontRenderer> progressNote,
    required List<TextComponent<SpriteFontRenderer>> rewardTexts,
    required AssetButtonComponent retryButton,
    required AssetButtonComponent continueButton,
    required AssetButtonComponent campaignButton,
  }) : _backdrop = backdrop,
       _inputShield = inputShield,
       _panel = panel,
       _title = title,
       _rewardsHeader = rewardsHeader,
       _progressNote = progressNote,
       _rewardTexts = rewardTexts,
       _retryButton = retryButton,
       _continueButton = continueButton,
       _campaignButton = campaignButton,
       super(priority: 110) {
    addAll([
      backdrop,
      inputShield,
      panel,
      title,
      rewardsHeader,
      progressNote,
      ...rewardTexts,
      retryButton,
      continueButton,
      campaignButton,
    ]);
  }

  static const double _panelWidth = 520;
  static const double _panelHeight = 332;
  static const double _buttonWidth = 148;
  static const double _buttonHeight = 62;

  final bool isSuccess;
  final List<String> rewardLines;
  final String? progressMessage;
  final VoidCallback? onContinue;
  final EdgeInsets safeAreaInsets;
  final RectangleComponent _backdrop;
  final TapShieldComponent _inputShield;
  final AssetPanelComponent _panel;
  final TextComponent<SpriteFontRenderer> _title;
  final TextComponent<SpriteFontRenderer> _rewardsHeader;
  final TextComponent<SpriteFontRenderer> _progressNote;
  final List<TextComponent<SpriteFontRenderer>> _rewardTexts;
  final AssetButtonComponent _retryButton;
  final AssetButtonComponent _continueButton;
  final AssetButtonComponent _campaignButton;

  bool get canContinue => isSuccess && onContinue != null;

  /// Loads UI sprites and creates the result screen without saving rewards.
  static Future<StageResultComponent> load(
    Images images, {
    required CampaignUiLabels labels,
    required EdgeInsets safeAreaInsets,
    required bool isSuccess,
    required List<String> rewardLines,
    String? progressMessage,
    required VoidCallback onRetry,
    VoidCallback? onContinue,
    required VoidCallback onCampaign,
  }) async {
    final font = await UiBitmapFont.load(images);
    final panelImage = await images.load(
      _cachePath(images, GameUiAssets.panel.path),
    );
    final backdrop = RectangleComponent(
      paint: Paint()..color = const Color(0xC0080C12),
      priority: -1,
    );
    final inputShield = TapShieldComponent(priority: 1);
    final panel = AssetPanelComponent(
      sprite: Sprite(panelImage),
      size: Vector2(_panelWidth, _panelHeight),
    );
    final title = TextComponent<SpriteFontRenderer>(
      text: isSuccess ? labels.completed : labels.failed,
      textRenderer: font,
      anchor: Anchor.center,
    );
    final rewardsHeader = TextComponent<SpriteFontRenderer>(
      text: isSuccess && rewardLines.isNotEmpty ? labels.rewards : '',
      textRenderer: font,
      anchor: Anchor.center,
    );
    final progressNote = TextComponent<SpriteFontRenderer>(
      text: progressMessage ?? '',
      textRenderer: font,
      anchor: Anchor.center,
    );
    final rewardTexts = [
      for (final line in rewardLines)
        TextComponent<SpriteFontRenderer>(
          text: line,
          textRenderer: font,
          anchor: Anchor.center,
        ),
    ];
    final retryButton =
        await AssetButtonComponent.load(
            images,
            buttonSize: GameButtonSize.medium,
            size: Vector2(_buttonWidth, _buttonHeight),
            label: labels.retry,
            labelRenderer: font,
            onPressed: onRetry,
          )
          ..priority = 2;
    final continueButton =
        await AssetButtonComponent.load(
            images,
            buttonSize: GameButtonSize.medium,
            size: Vector2(_buttonWidth, _buttonHeight),
            label: labels.continueCampaign,
            labelRenderer: font,
            onPressed: onContinue,
          )
          ..isVisible = isSuccess && onContinue != null
          ..enabled = isSuccess && onContinue != null
          ..priority = 2;
    final campaignButton =
        await AssetButtonComponent.load(
            images,
            buttonSize: GameButtonSize.medium,
            size: Vector2(_buttonWidth, _buttonHeight),
            label: labels.campaign,
            labelRenderer: font,
            onPressed: onCampaign,
          )
          ..priority = 2;

    return StageResultComponent._(
      isSuccess: isSuccess,
      rewardLines: List.unmodifiable(rewardLines),
      progressMessage: progressMessage,
      onContinue: onContinue,
      safeAreaInsets: safeAreaInsets,
      backdrop: backdrop,
      inputShield: inputShield,
      panel: panel,
      title: title,
      rewardsHeader: rewardsHeader,
      progressNote: progressNote,
      rewardTexts: rewardTexts,
      retryButton: retryButton,
      continueButton: continueButton,
      campaignButton: campaignButton,
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
    _retryButton.responsiveTextScale = scale;
    _continueButton.responsiveTextScale = scale;
    _campaignButton.responsiveTextScale = scale;
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
        panelTop + 54 * scale,
      )
      ..scale.setValues(
        AppTypography.bitmapScale(
          AppTypography.headlineSmallSize,
          responsiveScale: scale,
        ),
        AppTypography.bitmapScale(
          AppTypography.headlineSmallSize,
          responsiveScale: scale,
        ),
      );
    _progressNote
      ..position.setValues(
        (bounds.left + bounds.right) / 2,
        panelTop + 88 * scale,
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

    final hasRewards = isSuccess && rewardLines.isNotEmpty;
    _rewardsHeader
      ..position.setValues(
        (bounds.left + bounds.right) / 2,
        panelTop + 112 * scale,
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
    for (var index = 0; index < _rewardTexts.length; index++) {
      _rewardTexts[index]
        ..position.setValues(
          (bounds.left + bounds.right) / 2,
          panelTop + (142 + index * 23) * scale,
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
    }

    final buttonCount = canContinue ? 3 : 2;
    final gap = 8 * scale;
    final sidePadding = 18 * scale;
    final availableWidth =
        panelWidth - sidePadding * 2 - gap * (buttonCount - 1);
    final buttonWidth = (availableWidth / buttonCount)
        .clamp(0.0, _buttonWidth * scale)
        .toDouble();
    final buttonHeight = _buttonHeight * scale;
    final groupWidth = buttonCount * buttonWidth + (buttonCount - 1) * gap;
    final firstButtonX = (bounds.left + bounds.right - groupWidth) / 2;
    final buttonY = panelTop + panelHeight - buttonHeight - 24 * scale;
    _retryButton
      ..size.setValues(buttonWidth, buttonHeight)
      ..position.setValues(firstButtonX, buttonY);
    _continueButton
      ..size.setValues(buttonWidth, buttonHeight)
      ..position.setValues(firstButtonX + buttonWidth + gap, buttonY);
    _campaignButton
      ..size.setValues(buttonWidth, buttonHeight)
      ..position.setValues(
        firstButtonX + (buttonWidth + gap) * (buttonCount - 1),
        buttonY,
      );

    if (!hasRewards) _rewardsHeader.text = '';
  }
}

String _cachePath(Images images, String assetPath) =>
    assetPath.startsWith(images.prefix)
    ? assetPath.substring(images.prefix.length)
    : assetPath;
