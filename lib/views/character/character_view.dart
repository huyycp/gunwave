import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gunwave/data/constants/game/game_button.dart';
import 'package:gunwave/data/constants/game/game_color.dart';
import 'package:gunwave/data/constants/game/game_map.dart';
import 'package:gunwave/views/character/character_view_model.dart';
import 'package:gunwave/views/character/widgets/character_preview.dart';
import 'package:gunwave/views/character/widgets/status_board.dart';
import 'package:gunwave/views/home/widgets/background.dart';
import 'package:gunwave/widgets/base/base_view.dart';
import 'package:gunwave/widgets/game/game_button.dart';

class CharacterView extends BaseView {
  const CharacterView({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() {
    return CharacterViewState();
  }
}

class CharacterViewState extends BaseViewState<CharacterView, CharacterViewModel> {
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
    model.getCharacters();
  }

  @override
  Widget getView() {
    ref.watch(characterViewModel);
    final size = MediaQuery.of(context).size;
    final height = size.height - 32;
    final width = size.width - 72;
    return Scaffold(
      body: Stack(
        children: [
          Container(
            color: const Color.fromARGB(255, 90, 190, 189),
          ),
          _background,
          Center(
            child: !model.isLoading 
              ? LayoutBuilder(
                builder: (context, constaint) => SizedBox(
                  height: height,
                  width: width,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Expanded(child: _buildCharacterPreview(constaint.maxHeight, constaint.maxWidth)),
                      Expanded(child: _buildStatusBoard()),
                    ],
                  ),
                ),
              ) 
              : const Center(child: CircularProgressIndicator(color: GameColors.primary)),
          ),
          Positioned(
            top: 12,
            left: 12,
            child: _buildBackBtn(),
          )
        ],
      ),
    );
  }

  Widget _buildCharacterPreview(double height, double width) {
    return Container(
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/images/ui/buttons/button_square.png'),
          fit: BoxFit.fill,
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            child: GameWidget(game: CharacterPreview(
              character: model.characters[model.selectedCharacterIndex].character,
            )),
          ),
          Positioned(
            bottom: height * 0.15,
            left: 0,
            right: 0,
            child: Padding(
              padding: const EdgeInsets.only(top: 12),
              child: _buildCharacterName(),
            ),
          ),
          Positioned(
            top: height / 2,
            left: 8,
            child: _buildPreviousCharacterBtn(),
          ),
          Positioned(
            top: height / 2,
            right: 8,
            child: _buildNextCharacterBtn(),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBoard() {
    return StatusBoard(
      model.characters[model.selectedCharacterIndex],
    );
  }

  Widget _buildCharacterName() {
    return Text(
      model.characters[model.selectedCharacterIndex].name,
      style: GoogleFonts.pressStart2p(
        fontSize: 16,
        color: GameColors.primary,
      ),
      textAlign: TextAlign.center,
    );
  }

  Widget _buildNextCharacterBtn() {
    return GameButton(
      onPressed: () {
        model.onCharacterSelected((model.selectedCharacterIndex + 1) % model.characters.length);
      },
      size: GameButtonSize.small,
      child: const Text('>'),
    );
  }
  
  Widget _buildPreviousCharacterBtn() {
    return GameButton(
      onPressed: () {
        model.onCharacterSelected((model.selectedCharacterIndex - 1 + model.characters.length) % model.characters.length);
      },
      size: GameButtonSize.small,
      child: const Text('<'),
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

  @override
  CharacterViewModel getViewModel() {
    return ref.read(characterViewModel);
  }
}