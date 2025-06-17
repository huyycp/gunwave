import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gunwave/data/constants/game/game_button.dart';
import 'package:gunwave/data/constants/game/game_color.dart';
import 'package:gunwave/data/models/room_model.dart';
import 'package:gunwave/routes.dart';
import 'package:gunwave/utils/extensions/string_ex.dart';
import 'package:gunwave/widgets/app_image.dart';
import 'package:gunwave/widgets/game/game_button.dart';

class MyRoomWidget extends StatelessWidget {
  const MyRoomWidget(this.room, {super.key});

  final RoomModel room;

  final double _borderRadius = 16;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.sizeOf(context).width * 0.4,
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 71, 183, 181),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: GameColors.primary.withOpacity(0.5),
            blurRadius: 10,
            spreadRadius: 2,
          ),
        ],
      ),
      child: LayoutBuilder(
        builder: (context, constraints) => Stack(
          children: [
            Positioned.fill(child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              spacing: 8,
              children: [
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.vertical(top: Radius.circular(_borderRadius)),
                    color: const Color.fromARGB(255, 28, 168, 166),
                    
                  ),
                  child: AppImage(
                    room.map?.map?.imagePath ?? '',
                    height: constraints.maxHeight * 0.5,
                    borderRadius: BorderRadius.vertical(top: Radius.circular(_borderRadius)),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    mainAxisSize: MainAxisSize.min,
                    spacing: 12,
                    children: [
                      Text(
                        room.name,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.pressStart2p(
                          color: GameColors.primary,
                          fontSize: 16,
                        )
                      ),
                      Text(
                        room.map?.name.capitalize ?? 'Unknown Map',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.pressStart2p(
                          color: GameColors.primary,
                          fontSize: 14,
                        )
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '${room.quizzes.length} Quizzes',
                            style: GoogleFonts.pressStart2p(
                              color: GameColors.primary,
                              fontSize: 12,
                            )
                          ),
                          Text(
                            '20 played',
                            style: GoogleFonts.pressStart2p(
                              color: GameColors.primary,
                              fontSize: 12,
                            )
                          ),
                        ],
                      ),
                    ],
                  ),
                )
              ],
            )),
            Positioned(
              top: 8,
              right: 8,
              child: _buildRankInfoBtn(context),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRankInfoBtn(BuildContext context) {
    return GameButton(
      onPressed: () {
        context.push(
          Routes.rank,
          extra: {
            'room_id': room.id, 
          }
        );
      },
      size: GameButtonSize.small,
      child: const Icon(
        Icons.bar_chart,
        color: GameColors.primary,
      ),
    );
  }
}