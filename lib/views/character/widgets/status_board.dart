import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gunwave/data/constants/game/game_button.dart';
import 'package:gunwave/data/constants/game/game_color.dart';
import 'package:gunwave/data/constants/game/game_ui.dart';
import 'package:gunwave/data/models/character_model.dart';
import 'package:gunwave/repositories/character_repository.dart';
import 'package:gunwave/utils/exception/app_exception.dart';
import 'package:gunwave/views/game/components/sub_components/app_banner.dart';
import 'package:gunwave/widgets/base/base_widget.dart';
import 'package:gunwave/widgets/base/base_widget_model.dart';
import 'package:gunwave/widgets/game/game_button.dart';

class StatusBoard extends BaseWidget {
  const StatusBoard(
    this.character, {
    super.key,
  });

  final CharacterModel character;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() {
    return StatusBoardState();
  }
}

class StatusBoardState extends BaseWidgetState<StatusBoard, StatusBoardWidgetModel> {
  late final provider = ChangeNotifierProvider<StatusBoardWidgetModel>((ref) => StatusBoardWidgetModel(ref));

  final _background = GameWidget(
    game: FlameGame(
      children: [
        AppBanner(
          banner: GameBanners.bannerVertical,
          xCount: 5,
          yCount: 5,
        )
      ]  
    ),
  );

  @override
  Widget getWidget() {
    ref.watch(provider);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 24),
      child: Stack(
        children: [
          _background,
          Column(
            children: [
              _buildHeader(),
              const SizedBox(height: 4),
              _buildStatusPoint(),
              const SizedBox(height: 4),
              _buildCharacterAttr(CharacterAttr.hp, widget.character.hp),
              _buildCharacterAttr(CharacterAttr.str, widget.character.str),
              _buildCharacterAttr(CharacterAttr.vit, widget.character.vit),
              _buildCharacterAttr(CharacterAttr.agi, widget.character.agi),
              const SizedBox(height: 4),
              _buildResetButton(),
            ],
          ),
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
            color: GameColors.primary,
          ),
        ),
        Text(
          widget.character.sp.toString(),
          style: GoogleFonts.pressStart2p(
            fontSize: 10,
            color: GameColors.primary,
          ),
        ),
      ],
    );
  }
 
  Widget _buildCharacterAttr(CharacterAttr attr, int value) {
    return Row(
      children: [
        Expanded(
          child: Text(
            attr.name.toUpperCase(),
            style: GoogleFonts.pressStart2p(
              fontSize: 16,
              color: GameColors.primary,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value.toString(),
            style: GoogleFonts.pressStart2p(
              fontSize: 16,
              color: GameColors.primary,
            ),
          ),
        ),
        SizedBox(
          height: 40,
          width: 40,
          child: GameButton(
            onPressed: () {
              model.updateAttr(widget.character, attr);
            },
            size: GameButtonSize.small,
            child: const Text('+')
          ),
        )
      ],
    );
  }

  Widget _buildHeader() {
    return Text(
      "Status Board",
      style: GoogleFonts.pressStart2p(
        fontSize: 20,
        color: GameColors.primary,
      ),
    );
  }

  Widget _buildResetButton() {
    return GameButton(
      onPressed: () {
        model.resetAttr(widget.character);
      },
      child: const Text('Reset'),
    );
  }

  @override
  StatusBoardWidgetModel getWidgetModel() {
    return ref.read(provider);
  }
}

class StatusBoardWidgetModel extends BaseWidgetModel {
  StatusBoardWidgetModel(ChangeNotifierProviderRef ref) {
    _characterRepo = ref.read(characterRepoProvider);
  }

  late final CharacterRepository _characterRepo;
  
  Future<void> updateAttr(CharacterModel character, CharacterAttr attr) async {
    try {
      if (character.sp <= 0) return;
      final result = await _characterRepo.updateAttr(character.id, attr);
      if (result) {
         switch (attr) {
          case CharacterAttr.hp:
            character.hp++;
            break;
          case CharacterAttr.str:
            character.str++;
            break;
          case CharacterAttr.vit:
            character.vit++;
            break;
          case CharacterAttr.agi:
            character.agi++;
            break;
        } 
        character.sp--;
        notifyListeners();
      }
    } catch (err, stack) {
      AppException.log(runtimeType, err, stack);
    }
  }

  Future<void> resetAttr(CharacterModel character) async {
    try {
      final result = await _characterRepo.resetAttr(character.id);
      if (result) {
        character.hp = character.baseHp;
        character.str = character.baseStr;
        character.vit = character.baseVit;
        character.agi = character.baseAgi;
        character.sp = character.totalSp;
        notifyListeners();
      }
    } catch (err, stack) {
      AppException.log(runtimeType, err, stack);
    }
  }
}