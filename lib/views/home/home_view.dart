import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:gunwave/routes.dart';
import 'package:gunwave/views/home/widgets/background.dart';
import 'package:gunwave/views/home/widgets/lobby.dart';
import 'package:gunwave/views/home/home_view_model.dart';
import 'package:gunwave/views/home/widgets/login_widget.dart';
import 'package:gunwave/widgets/base/base_view.dart';
import 'package:gunwave/widgets/game/game_button.dart';

class HomeView extends BaseView {
  const HomeView({super.key});

  @override
  ConsumerState<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends BaseViewState<HomeView, HomeViewModel> {
  @override
  void onReady() {
    super.onReady();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (model.userRepo.user != null) {
        debugPrint("User: ${model.userRepo.user}");
        model.toggleLoginForm();
        model.userRepo.getAppUser().then((_) {
          model.getCharacters();
        });
      }
    });
  }

  @override
  Widget getView() {
    ref.watch(homeViewModel);
    return Scaffold(
      body: Stack(
        children: [
          _buildBackground(),
          if (model.isStatusBoardVisible)
            ..._buildStatusBoard()
          else Center(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                GameButton(
                  onPressed: () {
                    context.push(Routes.map);
                  },
                  child: const Text('Play')
                ),
                if (model.characters.isNotEmpty) GameButton(
                  onPressed: () {
                    model.toggleStatusBoard();
                  },
                  child: const Text('Status')
                ),
              ],
            ),
          ),
          if (model.isLoginFormVisible)
            Center(
              child: _buildLoginForm(),
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
  
  List<Widget> _buildStatusBoard() {
    return [
      Center(
        child: LobbyWidget(characters: model.characters),
      ),
      Positioned(
        top: 8,
        left: 8,
        child: GameButton(
          onPressed: () {
            model.toggleStatusBoard();
          },
          child: const Text('Back')
        ),
      ),
    ];
  }

  Widget _buildLoginForm() {
    return LoginWidget((isDone) {
      if (isDone) {
        model.toggleLoginForm();
        model.getCharacters();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Login failed'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    });
  }

  @override
  HomeViewModel getViewModel() {
    return ref.read(homeViewModel);
  }
}