import 'dart:async';

import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:gunwave/data/constants/game/game_hud_style.dart';
import 'package:gunwave/views/game/widgets/player_health_hud.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gunwave/data/constants/game/game_button.dart';
import 'package:gunwave/data/constants/game/game_play_mode.dart';
import 'package:gunwave/data/dtos/req/update_rank_req.dart';
import 'package:gunwave/data/models/campaign_stage_model.dart';
import 'package:gunwave/data/models/campaign_progress_model.dart';
import 'package:gunwave/data/models/character_model.dart';
import 'package:gunwave/data/models/rank_model.dart';
import 'package:gunwave/data/models/reward_model.dart';
import 'package:gunwave/data/models/room_model.dart';
import 'package:gunwave/localization/build_context_l10n.dart';
import 'package:gunwave/l10n/app_localizations.dart';
import 'package:gunwave/views/game/game_view_model.dart';
import 'package:gunwave/views/game/gunwave.dart';
import 'package:gunwave/views/game/ui/campaign_ui_labels.dart';
import 'package:gunwave/views/game/widgets/quiz_widget.dart';
import 'package:gunwave/views/game/widgets/ability_hud.dart';
import 'package:gunwave/views/game/game_touch_control_layout.dart';
import 'package:gunwave/views/game/widgets/stage_result_dialog.dart';
import 'package:gunwave/views/game/widgets/rank_submission_loading_dialog.dart';
import 'package:gunwave/widgets/base/base_view.dart';
import 'package:gunwave/widgets/game/game_button.dart';

class GameView extends BaseView {
  const GameView({
    this.room,
    this.campaignStage,
    required this.character,
    required this.playMode,
    this.onCampaignStageCompleted,
    this.onContinueCampaign,
    this.onReturnToCampaign,
    super.key,
  }) : assert((room != null) != (campaignStage != null));

  final RoomModel? room;
  final CampaignStageModel? campaignStage;
  final CharacterModel character;
  final GamePlayMode playMode;
  final Future<CampaignStageCompletion> Function(CampaignStageModel stage)?
  onCampaignStageCompleted;
  final VoidCallback? onContinueCampaign;
  final VoidCallback? onReturnToCampaign;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() {
    return GameViewState();
  }
}

class GameViewState extends BaseViewState<GameView, GameViewModel> {
  bool _isCompletingStage = false;
  bool _isConfirmingExit = false;
  bool _isCampaignPaused = false;
  bool _allowExit = false;
  DialogRoute<void>? _rankOverlayRoute;
  NavigatorState? _rankOverlayNavigator;
  final _gameFocus = FocusNode();

  late final Gunwave _gunwave = Gunwave(
    ref,
    map: widget.room?.map,
    campaignStage: widget.campaignStage,
    playMode: widget.playMode,
    gameCharacters: widget.character,
    campaignUiLabels: widget.campaignStage == null
        ? null
        : _buildCampaignUiLabels(),
    safeAreaInsets: MediaQuery.paddingOf(context),
    onStageCompleted: onStageCompleted,
    onCharacterReachCheckpoint: onCharacterReachCheckpoint,
    onExitRequested: () => unawaited(
      widget.campaignStage == null ? _requestExit() : _openCampaignPause(),
    ),
    onPauseRequested: () => unawaited(_openCampaignPause()),
  );

  @override
  void onReady() {
    super.onReady();

    final room = widget.room;
    if (room != null) {
      model.initializeTimer(room.map!.timeLimit);
      model.startTimer(() => onStageCompleted(false));
    }

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;
      if (widget.playMode.isGesture) {
        try {
          await model.startGestureRecognition();
        } catch (error) {
          if (!mounted) return;
          if (widget.campaignStage != null) {
            _gunwave.showCampaignNotice(context.l10n.gestureInputUnavailable);
            return;
          }
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                context.l10n.gestureRecognitionFailed(error.toString()),
              ),
            ),
          );
        }
      }
    });
  }

  @override
  void dispose() {
    _gunwave.controlsBlocked = true;
    _gunwave.abilities.dispose();
    _gunwave.character.healthNotifier.dispose();
    _gameFocus.dispose();
    model.stopTimer();
    // Stop gesture recognition before detaching the view (BaseWidgetState.dispose
    // will call model.detachView()). This ensures `ref` remains available
    // during shutdown logic inside the model.
    unawaited(_stopGestureRecognitionOnDispose());
    super.dispose();
  }

  Future<void> _stopGestureRecognitionOnDispose() async {
    try {
      await model.stopGestureRecognition();
    } catch (error) {
      debugPrint('Failed to stop gesture recognition: $error');
    }
  }

  @override
  Widget getView() {
    ref.watch(gameViewModel);
    if (widget.campaignStage != null) {
      _gunwave.controlsBlocked = _isCampaignPaused || _isCompletingStage;
      return PopScope(
        canPop: _allowExit || _isCompletingStage,
        onPopInvokedWithResult: (didPop, _) {
          if (!didPop) unawaited(_openCampaignPause());
        },
        child: Scaffold(
          backgroundColor: Colors.black,
          body: GameWidget(game: _gunwave, focusNode: _gameFocus),
        ),
      );
    }

    final touchAbilityInsets = GameTouchControlLayout.abilityInsets(
      MediaQuery.paddingOf(context),
    );
    _gunwave.controlsBlocked =
        model.isQuizVisible || _isCompletingStage || _isConfirmingExit;
    return PopScope(
      canPop: _allowExit || _isCompletingStage,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) unawaited(_requestExit());
      },
      child: Scaffold(
        body: Stack(
          children: [
            GameWidget(game: _gunwave, focusNode: _gameFocus),
            if (widget.playMode.isKeyboard && !model.isQuizVisible)
              Positioned(
                bottom: GameHudStyle.edge,
                left: GameHudStyle.edge,
                right: GameHudStyle.edge,
                child: IgnorePointer(
                  child: SafeArea(
                    top: false,
                    child: Text(
                      _gunwave.abilities.ability == null
                          ? context.l10n.keyboardControlsGuide
                          : context.l10n.keyboardAbilityControlsGuide,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: GameHudStyle.guideFontSize,
                        color: GameHudStyle.foreground,
                        shadows: [Shadow(blurRadius: 2, color: Colors.black)],
                      ),
                    ),
                  ),
                ),
              ),
            if (model.isQuizVisible)
              Positioned.fill(
                child: GestureDetector(
                  onTap: () {},
                  behavior: HitTestBehavior.opaque,
                  child: Container(),
                ),
              ),
            if (model.isQuizVisible) Positioned.fill(child: _buildQuiz()),
            if (model.isShowQuizBtnVisible)
              Align(
                alignment: Alignment.centerRight,
                child: Padding(
                  padding: const EdgeInsets.only(right: 16),
                  child: _buildShowQuizBtn(),
                ),
              ),
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: SafeArea(
                bottom: false,
                minimum: const EdgeInsets.all(GameHudStyle.edge),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Align(
                        alignment: Alignment.topLeft,
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(
                            maxWidth: GameHudStyle.playerPanelMaxWidth,
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                flex: 3,
                                child: PlayerHealthHud(
                                  health: _gunwave.character.healthNotifier,
                                  maxHealth: widget.character.hp,
                                ),
                              ),
                              if (widget.playMode.isKeyboard &&
                                  _gunwave.abilities.ability != null &&
                                  !model.isQuizVisible) ...[
                                const SizedBox(width: GameHudStyle.gap),
                                Flexible(
                                  flex: 2,
                                  child: _buildAbilityControls(),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: GameHudStyle.gap),
                    _buildTimeCounter(),
                    IconButton.filledTonal(
                      tooltip: context.l10n.exitStage,
                      onPressed: _isCompletingStage || _isConfirmingExit
                          ? null
                          : () => unawaited(_requestExit()),
                      icon: const Icon(Icons.logout),
                    ),
                  ],
                ),
              ),
            ),
            if (!widget.playMode.isKeyboard &&
                _gunwave.abilities.ability != null &&
                !model.isQuizVisible)
              Positioned(
                right: touchAbilityInsets.right,
                bottom: touchAbilityInsets.bottom,
                child: _buildAbilityControls(),
              ),
          ],
        ),
      ),
    );
  }

  /// Pauses combat and the stage timer while confirming a deliberate exit.
  Future<void> _requestExit() async {
    if (_isConfirmingExit || _isCompletingStage || _allowExit) return;
    setState(() => _isConfirmingExit = true);
    _gunwave.controlsBlocked = true;
    model.stopTimer();
    final leave = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(context.l10n.exitStage),
        content: Text(context.l10n.exitStageConfirmation),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(context.l10n.keepPlaying),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(context.l10n.exitStage),
          ),
        ],
      ),
    );
    if (!mounted) return;
    if (leave == true) {
      setState(() => _allowExit = true);
      // PopScope must rebuild before the deliberate route pop is allowed.
      await WidgetsBinding.instance.endOfFrame;
      if (mounted) Navigator.of(context).pop();
      return;
    }
    setState(() => _isConfirmingExit = false);
    _gunwave.controlsBlocked = model.isQuizVisible || _isCompletingStage;
    if (!_isCompletingStage) model.startTimer(() => onStageCompleted(false));
    if (widget.playMode.isKeyboard) _gameFocus.requestFocus();
  }

  /// Opens the asset-rendered campaign pause and deliberate-exit confirmation.
  Future<void> _openCampaignPause() async {
    if (widget.campaignStage == null ||
        _isCampaignPaused ||
        _isCompletingStage ||
        _allowExit) {
      return;
    }
    setState(() => _isCampaignPaused = true);
    _gunwave.controlsBlocked = true;
    await _gunwave.showPauseMenu(
      onResume: () {
        if (!mounted) return;
        setState(() => _isCampaignPaused = false);
        if (widget.playMode.isKeyboard) _gameFocus.requestFocus();
      },
      onExitConfirmed: () => unawaited(_exitCampaign()),
    );
  }

  Future<void> _exitCampaign() async {
    if (!mounted || _allowExit || _isCompletingStage) return;
    setState(() {
      _allowExit = true;
      _isCampaignPaused = false;
    });
    await WidgetsBinding.instance.endOfFrame;
    if (mounted) Navigator.of(context).pop();
  }

  Widget _buildAbilityControls() {
    return AbilityHud(
      controller: _gunwave.abilities,
      isKeyboard: widget.playMode.isKeyboard,
      onActivate: () {
        _gunwave.activateAbility();
        if (widget.playMode.isKeyboard) _gameFocus.requestFocus();
      },
    );
  }

  Widget _buildShowQuizBtn() {
    return GameButton(
      onPressed: () {
        model.toggleQuizVisible();
      },
      size: GameButtonSize.small,
      child: const Text('>'),
    );
  }

  Widget _buildQuiz() {
    final room = widget.room!;
    // Quiz doesn't depend on time now
    return QuizWidget(
      room.quizzes[model.currentQuizIndex],
      onQuestionAnswered: (answer) {
        final isCorrect = answer == room.quizzes[model.currentQuizIndex].answer;
        debugPrint('Quiz answered: $isCorrect');
        model.onQuizAnswered(answer, isCorrect);
        if (isCorrect) {
          if (model.currentQuizIndex < room.quizzes.length - 1) {
            model.setNextQuiz();
          } else {
            onStageCompleted(true);
          }
        } else {
          model.decreaseTime(5);
        }
      },
    );
  }

  Widget _buildTimeCounter() => ValueListenableBuilder<int>(
    valueListenable: model.timeRemaining,
    builder: (context, timeLimit, _) => Container(
      padding: const EdgeInsets.all(GameHudStyle.gap),
      decoration: BoxDecoration(
        color: GameHudStyle.panel,
        borderRadius: BorderRadius.circular(GameHudStyle.gap),
      ),
      child: Text(
        formatTime(timeLimit),
        style: const TextStyle(
          fontSize: GameHudStyle.labelFontSize,
          color: GameHudStyle.foreground,
        ),
      ),
    ),
  );

  // Helper method to format seconds as MM:SS
  String formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  void onStageCompleted(bool isSuccess) {
    unawaited(_completeStage(isSuccess));
  }

  Future<void> _completeStage(bool isSuccess) async {
    if (_isCompletingStage) return;
    final campaignStrings = widget.campaignStage == null ? null : context.l10n;
    _isCompletingStage = true;
    _gunwave.controlsBlocked = true;
    model.stopTimer();
    if (widget.playMode.isGesture) {
      try {
        await model.stopGestureRecognition();
      } catch (error) {
        debugPrint('Failed to stop gesture recognition: $error');
      }
    }

    final campaignStage = widget.campaignStage;
    if (campaignStage != null) {
      var canShowFirstCompletionRewards = isSuccess;
      String? progressMessage;
      final strings = campaignStrings!;
      final completionHandler = widget.onCampaignStageCompleted;
      if (isSuccess && completionHandler != null) {
        try {
          final completion = await completionHandler(campaignStage);
          canShowFirstCompletionRewards = completion.wasFirstCompletion;
          if (!completion.wasFirstCompletion) {
            progressMessage = strings.campaignRewardsAlreadyClaimed;
          }
        } catch (error, stackTrace) {
          debugPrint('Unable to save campaign completion: $error\n$stackTrace');
          canShowFirstCompletionRewards = false;
          progressMessage = strings.campaignProgressSaveFailed;
        }
      }
      final rewardLines = canShowFirstCompletionRewards
          ? campaignStage.rewards
                .map((reward) => _formatCampaignReward(reward, strings))
                .toList()
          : const <String>[];
      if (!mounted) return;
      await _gunwave.showStageResult(
        isSuccess: isSuccess,
        rewardLines: rewardLines,
        progressMessage: progressMessage,
        onRetry: () => unawaited(_retryCampaignStage()),
        onContinue: widget.onContinueCampaign,
        onCampaign: _returnToCampaign,
      );
      return;
    }

    RankModel? result;
    Object? rankError;
    if (isSuccess) {
      showOverlay();
      try {
        result = await model.rankRepo.updateUserRank(
          UpdateRankReq(
            characterId: widget.character.id,
            roomId: widget.room!.id,
            timeLeft: model.timeRemaining.value,
            monsters:
                _gunwave.stage?.monsters
                    .map(
                      (monster) => (
                        monsterId: monster.monster.id,
                        percentHpLeft: (monster.hp / monster.monster.hp).clamp(
                          0.0,
                          1.0,
                        ),
                      ),
                    )
                    .toList() ??
                [],
            quizzes: model.quizResult.entries
                .map(
                  (entry) => (
                    quizId: widget.room!.quizzes[entry.key].id,
                    answer: entry.value.answer,
                    failAttempts: entry.value.failAttempts,
                  ),
                )
                .toList(),
          ),
        );
      } catch (error) {
        rankError = error;
      } finally {
        _dismissRankOverlay();
      }
    }
    if (!mounted) return;
    StageResultDialog.show(
      result: isSuccess,
      rewards: widget.room!.map!.rewards,
      score: result?.score,
      errorMessage: rankError == null ? null : context.l10n.scoreNotSaved,
    );
  }

  void showOverlay() {
    final navigator = Navigator.of(context, rootNavigator: true);
    final route = DialogRoute<void>(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black54,
      barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
      builder: (_) => const RankSubmissionLoadingDialog(),
    );
    _rankOverlayNavigator = navigator;
    _rankOverlayRoute = route;
    unawaited(navigator.push<void>(route));
  }

  void _dismissRankOverlay() {
    final route = _rankOverlayRoute;
    final navigator = _rankOverlayNavigator;
    _rankOverlayRoute = null;
    _rankOverlayNavigator = null;
    if (route != null && navigator?.mounted == true && route.isActive) {
      navigator!.removeRoute(route);
    }
  }

  void onCharacterReachCheckpoint(bool isReached) {
    debugPrint('Character reached checkpoint: $isReached');
    model.setShowQuizBtnVisible(isReached);
  }

  CampaignUiLabels _buildCampaignUiLabels() {
    final l10n = context.l10n;
    return CampaignUiLabels(
      health: l10n.healthPoints,
      boss: l10n.boss,
      specialAbility: l10n.specialAbility,
      ready: l10n.abilityReady,
      paused: l10n.paused,
      resume: l10n.resume,
      exitStage: l10n.exitStage,
      exitConfirmation: l10n.pauseExitPrompt,
      completed: l10n.completed,
      failed: l10n.failed,
      rewards: l10n.rewards,
      rewardsAlreadyClaimed: l10n.campaignRewardsAlreadyClaimed,
      progressSaveFailed: l10n.campaignProgressSaveFailed,
      retry: l10n.retry,
      continueCampaign: l10n.continueCampaign,
      campaign: l10n.campaign,
      keyboardGuide: l10n.keyboardControlsGuide,
      keyboardAbilityGuide: l10n.keyboardAbilityControlsGuide,
      gestureInputUnavailable: l10n.gestureInputUnavailable,
      abilityCooldown: l10n.abilityCooldownHud,
      abilityActive: l10n.abilityActiveHud,
      roundProgress: l10n.roundLabel,
    );
  }

  String _formatCampaignReward(RewardModel reward, AppLocalizations strings) {
    final label = switch (reward.type) {
      RewardType.gold => strings.rewardGold,
      RewardType.sp => strings.rewardStatusPoints,
      RewardType.unknown => strings.rewardUnknown,
    };
    return '${reward.amount} $label';
  }

  Future<void> _retryCampaignStage() async {
    if (!mounted) return;
    await Navigator.of(context).pushReplacement<void, void>(
      MaterialPageRoute<void>(
        builder: (_) => GameView(
          campaignStage: widget.campaignStage!,
          character: widget.character,
          playMode: widget.playMode,
          onCampaignStageCompleted: widget.onCampaignStageCompleted,
          onContinueCampaign: widget.onContinueCampaign,
          onReturnToCampaign: widget.onReturnToCampaign,
        ),
      ),
    );
  }

  void _returnToCampaign() {
    final callback = widget.onReturnToCampaign;
    if (callback != null) {
      callback();
    } else if (mounted) {
      Navigator.of(context).pop();
    }
  }

  @override
  GameViewModel getViewModel() {
    return ref.read(gameViewModel);
  }
}
