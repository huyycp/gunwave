import 'package:carousel_slider/carousel_slider.dart';
import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gunwave/data/constants/game/game_color.dart';
import 'package:gunwave/data/constants/game/game_map.dart';
import 'package:gunwave/data/constants/game/game_ui.dart';
import 'package:gunwave/utils/extensions/string_ex.dart';
import 'package:gunwave/views/game/game_view.dart';
import 'package:gunwave/views/home/widgets/background.dart';
import 'package:gunwave/views/map/map_view_model.dart';
import 'package:gunwave/views/map/widgets/select_character.dart';
import 'package:gunwave/widgets/app_image.dart';
import 'package:gunwave/widgets/base/base_view.dart';
import 'package:gunwave/widgets/game/game_button.dart';

class MapView extends BaseView {
  const MapView({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() {
    return MapViewState();
  }
}

class MapViewState extends BaseViewState<MapView, MapViewModel> {
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
    model.getMaps();
  }

  @override
  Widget getView() {
    ref.watch(mapViewModel);
    return Scaffold(
      body: Container(
        color: const Color.fromARGB(255, 90, 190, 189),
        child: Stack(
          children: [
            _background,
            Positioned(
              top: 8,
              left: 8,
              child: _buildBackBtn(),
            ),
            if (model.maps.isNotEmpty) Positioned(
              top: 8,
              right: 8,
              child: _buildFightBtn(),
            ),
            Positioned.fill(
              top: 40,
              child: model.isLoading 
                ? const Center(child: CircularProgressIndicator(color: GameColors.primary))
                : _buildMapCarousel()
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBackBtn() {
    return GameButton(
      onPressed: () {
        context.pop();
      },
      child: const Text('Back'),
    );
  }

  Widget _buildMapCarousel() {
    final maps = model.maps;
    return CarouselSlider(
      options: CarouselOptions(
        viewportFraction: 0.7,
        enableInfiniteScroll: false,
        scrollPhysics: const BouncingScrollPhysics(),
        onPageChanged: (index, reason) {
          model.setMap(index);
        },
      ),
      items: maps.map((map) => Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        spacing: 8,
        children: [
          Container(
            height: MediaQuery.sizeOf(context).height * 0.6,
            margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: GameColors.primary.withOpacity(0.5),
                  blurRadius: 10,
                  spreadRadius: 5,
                ),
              ]
            ),
            child: AppImage(map.map?.imagePath ?? '', borderRadius: BorderRadius.circular(12)),
          ),
          Text(
            map.name.capitalize,
            style: GoogleFonts.pressStart2p(
              fontSize: 20,
              color: GameColors.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      )).toList(),
    );
  }

  Widget _buildFightBtn() {
    return GameButton(
      onPressed: () {
        showCharacterSelectDialog();
        

        // Navigator.of(context).push(
        //   MaterialPageRoute(
        //     builder: (context) => GameView(
        //       map: model.currentMap,
        //       joystickEnabled: model.isJoystickEnabled,
        //     ),
        //   ),
        // );
      },
      child: const Text('Fight'),
    );
  }

  void showCharacterSelectDialog() {
    SelectCharacterWidget.show((character) {
      model.selectCharacter(character);
      showPlayModeDialog();
    });
  }

  void showPlayModeDialog() {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => Dialog(
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            image: DecorationImage(
              image: AssetImage(GameBanners.carvedSlide.path),
              fit: BoxFit.fill,
              scale: 0.1,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            spacing: 8,
            children: [
              Text(
                'Play Mode',
                style: GoogleFonts.pressStart2p(
                  fontSize: 20,
                  color: GameColors.primary,
                ),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                spacing: 8,
                children: [
                  GameButton(
                    onPressed: () {
                      context.pop();
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => GameView(
                            map: model.maps[model.currentMapIndex],
                            character: model.selectedCharacter!,
                            joystickEnabled: true,
                          ),
                        ),
                      );
                    },
                    child: const Text('Joystick'),
                  ),
                  GameButton(
                    onPressed: () {
                      context.pop();
                    },
                    child: const Text('Gestures'),
                  ),
                  GameButton(
                    onPressed: () {
                      context.pop();
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => GameView(
                            map: model.maps[model.currentMapIndex],
                            character: model.selectedCharacter!,
                            joystickEnabled: false,
                          ),
                        ),
                      );
                    },
                    child: const Text('Keyboard'),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  @override
  MapViewModel getViewModel() {
    return ref.read(mapViewModel);
  }
}
