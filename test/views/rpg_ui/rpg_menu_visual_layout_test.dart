import 'package:flame/components.dart';
import 'package:flame/text.dart';
import 'package:flame_test/flame_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gunwave/views/game/ui/components/asset_panel_component.dart';
import 'package:gunwave/views/rpg_ui/rpg_menu_models.dart';
import 'package:gunwave/views/rpg_ui/scenes/shop_scene.dart';

import 'rpg_menu_test_support.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  for (final page in [
    RpgMenuPage.homeHub,
    RpgMenuPage.campaignMap,
    RpgMenuPage.stageBriefing,
    RpgMenuPage.heroLoadout,
    RpgMenuPage.shop,
    RpgMenuPage.settings,
  ]) {
    testWithGame(
      '${page.routeName} keeps menu text and art inside landscape bounds',
      () => testRpgMenuGame(
        initialPage: page,
        snapshot: page == RpgMenuPage.shop
            ? testRpgMenuSnapshot(
                shopHeroes: [
                  for (final (index, name) in [
                    'Elite Warrior',
                    'Holy Warrior',
                    'Adept Warrior',
                    'Master Warrior',
                    'Elite Pawn',
                    'Master Pawn',
                    'Holy Pawn',
                    'Adept Pawn',
                  ].indexed)
                    testHero(id: 'hero_$index').copyWith(name: name),
                ],
              )
            : null,
      ),
      (game) async {
        await game.ready();
        final scene = activeRpgMenuScene(game);
        for (final viewport in [
          Vector2(640, 360),
          Vector2(1280, 720),
          Vector2(1920, 1080),
        ]) {
          game.onGameResize(viewport);
          expectRpgMenuLayoutWithinViewport(scene, viewport);
          if (scene is ShopScene) {
            _expectShopNamesFitCards(scene);
          }
        }
      },
    );
  }
}

void _expectShopNamesFitCards(ShopScene scene) {
  final cards = scene.children
      .whereType<AssetPanelComponent>()
      .skip(1)
      .toList();
  final names = scene.children.whereType<TextComponent<SpriteFontRenderer>>();
  for (final name in names.where(
    (text) => text.text.contains('Warrior') || text.text.contains('Pawn'),
  )) {
    final nameBounds = name.toAbsoluteRect();
    final cardBounds = cards
        .map((card) => card.toAbsoluteRect())
        .singleWhere((rect) => rect.contains(nameBounds.center));
    expect(nameBounds.left, greaterThanOrEqualTo(cardBounds.left + 4));
    expect(nameBounds.right, lessThanOrEqualTo(cardBounds.right - 4));
    expect(name.scale.x, greaterThan(16 / 14 - 0.001));
  }
}
