import 'package:flame/game.dart';
import 'package:flutter/painting.dart' show EdgeInsets;
import 'package:gunwave/views/rpg_ui/rpg_menu_models.dart';
import 'package:gunwave/views/rpg_ui/scenes/campaign_map_scene.dart';
import 'package:gunwave/views/rpg_ui/scenes/hero_loadout_scene.dart';
import 'package:gunwave/views/rpg_ui/scenes/home_hub_scene.dart';
import 'package:gunwave/views/rpg_ui/scenes/rpg_menu_scene.dart';
import 'package:gunwave/views/rpg_ui/scenes/settings_scene.dart';
import 'package:gunwave/views/rpg_ui/scenes/shop_scene.dart';
import 'package:gunwave/views/rpg_ui/scenes/stage_briefing_scene.dart';

/// Flame RouterComponent host for the campaign hub and its menu scenes.
class RpgMenuGame extends FlameGame {
  RpgMenuGame({
    required this.snapshot,
    required this.labels,
    required this.actions,
    required this.safeAreaInsets,
    required this.initialPage,
    required this.showHubBackButton,
    required this.isStandaloneHeroLoadout,
    this.loadoutBackPage = RpgMenuPage.stageBriefing,
  });

  RpgMenuSnapshot snapshot;
  final RpgMenuLabels labels;
  final RpgMenuActions actions;
  final EdgeInsets safeAreaInsets;
  final RpgMenuPage initialPage;
  final bool showHubBackButton;
  final bool isStandaloneHeroLoadout;
  final RpgMenuPage loadoutBackPage;

  late final RouterComponent router = RouterComponent(
    initialRoute: initialPage.routeName,
    routes: {
      for (final page in RpgMenuPage.values)
        page.routeName: Route(() => _buildScene(page)),
    },
  );

  @override
  Future<void> onLoad() async {
    images.prefix = '';
    await super.onLoad();
    add(router);
  }

  /// Updates the data source used when the router next builds a scene.
  void updateSnapshot(RpgMenuSnapshot value) => snapshot = value;

  /// Routes menu taps through Flame's scene stack.
  void navigate(RpgMenuPage page) {
    actions.onPageChanged(page);
    router.pushNamed(page.routeName);
  }

  RpgMenuScene _buildScene(RpgMenuPage page) {
    final common = (
      snapshot: snapshot,
      labels: labels,
      actions: actions,
      safeAreaInsets: safeAreaInsets,
      onNavigate: navigate,
    );
    return switch (page) {
      RpgMenuPage.homeHub => HomeHubScene(
        snapshot: common.snapshot,
        labels: common.labels,
        actions: common.actions,
        safeAreaInsets: common.safeAreaInsets,
        onNavigate: common.onNavigate,
        showBackButton: showHubBackButton,
      ),
      RpgMenuPage.campaignMap => CampaignMapScene(
        snapshot: common.snapshot,
        labels: common.labels,
        actions: common.actions,
        safeAreaInsets: common.safeAreaInsets,
        onNavigate: common.onNavigate,
      ),
      RpgMenuPage.stageBriefing => StageBriefingScene(
        snapshot: common.snapshot,
        labels: common.labels,
        actions: common.actions,
        safeAreaInsets: common.safeAreaInsets,
        onNavigate: common.onNavigate,
      ),
      RpgMenuPage.heroLoadout => HeroLoadoutScene(
        snapshot: common.snapshot,
        labels: common.labels,
        actions: common.actions,
        safeAreaInsets: common.safeAreaInsets,
        onNavigate: common.onNavigate,
        backToHost: isStandaloneHeroLoadout,
        backPage: loadoutBackPage,
      ),
      RpgMenuPage.shop => ShopScene(
        snapshot: common.snapshot,
        labels: common.labels,
        actions: common.actions,
        safeAreaInsets: common.safeAreaInsets,
        onNavigate: common.onNavigate,
      ),
      RpgMenuPage.settings => SettingsScene(
        snapshot: common.snapshot,
        labels: common.labels,
        actions: common.actions,
        safeAreaInsets: common.safeAreaInsets,
        onNavigate: common.onNavigate,
      ),
    };
  }
}
