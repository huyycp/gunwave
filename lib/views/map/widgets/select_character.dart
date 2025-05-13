import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gunwave/data/constants/game/game_button.dart';
import 'package:gunwave/data/constants/game/game_color.dart';
import 'package:gunwave/data/constants/game/game_ui.dart';
import 'package:gunwave/data/models/character_model.dart';
import 'package:gunwave/routes.dart';
import 'package:gunwave/views/character/widgets/character_preview.dart';
import 'package:gunwave/views/game/components/sub_components/app_banner.dart';
import 'package:gunwave/widgets/base/base_widget.dart';
import 'package:gunwave/widgets/base/base_widget_model.dart';
import 'package:gunwave/widgets/game/game_button.dart';

class SelectCharacterWidget extends BaseWidget {
  const SelectCharacterWidget(this.onCharacterSelected, {super.key});

  final void Function(CharacterModel) onCharacterSelected;

  static void show(void Function(CharacterModel) onCharacterSelected) {
    final context = navigatorKey.currentContext;
    if (context != null) {
      showDialog(
        context: context,
        builder: (context) {
          return Dialog(child: SelectCharacterWidget(onCharacterSelected));
        },
      );
    }
  }

  @override
  ConsumerState<ConsumerStatefulWidget> createState() {
    return SelectCharacterWidgetState();
  }
}

class SelectCharacterWidgetState extends BaseWidgetState<SelectCharacterWidget, SelectCharacterWidgetModel> {
  late final provider = ChangeNotifierProvider<SelectCharacterWidgetModel>((ref) => SelectCharacterWidgetModel(widget.onCharacterSelected));
  
  final _background = GameWidget(
    game: FlameGame(
      children: [
        AppBanner(
          banner: GameBanners.bannerHorizontal,
          xCount: 10,
          yCount: 5,
        )
      ]  
    ),
  );

  @override
  void onReady() {
    super.onReady();
    model.getCharacters();
  }

  @override
  Widget getWidget() {
    ref.watch(provider);
    final size = MediaQuery.of(context).size;
    final height = size.height - 32;
    final width = size.width - 72;
    return SizedBox(
      width: width,
      child: Stack(
        alignment: Alignment.center,
        children: [
          _background,
          if (model.isLoading)
            const Center(
              child: CircularProgressIndicator(color: GameColors.primary),
            )
          else ...[
            Positioned(
              child: SizedBox(
                width: 192 * 2,
                child: GameWidget(game: CharacterPreview(
                  character: model.characters[model.selectedCharacterIndex].character,
                )),
              ),
            ),
            Positioned(
              bottom: height * 0.05,
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
            Positioned(
              top: 8,
              right: 8,
              child: _buildNextBtn(),
            ),
            Positioned(
              top: 8,
              left: 8,
              child: _buildBackBtn(),
            ),
          ],
        ],
      ),
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
        model.selectCharacter((model.selectedCharacterIndex + 1) % model.characters.length);
      },
      size: GameButtonSize.small,
      child: const Text('>'),
    );
  }
  
  Widget _buildPreviousCharacterBtn() {
    return GameButton(
      onPressed: () {
        model.selectCharacter((model.selectedCharacterIndex - 1 + model.characters.length) % model.characters.length);
      },
      size: GameButtonSize.small,
      child: const Text('<'),
    );
  }

  Widget _buildBackBtn() {
    return GameButton(
      onPressed: () {
        Navigator.of(context).pop();
      },
      child: const Text('Back'),
    );
  }

  Widget _buildNextBtn() {
    return GameButton(
      onPressed: () {
        Navigator.of(context).pop();
        widget.onCharacterSelected(model.characters[model.selectedCharacterIndex]);
      },
      child: const Text('Next'),
    );
  }

  @override
  SelectCharacterWidgetModel getWidgetModel() {
    return ref.read(provider);
  }
}

class SelectCharacterWidgetModel extends BaseWidgetModel {
  SelectCharacterWidgetModel(this.onCharacterSelected);

  final void Function(CharacterModel) onCharacterSelected;
  List<CharacterModel> characters = [];
  int selectedCharacterIndex = 0;

  bool isLoading = true;

  Future<void> getCharacters() async {
    try {
      await Future.delayed(Duration.zero, () {
        characters = userRepo.appUser?.characters ?? [];
        debugPrint("Characters loaded: $characters");
        setLoading(false);
      });
    } catch (e) {
      debugPrint("Error loading characters: $e");
    } finally {
      setLoading(false);
    }
  }

  void setLoading(bool loading) {
    isLoading = loading;
    notifyListeners();
  }

  void selectCharacter(int index) {
    selectedCharacterIndex = index;
    debugPrint("Character changed to: ${characters[index].name}");
    notifyListeners();
  }
}