import 'package:carousel_slider/carousel_slider.dart';
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
import 'package:gunwave/data/models/room_model.dart';
import 'package:gunwave/utils/extensions/string_ex.dart';
import 'package:gunwave/views/game/game_view.dart';
import 'package:gunwave/views/home/widgets/background.dart';
import 'package:gunwave/views/room/room_view_model.dart';
import 'package:gunwave/views/room/widgets/room_preview_widget.dart';
import 'package:gunwave/views/room/widgets/select_character.dart';
import 'package:gunwave/widgets/app_image.dart';
import 'package:gunwave/widgets/base/base_view.dart';
import 'package:gunwave/widgets/game/game_button.dart';

class RoomView extends BaseView {
  const RoomView({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() {
    return RoomViewState();
  }
}

class RoomViewState extends BaseViewState<RoomView, RoomViewModel> {
  late final Widget _background = GameWidget(game: FlameGame(
    world: Background(
      backgroundPath: GameMaps.loading,
      screenSize: Vector2(MediaQuery.sizeOf(context).width, MediaQuery.sizeOf(context).height),
    ),
    camera: CameraComponent()
      ..viewfinder.anchor = Anchor.topLeft
      ..viewfinder.zoom = 1.0
  ));

  @override
  void onReady() {
    super.onReady();
    model.getRooms();
  }

  @override
  Widget getView() {
    ref.watch(roomViewModel);
    return Scaffold(
      body: Container(
        color: const Color.fromARGB(255, 90, 190, 189),
        child: Stack(
          children: [
            _background,
            Positioned(
              top: 16,
              left: 16,
              child: _buildBackBtn(),
            ),
            Center(
              child: model.isLoading 
                ? const Center(child: CircularProgressIndicator(color: GameColors.primary))
                : _buildRoomCarousel()
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
      size: GameButtonSize.small,
      child: const Icon(Icons.arrow_back, color: GameColors.primary),
    );
  }

  Widget _buildRoomCarousel() {
    final rooms = model.rooms;
    return CarouselSlider(
      options: CarouselOptions(
        viewportFraction: 0.7,
        enableInfiniteScroll: false,
        scrollPhysics: const BouncingScrollPhysics(),
      ),
      items: rooms.map((room) => RoomPreviewWidget(room, onPlay: showCharacterSelectDialog)).toList(),
    );
  }

  void showCharacterSelectDialog(RoomModel room) {
    SelectCharacterWidget.show((character) {
      model.selectCharacter(character);
      showPlayModeDialog(room);
    });
  }

  void showPlayModeDialog(RoomModel room) {
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
                            room: room,
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
                            room: room,
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
  RoomViewModel getViewModel() {
    return ref.read(roomViewModel);
  }
}
