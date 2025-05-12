import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gunwave/data/models/character_model.dart';
import 'package:gunwave/data/models/map_model.dart';
import 'package:gunwave/theme/app_colors.dart';
import 'package:gunwave/views/character/character_view_model.dart';
import 'package:gunwave/views/game/game_view_model.dart';
import 'package:gunwave/views/game/gunwave.dart';
import 'package:gunwave/views/game/widgets/stage_result_dialog.dart';
import 'package:gunwave/widgets/app_button.dart';
import 'package:gunwave/widgets/base/base_view.dart';

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
  @override
  Widget getView() {
    return Scaffold(
      body: GameWidget(game: Gunwave(
        ref,
        map: widget.map,
        gameCharacters: widget.character,
        isJoystickEnabled: widget.joystickEnabled,
        onStageCompleted: onStageCompleted,
        onStageFailed: onStageFailed,
      )),
    );
  }

  void onStageCompleted() {
    StageResultDialog.show(
      result: true,
      rewards: widget.map.rewards,
    );
  }
  
  void onStageFailed() {
    StageResultDialog.show(
      result: false,
      rewards: widget.map.rewards,
    );
  }

  @override
  GameViewModel getViewModel() {
    return ref.read(gameViewModel);
  }
}