import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gunwave/data/constants/game/game_map.dart';
import 'package:gunwave/theme/app_colors.dart';
import 'package:gunwave/views/game/game_view_model.dart';
import 'package:gunwave/views/game/gunwave.dart';
import 'package:gunwave/widgets/app_button.dart';
import 'package:gunwave/widgets/base/base_view.dart';

class GameView extends BaseView {
  const GameView({
    required this.map,
    this.joystickEnabled = false,
    super.key,
  });

  final GameMap map;
  final bool joystickEnabled;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() {
    return GameViewState();
  }
}

class GameViewState extends BaseViewState<GameView, GameViewModel> {
  @override
  Widget getView() {
    return Scaffold(
      body: GameWidget(game: Gunwave(
        ref,
        map: widget.map,
        isJoystickEnabled: widget.joystickEnabled,
        onStageCompleted: onStageCompleted,
        onStageFailed: onStageFailed,
      )),
    );
  }

  void onStageCompleted() {
    showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black.withOpacity(0.2),
      builder: (context) => Dialog(
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            color: kColorSuccess.withOpacity(0.20),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text("Stage Completed!"),
              const SizedBox(height: 16),
              AppButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  Navigator.of(context).pop();
                },
                child: const Text("Continue"),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  void onStageFailed() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            color: kColorError.withOpacity(0.20),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text("Stage Failed!"),
              const SizedBox(height: 16),
              AppButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  Navigator.of(context).pop();
                },
                child: const Text("Retry"),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  GameViewModel getViewModel() {
    return ref.read(gameViewModel);
  }
}