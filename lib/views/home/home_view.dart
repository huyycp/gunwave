import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:gunwave/data/constants/game/game_button.dart';
import 'package:gunwave/data/constants/game/game_map.dart';
import 'package:gunwave/routes.dart';
import 'package:gunwave/localization/build_context_l10n.dart';
import 'package:gunwave/gen/assets.gen.dart';
import 'package:gunwave/views/home/widgets/background.dart';
import 'package:gunwave/views/home/home_view_model.dart';
import 'package:gunwave/views/home/widgets/login_widget.dart';
import 'package:gunwave/views/rpg_ui/rpg_menu_host.dart';
import 'package:gunwave/views/rpg_ui/rpg_menu_models.dart';
import 'package:gunwave/widgets/base/base_view.dart';
import 'package:gunwave/widgets/game/game_button.dart';

class HomeView extends BaseView {
  const HomeView({super.key});

  @override
  ConsumerState<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends BaseViewState<HomeView, HomeViewModel> {
  late final _background = GameWidget(
    game: FlameGame(
      world: Background(
        backgroundPath: GameMaps.background,
        screenSize: Vector2(
          MediaQuery.sizeOf(context).width,
          MediaQuery.sizeOf(context).height,
        ),
      ),
      camera: CameraComponent()
        ..viewfinder.anchor = Anchor.topLeft
        ..viewfinder.zoom =
            1.0, // Use full size since we're scaling the component
    ),
  );

  @override
  Widget getView() {
    ref.watch(homeViewModel);
    if (model.userRepo.appUser != null || model.isSoloSession) {
      return RpgMenuHost(
        initialPage: RpgMenuPage.homeHub,
        onBack: model.isSoloSession ? model.returnToAuthOptions : null,
      );
    }
    return Scaffold(
      body: Stack(
        children: [
          _background,
          if (model.isLoginFormVisible)
            Center(child: _buildLoginForm())
          else
            Center(child: _buildAuthOptions()),
          Positioned(top: 8, right: 32, child: _buildSettingsBtn()),
        ],
      ),
    );
  }

  Widget _buildSettingsBtn() => Tooltip(
    message: context.l10n.settings,
    child: Semantics(
      button: true,
      label: context.l10n.settings,
      child: GameButton(
        size: GameButtonSize.small,
        onPressed: () => context.push(Routes.settings),
        child: Assets.images.ui.icons.setting.image(
          filterQuality: FilterQuality.none,
        ),
      ),
    ),
  );

  Widget _buildLoginForm() {
    return LoginWidget((isDone) {
      model.onLoginComplete(isDone);
      if (!isDone) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(context.l10n.loginFailed),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    }, onBack: model.showAuthOptions);
  }

  Widget _buildAuthOptions() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        GameButton(
          onPressed: model.playSolo,
          child: Text(context.l10n.playSolo),
        ),
        const SizedBox(height: 12),
        GameButton(
          onPressed: () async {
            final succeeded = await model.continueAsGuest();
            if (!succeeded && mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(context.l10n.loginFailed),
                  duration: const Duration(seconds: 2),
                ),
              );
            }
          },
          child: Text(context.l10n.guest),
        ),
        const SizedBox(height: 12),
        GameButton(
          onPressed: model.showLoginForm,
          child: Text(context.l10n.login),
        ),
      ],
    );
  }

  @override
  HomeViewModel getViewModel() {
    return ref.read(homeViewModel);
  }
}
