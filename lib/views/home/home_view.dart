import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gunwave/views/game/game_view.dart';
import 'package:gunwave/views/home/widgets/background.dart';
import 'package:gunwave/views/home/widgets/lobby.dart';
import 'package:gunwave/views/home/home_view_model.dart';
import 'package:gunwave/widgets/base/base_view.dart';
import 'package:gunwave/widgets/game/game_button.dart';

class HomeView extends BaseView {
  const HomeView({super.key});

  @override
  ConsumerState<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends BaseViewState<HomeView, HomeViewModel> {
  bool joystickEnabled = false;

  @override
  Widget getView() {
    ref.watch(homeViewModel);
    return Scaffold(
      body: Stack(
        children: [
          _buildBackground(),
          if (model.isStatusBoardVisible) ...[
            const Center(
              child: LobbyWidget(),
            ),
            Positioned(
              top: 8,
              left: 8,
              child: GameButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => GameView(joystickEnabled: joystickEnabled),
                    ),
                  );
                },
                child: const Text('Fight')
              ),
            ),
          ] else Center(
            child: GameButton(
              onPressed: () {
                model.toggleStatusBoard();
              },
              child: const Text('Play')
            ),
          )
        ],
      ),
    );
  }

  Widget _buildBackground() {
    final screenSize = MediaQuery.of(context).size;
    
    return GameWidget(game: FlameGame(
      world: Background(
        screenSize: Vector2(screenSize.width, screenSize.height),
      ),
      camera: CameraComponent()
        ..viewfinder.anchor = Anchor.topLeft
        ..viewfinder.zoom = 1.0  // Use full size since we're scaling the component
    ));
  }

  @override
  HomeViewModel getViewModel() {
    return ref.read(homeViewModel);
  }
}