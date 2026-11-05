import 'dart:async';

import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:gunwave/data/constants/game/game_play_mode.dart';
import 'package:gunwave/data/data_sources/local/campaign_hero_catalog.dart';
import 'package:gunwave/data/models/campaign_progress_model.dart';
import 'package:gunwave/data/models/campaign_stage_model.dart';
import 'package:gunwave/data/models/character_model.dart';
import 'package:gunwave/l10n/app_localizations.dart';
import 'package:gunwave/localization/app_locale_controller.dart';
import 'package:gunwave/localization/app_locale_mode.dart';
import 'package:gunwave/repositories/campaign_repository.dart';
import 'package:gunwave/repositories/campaign_progress_repository.dart';
import 'package:gunwave/repositories/character_repository.dart';
import 'package:gunwave/routes.dart';
import 'package:gunwave/views/game/game_view.dart';
import 'package:gunwave/views/rpg_ui/rpg_menu_game.dart';
import 'package:gunwave/views/rpg_ui/rpg_menu_models.dart';

/// Flutter host that supplies data and callbacks to the asset-rendered menu.
class RpgMenuHost extends ConsumerStatefulWidget {
  const RpgMenuHost({required this.initialPage, this.onBack, super.key});

  final RpgMenuPage initialPage;
  final VoidCallback? onBack;

  @override
  ConsumerState<RpgMenuHost> createState() => _RpgMenuHostState();
}

class _RpgMenuHostState extends ConsumerState<RpgMenuHost> {
  late RpgMenuGame _game;
  late RpgMenuSnapshot _snapshot;
  late RpgMenuPage _currentPage;
  late EdgeInsets _safeAreaInsets;
  late Locale _gameLocale;
  String? _selectedStageId;
  GamePlayMode _selectedPlayMode = GamePlayMode.joystick;
  RpgMenuPage? _previousPage;
  List<CampaignStageModel> _stages = const [];
  CampaignProgressModel _campaignProgress = CampaignProgressModel();
  List<CharacterModel> _ownedHeroes = const [];
  List<CharacterModel> _shopHeroes = const [];
  int _selectedHeroIndex = 0;
  int _gold = 0;
  bool _shopDataUnavailable = false;
  bool _initialized = false;
  bool _heroDataLoaded = false;
  bool _heroDataLoading = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final locale = Localizations.localeOf(context);
    final padding = MediaQuery.paddingOf(context);
    if (!_initialized) {
      _initialized = true;
      _currentPage = widget.initialPage;
      _safeAreaInsets = padding;
      _gameLocale = locale;
      _snapshot = _createSnapshot(isLoading: true);
      _game = _createGame(AppLocalizations.of(context)!, _snapshot);
      unawaited(_loadMenuData());
      return;
    }
    if (locale != _gameLocale || padding != _safeAreaInsets) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        _gameLocale = Localizations.localeOf(context);
        _safeAreaInsets = MediaQuery.paddingOf(context);
        _snapshot = _createSnapshot(isLoading: _snapshot.isLoading);
        _replaceGame();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(appLocaleControllerProvider);
    return Scaffold(
      backgroundColor: Colors.black,
      body: GameWidget(game: _game),
    );
  }

  Future<void> _loadMenuData() async {
    try {
      _stages = await ref.read(campaignRepositoryProvider).getStages();
      _campaignProgress = await ref
          .read(campaignProgressRepositoryProvider)
          .getProgress();
      if (_pageNeedsHeroes(widget.initialPage)) {
        await _loadHeroData();
      }
      _selectedStageId ??= _firstUnlockedStageId(_stages);
    } catch (error, stackTrace) {
      debugPrint('Unable to load RPG menu data: $error\n$stackTrace');
    }
    if (!mounted) return;
    _snapshot = _createSnapshot(isLoading: false);
    _replaceGame();
  }

  RpgMenuSnapshot _createSnapshot({required bool isLoading}) => RpgMenuSnapshot(
    stages: List.unmodifiable(_stages),
    ownedHeroes: List.unmodifiable(_ownedHeroes),
    shopHeroes: List.unmodifiable(_shopHeroes),
    clearedStageIds: _campaignProgress.completedStageIds,
    gold: _gold,
    campaignGold: _campaignProgress.goldBalance,
    campaignStatusPoints: _campaignProgress.statusPointBalance,
    shopDataUnavailable: _shopDataUnavailable,
    selectedHeroIndex: _selectedHeroIndex,
    selectedStageId: _selectedStageId,
    selectedPlayMode: _selectedPlayMode,
    localeMode: ref.read(appLocaleControllerProvider).mode,
    isLoading: isLoading,
  );

  String? _firstUnlockedStageId(List<CampaignStageModel> stages) {
    for (final stage in stages) {
      if (stage.unlockRequirementStageId == null) return stage.id;
    }
    return null;
  }

  RpgMenuGame _createGame(
    AppLocalizations localizations,
    RpgMenuSnapshot data,
  ) => RpgMenuGame(
    snapshot: data,
    labels: RpgMenuLabels.fromLocalizations(localizations),
    safeAreaInsets: _safeAreaInsets,
    initialPage: _currentPage,
    showHubBackButton:
        widget.initialPage != RpgMenuPage.homeHub || widget.onBack != null,
    isStandaloneHeroLoadout: widget.initialPage == RpgMenuPage.heroLoadout,
    loadoutBackPage:
        _previousPage ??
        (widget.initialPage == RpgMenuPage.homeHub
            ? RpgMenuPage.homeHub
            : RpgMenuPage.stageBriefing),
    actions: RpgMenuActions(
      onPageChanged: _onPageChanged,
      onBack: _onBack,
      onLaunchStage: _launchStage,
      onSelectStage: _selectStage,
      onSelectHero: _selectHero,
      onPurchase: _purchase,
      onSelectLocale: _selectLocale,
      onSelectPlayMode: _selectPlayMode,
      onUpgradeHero: _upgradeHero,
    ),
  );

  void _replaceGame() {
    if (!mounted) return;
    setState(() {
      _game = _createGame(AppLocalizations.of(context)!, _snapshot);
    });
  }

  void _onPageChanged(RpgMenuPage page) {
    if (page != _currentPage) _previousPage = _currentPage;
    _currentPage = page;
    _snapshot = _createSnapshot(isLoading: _snapshot.isLoading);
    _game.updateSnapshot(_snapshot);
    if (_pageNeedsHeroes(page) && !_heroDataLoaded) {
      unawaited(_ensureHeroDataLoaded());
    }
  }

  bool _pageNeedsHeroes(RpgMenuPage page) =>
      page == RpgMenuPage.homeHub ||
      page == RpgMenuPage.heroLoadout ||
      page == RpgMenuPage.shop;

  Future<void> _ensureHeroDataLoaded() async {
    if (_heroDataLoaded || _heroDataLoading) return;
    try {
      await _loadHeroData();
    } catch (error, stackTrace) {
      debugPrint('Unable to load hero menu data: $error\n$stackTrace');
    }
    if (!mounted) return;
    _snapshot = _createSnapshot(isLoading: false);
    _replaceGame();
  }

  Future<void> _loadHeroData() async {
    if (_heroDataLoaded || _heroDataLoading) return;
    _heroDataLoading = true;
    try {
      final characterRepository = ref.read(characterRepoProvider);
      _ownedHeroes = _withStarterHero(
        await characterRepository.getOwnedCharacters(),
      );
      _shopHeroes = _withStarterHero(await characterRepository.getCharacters());
      _gold = await characterRepository.getGoldBalance();
      _shopDataUnavailable = false;
      final persistedHeroIndex = _ownedHeroes.indexWhere(
        (hero) => hero.id == _campaignProgress.selectedHeroId,
      );
      _selectedHeroIndex = persistedHeroIndex >= 0 ? persistedHeroIndex : 0;
      _heroDataLoaded = true;
    } catch (error, stackTrace) {
      _shopDataUnavailable = true;
      if (_ownedHeroes.isEmpty) {
        _ownedHeroes = [CampaignHeroCatalog.starter];
      }
      if (_shopHeroes.isEmpty) {
        _shopHeroes = [CampaignHeroCatalog.starter];
      }
      debugPrint('Unable to load local hero data: $error\n$stackTrace');
    } finally {
      _heroDataLoading = false;
    }
  }

  List<CharacterModel> _withStarterHero(List<CharacterModel> heroes) {
    final hasStarter = heroes.any(
      (hero) => hero.id == CampaignHeroCatalog.starter.id,
    );
    final hasStarterAsset = heroes.any(
      (hero) => hero.filename == CampaignHeroCatalog.starter.filename,
    );
    if (hasStarter || hasStarterAsset) return List.unmodifiable(heroes);
    return List.unmodifiable([CampaignHeroCatalog.starter, ...heroes]);
  }

  void _selectStage(String stageId) {
    _selectedStageId = stageId;
    _snapshot = _createSnapshot(isLoading: false);
    _game.updateSnapshot(_snapshot);
  }

  Future<void> _selectHero(int index) async {
    if (index < 0 || index >= _ownedHeroes.length) return;
    _selectedHeroIndex = index;
    try {
      _campaignProgress = await ref
          .read(campaignProgressRepositoryProvider)
          .selectHero(_ownedHeroes[index].id);
    } catch (error, stackTrace) {
      debugPrint('Unable to save selected campaign hero: $error\n$stackTrace');
    }
    _snapshot = _createSnapshot(isLoading: false);
    _replaceGame();
  }

  Future<void> _purchase(CharacterModel character) async {
    try {
      final repository = ref.read(characterRepoProvider);
      final purchased = await repository.buyCharacter(character.id);
      if (!purchased) return;
      _ownedHeroes = _withStarterHero(await repository.getOwnedCharacters());
      _shopHeroes = _withStarterHero(await repository.getCharacters());
      _shopDataUnavailable = false;
      _gold = await repository.getGoldBalance();
      _snapshot = _createSnapshot(isLoading: false);
      _replaceGame();
    } catch (error, stackTrace) {
      debugPrint('Unable to purchase local hero: $error\n$stackTrace');
    }
  }

  Future<void> _upgradeHero(
    CharacterModel character,
    CharacterAttr attr,
  ) async {
    if (character.sp <= 0) return;
    final updated = await ref
        .read(characterRepoProvider)
        .updateAttr(character.id, attr);
    if (!updated) return;
    _ownedHeroes = _withStarterHero(
      ref.read(characterRepoProvider).ownedCharacters,
    );
    _snapshot = _createSnapshot(isLoading: false);
    _replaceGame();
  }

  Future<void> _selectLocale(AppLocaleMode mode) async {
    await ref.read(appLocaleControllerProvider).setMode(mode);
    await WidgetsBinding.instance.endOfFrame;
    if (!mounted) return;
    _gameLocale = Localizations.localeOf(context);
    _snapshot = _createSnapshot(isLoading: false);
    _replaceGame();
  }

  void _selectPlayMode(GamePlayMode mode) {
    if (_selectedPlayMode == mode) return;
    _selectedPlayMode = mode;
    _snapshot = _createSnapshot(isLoading: false);
    _replaceGame();
  }

  void _onBack() {
    if (_currentPage == widget.initialPage &&
        widget.initialPage != RpgMenuPage.homeHub) {
      final callback = widget.onBack;
      if (callback != null) {
        callback();
      } else if (context.canPop()) {
        context.pop();
      } else {
        context.go(Routes.home);
      }
      return;
    }
    if (_currentPage != RpgMenuPage.homeHub) {
      _game.navigate(RpgMenuPage.homeHub);
      return;
    }
    final callback = widget.onBack;
    if (callback != null) {
      callback();
    } else if (context.canPop()) {
      context.pop();
    } else {
      context.go(Routes.home);
    }
  }

  void _launchStage(CampaignStageModel stage, CharacterModel hero) {
    Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (_) => GameView(
          campaignStage: stage,
          character: hero,
          playMode: _selectedPlayMode,
          onCampaignStageCompleted: _completeCampaignStage,
          onContinueCampaign: _returnToCampaignMap,
          onReturnToCampaign: _returnToCampaignMap,
        ),
      ),
    );
  }

  Future<CampaignStageCompletion> _completeCampaignStage(
    CampaignStageModel stage,
  ) async {
    final completion = await ref
        .read(campaignProgressRepositoryProvider)
        .completeStage(stage);
    _campaignProgress = completion.progress;
    _snapshot = _createSnapshot(isLoading: false);
    _game.updateSnapshot(_snapshot);
    return completion;
  }

  void _returnToCampaignMap() {
    _game.navigate(RpgMenuPage.campaignMap);
    if (Navigator.of(context).canPop()) Navigator.of(context).pop();
  }
}
