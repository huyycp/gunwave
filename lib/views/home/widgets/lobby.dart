import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gunwave/data/constants/game/game_button.dart';
import 'package:gunwave/data/constants/game/game_color.dart';
import 'package:gunwave/data/models/character_model.dart';
import 'package:gunwave/views/home/widgets/character_preview.dart';
import 'package:gunwave/views/home/widgets/status_board.dart';
import 'package:gunwave/widgets/base/base_widget.dart';
import 'package:gunwave/widgets/base/base_widget_model.dart';
import 'package:gunwave/widgets/game/game_button.dart';

class LobbyWidget extends BaseWidget {
  const LobbyWidget({
    this.characters = const [],
    super.key,
  });

  final List<CharacterModel> characters;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() {
    return LobbyWidgetState();
  }
}

class LobbyWidgetState extends BaseWidgetState<LobbyWidget, LobbyWidgetModel> {
  late final provider = ChangeNotifierProvider((ref) => LobbyWidgetModel(characters: widget.characters));
  
  @override
  Widget getWidget() {
    ref.watch(provider);
    final size = MediaQuery.of(context).size;
    final height = size.height - 32;
    final width = size.width - 72;
    return LayoutBuilder(
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

  Widget _buildCharacterName() {
    return Text(
      model.characters[model.selectedCharacterIndex].name,
      style: GoogleFonts.pressStart2p(
        fontSize: 16,
        color: GameColor.primary,
      ),
      textAlign: TextAlign.center,
    );
  }

  Widget _buildStatusBoard() {
    return StatusBoard(model.characters[model.selectedCharacterIndex]);
  }

  @override
  LobbyWidgetModel getWidgetModel() {
    return ref.read(provider);
  }
}

class LobbyWidgetModel extends BaseWidgetModel {
  LobbyWidgetModel({
    this.characters = const [],
  });

  List<CharacterModel> characters;
  int selectedCharacterIndex = 0;

  void onCharacterSelected(int index) {
    if (index < 0 || index >= characters.length) return;
    selectedCharacterIndex = index;
    notifyListeners(); 
  }
}