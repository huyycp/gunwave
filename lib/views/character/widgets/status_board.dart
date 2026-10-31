import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gunwave/data/constants/game/game_button.dart';
import 'package:gunwave/data/constants/game/game_color.dart';
import 'package:gunwave/data/constants/game/game_ui.dart';
import 'package:gunwave/data/models/character_model.dart';
import 'package:gunwave/localization/build_context_l10n.dart';
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

class StatusBoardState
    extends BaseWidgetState<StatusBoard, StatusBoardWidgetModel> {
  late final provider = ChangeNotifierProvider<StatusBoardWidgetModel>(
    (ref) => StatusBoardWidgetModel(ref, widget.character),
  );

  final _background = GameWidget(
    game: FlameGame(children: [
      AppBanner(
        banner: GameBanners.bannerVertical,
        xCount: 5,
        yCount: 5,
      )
    ]),
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
              _buildCharacterAttr(CharacterAttr.hp, model.character.hp),
              _buildCharacterAttr(CharacterAttr.str, model.character.str),
              _buildCharacterAttr(CharacterAttr.vit, model.character.vit),
              _buildCharacterAttr(CharacterAttr.agi, model.character.agi),
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
          context.l10n.statusPoint,
          style: GoogleFonts.pressStart2p(
            fontSize: 10,
            color: GameColors.primary,
          ),
        ),
        Text(
          model.character.sp.toString(),
          style: GoogleFonts.pressStart2p(
            fontSize: 10,
            color: GameColors.primary,
          ),
        ),
      ],
    );
  }

  Widget _buildCharacterAttr(CharacterAttr attr, int value) {
    final strings = context.l10n;
    final label = switch (attr) {
      CharacterAttr.hp => strings.healthPoints,
      CharacterAttr.str => strings.strength,
      CharacterAttr.vit => strings.vitality,
      CharacterAttr.agi => strings.agility,
    };
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
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
                model.updateAttr(model.character, attr);
              },
              size: GameButtonSize.small,
              child: const Text('+')),
        )
      ],
    );
  }

  Widget _buildHeader() {
    return Text(
      context.l10n.statusBoard,
      style: GoogleFonts.pressStart2p(
        fontSize: 20,
        color: GameColors.primary,
      ),
    );
  }

  Widget _buildResetButton() {
    return GameButton(
      onPressed: () {
        model.resetAttr(model.character);
      },
      child: Text(context.l10n.reset),
    );
  }

  @override
  StatusBoardWidgetModel getWidgetModel() {
    return ref.read(provider);
  }
}

class StatusBoardWidgetModel extends BaseWidgetModel {
  StatusBoardWidgetModel(
    ChangeNotifierProviderRef ref,
    CharacterModel character,
  ) : _character = character {
    _characterRepo = ref.read(characterRepoProvider);
  }

  late final CharacterRepository _characterRepo;
  CharacterModel _character;

  CharacterModel get character => _character;

  /// Spends one status point to upgrade [attr] and refreshes the displayed copy.
  Future<void> updateAttr(CharacterModel character, CharacterAttr attr) async {
    try {
      if (_character.sp <= 0) return;
      final result = await _characterRepo.updateAttr(character.id, attr);
      if (result) {
        final currentCharacter = _character;
        final updatedCharacter = switch (attr) {
          CharacterAttr.hp =>
            currentCharacter.copyWith(hp: currentCharacter.hp + 1),
          CharacterAttr.str =>
            currentCharacter.copyWith(str: currentCharacter.str + 1),
          CharacterAttr.vit =>
            currentCharacter.copyWith(vit: currentCharacter.vit + 1),
          CharacterAttr.agi =>
            currentCharacter.copyWith(agi: currentCharacter.agi + 1),
        };
        _character = updatedCharacter.copyWith(sp: currentCharacter.sp - 1);
        notifyListeners();
      }
    } catch (err, stack) {
      AppException.log(runtimeType, err, stack, function: 'updateAttr');
    }
  }

  /// Resets the character's upgrades and reloads its saved stats.
  Future<void> resetAttr(CharacterModel character) async {
    try {
      final result = await _characterRepo.resetAttr(character.id);
      if (result) {
        _character = await _characterRepo.getOwnedCharacter(
              userRepo.appUser!.id,
              character.id,
            ) ??
            character;
        notifyListeners();
      }
    } catch (err, stack) {
      AppException.log(runtimeType, err, stack, function: 'resetAttr');
    }
  }
}
