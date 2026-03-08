import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gunwave/data/constants/game/game_color.dart';
import 'package:gunwave/data/constants/game/game_play_mode.dart';
import 'package:gunwave/data/constants/game/game_ui.dart';
import 'package:gunwave/data/models/character_model.dart';
import 'package:gunwave/data/models/room_model.dart';
import 'package:gunwave/routes.dart';
import 'package:gunwave/utils/extensions/string_ex.dart';
import 'package:gunwave/views/game/game_view.dart';
import 'package:gunwave/widgets/base/base_widget.dart';
import 'package:gunwave/widgets/base/base_widget_model.dart';
import 'package:gunwave/widgets/game/game_button.dart';

class PlayModeDialog extends BaseWidget {
  const PlayModeDialog(this.room, this.selectedCharacter, {super.key});

  final RoomModel room;
  final CharacterModel selectedCharacter;

  static void show(RoomModel room, CharacterModel selectedCharacter) {
    showDialog(
      context: navigatorKey.currentContext!,
      barrierDismissible: true,
      builder: (context) => Dialog(child: PlayModeDialog(room, selectedCharacter)),
    );
  }

  @override
  ConsumerState<ConsumerStatefulWidget> createState() {
    return PlayModeDialogState();
  }
}

class PlayModeDialogState extends BaseWidgetState<PlayModeDialog, PlayModeDialogModel> {
  final provider = ChangeNotifierProvider((ref) => PlayModeDialogModel());

  @override
  Widget getWidget() {
    return Container(
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
              _buildPlayModeItem(GamePlayMode.joystick),
              _buildPlayModeItem(GamePlayMode.gesture),
              _buildPlayModeItem(GamePlayMode.keyboard), 
            ],
          )
        ],
      ),
    );
  }

  Widget _buildPlayModeItem(GamePlayMode mode) {
    return GameButton(
      onPressed: () {
        context.pop();
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => GameView(
              room: widget.room,
              character: widget.selectedCharacter,
              playMode: mode,
            ),
          ),
        );
      },
      child: Text(
        mode.name.capitalize,
        style: GoogleFonts.pressStart2p(
          fontSize: 16,
          color: GameColors.primary,
        ),
      ),
    );

  }

  @override
  PlayModeDialogModel getWidgetModel() {
    return ref.read(provider);
  }
}

class PlayModeDialogModel extends BaseWidgetModel {

}