import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gunwave/data/constants/game/game_button.dart';
import 'package:gunwave/data/constants/game/game_color.dart';
import 'package:gunwave/data/constants/game/game_map.dart';
import 'package:gunwave/data/constants/game/game_ui.dart';
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
          if (model.userRepo.appUser != null) ...[
            Positioned(
              top: 16,
              left: 48,
              child: _buildUserInfo(),
            ),
            Positioned(
              top: 16,
              right: 48,
              child: _buildUserGold(),
            ),
            Positioned(
              bottom: 16,
              left: 48,
              child: _buildShopBtn(),
            ),
            Positioned(
              bottom: 16,
              left: 116,
              child: _buildCharacterBtn(),
            ),
            Positioned(
              bottom: 16,
              left: 184,
              child: _buildMyRoomBtn(),
            ),
            Positioned(
              bottom: 16,
              right: 32,
              child: _buildPlayBtn(),
            ),
          ] else Center(
              child: _buildLoginForm(),
            ),
        ],
      ),
    );
  }

  Widget _buildUserInfo() {
    return Text(
      model.userRepo.appUser?.name ?? 'Guest',
      style: GoogleFonts.pressStart2p(
        color: GameColors.primary,
        fontSize: 20,
      ),
    );
  }

  Widget _buildUserGold() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage(GameBanners.carvedSlide.path),
          fit: BoxFit.cover,
        ),
        // color: Colors.red,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.monetization_on,
            color: Colors.amber,
            size: 24,
          ),
          const SizedBox(width: 8),
          Text(
            '${model.userRepo.appUser?.gold ?? 0}',
            style: GoogleFonts.pressStart2p(
              color: GameColors.primary,
              fontSize: 18,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCharacterBtn() {
    return GameButton(
      onPressed: () {
        context.push(Routes.character);
      },
      size: GameButtonSize.small,
      child: const Icon(Icons.people, color: GameColors.primary),
    );
  }

  Widget _buildShopBtn() {
    return GameButton(
      onPressed: () {
        context.push(Routes.shop);
      },
      size: GameButtonSize.small,
      child: const Icon(Icons.store, color: GameColors.primary),
    );
  }

  Widget _buildMyRoomBtn() {
    return GameButton(
      onPressed: () {
        context.push(Routes.myRoom);
      },
      size: GameButtonSize.small,
      child: const Icon(Icons.apps, color: GameColors.primary),
    );
  }

  Widget _buildPlayBtn() {
    return GameButton(
      onPressed: () {
        context.push(Routes.map);
      },
      child: const Text('Play'),
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