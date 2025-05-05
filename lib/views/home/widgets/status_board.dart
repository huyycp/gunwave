import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/src/consumer.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gunwave/data/constants/game/game_button.dart';
import 'package:gunwave/data/constants/game/game_color.dart';
import 'package:gunwave/widgets/base/base_widget.dart';
import 'package:gunwave/widgets/base/base_widget_model.dart';
import 'package:gunwave/widgets/game/game_button.dart';

class StatusBoard extends BaseWidget {
  const StatusBoard({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() {
    return StatusBoardState();
  }
}

class StatusBoardState extends BaseWidgetState<StatusBoard, StatusBoardWidgetModel> {
  final provider = ChangeNotifierProvider((ref) => StatusBoardWidgetModel());

  @override
  Widget getWidget() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 24),
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/images/ui/banners/carved_square.png'),
          // fit: BoxFit.fill,
          scale: 0.1
        ),
      ),
      clipBehavior: Clip.hardEdge,
      child: Column(
        children: [
          _buildHeader(),
          const SizedBox(height: 4),
          _buildStatusPoint(),
          const SizedBox(height: 4),
          _buildCharacterAttr('HP', 100),
          _buildCharacterAttr('STR', 10),
          _buildCharacterAttr('VIT', 5),
          _buildCharacterAttr('AGI', 7),
        ],
      ),
    );
  }

  Widget _buildStatusPoint() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Status Point:',
          style: GoogleFonts.pressStart2p(
            fontSize: 10,
            color: GameColor.primary,
          ),
        ),
        Text(
          '10',
          style: GoogleFonts.pressStart2p(
            fontSize: 10,
            color: GameColor.primary,
          ),
        ),
      ],
    );
  }
 
  Widget _buildCharacterAttr(String attr, int value) {
    return Row(
      children: [
        Expanded(
          child: Text(
            attr,
            style: GoogleFonts.pressStart2p(
              fontSize: 16,
              color: GameColor.primary,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value.toString(),
            style: GoogleFonts.pressStart2p(
              fontSize: 16,
              color: GameColor.primary,
            ),
          ),
        ),
        GameButton(
          onPressed: () {
            // Handle button press
          },
          size: GameButtonSize.small,
          child: const Text('+')
        )
      ],
    );
  }

  Widget _buildHeader() {
    return Container(
      // decoration: const BoxDecoration(
      //   image: DecorationImage(
      //     image: AssetImage('assets/images/ui/banners/banner_horizontal.png'),
      //     fit: BoxFit.cover,
      //   ),
      // ),
      child: Text(
        "Status Board",
        style: GoogleFonts.pressStart2p(
          fontSize: 20,
          color: GameColor.primary,
        ),
      ),
    );
  }

  @override
  StatusBoardWidgetModel getWidgetModel() {
    return StatusBoardWidgetModel();
  }
}

class StatusBoardWidgetModel extends BaseWidgetModel {

}