import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gunwave/data/constants/game/game_character.dart';
import 'package:gunwave/views/home/widgets/character_preview.dart';
import 'package:gunwave/views/home/widgets/status_board.dart';
import 'package:gunwave/widgets/base/base_widget.dart';
import 'package:gunwave/widgets/base/base_widget_model.dart';

class LobbyWidget extends BaseWidget {
  const LobbyWidget({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() {
    return LobbyWidgetState();
  }

}

class LobbyWidgetState extends BaseWidgetState<LobbyWidget, LobbyWidgetModel> {
  final provider = ChangeNotifierProvider((ref) => LobbyWidgetModel());
  
  @override
  Widget getWidget() {
    final size = MediaQuery.of(context).size;
    return SizedBox(
      height: size.height - 32,
      width: size.width - 72,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(child: _buildCharacterPreview()),
          // Expanded(child: Container(color: Colors.amber)),
          // Expanded(child: Container(color: Colors.red)),
          Expanded(child: _buildStatusBoard()),
        ],
      ),
    );
  }

  Widget _buildCharacterPreview() {
    return Container(
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/images/ui/buttons/button_square.png'),
          fit: BoxFit.fill,
        ),
      ),
      child: GameWidget(game: CharacterPreview(
          character: GameCharacters.instance.blueWarrior,
        
        
      )),
    );
  }

  Widget _buildStatusBoard() {
    return const StatusBoard();
  }

  @override
  LobbyWidgetModel getWidgetModel() {
    return ref.read(provider);
  }
}

class LobbyWidgetModel extends BaseWidgetModel {

}