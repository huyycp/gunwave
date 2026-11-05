import 'dart:math' as math;

import 'package:flame/components.dart';
import 'package:flame/text.dart';
import 'package:gunwave/data/constants/game/game_menu_style.dart';
import 'package:gunwave/data/data_sources/local/campaign_hero_catalog.dart';
import 'package:gunwave/data/models/character_model.dart';
import 'package:gunwave/theme/app_typography.dart';
import 'package:gunwave/views/game/ui/components/asset_button_component.dart';
import 'package:gunwave/views/game/ui/components/asset_panel_component.dart';
import 'package:gunwave/views/rpg_ui/scenes/rpg_menu_scene.dart';

/// Asset-rendered hero shop; purchase rules remain in the host view model.
class ShopScene extends RpgMenuScene {
  ShopScene({
    required super.snapshot,
    required super.labels,
    required super.actions,
    required super.safeAreaInsets,
    required super.onNavigate,
  });

  late final AssetPanelComponent _panel;
  late final TextComponent<SpriteFontRenderer> _title;
  late final TextComponent<SpriteFontRenderer> _balance;
  late final TextComponent<SpriteFontRenderer> _emptyText;
  TextComponent<SpriteFontRenderer>? _statusText;
  late final AssetButtonComponent _backButton;
  late final List<_ShopCard> _cards;

  @override
  Future<void> loadScene() async {
    _panel = addPanel(Vector2.all(1));
    _title = addText(labels.shop, fontSize: AppTypography.titleSize);
    _balance = addText(
      '${labels.gold}: ${snapshot.gold}',
      fontSize: AppTypography.bodySmallSize,
    );
    _emptyText = addText(_emptyMessage, fontSize: AppTypography.bodySize);
    final status = snapshot.isLoading
        ? labels.loading
        : !snapshot.isAccountSignedIn
        ? labels.signInToShop
        : snapshot.shopDataUnavailable
        ? labels.shopUnavailable
        : null;
    if (status != null) {
      _statusText = addText(status, fontSize: AppTypography.captionSize);
    }
    _backButton = await addButton(
      labels.back,
      actions.onBack,
      buttonSize: Vector2(150, 56),
    );
    _cards = [];
    for (final character in snapshot.shopHeroes.take(8)) {
      final panel = addPanel(Vector2.all(1));
      final preview = await loadHeroPreview(character, size: Vector2.all(92));
      final name = addText(
        character.name,
        fontSize: AppTypography.bodySmallSize,
      );
      final isOwned = snapshot.ownedHeroes.any(
        (hero) =>
            hero.id == character.id ||
            (hero.id == CampaignHeroCatalog.starter.id &&
                character.filename == CampaignHeroCatalog.starter.filename),
      );
      final button = await addButton(
        isOwned ? labels.owned : '${character.price}',
        () => actions.onPurchase(character),
        buttonSize: Vector2(142, 48),
        enabled:
            snapshot.isAccountSignedIn &&
            !isOwned &&
            snapshot.gold >= character.price,
      );
      _cards.add(_ShopCard(character, panel, preview, name, button));
    }
  }

  @override
  void layoutScene() {
    // Four columns and two rows keep the hero, name, and action distinct on
    // compact landscape screens.
    final bounds = contentBounds;
    final scale = uiScale;
    final panelWidth = math.min(
      bounds.width * GameMenuStyle.shopWidthRatio,
      GameMenuStyle.shopMaxWidth * scale,
    );
    final panelHeight = math.min(
      bounds.height * GameMenuStyle.shopHeightRatio,
      GameMenuStyle.shopMaxHeight * scale,
    );
    final left = bounds.center.dx - panelWidth / 2;
    final top = bounds.center.dy - panelHeight / 2;
    _panel
      ..size = Vector2(panelWidth, panelHeight)
      ..position = Vector2(left, top);
    _title.position = Vector2(bounds.center.dx, top + 34 * scale);
    _balance.position = Vector2(
      left + panelWidth - 104 * scale,
      top + 34 * scale,
    );
    _backButton
      ..size = Vector2(150 * scale, 56 * scale)
      ..position = Vector2(left + 90 * scale, top + 34 * scale);
    final columns = math.min(4, math.max(1, _cards.length));
    final rows = (_cards.length / columns).ceil();
    final gap = 12 * scale;
    final statusText = _statusText;
    statusText?.position = Vector2(bounds.center.dx, top + 62 * scale);
    final contentTop = top + (statusText == null ? 76 : 92) * scale;
    final contentHeight = panelHeight - (statusText == null ? 94 : 110) * scale;
    final cardWidth = (panelWidth - 32 * scale - gap * (columns - 1)) / columns;
    final cardHeight = rows == 0
        ? contentHeight
        : (contentHeight - (rows - 1) * gap) / rows;
    for (var index = 0; index < _cards.length; index++) {
      final card = _cards[index];
      final column = index % columns;
      final row = index ~/ columns;
      final cardLeft = left + 16 * scale + column * (cardWidth + gap);
      final cardTop = contentTop + row * (cardHeight + gap);
      card
        ..panel.size = Vector2(cardWidth, cardHeight)
        ..panel.position = Vector2(cardLeft, cardTop);
      final preview = card.preview;
      if (preview != null) {
        final previewSize = math.min(72 * scale, cardHeight * 0.36);
        preview
          ..size = Vector2.all(previewSize)
          ..position = Vector2(
            cardLeft + cardWidth / 2,
            cardTop + cardHeight * 0.24,
          );
      }
      card.name.position = Vector2(
        cardLeft + cardWidth / 2,
        cardTop + cardHeight * 0.52,
      );
      card.name.scale = Vector2.all(0.5 * scale);
      final buttonWidth = math.min(142 * scale, cardWidth - 12 * scale);
      final buttonHeight = math.min(44 * scale, cardHeight * 0.4);
      card.button
        ..size = Vector2(buttonWidth, buttonHeight)
        ..position = Vector2(
          cardLeft + cardWidth / 2,
          cardTop + cardHeight * 0.79,
        )
        ..anchor = Anchor.center;
    }
    _emptyText
      ..text = _cards.isEmpty ? _emptyMessage : ''
      ..position = Vector2(bounds.center.dx, top + panelHeight * 0.58);
  }

  String get _emptyMessage {
    if (snapshot.isLoading ||
        !snapshot.isAccountSignedIn ||
        snapshot.shopDataUnavailable) {
      return '';
    }
    return labels.noCharacters;
  }
}

class _ShopCard {
  const _ShopCard(
    this.character,
    this.panel,
    this.preview,
    this.name,
    this.button,
  );

  final CharacterModel character;
  final AssetPanelComponent panel;
  final SpriteAnimationComponent? preview;
  final TextComponent<SpriteFontRenderer> name;
  final AssetButtonComponent button;
}
