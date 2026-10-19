import 'package:flutter/material.dart';
import 'package:gunwave/data/constants/game/game_color.dart';

/// Shows rank submission progress and keeps system Back on the game route.
class RankSubmissionLoadingDialog extends StatelessWidget {
  const RankSubmissionLoadingDialog({super.key});

  @override
  Widget build(BuildContext context) => const PopScope<void>(
    canPop: false,
    child: Center(child: CircularProgressIndicator(color: GameColors.primary)),
  );
}
