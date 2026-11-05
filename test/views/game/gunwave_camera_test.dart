import 'package:flame/components.dart';
import 'package:flame/flame.dart';
import 'package:flutter/painting.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gunwave/data/constants/game/game_constants.dart';
import 'package:gunwave/data/constants/game/game_play_mode.dart';
import 'package:gunwave/data/data_sources/local/campaign_content_data_source.dart';
import 'package:gunwave/data/models/character_model.dart';
import 'package:gunwave/repositories/campaign_repository.dart';
import 'package:gunwave/views/game/gunwave.dart';

import 'ui/campaign_ui_test_support.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('campaign camera centers the hero in the viewport', () async {
    final stage = await CampaignRepository(AssetCampaignContentDataSource())
        .getStage('stage_1');
    final originalPrefix = Flame.images.prefix;
    final game = Gunwave(
      _TestWidgetRef(),
      campaignStage: stage,
      gameCharacters: const CharacterModel(
        filename: 'warrior_blue',
        hp: 100,
        str: 10,
        agi: 100,
      ),
      playMode: GamePlayMode.joystick,
      onStageCompleted: (_) {},
      campaignUiLabels: testCampaignUiLabels(),
      safeAreaInsets: EdgeInsets.zero,
    );

    game.onGameResize(Vector2(844, 390));
    try {
      // ignore: invalid_use_of_internal_member
      await game.load();
      // ignore: invalid_use_of_internal_member
      game.mount();
      await game.ready();
      game.update(GameConstants.refreshRate * 2);

      expect(game.camera.viewfinder.anchor, Anchor.center);
      expect(
        game.camera.viewfinder.position.x,
        closeTo(game.character.combatCenter.x, 0.001),
      );
      expect(
        game.camera.viewfinder.position.y,
        closeTo(game.character.combatCenter.y, 0.001),
      );
    } finally {
      game.onRemove();
      Flame.images.prefix = originalPrefix;
      Flame.images.clearCache();
    }
  });
}

class _TestWidgetRef implements WidgetRef {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
