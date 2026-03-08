import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gunwave/data/constants/game/game_color.dart';
import 'package:gunwave/data/constants/game/game_ui.dart';
import 'package:gunwave/data/models/reward_model.dart';
import 'package:gunwave/routes.dart';
import 'package:gunwave/views/game/components/sub_components/app_banner.dart';

class StageResultDialog extends StatelessWidget {
  StageResultDialog({
    required this.result,
    required this.rewards,
    this.score,
    super.key,
  });

  final bool result;
  final List<RewardModel> rewards;
  int? score;

  static void show({
    required bool result,
    required List<RewardModel> rewards,
    int? score,
  }) {
    showDialog(
      context: navigatorKey.currentContext!,
      barrierDismissible: false,
      builder: (context) => Dialog(
        child: StageResultDialog(
          result: result,
          rewards: rewards,
          score: score,
        ),
      ),
    );
  }

  final _background = GameWidget(
    game: FlameGame(
      children: [
        AppBanner(
          banner: GameBanners.bannerHorizontal,
          xCount: 6,
          yCount: 3,
        )
      ]  
    ),
  );

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 400,
      height: 200,
      child: Stack(
        children: [
          _background,
          Center(
            child: Column(
              spacing: 16,
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  result ? 'Completed' : 'Failed',
                  style: GoogleFonts.pressStart2p(
                    fontSize: 24,
                    color: GameColors.primary,
                  ),
                  textAlign: TextAlign.center,
                ),
                if (result) ...[
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    spacing: 8,
                    children: [
                      Text(
                        'Rewards',
                        style: GoogleFonts.pressStart2p(
                          fontSize: 16,
                          color: GameColors.primary,
                        ),
                      ),
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: rewards.map((reward) => _buildRewardItem(reward)).toList(),
                      )
                    ],
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    spacing: 8,
                    children: [
                      Text(
                        'Score',
                        style: GoogleFonts.pressStart2p(
                          fontSize: 16,
                          color: GameColors.primary,
                        ),
                      ),
                      Text(
                        score?.toString() ?? '0',
                        style: GoogleFonts.pressStart2p(
                          fontSize: 16,
                          color: GameColors.primary,
                        ),
                      ),
                    ],
                  ),
                ],
                _buildCloseButton(context),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRewardItem(RewardModel reward) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      spacing: 4,
      children: [
        Text(
          reward.amount.toString(),
          style: GoogleFonts.pressStart2p(
            fontSize: 16,
            color: GameColors.primary,
          ),
        ),
        Text(reward.type.name.toUpperCase(), style: GoogleFonts.pressStart2p(fontSize: 16, color: GameColors.primary)),
      ],
    );
  }

  Widget _buildCloseButton(BuildContext context) {
    return GestureDetector(
      onTap: () {
        context.pop();
        context.pop();
      },
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage(GameBanners.carvedSlide.path),
            fit: BoxFit.fill,
          ),
        ),
        child: Text(
          'Back',
          style: GoogleFonts.pressStart2p(
            fontSize: 16,
            color: Colors.white,
          ),
        ),
      )
    );
  }
}