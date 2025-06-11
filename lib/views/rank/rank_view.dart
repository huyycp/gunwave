import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:gunwave/data/constants/game/game_button.dart';
import 'package:gunwave/data/constants/game/game_color.dart';
import 'package:gunwave/data/constants/game/game_map.dart';
import 'package:gunwave/data/models/rank_model.dart';
import 'package:gunwave/views/home/widgets/background.dart';
import 'package:gunwave/views/rank/rank_view_model.dart';
import 'package:gunwave/widgets/base/base_view.dart';
import 'package:gunwave/widgets/game/game_button.dart';
import 'package:intl/intl.dart';

class RankView extends BaseView {
  const RankView({this.roomId, this.userId, super.key});

  final String? roomId;
  final String? userId;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() {
    return RankViewState();
  }
}

class RankViewState extends BaseViewState<RankView, RankViewModel> { 
  late final Widget _background = GameWidget(game: FlameGame(
    world: Background(
      backgroundPath: GameMaps.loading,
      screenSize: Vector2(MediaQuery.sizeOf(context).width, MediaQuery.sizeOf(context).height),
    ),
    camera: CameraComponent()
      ..viewfinder.anchor = Anchor.topLeft
      ..viewfinder.zoom = 1.0
  ));

  @override
  void onReady() {
    super.onReady();
    model.getRanks(roomId: widget.roomId);
  }
  
  @override
  Widget getView() {
    ref.watch(rankViewModel);
    return Scaffold(
      body: Stack(
        children: [
          _background,
          Positioned(
            top: 16,
            left: 32,
            child: _buildBackBtn(),
          ),
          Positioned(
            top: 16,
            left: 96,
            right: 16,
            child: _buildHeader(),
          ),
          Positioned.fill(
            top: 84,
            left: 96,
            right: 16,
            child: _buildListRank(),
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
      size: GameButtonSize.small,
      child: const Icon(Icons.arrow_back, color: GameColors.primary),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: GameColors.primary.withOpacity(0.3),
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              'Player',
              style: TextStyle(color: GameColors.primary, fontSize: 20),
            ),
          ),
          Expanded(
            child: Text(
              'Score',
              textAlign: TextAlign.center,
              style: TextStyle(color: GameColors.primary, fontSize: 20),
            ),
          ),
          Expanded(
            child: Text(
              'Duration',
              textAlign: TextAlign.center,
              style: TextStyle(color: GameColors.primary, fontSize: 20),
            ),
          ),
          Expanded(
            child: Text(
              'At',
              style: TextStyle(color: GameColors.primary, fontSize: 20),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildListRank() {
    return ListView.separated(
      itemCount: model.ranks.length,
      itemBuilder: (context, index) {
        return _buildRankItem(model.ranks[index]);
      },
      separatorBuilder: (context, index) => const SizedBox(height: 16)
    );
  }

  Widget _buildRankItem(RankModel rank) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: GameColors.primary.withOpacity(0.3),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              rank.user.name,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: GameColors.primary, fontSize: 20)
            )
          ),
          Expanded(
            child: Text(
              '${rank.score}', 
              textAlign: TextAlign.center,
              style: const TextStyle(color: GameColors.primary, fontSize: 18)
            )
          ),
          Expanded(
            child: Text(
              '${rank.duration.inSeconds}s', 
              textAlign: TextAlign.center,
              style: const TextStyle(color: GameColors.primary, fontSize: 18)
            )
          ),
          Expanded(
            child: Text(
                DateFormat('HH:mm:ss dd/MM/yyyy').format(rank.createdAt.toLocal()), 
              style: const TextStyle(color: GameColors.primary, fontSize: 18)
            )
          ),
        ],
      ),
    );
  }
  
  @override
  RankViewModel getViewModel() {
    return ref.read(rankViewModel);
  }
}