import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gunwave/data/constants/game/game_color.dart';
import 'package:gunwave/data/models/room_model.dart';
import 'package:gunwave/utils/extensions/string_ex.dart';
import 'package:gunwave/widgets/app_image.dart';
import 'package:gunwave/widgets/app_list_tile.dart';
import 'package:gunwave/widgets/game/game_button.dart';

class RoomPreviewWidget extends StatelessWidget {
  const RoomPreviewWidget(this.room, {this.onPlay, super.key});

  final RoomModel room;
  final void Function(RoomModel)? onPlay;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.sizeOf(context).height * 0.8,
      alignment: Alignment.center,
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
      child: Stack(
        children: [
          Positioned.fill(
            left: MediaQuery.sizeOf(context).width * 0.2,
            top: 0,
            bottom: 0,
            child: _buildImage(),
          ),
          Positioned.fill(
            child: _buildRoomInfo(),
          ),
        ],
      )
    );
  }

  Widget _buildImage() {
    return ShaderMask(
      shaderCallback: (rect) {
        return const LinearGradient(
          begin: Alignment.centerRight,
          end: Alignment.centerLeft,
          colors: [ GameColors.primary, Colors.transparent ],
          stops: [ 0.8, 1 ],
        ).createShader(Rect.fromLTRB(0, 0, rect.width, rect.height));
      },
      blendMode: BlendMode.dstIn,
      child: AppImage(
        room.map?.map?.imagePath ?? '',
        borderRadius: const BorderRadius.horizontal(left: Radius.circular(16)),
        fit: BoxFit.cover,
      ),
    );
  }

  Widget _buildRoomInfo() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        spacing: 16,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            room.name, 
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.pressStart2p(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: GameColors.primary,
            ),
          ),
          Text(
            room.map?.name.capitalize ?? 'Unknown Map',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.pressStart2p(
              fontSize: 14,
              color: GameColors.primary,
            ),
          ),
          AppListTile(
            padding: EdgeInsets.zero,
            leading: AppImage(
              '',
              height: 20,
              width: 20,
              isCircle: true,
              placeHolder: Container(color: GameColors.primary),
            ),
            title: room.user?.name ?? 'Unknown Creator',
            titleStyle: GoogleFonts.pressStart2p(
              fontSize: 14,
              color: GameColors.primary,
            ),
            leadingTitleSpacing: 8,
          ),
          const Spacer(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 12,
                children: [
                  Text(
                    '${room.quizzes.length} quizzes',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.pressStart2p(
                      fontSize: 13,
                      color: GameColors.primary,
                    ),
                  ),
                  Text(
                    'Time ${room.map?.timeLimit ?? 0}s',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.pressStart2p(
                      fontSize: 13,
                      color: GameColors.primary,
                    ),
                  ),
                ],
              ),
              GameButton(
                onPressed: () {
                  if (onPlay != null) {
                    onPlay!(room);
                  }
                }, 
                child: const Text('Play')
              ),
            ],
          )
        ],
      ),
    );
  }
}