import 'package:flutter/foundation.dart';
import 'package:gunwave/data/constants/game/game_play_mode.dart';
import 'package:gunwave/data/models/campaign_stage_model.dart';
import 'package:gunwave/data/models/character_model.dart';
import 'package:gunwave/l10n/app_localizations.dart';
import 'package:gunwave/localization/app_locale_mode.dart';

/// Pages hosted inside the asset-rendered RPG menu game.
enum RpgMenuPage {
  homeHub('home'),
  campaignMap('campaign'),
  stageBriefing('briefing'),
  heroLoadout('loadout'),
  shop('shop'),
  settings('settings');

  const RpgMenuPage(this.routeName);

  final String routeName;
}

/// Localized strings passed into Flame without a Flutter rendering dependency.
class RpgMenuLabels {
  const RpgMenuLabels({
    required this.campaign,
    required this.continueCampaign,
    required this.settings,
    required this.shop,
    required this.back,
    required this.play,
    required this.rewards,
    required this.boss,
    required this.stageBriefing,
    required this.heroLoadout,
    required this.stageNumber,
    required this.roundNumber,
    required this.roundsCount,
    required this.forestOutskirts,
    required this.available,
    required this.locked,
    required this.cleared,
    required this.startStage,
    required this.selectHero,
    required this.gold,
    required this.statusPoints,
    required this.loading,
    required this.noCampaignStages,
    required this.owned,
    required this.noCharacters,
    required this.signInToShop,
    required this.shopUnavailable,
    required this.language,
    required this.gameControls,
    required this.deviceLanguage,
    required this.english,
    required this.vietnamese,
    required this.joystick,
    required this.keyboard,
    required this.gesture,
    required this.health,
    required this.strength,
    required this.vitality,
    required this.agility,
  });

  final String campaign;
  final String continueCampaign;
  final String settings;
  final String shop;
  final String back;
  final String play;
  final String rewards;
  final String boss;
  final String stageBriefing;
  final String heroLoadout;
  final String Function(int number) stageNumber;
  final String Function(int number) roundNumber;
  final String Function(int count) roundsCount;
  final String forestOutskirts;
  final String available;
  final String locked;
  final String cleared;
  final String startStage;
  final String selectHero;
  final String gold;
  final String statusPoints;
  final String loading;
  final String noCampaignStages;
  final String owned;
  final String noCharacters;
  final String signInToShop;
  final String shopUnavailable;
  final String language;
  final String gameControls;
  final String deviceLanguage;
  final String english;
  final String vietnamese;
  final String joystick;
  final String keyboard;
  final String gesture;
  final String health;
  final String strength;
  final String vitality;
  final String agility;

  factory RpgMenuLabels.fromLocalizations(AppLocalizations strings) =>
      RpgMenuLabels(
        campaign: strings.campaign,
        continueCampaign: strings.continueCampaign,
        settings: strings.settings,
        shop: strings.openShop,
        back: strings.back,
        play: strings.play,
        rewards: strings.rewards,
        boss: strings.boss,
        stageBriefing: strings.stageBriefing,
        heroLoadout: strings.heroLoadout,
        stageNumber: strings.stageNumber,
        roundNumber: strings.roundNumber,
        roundsCount: strings.roundsCount,
        forestOutskirts: strings.forestOutskirts,
        available: strings.available,
        locked: strings.locked,
        cleared: strings.cleared,
        startStage: strings.startStage,
        selectHero: strings.selectHero,
        gold: strings.gold,
        statusPoints: strings.rewardStatusPoints,
        loading: strings.loading,
        noCampaignStages: strings.noCampaignStages,
        owned: strings.owned,
        noCharacters: strings.noCharactersAvailable,
        signInToShop: strings.signInToShop,
        shopUnavailable: strings.shopUnavailable,
        language: strings.language,
        gameControls: strings.gameControls,
        deviceLanguage: strings.deviceLanguage,
        english: strings.english,
        vietnamese: strings.vietnamese,
        joystick: strings.joystick,
        keyboard: strings.keyboard,
        gesture: strings.gesture,
        health: strings.healthPoints,
        strength: strings.strength,
        vitality: strings.vitality,
        agility: strings.agility,
      );
}

/// Read-only campaign and player data consumed by Flame scenes.
class RpgMenuSnapshot {
  const RpgMenuSnapshot({
    this.stages = const [],
    this.ownedHeroes = const [],
    this.shopHeroes = const [],
    this.clearedStageIds = const {},
    this.gold = 0,
    this.campaignGold = 0,
    this.campaignStatusPoints = 0,
    this.isAccountSignedIn = true,
    this.shopDataUnavailable = false,
    this.selectedHeroIndex = 0,
    this.selectedStageId,
    this.selectedPlayMode = GamePlayMode.joystick,
    this.localeMode = AppLocaleMode.system,
    this.isLoading = true,
  });

  final List<CampaignStageModel> stages;
  final List<CharacterModel> ownedHeroes;
  final List<CharacterModel> shopHeroes;
  final Set<String> clearedStageIds;

  /// Online account balance used by the existing character shop.
  final int gold;

  /// Local balance earned through first-time campaign completions.
  final int campaignGold;

  /// Local status-point rewards earned through the campaign.
  final int campaignStatusPoints;
  final bool isAccountSignedIn;
  final bool shopDataUnavailable;
  final int selectedHeroIndex;
  final String? selectedStageId;
  final GamePlayMode selectedPlayMode;
  final AppLocaleMode localeMode;
  final bool isLoading;

  CharacterModel? get selectedHero =>
      ownedHeroes.isEmpty ||
          selectedHeroIndex < 0 ||
          selectedHeroIndex >= ownedHeroes.length
      ? null
      : ownedHeroes[selectedHeroIndex];

  CampaignStageModel? get firstPlayableStage {
    for (final stage in stages) {
      if (isStageUnlocked(stage)) return stage;
    }
    return null;
  }

  CampaignStageModel? get selectedStage {
    for (final stage in stages) {
      if (stage.id == selectedStageId) return stage;
    }
    return firstPlayableStage;
  }

  bool isStageUnlocked(CampaignStageModel stage) =>
      stage.unlockRequirementStageId == null ||
      clearedStageIds.contains(stage.unlockRequirementStageId);

  bool isStageCleared(CampaignStageModel stage) =>
      clearedStageIds.contains(stage.id);
}

/// App-layer callbacks invoked by Flame; scene components do not own state.
class RpgMenuActions {
  const RpgMenuActions({
    required this.onPageChanged,
    required this.onBack,
    required this.onLaunchStage,
    required this.onSelectStage,
    required this.onSelectHero,
    required this.onPurchase,
    required this.onSelectLocale,
    required this.onSelectPlayMode,
    required this.onUpgradeHero,
  });

  final ValueChanged<RpgMenuPage> onPageChanged;
  final VoidCallback onBack;
  final void Function(CampaignStageModel stage, CharacterModel hero)
  onLaunchStage;
  final ValueChanged<String> onSelectStage;
  final ValueChanged<int> onSelectHero;
  final Future<void> Function(CharacterModel character) onPurchase;
  final ValueChanged<AppLocaleMode> onSelectLocale;
  final ValueChanged<GamePlayMode> onSelectPlayMode;
  final Future<void> Function(CharacterModel character, CharacterAttr attr)
  onUpgradeHero;
}
