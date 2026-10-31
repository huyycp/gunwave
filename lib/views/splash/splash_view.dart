import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gunwave/data/constants/app_constant.dart';
import 'package:gunwave/data/constants/game/game_color.dart';
import 'package:gunwave/data/constants/game/game_map.dart';
import 'package:gunwave/gen/assets.gen.dart';
import 'package:gunwave/views/home/widgets/background.dart';
import 'package:gunwave/views/splash/splash_view_model.dart';
import 'package:gunwave/widgets/base/base_view.dart';

class SplashView extends BaseView {
  const SplashView({super.key});

  @override
  ConsumerState<SplashView> createState() => _SplashViewState();
}

class _SplashViewState extends BaseViewState<SplashView, SplashViewModel> {
  late final Widget _background = GameWidget(game: FlameGame(
    world: Background(
      backgroundPath: GameMaps.loading,
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
        model.init(openApp);
    });
  }
  
  @override
  Widget getView() {
    return Scaffold(
      body: Center(
        child: Stack(
          children: [
            _background,
            Positioned.fill(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    Assets.images.buildings.tower.towerBlue.path,
                    width: 160,
                    height: 160,
                  ),
                  const SizedBox(height: 24),
                  Text(
                    AppConstant.appName,
                    style: GoogleFonts.pressStart2p(
                      fontSize: 32,
                      color: GameColors.primary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  SplashViewModel getViewModel() {
    return ref.read(splashViewModel);
  }
}