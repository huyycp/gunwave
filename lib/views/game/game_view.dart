import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_riverpod/src/consumer.dart';
import 'package:gunwave/views/game/game_view_model.dart';
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
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AppButton(
              onPressed: () {
                model.startGestureRecognition();
              },
              child: const Text("Start Gesture Recognition"),
            ),
            AppButton(
              onPressed: () {
                model.stopGestureRecognition();
              },
              child: const Text("Stop Gesture Recognition"),
            ),
            Text(
              ref.watch(gameViewModel.select((value) => value.gesture ?? 'No gesture recognized')),
            )
          ],
        ),
      ),
    );
  }

  @override
  GameViewModel getViewModel() {
    return ref.read(gameViewModel);
  }
}