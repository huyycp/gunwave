import 'dart:async';

import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:gunwave/data/constants/game/game_hud_style.dart';
import 'package:gunwave/views/game/widgets/player_health_hud.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gunwave/data/constants/game/game_button.dart';
import 'package:gunwave/data/constants/game/game_play_mode.dart';
import 'package:gunwave/data/dtos/req/update_rank_req.dart';
import 'package:gunwave/data/models/character_model.dart';
import 'package:gunwave/data/models/rank_model.dart';
import 'package:gunwave/data/models/room_model.dart';
import 'package:gunwave/localization/build_context_l10n.dart';
import 'package:gunwave/views/game/game_view_model.dart';
import 'package:gunwave/views/game/gunwave.dart';
import 'package:gunwave/views/game/widgets/quiz_widget.dart';
import 'package:gunwave/views/game/widgets/ability_hud.dart';
import 'package:gunwave/views/game/widgets/stage_result_dialog.dart';
import 'package:gunwave/views/game/widgets/rank_submission_loading_dialog.dart';
import 'package:gunwave/widgets/base/base_view.dart';
import 'package:gunwave/widgets/game/game_button.dart';

class GameView extends BaseView {
  const GameView({
    required this.room,
    required this.character,
    required this.playMode,
    super.key,
  });

  final RoomModel room;
  final CharacterModel character;
  final GamePlayMode playMode;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() {
    return GameViewState();
  }
}

class GameViewState extends BaseViewState<GameView, GameViewModel> {
  bool _isCompletingStage = false;
  bool _isConfirmingExit = false;
  bool _allowExit = false;
  DialogRoute<void>? _rankOverlayRoute;
  NavigatorState? _rankOverlayNavigator;
  final _gameFocus = FocusNode();

  late final Gunwave _gunwave = Gunwave(
    ref,
    map: widget.room.map!,
    playMode: widget.playMode,
    gameCharacters: widget.character,
    onStageCompleted: onStageCompleted,
    onCharacterReachCheckpoint: onCharacterReachCheckpoint,
    onExitRequested: () => unawaited(_requestExit()),
  );

  @override
  void onReady() {
    super.onReady();

    // Initialize timer in view model
    model.initializeTimer(widget.room.map!.timeLimit);

    // Start the timer
    model.startTimer(() {
      onStageCompleted(false);
    });

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;
      if (widget.playMode.isGesture) {
        try {
          await model.startGestureRecognition();
        } catch (error) {
          if (!mounted) return;
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
                right: GameHudStyle.touchRight,
                bottom: GameHudStyle.touchBottom,
                child: SafeArea(
                  top: false,
                  left: false,
                  child: _buildAbilityControls(),
                ),
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
    // Quiz doesn't depend on time now
    return QuizWidget(
      widget.room.quizzes[model.currentQuizIndex],
      onQuestionAnswered: (answer) {
        final isCorrect =
            answer == widget.room.quizzes[model.currentQuizIndex].answer;
        debugPrint('Quiz answered: $isCorrect');
        model.onQuizAnswered(answer, isCorrect);
        if (isCorrect) {
          if (model.currentQuizIndex < widget.room.quizzes.length - 1) {
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

    RankModel? result;
    Object? rankError;
    if (isSuccess) {
      showOverlay();
      try {
        result = await model.rankRepo.updateUserRank(
          UpdateRankReq(
            characterId: widget.character.id,
            roomId: widget.room.id,
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
                    quizId: widget.room.quizzes[entry.key].id,
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
      rewards: widget.room.map!.rewards,
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

  @override
  GameViewModel getViewModel() {
    return ref.read(gameViewModel);
  }
}
