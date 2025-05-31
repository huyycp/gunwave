import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:gunwave/data/constants/game/game_button.dart';
import 'package:gunwave/data/constants/game/game_color.dart';
import 'package:gunwave/data/constants/game/game_map.dart';
import 'package:gunwave/views/home/widgets/background.dart';
import 'package:gunwave/views/my_room/my_room_view_model.dart';
import 'package:gunwave/views/my_room/widgets/my_room_widget.dart';
import 'package:gunwave/widgets/base/base_view.dart';
import 'package:gunwave/widgets/game/game_button.dart';

class MyRoomView extends BaseView {
  const MyRoomView({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() {
    return MyRoomViewState();
  }
}

class MyRoomViewState extends BaseViewState<MyRoomView, MyRoomViewModel> {
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
    model.getMyRooms();
  }
  
  @override
  Widget getView() {
    ref.watch(myRoomViewModel);
    return Scaffold(
      body: Container(
        color: const Color.fromARGB(255, 90, 190, 189),
        child: Stack(
          children: [
            _background,
            Positioned(
              top: 16,
              left: 32,
              child: _buildBackBtn(),
            ),
            model.isLoading 
              ? const Center(child: CircularProgressIndicator(color: GameColors.primary))
              : Positioned.fill(
                  top: 48,
                  left: 32,
                  child: _buildMyRoomCarousel()
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

  Widget _buildMyRoomCarousel() {
    return ListView.builder(
      scrollDirection: Axis.horizontal,
      itemCount: model.rooms.length,
      padding: const EdgeInsets.only(left: 32, top: 32, bottom: 16),
      itemBuilder: (context, index) {
        final room = model.rooms[index];
        return MyRoomWidget(room);
      },
    );
  }

  @override
  MyRoomViewModel getViewModel() {
    return ref.read(myRoomViewModel);
  }
  
}

