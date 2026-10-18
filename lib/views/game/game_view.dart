import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gunwave/data/constants/game/game_button.dart';
import 'package:gunwave/data/constants/game/game_color.dart';
import 'package:gunwave/data/constants/game/game_play_mode.dart';
import 'package:gunwave/data/dtos/req/update_rank_req.dart';
import 'package:gunwave/data/models/character_model.dart';
import 'package:gunwave/data/models/rank_model.dart';
import 'package:gunwave/data/models/room_model.dart';
import 'package:gunwave/views/game/game_view_model.dart';
import 'package:gunwave/views/game/gunwave.dart';
import 'package:gunwave/views/game/widgets/quiz_widget.dart';
import 'package:gunwave/views/game/widgets/stage_result_dialog.dart';
import 'package:gunwave/widgets/base/base_view.dart';
import 'package:gunwave/widgets/game/game_button.dart';
import 'package:google_fonts/google_fonts.dart';

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

  late final Gunwave _gunwave = Gunwave(
    ref,
    map: widget.room.map!,
    playMode: widget.playMode,
    gameCharacters: widget.character,
    onStageCompleted: onStageCompleted,
    onCharacterReachCheckpoint: onCharacterReachCheckpoint,
  );

  @override
  void onReady() {
    super.onReady();

    _gunwave.character.hp;
    model.timeRemaining;
    _gunwave.stage?.monsters;

    // Initialize timer in view model
    model.initializeTimer(widget.room.map!.timeLimit);

    // Start the timer
    model.startTimer(() {
      onStageCompleted(false);
    });

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (widget.playMode.isGesture) {
        try {
          await model.startGestureRecognition();
        } catch (error) {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Gesture recognition failed: $error')),
          );
        }
      }
    });
  }

  @override
  void dispose() {
    model.stopTimer();
    // Stop gesture recognition before detaching the view (BaseWidgetState.dispose
    // will call model.detachView()). This ensures `ref` remains available
    // during shutdown logic inside the model.
    model.stopGestureRecognition();
    super.dispose();
  }

  @override
  Widget getView() {
    ref.watch(gameViewModel);
    return Scaffold(
      body: Stack(
        children: [
          GameWidget(game: _gunwave),
          if (model.isQuizVisible)
            Positioned.fill(
              child: GestureDetector(
                onTap: () {}, // Absorb taps
                behavior: HitTestBehavior.opaque,
                child: Container(),
              ),
            ),
          if (model.isQuizVisible) Positioned.fill(child: _buildQuiz()),
          if (model.isShowQuizBtnVisible)
            Align(
              alignment: Alignment.centerRight,
              child: Padding(
                padding: const EdgeInsets.only(right: 16.0),
                child: _buildShowQuizBtn(),
              ),
            ),
          Positioned(
            top: 16,
            left: 16,
            child: _buildTimeCounter(),
          ),
        ],
      ),
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

  Widget _buildTimeCounter() {
    // Use ValueListenableBuilder to only rebuild the timer widget
    return ValueListenableBuilder<int>(
      valueListenable: model.timeRemaining,
      builder: (context, timeLimit, child) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            image: const DecorationImage(
              image: AssetImage('assets/images/ui/buttons/button_square.png'),
              fit: BoxFit.fill,
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.timer,
                color: Colors.white,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                formatTime(timeLimit),
                style: GoogleFonts.pressStart2p(
                  fontSize: 16,
                  color: timeLimit <= 30
                      ? (timeLimit % 2 == 0 ? Colors.red : Colors.white)
                      : Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // Helper method to format seconds as MM:SS
  String formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  void onStageCompleted(bool isSuccess) async {
    if (_isCompletingStage) return;
    _isCompletingStage = true;
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
        result = await model.rankRepo.updateUserRank(UpdateRankReq(
          characterId: widget.character.id,
          roomId: widget.room.id,
          timeLeft: model.timeRemaining.value,
          monsters: _gunwave.stage?.monsters
                  .map((monster) => (
                        monsterId: monster.monster.id,
                        percentHpLeft:
                            (monster.hp / monster.monster.hp).clamp(0.0, 1.0),
                      ))
                  .toList() ??
              [],
          quizzes: model.quizResult.entries
              .map((entry) => (
                    quizId: widget.room.quizzes[entry.key].id,
                    answer: entry.value.answer,
                    failAttempts: entry.value.failAttempts,
                  ))
              .toList(),
        ));
      } catch (error) {
        rankError = error;
      } finally {
        if (mounted) Navigator.of(context, rootNavigator: true).pop();
      }
    }
    if (!mounted) return;
    StageResultDialog.show(
      result: isSuccess,
      rewards: widget.room.map!.rewards,
      score: result?.score,
      errorMessage: rankError == null ? null : 'Score was not saved.',
    );
  }

  void showOverlay() {
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (context) {
        return const Center(
            child: CircularProgressIndicator(color: GameColors.primary));
      },
    );
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
