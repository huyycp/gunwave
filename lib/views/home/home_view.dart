import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:gunwave/data/constants/game/game_map.dart';
import 'package:gunwave/routes.dart';
import 'package:gunwave/views/home/widgets/background.dart';
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
 late final _background = GameWidget(game: FlameGame(
    world: Background(
      backgroundPath: GameMaps.background,
      screenSize: Vector2(MediaQuery.sizeOf(context).width, MediaQuery.sizeOf(context).height),
    ),
    camera: CameraComponent()
      ..viewfinder.anchor = Anchor.topLeft
      ..viewfinder.zoom = 1.0  // Use full size since we're scaling the component
  ));
 
  @override
  void onReady() {
    super.onReady();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (model.userRepo.appUser == null) {
        // debugPrint("User: ${model.userRepo.user}");
        model.toggleLoginForm();
      // model.userRepo.getAppUser();
      }
    });
  }

  @override
  Widget getView() {
    ref.watch(homeViewModel);
    return Scaffold(
      body: Stack(
        children: [
          _background,
          Center(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                GameButton(
                  onPressed: () {
                    context.push(Routes.map);
                  },
                  child: const Text('Maps')
                ),
                GameButton(
                  onPressed: () {
                    context.push(Routes.character);
                  },
                  child: const Text('Champs')
                ),
                GameButton(
                  onPressed: () {
                    context.push(Routes.shop);
                  },
                  child: const Text('Shop')
                ),
                GameButton(
                  onPressed: () {
                    context.push(Routes.shop);
                  },
                  child: const Text('Shop')
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

  Widget _buildLoginForm() {
    return LoginWidget((isDone) {
      if (isDone) {
        model.toggleLoginForm();
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