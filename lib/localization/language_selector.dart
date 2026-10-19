import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gunwave/data/constants/game/game_color.dart';
import 'package:gunwave/data/constants/game/game_ui.dart';
import 'package:gunwave/localization/build_context_l10n.dart';
import 'package:gunwave/localization/app_locale_controller.dart';
import 'package:gunwave/localization/app_locale_mode.dart';

/// Parchment language choices for Settings, backed by the persisted app locale.
/// RadioGroup provides selection semantics and keyboard navigation.
class LanguageSelector extends ConsumerWidget {
  const LanguageSelector({super.key});

  static const _gap = 8.0;
  static const _fontSize = 12.0;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.watch(appLocaleControllerProvider);
    final strings = context.l10n;
    final options = [
      (AppLocaleMode.system, strings.deviceLanguage),
      (AppLocaleMode.english, strings.english),
      (AppLocaleMode.vietnamese, strings.vietnamese),
    ];
    return RadioTheme(
      data: const RadioThemeData(
        fillColor: WidgetStatePropertyAll(GameColors.primary),
      ),
      child: RadioGroup<AppLocaleMode>(
        groupValue: controller.mode,
        onChanged: (mode) {
          if (mode != null) unawaited(controller.setMode(mode));
        },
        child: Column(
          spacing: _gap,
          children: [
            for (final (mode, label) in options)
              DecoratedBox(
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage(GameBanners.carvedSlide.path),
                    fit: BoxFit.fill,
                    filterQuality: FilterQuality.none,
                  ),
                ),
                child: Material(
                  color: Colors.transparent,
                  child: RadioListTile<AppLocaleMode>(
                    value: mode,
                    selected: controller.mode == mode,
                    title: Text(
                      label,
                      style: GoogleFonts.pressStart2p(
                        fontSize: _fontSize,
                        color: GameColors.primary,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
