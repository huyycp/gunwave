import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gunwave/data/constants/game/game_button.dart';
import 'package:gunwave/data/constants/game/game_color.dart';
import 'package:gunwave/data/constants/game/game_ui.dart';
import 'package:gunwave/localization/build_context_l10n.dart';
import 'package:gunwave/localization/language_selector.dart';
import 'package:gunwave/routes.dart';
import 'package:gunwave/widgets/game/game_button.dart';

/// App preferences available before sign-in and to guest or registered players.
/// Language state and persistence stay in the shared locale controller.
class SettingsView extends StatelessWidget {
  const SettingsView({super.key});

  // Keep the parchment readable on wide screens and scrollable in landscape.
  static const _panelWidth = 480.0;
  static const _edge = 16.0;
  static const _panelPadding = 24.0;
  static const _titleSize = 18.0;
  static const _labelSize = 12.0;

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: GameColors.primary,
    body: SafeArea(
      child: Column(
        children: [
          Align(
            alignment: Alignment.topLeft,
            child: Padding(
              padding: const EdgeInsets.all(_edge),
              child: Tooltip(
                message: context.l10n.back,
                child: Semantics(
                  button: true,
                  label: context.l10n.back,
                  child: GameButton(
                    size: GameButtonSize.small,
                    onPressed: () => context.canPop()
                        ? context.pop()
                        : context.go(Routes.home),
                    child: const Icon(
                      Icons.arrow_back,
                      color: GameColors.primary,
                    ),
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(_edge, 0, _edge, _edge),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: _panelWidth),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(_panelPadding),
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: AssetImage(GameBanners.carvedSquare.path),
                        fit: BoxFit.fill,
                        filterQuality: FilterQuality.none,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          context.l10n.settings,
                          textAlign: TextAlign.center,
                          style: GoogleFonts.pressStart2p(
                            fontSize: _titleSize,
                            color: GameColors.primary,
                          ),
                        ),
                        const SizedBox(height: _panelPadding),
                        Text(
                          context.l10n.language,
                          style: GoogleFonts.pressStart2p(
                            fontSize: _labelSize,
                            color: GameColors.primary,
                          ),
                        ),
                        const SizedBox(height: _edge),
                        const LanguageSelector(),
                      ],
                    ),
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
