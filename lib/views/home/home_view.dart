import 'package:flame/camera.dart';
import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gunwave/views/game/game_view.dart';
import 'package:gunwave/views/home/widgets/background.dart';
import 'package:gunwave/views/home/widgets/lobby.dart';
import 'package:gunwave/views/test_recognizer/test_recognizer.dart';
import 'package:gunwave/views/home/home_view_model.dart';
import 'package:gunwave/widgets/app_button.dart';
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
    return Scaffold(
      body: Stack(
        children: [
          _buildBackground(),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // AppButton(
                //   onPressed: () {
                //     Navigator.push(
                //       context,
                //       MaterialPageRoute(
                //         builder: (context) => GameView(joystickEnabled: joystickEnabled),
                //       ),
                //     );
                //   },
                //   child: const Text('Game'),
                // ),
                // const SizedBox(height: 16),
                // AppButton(
                //   onPressed: () {
                //     Navigator.push(
                //       context,
                //       MaterialPageRoute(
                //         builder: (context) => const GestureRecognizerApp(),
                //       ),
                //     );
                //   },
                //   child: const Text('Test Recognizer'),
                // ),
                // const SizedBox(height: 16),
                // AppButton(
                //   onPressed: () {
                //     setState(() {
                //       joystickEnabled = !joystickEnabled;
                //     });
                //   },
                //   child: Text('Joystick $joystickEnabled'),
                // ),
                // const SizedBox(height: 16),
                LobbyWidget(),
              ],
            ),
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
                    child: const Text('Play')
                  ),
                ),
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