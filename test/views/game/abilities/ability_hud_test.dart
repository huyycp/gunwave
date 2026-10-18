import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gunwave/data/models/ability_model.dart';
import 'package:gunwave/l10n/app_localizations.dart';
import 'package:gunwave/views/game/abilities/ability_controller.dart';
import 'package:gunwave/views/game/abilities/ability_registry.dart';
import 'package:gunwave/views/game/widgets/ability_hud.dart';

import 'ability_test_support.dart';

void main() {
  Future<void> mount(
    WidgetTester tester,
    AbilityController controller, {
    bool keyboard = true,
    String language = 'en',
  }) => tester.pumpWidget(
    MaterialApp(
      locale: Locale(language),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(
        body: Center(
          child: AbilityHud(
            controller: controller,
            isKeyboard: keyboard,
            onActivate: () => controller.activate(),
          ),
        ),
      ),
    ),
  );

  testWidgets(
    'shield HUD shows active duration and disabled cooldown, then expires',
    (tester) async {
      final context = FakeContext();
      final controller = AbilityController(
        context: context,
        ability: AbilityRegistry.create(
          const AbilityModel(
            key: 'bulwark',
            name: 'Bulwark',
            cooldownMs: 14000,
            durationMs: 3000,
            parameters: {'damage_reduction': .4},
          ),
        ),
      );
      addTearDown(controller.dispose);
      await mount(tester, controller);
      expect(find.text('In use'), findsNothing);
      await tester.tap(find.text('Special (K)'));
      await tester.pump();
      expect(find.text('In use'), findsOneWidget);
      expect(find.text('Active: 3s'), findsNothing);
      expect(find.text('14s'), findsOneWidget);
      expect(tester.widget<InkWell>(find.byType(InkWell)).onTap, isNull);
      context.caster.effects.update(3);
      controller.update(3);
      await tester.pump();
      expect(find.text('In use'), findsNothing);
      expect(find.text('Active: 3s'), findsNothing);
    },
  );

  testWidgets('charged attacks update the HUD when consumed', (tester) async {
    final context = FakeContext();
    final controller = AbilityController(
      context: context,
      ability: AbilityRegistry.create(
        const AbilityModel(
          key: 'power_break',
          name: 'Power Break',
          cooldownMs: 14000,
          parameters: {'attack_count': 3, 'damage_multiplier': 1.5},
        ),
      ),
    );
    addTearDown(controller.dispose);
    await mount(tester, controller);
    await tester.tap(find.text('Special (K)'));
    await tester.pump();
    expect(find.text('In use'), findsOneWidget);
    expect(find.text('Enhanced attacks: 3'), findsNothing);
    context.caster.effects.consumeAttackMultiplier();
    controller.update(.1);
    await tester.pump();
    expect(find.text('In use'), findsOneWidget);
    context.caster.effects.consumeAttackMultiplier();
    context.caster.effects.consumeAttackMultiplier();
    controller.update(1);
    await tester.pump();
    expect(find.text('In use'), findsNothing);
    expect(find.text('Enhanced attacks: 2'), findsNothing);
  });

  testWidgets('touch button shows only cooldown and blocks repeated casts', (
    tester,
  ) async {
    final context = FakeContext()..caster.hp = 50;
    final controller = AbilityController(
      context: context,
      ability: AbilityRegistry.create(
        const AbilityModel(
          key: 'first_aid',
          name: 'First Aid',
          cooldownMs: 20000,
          parameters: {'heal_max_hp_fraction': .2},
        ),
      ),
    );
    addTearDown(controller.dispose);
    await mount(tester, controller, keyboard: false);
    await tester.tap(find.byType(InkWell));
    await tester.pump();
    expect(find.text('In use'), findsNothing);
    expect(find.text('20'), findsOneWidget);
    expect(tester.widget<InkWell>(find.byType(InkWell)).onTap, isNull);
    controller.update(.8);
    await tester.pump();
    expect(find.text('In use'), findsNothing);
  });

  testWidgets('in-use badge is localized in Vietnamese', (tester) async {
    final controller = AbilityController(
      context: FakeContext(),
      ability: AbilityRegistry.create(
        const AbilityModel(
          key: 'bulwark',
          name: 'Bulwark',
          cooldownMs: 14000,
          durationMs: 3000,
          parameters: {'damage_reduction': .4},
        ),
      ),
    );
    addTearDown(controller.dispose);
    await mount(tester, controller, language: 'vi');
    await tester.tap(find.text('Kỹ năng (K)'));
    await tester.pump();
    expect(find.text('Đang sử dụng'), findsOneWidget);
  });
}
