import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_riverpod/src/consumer.dart';
import 'package:gunwave/views/game/game_view_model.dart';
import 'package:gunwave/views/game/pixel_adventure.dart';
import 'package:gunwave/widgets/app_button.dart';
import 'package:gunwave/widgets/base/base_view.dart';

class GameView extends BaseView {
  const GameView({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() {
    return GameViewState();
  }
}

class GameViewState extends BaseViewState<GameView, GameViewModel> {
  @override
  Widget getView() {
    return Scaffold(
      body: Stack(
        children: [
          GameWidget(game: PixelAdventure(ref)),
          Positioned(
            top: 20,
            left: 20,
            child: AppButton(
              onPressed: () {
                model.startGestureRecognition();
              },
              child: const Text("Start Gesture Recognition"),
            ),
          ),
          Positioned(
            top: 50,
            left: 20,
            child: AppButton(
              onPressed: () {
                model.stopGestureRecognition();
              },
              child: const Text("Stop Gesture Recognition"),
            ),
          ),
          Positioned(
            top: 70,
            left: 20,
            child: Text(
              ref.watch(gameViewModel.select((value) => value.gesture ?? 'No gesture recognized')),
            ),
          ), 
        ],
      ),
    );
  }

  @override
  GameViewModel getViewModel() {
    return ref.read(gameViewModel);
  }
}