import 'dart:async';

import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:gunwave/data/constants/game/game_play_mode.dart';
import 'package:gunwave/data/models/campaign_stage_model.dart';
import 'package:gunwave/data/models/character_model.dart';
import 'package:gunwave/l10n/app_localizations.dart';
import 'package:gunwave/localization/app_locale_controller.dart';
import 'package:gunwave/localization/app_locale_mode.dart';
import 'package:gunwave/repositories/campaign_repository.dart';
import 'package:gunwave/repositories/character_repository.dart';
import 'package:gunwave/repositories/user_repository.dart';
import 'package:gunwave/routes.dart';
import 'package:gunwave/views/character/character_view_model.dart';
import 'package:gunwave/views/game/game_view.dart';
import 'package:gunwave/views/rpg_ui/rpg_menu_game.dart';
import 'package:gunwave/views/rpg_ui/rpg_menu_models.dart';
import 'package:gunwave/views/shop/shop_view_model.dart';

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
  RpgMenuPage? _previousPage;
  List<CampaignStageModel> _stages = const [];
  List<CharacterModel> _ownedHeroes = const [];
  List<CharacterModel> _shopHeroes = const [];
  int _selectedHeroIndex = 0;
  int _gold = 0;
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
      if (_pageNeedsHeroes(widget.initialPage)) {
        _gold = ref.read(userRepoProvider).appUser?.gold ?? 0;
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
    clearedStageIds: const {},
    gold: _gold,
    selectedHeroIndex: _selectedHeroIndex,
    selectedStageId: _selectedStageId,
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
    showHubBackButton: widget.initialPage != RpgMenuPage.homeHub,
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
      final shopModel = ref.read(shopViewModel);
      await shopModel.getCharacters();
      final characterRepository = ref.read(characterRepoProvider);
      _ownedHeroes = List.unmodifiable(characterRepository.ownedCharacters);
      _shopHeroes = List.unmodifiable(shopModel.characters);
      _gold = ref.read(userRepoProvider).appUser?.gold ?? shopModel.userBalance;
      _selectedHeroIndex = ref
          .read(characterViewModel)
          .selectedCharacterIndex
          .clamp(0, _ownedHeroes.isEmpty ? 0 : _ownedHeroes.length - 1)
          .toInt();
      _heroDataLoaded = true;
    } finally {
      _heroDataLoading = false;
    }
  }

  void _selectStage(String stageId) {
    _selectedStageId = stageId;
    _snapshot = _createSnapshot(isLoading: false);
    _game.updateSnapshot(_snapshot);
  }

  void _selectHero(int index) {
    ref.read(characterViewModel).onCharacterSelected(index);
    _selectedHeroIndex = index;
    _ownedHeroes = List.unmodifiable(
      ref.read(characterRepoProvider).ownedCharacters,
    );
    _snapshot = _createSnapshot(isLoading: false);
    _replaceGame();
  }

  Future<void> _purchase(CharacterModel character) async {
    await ref.read(shopViewModel).buyCharacter(character);
    final userId = ref.read(userRepoProvider).appUser?.id;
    if (userId != null) {
      _ownedHeroes = List.unmodifiable(
        await ref.read(characterRepoProvider).getOwnedCharacters(userId),
      );
    }
    final shopModel = ref.read(shopViewModel);
    _shopHeroes = List.unmodifiable(shopModel.characters);
    _gold = ref.read(userRepoProvider).appUser?.gold ?? shopModel.userBalance;
    _snapshot = _createSnapshot(isLoading: false);
    _replaceGame();
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
    _ownedHeroes = List.unmodifiable(
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
          playMode: GamePlayMode.joystick,
          onContinueCampaign: _returnToCampaignMap,
          onReturnToCampaign: _returnToCampaignMap,
        ),
      ),
    );
  }

  void _returnToCampaignMap() {
    _game.navigate(RpgMenuPage.campaignMap);
    if (Navigator.of(context).canPop()) Navigator.of(context).pop();
  }
}
