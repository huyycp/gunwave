import 'dart:math' as math;

import 'package:flame/components.dart';
import 'package:flame/text.dart';
import 'package:gunwave/data/models/character_model.dart';
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
  late final AssetButtonComponent _backButton;
  late final List<_ShopCard> _cards;

  @override
  Future<void> loadScene() async {
    _panel = addPanel(Vector2.all(1));
    _title = addText(labels.shop, scale: 1.12);
    _balance = addText('${labels.gold}: ${snapshot.gold}', scale: 0.72);
    _backButton = await addButton(
      labels.back,
      actions.onBack,
      buttonSize: Vector2(150, 56),
    );
    _cards = [];
    for (final character in snapshot.shopHeroes.take(8)) {
      final panel = addPanel(Vector2.all(1));
      final preview = await loadHeroPreview(character, size: Vector2.all(92));
      final name = addText(character.name, scale: 0.52);
      final isOwned = snapshot.ownedHeroes.any(
        (hero) => hero.id == character.id,
      );
      final button = await addButton(
        isOwned ? labels.owned : '${character.price}',
        () => actions.onPurchase(character),
        buttonSize: Vector2(142, 48),
        enabled: !isOwned && snapshot.gold >= character.price,
      );
      _cards.add(_ShopCard(character, panel, preview, name, button));
    }
  }

  @override
  void layoutScene() {
    // Four columns and two rows show the current eight-hero catalog together;
    // each card separates the sprite, name, and purchase hit target vertically.
    final bounds = contentBounds;
    final scale = uiScale;
    final panelWidth = math.min(bounds.width - 32 * scale, 1120 * scale);
    final panelHeight = math.min(bounds.height - 32 * scale, 600 * scale);
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
    final rows = (_cards.length / 4).ceil();
    final gap = 12 * scale;
    final contentTop = top + 76 * scale;
    final contentHeight = panelHeight - 94 * scale;
    final cardWidth = (panelWidth - 32 * scale - gap * 3) / 4;
    final cardHeight = rows == 0
        ? contentHeight
        : (contentHeight - (rows - 1) * gap) / rows;
    for (var index = 0; index < _cards.length; index++) {
      final card = _cards[index];
      final column = index % columns;
      final row = index ~/ 4;
      final cardLeft = left + 16 * scale + column * (cardWidth + gap);
      final cardTop = contentTop + row * (cardHeight + gap);
      card
        ..panel.size = Vector2(cardWidth, cardHeight)
        ..panel.position = Vector2(cardLeft, cardTop);
      card.name.position = Vector2(
        cardLeft + cardWidth / 2,
        cardTop + cardHeight - 64 * scale,
      );
      final preview = card.preview;
      if (preview != null) {
        final previewSize = math.min(100 * scale, cardHeight * 0.32);
        preview
          ..size = Vector2.all(previewSize)
          ..position = Vector2(
            cardLeft + cardWidth / 2,
            cardTop + cardHeight * 0.34,
          );
      }
      card.button
        ..size = Vector2(
          math.min(142 * scale, cardWidth - 12 * scale),
          46 * scale,
        )
        ..position = Vector2(
          cardLeft + cardWidth / 2,
          cardTop + cardHeight - 10 * scale,
        )
        ..anchor = Anchor.bottomCenter;
    }
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
