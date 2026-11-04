import 'package:flame/events.dart';
import 'package:flame_test/flame_test.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/painting.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gunwave/views/game/ui/components/asset_button_component.dart';
import 'package:gunwave/views/game/ui/components/stage_result_component.dart';

import 'campaign_ui_test_support.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWithFlameGame('success result exposes retry, continue, and campaign', (
    game,
  ) async {
    var retries = 0;
    var continues = 0;
    var campaignReturns = 0;
    final result = await StageResultComponent.load(
      game.images,
      labels: testCampaignUiLabels(),
      safeAreaInsets: EdgeInsets.zero,
      isSuccess: true,
      rewardLines: const ['100 GOLD'],
      onRetry: () => retries++,
      onContinue: () => continues++,
      onCampaign: () => campaignReturns++,
    );
    await game.ensureAdd(result);

    expect(result.canContinue, isTrue);
    expect(result.rewardLines, ['100 GOLD']);
    final buttons = result.children.whereType<AssetButtonComponent>().toList();
    expect(buttons, hasLength(3));
    for (var index = 0; index < buttons.length; index++) {
      final button = buttons[index];
      button.onTapDown(
        TapDownEvent(
          index + 1,
          game,
          TapDownDetails(globalPosition: Offset.zero),
        ),
      );
      button.onTapUp(
        TapUpEvent(
          index + 1,
          game,
          TapUpDetails(
            globalPosition: Offset.zero,
            kind: PointerDeviceKind.touch,
          ),
        ),
      );
    }

    expect(retries, 1);
    expect(continues, 1);
    expect(campaignReturns, 1);
  });

  testWithFlameGame('failed result has no rewards or continue action', (
    game,
  ) async {
    var continueCalls = 0;
    final result = await StageResultComponent.load(
      game.images,
      labels: testCampaignUiLabels(),
      safeAreaInsets: EdgeInsets.zero,
      isSuccess: false,
      rewardLines: const [],
      onRetry: () {},
      onContinue: () => continueCalls++,
      onCampaign: () {},
    );
    await game.ensureAdd(result);

    expect(result.canContinue, isFalse);
    final buttons = result.children.whereType<AssetButtonComponent>().toList();
    expect(buttons, hasLength(3));
    expect(buttons[1].isVisible, isFalse);
    expect(buttons[1].enabled, isFalse);
    buttons[1].onTapDown(
      TapDownEvent(1, game, TapDownDetails(globalPosition: Offset.zero)),
    );
    buttons[1].onTapUp(
      TapUpEvent(
        1,
        game,
        TapUpDetails(
          globalPosition: Offset.zero,
          kind: PointerDeviceKind.touch,
        ),
      ),
    );
    expect(continueCalls, 0);
  });
}
