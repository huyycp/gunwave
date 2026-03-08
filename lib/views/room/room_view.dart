import 'package:carousel_slider/carousel_slider.dart';
import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:gunwave/data/constants/game/game_button.dart';
import 'package:gunwave/data/constants/game/game_color.dart';
import 'package:gunwave/data/constants/game/game_map.dart';
import 'package:gunwave/data/models/room_model.dart';
import 'package:gunwave/views/home/widgets/background.dart';
import 'package:gunwave/views/room/room_view_model.dart';
import 'package:gunwave/views/room/widgets/play_mode_dialog.dart';
import 'package:gunwave/views/room/widgets/room_preview_widget.dart';
import 'package:gunwave/views/room/widgets/select_character.dart';
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
      body: Stack(
        children: [
          _background,
          Center(
            child: model.isLoading 
              ? const Center(child: CircularProgressIndicator(color: GameColors.primary))
              : _buildRoomCarousel()
          ),
          Positioned(
            top: 16,
            left: 16,
            child: _buildBackBtn(),
          ),
        ],
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
      items: rooms.map((room) => Container(
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
        child: RoomPreviewWidget(room, onPlay: showCharacterSelectDialog)
      )).toList(),
    );
  }

  void showCharacterSelectDialog(RoomModel room) {
    SelectCharacterWidget.show((character) {
      model.selectCharacter(character);
      showPlayModeDialog(room);
    });
  }

  void showPlayModeDialog(RoomModel room) {
    if (model.selectedCharacter != null) {
      PlayModeDialog.show(room, model.selectedCharacter!);
    }
  }

  @override
  RoomViewModel getViewModel() {
    return ref.read(roomViewModel);
  }
}
