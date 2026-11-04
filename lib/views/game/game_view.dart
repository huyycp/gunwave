import 'dart:async';

import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gunwave/data/constants/game/game_play_mode.dart';
import 'package:gunwave/data/models/campaign_progress_model.dart';
import 'package:gunwave/data/models/campaign_stage_model.dart';
import 'package:gunwave/data/models/character_model.dart';
import 'package:gunwave/data/models/reward_model.dart';
import 'package:gunwave/localization/build_context_l10n.dart';
import 'package:gunwave/l10n/app_localizations.dart';
import 'package:gunwave/views/game/game_view_model.dart';
import 'package:gunwave/views/game/gunwave.dart';
import 'package:gunwave/views/game/ui/campaign_ui_labels.dart';
import 'package:gunwave/widgets/base/base_view.dart';

class GameView extends BaseView {
  const GameView({
    required this.campaignStage,
    required this.character,
    required this.playMode,
    required this.onCampaignStageCompleted,
    this.onContinueCampaign,
    this.onReturnToCampaign,
    super.key,
  });

  final CampaignStageModel campaignStage;
  final CharacterModel character;
  final GamePlayMode playMode;
  final Future<CampaignStageCompletion> Function(CampaignStageModel stage)
  onCampaignStageCompleted;
  final VoidCallback? onContinueCampaign;
  final VoidCallback? onReturnToCampaign;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => GameViewState();
}

class GameViewState extends BaseViewState<GameView, GameViewModel> {
  bool _isCompletingStage = false;
  bool _isCampaignPaused = false;
  bool _allowExit = false;
  final _gameFocus = FocusNode();

  late final Gunwave _gunwave = Gunwave(
    ref,
    campaignStage: widget.campaignStage,
    playMode: widget.playMode,
    gameCharacters: widget.character,
    campaignUiLabels: _buildCampaignUiLabels(),
    safeAreaInsets: MediaQuery.paddingOf(context),
    onStageCompleted: onStageCompleted,
    onExitRequested: () => unawaited(_openCampaignPause()),
    onPauseRequested: () => unawaited(_openCampaignPause()),
  );

  @override
  void onReady() {
    super.onReady();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted || !widget.playMode.isGesture) return;
      try {
        await model.startGestureRecognition();
      } catch (error) {
        if (!mounted) return;
        _gunwave.showCampaignNotice(context.l10n.gestureInputUnavailable);
      }
    });
  }

  @override
  void dispose() {
    _gunwave.controlsBlocked = true;
    _gunwave.abilities.dispose();
    _gunwave.character.healthNotifier.dispose();
    _gameFocus.dispose();
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

  Future<void> _openCampaignPause() async {
    if (_isCampaignPaused || _isCompletingStage || _allowExit) return;
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

  void onStageCompleted(bool isSuccess) {
    unawaited(_completeStage(isSuccess));
  }

  Future<void> _completeStage(bool isSuccess) async {
    if (_isCompletingStage) return;
    final strings = context.l10n;
    _isCompletingStage = true;
    _gunwave.controlsBlocked = true;
    if (widget.playMode.isGesture) {
      try {
        await model.stopGestureRecognition();
      } catch (error) {
        debugPrint('Failed to stop gesture recognition: $error');
      }
    }

    var canShowFirstCompletionRewards = false;
    String? progressMessage;
    if (isSuccess) {
      try {
        final completion = await widget.onCampaignStageCompleted(
          widget.campaignStage,
        );
        canShowFirstCompletionRewards = completion.wasFirstCompletion;
        if (!completion.wasFirstCompletion) {
          progressMessage = strings.campaignRewardsAlreadyClaimed;
        }
      } catch (error, stackTrace) {
        debugPrint('Unable to save campaign completion: $error\n$stackTrace');
        progressMessage = strings.campaignProgressSaveFailed;
      }
    }

    final rewardLines = canShowFirstCompletionRewards
        ? widget.campaignStage.rewards
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
          campaignStage: widget.campaignStage,
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
  GameViewModel getViewModel() => ref.read(gameViewModel);
}
