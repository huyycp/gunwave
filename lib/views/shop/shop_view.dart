import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gunwave/data/constants/game/game_color.dart';
import 'package:gunwave/data/constants/game/game_ui.dart';
import 'package:gunwave/data/models/character_model.dart';
import 'package:gunwave/views/character/widgets/character_preview.dart';
import 'package:gunwave/views/game/components/sub_components/app_banner.dart';
import 'package:gunwave/views/shop/shop_view_model.dart';
import 'package:gunwave/widgets/base/base_view.dart';
import 'package:gunwave/widgets/game/game_button.dart';

class ShopView extends BaseView {
  const ShopView({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() {
    return ShopViewState();
  }
}

class ShopViewState extends BaseViewState<ShopView, ShopViewModel> {
  final _background = GameWidget(
    game: FlameGame(
      children: [
        AppBanner(
          banner: GameBanners.bannerHorizontal,
          xCount: 13,
          yCount: 6,
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
  Widget getView() {
    ref.watch(shopViewModel);
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(child: _background),
          Positioned.fill(child: _buildCharacters()),
          Positioned(
            top: 8,
            left: 8,
            child: _buildBackBtn(),
          ),
        ],
      ),
    );
  }

  Widget _buildCharacters() {
    final characters = model.characters;
    return model.isLoading
      ? const Center(child: CircularProgressIndicator(color: GameColors.primary))
      : characters.isEmpty
        ? const Center(child: Text('No characters available'))
        : ListView.separated(
          scrollDirection: Axis.horizontal,
          itemCount: characters.length,
          itemBuilder: (context, index) => _buildCharacterItem(characters[index]),
          separatorBuilder: (context, index) => const SizedBox(height: 24),
        );
  }

  Widget _buildCharacterItem(CharacterModel character) {
    return Container(
      width: 192 * 2 + 16 * 2,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage(GameBanners.carvedSquare.path),
          fit: BoxFit.fill,
        ),
      ),
      child: Stack(
        children: [
          GameWidget(game: CharacterPreview(
            character: character.character,
          )),
          Positioned(
            top: 192 / 3,
            left: 0,
            right: 0,
            child: Text(
              character.name,
              textAlign: TextAlign.center,
              style: GoogleFonts.pressStart2p(
                fontSize: 16,
                color: GameColors.primary,
              ),
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 8,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                GameButton(
                  onPressed: 
                    !model.isCharacterOwned(character.id) &&
                    model.userBalance >= character.price  
                      ? () {
                        model.buyCharacter(character);
                      } 
                      : null,
                  child: Text(
                    model.isCharacterOwned(character.id)
                      ? 'Owned'
                      : character.price.toString()
                    ),
                ),
              ],
            ),
          )
        ],
      ),
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
  ShopViewModel getViewModel() {
    return ref.read(shopViewModel);
  }
}