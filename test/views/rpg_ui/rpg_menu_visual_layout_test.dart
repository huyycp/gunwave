import 'dart:ui' show Rect;

import 'package:flame/components.dart';
import 'package:flame/text.dart';
import 'package:flame_test/flame_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gunwave/theme/app_typography.dart';
import 'package:gunwave/views/game/ui/components/asset_button_component.dart';
import 'package:gunwave/views/game/ui/components/asset_panel_component.dart';
import 'package:gunwave/views/rpg_ui/rpg_menu_models.dart';
import 'package:gunwave/views/rpg_ui/scenes/hero_loadout_scene.dart';
import 'package:gunwave/views/rpg_ui/scenes/home_hub_scene.dart';
import 'package:gunwave/views/rpg_ui/scenes/settings_scene.dart';
import 'package:gunwave/views/rpg_ui/scenes/shop_scene.dart';
import 'package:gunwave/views/rpg_ui/scenes/stage_briefing_scene.dart';

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
        snapshot: switch (page) {
          RpgMenuPage.shop => testRpgMenuSnapshot(
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
          ),
          RpgMenuPage.homeHub => testRpgMenuSnapshot(
            campaignGold: 235,
            campaignStatusPoints: 7,
          ),
          _ => null,
        },
      ),
      (game) async {
        await game.ready();
        final scene = activeRpgMenuScene(game);
        final title = scene.children
            .whereType<TextComponent<SpriteFontRenderer>>()
            .firstWhere((text) => text.text.isNotEmpty);
        final firstButton = scene.children
            .whereType<AssetButtonComponent>()
            .first;
        final buttonLabel = firstButton.children
            .whereType<TextComponent<SpriteFontRenderer>>()
            .single;
        double? previousTitleScale;
        double? previousButtonLabelScale;
        double? initialButtonLabelScale;
        for (final viewport in [
          Vector2(640, 360),
          Vector2(844, 390),
          Vector2(900, 506),
          Vector2(1280, 720),
          Vector2(1920, 1080),
        ]) {
          game.onGameResize(viewport);
          expectRpgMenuLayoutWithinViewport(scene, viewport);
          if (previousTitleScale != null) {
            expect(title.scale.x, greaterThan(previousTitleScale));
            expect(
              buttonLabel.scale.x,
              greaterThanOrEqualTo(previousButtonLabelScale!),
            );
          }
          initialButtonLabelScale ??= buttonLabel.scale.x;
          previousTitleScale = title.scale.x;
          previousButtonLabelScale = buttonLabel.scale.x;
          if (scene is HomeHubScene) {
            _expectHomeHubArtAndHeaderFit(scene);
          }
          if (scene is StageBriefingScene || scene is SettingsScene) {
            expect(
              scene.children.whereType<AssetPanelComponent>().first.height /
                  scene.size.y,
              greaterThanOrEqualTo(0.90),
            );
          }
          if (scene is HeroLoadoutScene) {
            _expectLoadoutHeroUsesItsPanel(scene);
          }
          if (scene is ShopScene) {
            _expectShopNamesFitCards(scene);
            _expectShopCardContentIsReadable(scene);
          }
        }
        expect(buttonLabel.scale.x, greaterThan(initialButtonLabelScale!));
      },
    );
  }
}

void _expectHomeHubArtAndHeaderFit(HomeHubScene scene) {
  final panels = scene.children.whereType<AssetPanelComponent>().toList();
  final heroPanelBounds = panels.first.toAbsoluteRect();
  final campaignPanelBounds = panels[1].toAbsoluteRect();
  final preview = scene.children.whereType<SpriteAnimationComponent>().single;
  final previewBounds = preview.toAbsoluteRect();
  expect(heroPanelBounds.contains(previewBounds.topLeft), isTrue);
  expect(heroPanelBounds.contains(previewBounds.bottomRight), isTrue);
  expect(heroPanelBounds.height / scene.size.y, greaterThanOrEqualTo(0.72));
  expect(preview.height / heroPanelBounds.height, greaterThanOrEqualTo(0.82));

  final text = scene.children.whereType<TextComponent<SpriteFontRenderer>>();
  Rect textBounds(String value) =>
      text.singleWhere((component) => component.text == value).toAbsoluteRect();

  for (final value in ['Stage 1', 'Forest Outskirts', '5 rounds  |  Boss']) {
    final bounds = textBounds(value);
    expect(bounds.left, greaterThanOrEqualTo(campaignPanelBounds.left));
    expect(bounds.right, lessThanOrEqualTo(campaignPanelBounds.right));
  }

  final settingsBounds = scene.children
      .whereType<AssetButtonComponent>()
      .singleWhere((button) => button.label == 'Settings')
      .toAbsoluteRect();
  final titleBounds = textBounds('Campaign');
  final statusLabelBounds = textBounds('Status points');
  final statusValueBounds = textBounds('7');
  final goldLabelBounds = textBounds('Gold');
  final goldValueBounds = textBounds('235');
  expect(titleBounds.right, lessThanOrEqualTo(statusLabelBounds.left));
  expect(statusLabelBounds.right, lessThanOrEqualTo(statusValueBounds.left));
  expect(statusValueBounds.right, lessThanOrEqualTo(goldLabelBounds.left));
  expect(goldLabelBounds.right, lessThanOrEqualTo(goldValueBounds.left));
  expect(goldValueBounds.right, lessThanOrEqualTo(settingsBounds.left));
}

void _expectLoadoutHeroUsesItsPanel(HeroLoadoutScene scene) {
  final panels = scene.children.whereType<AssetPanelComponent>().toList();
  final heroPanelBounds = panels.first.toAbsoluteRect();
  final statsPanelBounds = panels[1].toAbsoluteRect();
  final preview = scene.children.whereType<SpriteAnimationComponent>().single;
  final previewBounds = preview.toAbsoluteRect();
  expect(heroPanelBounds.contains(previewBounds.topLeft), isTrue);
  expect(heroPanelBounds.contains(previewBounds.bottomRight), isTrue);
  expect(preview.height / heroPanelBounds.height, greaterThanOrEqualTo(0.70));

  final text = scene.children.whereType<TextComponent<SpriteFontRenderer>>();
  final labels = ['HP', 'Strength', 'Vitality', 'Agility'];
  final values = ['100', '10', '3', '4'];
  final plusButtons = scene.children
      .whereType<AssetButtonComponent>()
      .where((button) => button.label == '+')
      .toList();
  for (var index = 0; index < labels.length; index++) {
    final labelBounds = text
        .singleWhere((component) => component.text == labels[index])
        .toAbsoluteRect();
    final valueBounds = text
        .singleWhere((component) => component.text == values[index])
        .toAbsoluteRect();
    final plusBounds = plusButtons[index].toAbsoluteRect();
    expect(labelBounds.left, greaterThanOrEqualTo(statsPanelBounds.left));
    expect(labelBounds.right, lessThan(valueBounds.left));
    expect(valueBounds.right, lessThan(plusBounds.left));
    expect(plusBounds.right, lessThanOrEqualTo(statsPanelBounds.right));
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
    expect(
      name.scale.x,
      greaterThanOrEqualTo(
        AppTypography.minimumBitmapFontSize / AppTypography.bitmapFontBaseSize -
            0.001,
      ),
    );
  }
}

void _expectShopCardContentIsReadable(ShopScene scene) {
  final cards = scene.children
      .whereType<AssetPanelComponent>()
      .skip(1)
      .toList();
  final previews = scene.children.whereType<SpriteAnimationComponent>();
  final names = scene.children
      .whereType<TextComponent<SpriteFontRenderer>>()
      .where(
        (text) => text.text.contains('Warrior') || text.text.contains('Pawn'),
      );
  final buttons = scene.children.whereType<AssetButtonComponent>();
  expect(previews, hasLength(cards.length));
  expect(names, hasLength(cards.length));

  for (final card in cards) {
    final cardBounds = card.toAbsoluteRect();
    final previewBounds = previews
        .map((preview) => preview.toAbsoluteRect())
        .singleWhere((rect) => cardBounds.contains(rect.center));
    final nameBounds = names
        .map((name) => name.toAbsoluteRect())
        .singleWhere((rect) => cardBounds.contains(rect.center));
    final buttonBounds = buttons
        .where((button) => button.label != 'Back')
        .map((button) => button.toAbsoluteRect())
        .singleWhere((rect) => cardBounds.contains(rect.center));

    expect(previewBounds.top, greaterThanOrEqualTo(cardBounds.top - 0.5));
    expect(previewBounds.bottom, lessThan(nameBounds.top));
    expect(nameBounds.bottom, lessThan(buttonBounds.top));
    expect(buttonBounds.bottom, lessThanOrEqualTo(cardBounds.bottom));
    expect(previewBounds.height / cardBounds.height, greaterThan(0.48));
  }
}
