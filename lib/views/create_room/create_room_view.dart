import 'package:carousel_slider/carousel_slider.dart';
import 'package:collection/collection.dart';
import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/src/consumer.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gunwave/data/constants/game/game_button.dart';
import 'package:gunwave/data/constants/game/game_color.dart';
import 'package:gunwave/data/constants/game/game_map.dart';
import 'package:gunwave/utils/extensions/list_widget_ex.dart';
import 'package:gunwave/views/create_room/create_room_view_model.dart';
import 'package:gunwave/views/create_room/widgets/quiz_input_form.dart';
import 'package:gunwave/views/home/widgets/background.dart';
import 'package:gunwave/widgets/app_image.dart';
import 'package:gunwave/widgets/app_list_tile.dart';
import 'package:gunwave/widgets/app_text_form_field.dart';
import 'package:gunwave/widgets/base/base_view.dart';
import 'package:gunwave/widgets/game/game_button.dart';

class CreateRoomView extends BaseView {
  const CreateRoomView(this.onSuccess, {super.key});

  final void Function(bool) onSuccess;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() {
    return CreateRoomViewState();
  }
}

class CreateRoomViewState extends BaseViewState<CreateRoomView, CreateRoomViewModel> {
  late final provider = ChangeNotifierProvider<CreateRoomViewModel>((ref) => CreateRoomViewModel(ref, widget.onSuccess));

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
    model.getMaps();
  }

  @override
  Widget getView() {
    ref.watch(provider);
    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Scaffold(
        body: Stack(
          children: [
            _background,
            Positioned.fill(
              child: ListView(
                padding: const EdgeInsets.only(top: 48),
                children: <Widget>[
                  _buildNameInput(),
                  _buildMapSelector(),
                  _buildPrivateToggle(),
                  _buildQuizzes(),
                ].addSpace(16, Axis.vertical),
              )
            ),
            Positioned(
              top: 16,
              left: 32,
              child: _buildBackBtn(),
            ),
            Positioned(
              top: 16,
              right: 32,
              child: _buildCreateRoomBtn(),
            ),
            if (model.isCreating) Positioned.fill(
              child: Container(
                color: GameColors.primary.withOpacity(0.5),
                child: const Center(child: CircularProgressIndicator(color: GameColors.primary)),
              )
            )
          ],
        ),
      ),
    );
  }

  Widget _buildNameInput() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 100, vertical: 16),
      child: AppTextFormField(
        controller: model.nameController,
        statesController: model.nameStatesController,
        title: 'Room Name',
        titleStyle: GoogleFonts.pressStart2p(
          color: GameColors.primary,
          fontSize: 16,
        ),
      ),
    );
  }

  Widget _buildMapSelector() {
    return Column(
      spacing: 16,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 100),
          child: Text(
            'Select a Map',
            style: GoogleFonts.pressStart2p(
              color: GameColors.primary,
              fontSize: 16,
            ),
          ),
        ),
        model.isLoading
          ? const Center(child: CircularProgressIndicator(color: GameColors.primary))
          : CarouselSlider(
              options: CarouselOptions(
                viewportFraction: 0.7,
                initialPage: 0,
                enableInfiniteScroll: false,
                onPageChanged: (index, reason) {
                  model.selectMap(index);
                },
              ),
              items: model.maps.map((map) {
                return Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    color: const Color.fromARGB(255, 71, 183, 181),
                    boxShadow: [
                      BoxShadow(
                        color: GameColors.primary.withOpacity(0.5),
                        blurRadius: 10,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: AppImage(
                    map.map?.imagePath ?? '',
                    // width: 200,
                    height: 280,
                    borderRadius: BorderRadius.circular(16),
                    fit: BoxFit.cover,
                  ),
                );
              }).toList(),
            )
      ],
    );
  }

  Widget _buildPrivateToggle() {
    return AppListTile(
      title: 'Private',
      subTitle: 'This rooom will not be visible to others. Only invited players can join.',
      isSubTitleWrap: true,
      titleStyle: GoogleFonts.pressStart2p(
        color: GameColors.primary,
        fontSize: 16,
      ),
      subTitleStyle: GoogleFonts.pressStart2p(
        color: GameColors.primary.withOpacity(0.7),
        fontSize: 12,
      ),
      trailing: Switch(
        value: model.isPrivate,
        activeColor: const Color.fromARGB(255, 71, 183, 181),
        inactiveThumbColor: GameColors.primary.withOpacity(0.5),
        activeTrackColor: GameColors.primary.withOpacity(0.7),
        inactiveTrackColor: GameColors.primary.withOpacity(0.3),
        onChanged: (value) {
          model.togglePrivate();
        },
      ),
      trailingTitleSpacing: 48,
      padding: const EdgeInsets.symmetric(horizontal: 100, vertical: 16),
    );
  }

  Widget _buildQuizzes() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 100, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        spacing: 16,
        children: [
          Text(
            'Quizzes',
            style: GoogleFonts.pressStart2p(
              color: GameColors.primary,
              fontSize: 16,
            ),
          ),
          ...model.quizzes.mapIndexed((index, quiz) {
            return AppListTile(
              title: '${index + 1}. ${quiz.question}',
              titleStyle: GoogleFonts.pressStart2p(
                color: GameColors.primary,
                fontSize: 14,
              ),
              padding: const EdgeInsets.symmetric(vertical: 8),
            );
          }).toList(),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              GameButton(
                onPressed: () {
                  QuizInputForm.show(model.addQuiz);
                },
                child: const Text('Add Quiz'),
              ),
            ],
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

  Widget _buildCreateRoomBtn() {
    return GameButton(
      onPressed: () {
        if (model.quizzes.isEmpty) return;
        model.createRoom();
      },
      child: const Text('Create'),
    );
  }
  
  @override
  CreateRoomViewModel getViewModel() {
    return ref.read(provider);
  }
}