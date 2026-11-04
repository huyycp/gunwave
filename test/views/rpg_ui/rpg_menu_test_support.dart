import 'package:flutter/painting.dart';
import 'package:gunwave/data/models/campaign_stage_model.dart';
import 'package:gunwave/data/models/character_model.dart';
import 'package:gunwave/data/models/monster_model.dart';
import 'package:gunwave/data/models/reward_model.dart';
import 'package:gunwave/data/models/stage_encounter_model.dart';
import 'package:gunwave/data/models/stage_round_model.dart';
import 'package:gunwave/localization/app_locale_mode.dart';
import 'package:gunwave/views/rpg_ui/rpg_menu_models.dart';
import 'package:gunwave/views/rpg_ui/rpg_menu_game.dart';
import 'package:gunwave/views/rpg_ui/scenes/rpg_menu_scene.dart';

RpgMenuLabels testRpgMenuLabels() => RpgMenuLabels(
  campaign: 'Campaign',
  continueCampaign: 'Continue',
  settings: 'Settings',
  shop: 'Shop',
  back: 'Back',
  play: 'Play',
  rewards: 'Rewards',
  boss: 'Boss',
  stageBriefing: 'Stage Briefing',
  heroLoadout: 'Hero Loadout',
  stageNumber: (number) => 'Stage $number',
  roundNumber: (number) => 'Round $number',
  roundsCount: (count) => '$count rounds',
  forestOutskirts: 'Forest Outskirts',
  available: 'Available',
  locked: 'Locked',
  cleared: 'Cleared',
  startStage: 'Start Stage',
  selectHero: 'Select Hero',
  gold: 'Gold',
  statusPoints: 'Status points',
  loading: 'Loading',
  noCampaignStages: 'No stages',
  owned: 'Owned',
  noCharacters: 'No heroes',
  language: 'Language',
  deviceLanguage: 'Device language',
  english: 'English',
  vietnamese: 'Vietnamese',
  health: 'HP',
  strength: 'Strength',
  vitality: 'Vitality',
  agility: 'Agility',
);

RpgMenuActions testRpgMenuActions({
  void Function(RpgMenuPage page)? onPageChanged,
  void Function()? onBack,
  void Function(CampaignStageModel stage, CharacterModel hero)? onLaunchStage,
  void Function(String stageId)? onSelectStage,
  void Function(int index)? onSelectHero,
  Future<void> Function(CharacterModel hero)? onPurchase,
  void Function(AppLocaleMode mode)? onSelectLocale,
  Future<void> Function(CharacterModel hero, CharacterAttr attr)? onUpgradeHero,
}) => RpgMenuActions(
  onPageChanged: onPageChanged ?? (_) {},
  onBack: onBack ?? () {},
  onLaunchStage: onLaunchStage ?? (_, _) {},
  onSelectStage: onSelectStage ?? (_) {},
  onSelectHero: onSelectHero ?? (_) {},
  onPurchase: onPurchase ?? (_) async {},
  onSelectLocale: onSelectLocale ?? (_) {},
  onUpgradeHero: onUpgradeHero ?? (_, _) async {},
);

CampaignStageModel testCampaignStage() => CampaignStageModel(
  id: 'stage_1',
  order: 1,
  name: 'Forest Outskirts',
  mapKey: 'forest',
  enemies: const [
    MonsterModel(
      id: 'elder_torch_boss',
      name: 'Elder Torch',
      filename: 'torch_purple',
      hp: 24,
    ),
  ],
  rounds: [
    for (var number = 1; number <= 5; number++)
      StageRoundModel(
        id: 'stage_1_round_$number',
        number: number,
        isBoss: number == 5,
        encounters: const [
          StageEncounterModel(
            enemyId: 'elder_torch_boss',
            spawnMarker: 'torch_blue',
            count: 1,
          ),
        ],
      ),
  ],
  rewards: const [RewardModel(type: RewardType.gold, amount: 100)],
);

CharacterModel testHero({String id = 'hero_blue'}) => CharacterModel(
  id: id,
  name: 'Blue Warrior',
  filename: 'warrior_blue',
  price: 50,
  hp: 100,
  str: 10,
  vit: 3,
  agi: 4,
  sp: 1,
);

RpgMenuSnapshot testRpgMenuSnapshot({
  List<CampaignStageModel>? stages,
  List<CharacterModel>? ownedHeroes,
  List<CharacterModel>? shopHeroes,
  Set<String> clearedStageIds = const {},
  int gold = 100,
  int selectedHeroIndex = 0,
  String? selectedStageId,
  AppLocaleMode localeMode = AppLocaleMode.system,
  bool isLoading = false,
}) => RpgMenuSnapshot(
  stages: stages ?? [testCampaignStage()],
  ownedHeroes: ownedHeroes ?? [testHero()],
  shopHeroes: shopHeroes ?? [testHero(id: 'hero_red')],
  clearedStageIds: clearedStageIds,
  gold: gold,
  selectedHeroIndex: selectedHeroIndex,
  selectedStageId: selectedStageId,
  localeMode: localeMode,
  isLoading: isLoading,
);

const testSafeAreaInsets = EdgeInsets.zero;

RpgMenuGame testRpgMenuGame({
  required RpgMenuPage initialPage,
  RpgMenuSnapshot? snapshot,
  RpgMenuActions? actions,
  RpgMenuPage? loadoutBackPage,
}) => RpgMenuGame(
  snapshot: snapshot ?? testRpgMenuSnapshot(),
  labels: testRpgMenuLabels(),
  actions: actions ?? testRpgMenuActions(),
  safeAreaInsets: testSafeAreaInsets,
  initialPage: initialPage,
  showHubBackButton: initialPage != RpgMenuPage.homeHub,
  isStandaloneHeroLoadout: initialPage == RpgMenuPage.heroLoadout,
  loadoutBackPage:
      loadoutBackPage ??
      (initialPage == RpgMenuPage.homeHub
          ? RpgMenuPage.homeHub
          : RpgMenuPage.stageBriefing),
);

RpgMenuScene activeRpgMenuScene(RpgMenuGame game) =>
    game.router.currentRoute.children.whereType<RpgMenuScene>().single;
