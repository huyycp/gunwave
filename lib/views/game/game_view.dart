import 'dart:async';

import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gunwave/data/constants/game/game_button.dart';
import 'package:gunwave/data/models/character_model.dart';
import 'package:gunwave/data/models/map_model.dart';
import 'package:gunwave/views/game/game_view_model.dart';
import 'package:gunwave/views/game/gunwave.dart';
import 'package:gunwave/views/game/widgets/question_widget.dart';
import 'package:gunwave/views/game/widgets/stage_result_dialog.dart';
import 'package:gunwave/widgets/base/base_view.dart';
import 'package:gunwave/widgets/game/game_button.dart';
import 'package:google_fonts/google_fonts.dart';

class GameView extends BaseView {
  const GameView({
    required this.map,
    required this.character,
    this.joystickEnabled = false,
    super.key,
  });

  final MapModel map;
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
    map: widget.map,
    gameCharacters: widget.character,
    isJoystickEnabled: widget.joystickEnabled,
    onStageCompleted: onStageCompleted,
    onStageFailed: onStageFailed,
    onCharacterReachCheckpoint: onCharacterReachCheckpoint,
  );

  @override
  void onReady() {
    super.onReady();

    // Initialize timer in view model
    model.initializeTimer(widget.map.timeLimit);

    // Start the timer
    model.startTimer(() {
      onStageFailed();
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
    return QuestionWidget(
      widget.map.questions[model.currentQuestionIndex],
      onQuestionAnswered: (isCorrect) {
        debugPrint('Question answered: $isCorrect');
        if (isCorrect) {
          if (model.currentQuestionIndex < widget.map.questions.length - 1) {
            model.setNextQuestion();
          } else {
            onStageCompleted();
          }
        } else {
          // Use view model to decrease time instead of setState
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

  void onStageCompleted() {
    model.stopTimer();
    StageResultDialog.show(
      result: true,
      rewards: widget.map.rewards,
    );
  }

  void onStageFailed() {
    model.stopTimer();
    StageResultDialog.show(
      result: false,
      rewards: widget.map.rewards,
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