import 'dart:math' as math;

import 'package:flame/components.dart';
import 'package:flame/text.dart';
import 'package:gunwave/data/constants/game/game_button.dart';
import 'package:gunwave/data/constants/game/game_menu_style.dart';
import 'package:gunwave/data/models/character_model.dart';
import 'package:gunwave/views/game/ui/components/asset_button_component.dart';
import 'package:gunwave/views/game/ui/components/asset_panel_component.dart';
import 'package:gunwave/views/rpg_ui/rpg_menu_models.dart';
import 'package:gunwave/views/rpg_ui/scenes/rpg_menu_scene.dart';

/// Hero selection and stat summary immediately before a local stage launch.
class HeroLoadoutScene extends RpgMenuScene {
  HeroLoadoutScene({
    required super.snapshot,
    required super.labels,
    required super.actions,
    required super.safeAreaInsets,
    required super.onNavigate,
    this.backToHost = false,
    this.backPage = RpgMenuPage.stageBriefing,
  });

  final bool backToHost;
  final RpgMenuPage backPage;

  late final AssetPanelComponent _heroPanel;
  late final AssetPanelComponent _statsPanel;
  late final TextComponent<SpriteFontRenderer> _title;
  late final TextComponent<SpriteFontRenderer> _heroName;
  late final TextComponent<SpriteFontRenderer> _abilityName;
  late final TextComponent<SpriteFontRenderer> _statusPoints;
  late final TextComponent<SpriteFontRenderer> _emptyState;
  late final AssetButtonComponent _previousButton;
  late final AssetButtonComponent _nextButton;
  late final AssetButtonComponent _backButton;
  late final AssetButtonComponent _shopButton;
  late final AssetButtonComponent _launchButton;
  final List<_HeroStatRow> _statRows = [];
  SpriteAnimationComponent? _heroPreview;

  CharacterModel? get _hero => snapshot.selectedHero;

  @override
  Future<void> loadScene() async {
    _heroPanel = addPanel(Vector2.all(1));
    _statsPanel = addPanel(Vector2.all(1));
    _title = addText(labels.heroLoadout, scale: 1.2);
    _heroName = addText(
      _hero?.name ??
          (snapshot.isLoading ? labels.loading : labels.noCharacters),
      scale: 0.86,
    );
    _abilityName = addText(
      _hero?.ability?.name ?? labels.selectHero,
      scale: 0.62,
    );
    _statusPoints = addText(
      '${labels.statusPoints}: ${_hero?.sp ?? 0}',
      scale: 0.68,
    );
    _emptyState = addText(
      snapshot.ownedHeroes.isEmpty
          ? (snapshot.isLoading ? labels.loading : labels.noCharacters)
          : '',
      scale: 0.7,
    );
    _heroPreview = await loadHeroPreview(_hero, size: Vector2.all(180));
    _statRows.addAll(
      await Future.wait([
        _createStatRow(labels.health, _hero?.hp ?? 0, CharacterAttr.hp),
        _createStatRow(labels.strength, _hero?.str ?? 0, CharacterAttr.str),
        _createStatRow(labels.vitality, _hero?.vit ?? 0, CharacterAttr.vit),
        _createStatRow(labels.agility, _hero?.agi ?? 0, CharacterAttr.agi),
      ]),
    );
    _previousButton = await addButton(
      '<',
      () => _selectHero(snapshot.selectedHeroIndex - 1),
      buttonSize: Vector2(64, 56),
      assetSize: GameButtonSize.small,
      enabled: snapshot.ownedHeroes.length > 1,
    );
    _nextButton = await addButton(
      '>',
      () => _selectHero(snapshot.selectedHeroIndex + 1),
      buttonSize: Vector2(64, 56),
      assetSize: GameButtonSize.small,
      enabled: snapshot.ownedHeroes.length > 1,
    );
    _backButton = await addButton(
      labels.back,
      backToHost ? actions.onBack : () => onNavigate(backPage),
      buttonSize: Vector2(154, 56),
    );
    _shopButton = await addButton(
      labels.shop,
      () => onNavigate(RpgMenuPage.shop),
      buttonSize: Vector2(154, 56),
    );
    final stage = snapshot.selectedStage;
    _launchButton = await addButton(
      labels.play,
      () {
        final hero = _hero;
        if (stage != null && hero != null && snapshot.isStageUnlocked(stage)) {
          actions.onLaunchStage(stage, hero);
        }
      },
      buttonSize: Vector2(186, 62),
      assetSize: GameButtonSize.large,
      enabled:
          _hero != null && stage != null && snapshot.isStageUnlocked(stage),
    );
  }

  Future<_HeroStatRow> _createStatRow(
    String label,
    int value,
    CharacterAttr attr,
  ) async {
    final labelText = addText(label, scale: 0.62, anchor: Anchor.centerLeft);
    final valueText = addText('$value', scale: 0.72);
    final plus = await addButton(
      '+',
      () {
        final hero = _hero;
        if (hero != null && hero.sp > 0) {
          actions.onUpgradeHero(hero, attr);
        }
      },
      buttonSize: Vector2(52, 48),
      assetSize: GameButtonSize.small,
      enabled: (_hero?.sp ?? 0) > 0,
    );
    return _HeroStatRow(labelText, valueText, plus, attr);
  }

  void _selectHero(int index) {
    if (snapshot.ownedHeroes.isEmpty) return;
    final nextIndex =
        (index % snapshot.ownedHeroes.length + snapshot.ownedHeroes.length) %
        snapshot.ownedHeroes.length;
    actions.onSelectHero(nextIndex);
  }

  @override
  void layoutScene() {
    // Give the hero panel 40% of the card and keep the four stat rows within
    // the remaining area above the fixed action row.
    final bounds = contentBounds;
    final scale = uiScale;
    final panelWidth = math.min(
      bounds.width * GameMenuStyle.loadoutWidthRatio,
      GameMenuStyle.loadoutMaxWidth * scale,
    );
    final panelHeight = math.min(
      bounds.height * GameMenuStyle.loadoutHeightRatio,
      GameMenuStyle.loadoutMaxHeight * scale,
    );
    final left = bounds.center.dx - panelWidth / 2;
    final top = bounds.center.dy - panelHeight / 2;
    final gap = 16 * scale;
    final heroWidth = panelWidth * 0.38;
    final statsWidth = panelWidth - heroWidth - gap;
    final bodyTop = top + 64 * scale;
    final bodyHeight = panelHeight - 148 * scale;
    _heroPanel
      ..size = Vector2(heroWidth, bodyHeight)
      ..position = Vector2(left, bodyTop);
    _statsPanel
      ..size = Vector2(statsWidth, bodyHeight)
      ..position = Vector2(left + heroWidth + gap, bodyTop);
    _title.position = Vector2(bounds.center.dx, top + 28 * scale);
    _heroName.position = Vector2(left + heroWidth / 2, bodyTop + 26 * scale);
    _abilityName.position = Vector2(
      left + heroWidth / 2,
      bodyTop + bodyHeight - 32 * scale,
    );
    _statusPoints.position = Vector2(
      left + heroWidth + gap + statsWidth / 2,
      bodyTop + 24 * scale,
    );
    final hero = _heroPreview;
    if (hero != null) {
      hero
        ..size = Vector2.all(math.min(heroWidth * 0.58, bodyHeight * 0.52))
        ..position = Vector2(left + heroWidth / 2, bodyTop + bodyHeight * 0.54);
    }
    _emptyState.position = Vector2(
      left + heroWidth / 2,
      bodyTop + bodyHeight / 2,
    );
    _previousButton
      ..size = Vector2(58 * scale, 52 * scale)
      ..position = Vector2(left + 26 * scale, bodyTop + bodyHeight / 2)
      ..anchor = Anchor.centerLeft;
    _nextButton
      ..size = Vector2(58 * scale, 52 * scale)
      ..position = Vector2(
        left + heroWidth - 26 * scale,
        bodyTop + bodyHeight / 2,
      )
      ..anchor = Anchor.centerRight;
    for (var index = 0; index < _statRows.length; index++) {
      final row = _statRows[index];
      final rowTop = math.min(86 * scale, bodyHeight * 0.23);
      final rowGap = math.min(62 * scale, (bodyHeight - 100 * scale) / 3);
      final y = bodyTop + rowTop + index * rowGap;
      row.label.position = Vector2(left + heroWidth + gap + 28 * scale, y);
      row.value.position = Vector2(
        left + heroWidth + gap + statsWidth * 0.70,
        y,
      );
      row.plus
        ..size = Vector2(50 * scale, 46 * scale)
        ..position = Vector2(left + panelWidth - 38 * scale, y)
        ..anchor = Anchor.centerRight;
    }
    final bottom = top + panelHeight - 14 * scale;
    _backButton
      ..size = Vector2(154 * scale, 56 * scale)
      ..position = Vector2(left + 104 * scale, bottom)
      ..anchor = Anchor.bottomCenter;
    _shopButton
      ..size = Vector2(154 * scale, 56 * scale)
      ..position = Vector2(left + panelWidth * 0.52, bottom)
      ..anchor = Anchor.bottomCenter;
    _launchButton
      ..size = Vector2(186 * scale, 62 * scale)
      ..position = Vector2(left + panelWidth - 112 * scale, bottom)
      ..anchor = Anchor.bottomCenter;
  }
}

class _HeroStatRow {
  const _HeroStatRow(this.label, this.value, this.plus, this.attr);

  final TextComponent<SpriteFontRenderer> label;
  final TextComponent<SpriteFontRenderer> value;
  final AssetButtonComponent plus;
  final CharacterAttr attr;
}
