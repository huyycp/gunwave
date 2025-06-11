import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:gunwave/data/constants/game/game_button.dart';
import 'package:gunwave/data/constants/game/game_color.dart';
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
    this.joystickEnabled = false,
    super.key,
  });

  final RoomModel room;
  final CharacterModel character;
  final bool joystickEnabled;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() {
    return GameViewState();
  }
}

class GameViewState extends BaseViewState<GameView, GameViewModel> {
  late final Gunwave _gunwave = Gunwave(
    ref,
    map: widget.room.map!,
    gameCharacters: widget.character,
    isJoystickEnabled: widget.joystickEnabled,
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
  }

  @override
  void dispose() {
    model.stopTimer();
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
          if (model.isQuizVisible)
            Positioned.fill(child: _buildQuiz()),
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
      onQuestionAnswered: (isCorrect) {
        debugPrint('Quiz answered: $isCorrect');
        model.onQuizAnswered(isCorrect);
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
    model.stopTimer();
    RankModel? result;
    if (isSuccess) {
      showOverlay();
      result = await model.rankRepo.updateUserRank(UpdateRankReq(
        characterId: widget.character.id,
        roomId: widget.room.id,
        timeLeft: model.timeRemaining.value,
        timeLimit: widget.room.map!.timeLimit,
        monsters: _gunwave.stage?.monsters.map((monster) => (
          percenHpLeft: monster.hp / monster.monster.hp,
          score: monster.monster.score
        )).toList() ?? [],
        quizzes: model.quizResult.values.map((result) => (
          failAttempts: result.failAttempts,
          isCorrect: result.isCorrect
        )).toList(),
      ));
      context.pop();
    }
    StageResultDialog.show(
      result: isSuccess,
      rewards: widget.room.map!.rewards,
      score: result?.score,
    );
  }

  void showOverlay() {
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (context) {
        return const Center(
          child: CircularProgressIndicator(
            color: GameColors.primary
          )
        );
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