import 'package:flame/components.dart';
import 'package:flame/flame.dart';
import 'package:flame_tiled/flame_tiled.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gunwave/data/constants/game/game_components.dart';
import 'package:gunwave/data/constants/game/game_constants.dart';
import 'package:gunwave/data/constants/game/game_layer.dart';
import 'package:gunwave/data/data_sources/local/campaign_content_data_source.dart';
import 'package:gunwave/data/models/stage_round_model.dart';
import 'package:gunwave/repositories/campaign_repository.dart';
import 'package:gunwave/utils/tiled_map_asset_images.dart';
import 'package:gunwave/views/game/components/campaign_spawn_marker_validator.dart';
import 'package:gunwave/views/game/components/round_director.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test(
    'starts each configured round once and completes after the boss clears',
    () {
      final startedRounds = <int>[];
      var completionCount = 0;
      final director = RoundDirector(
        rounds: _rounds(),
        intermissionDuration: const Duration(milliseconds: 500),
        onRoundStarted: (round) => startedRounds.add(round.number),
        onStageCompleted: () => completionCount++,
      );

      director.start();
      director.start();
      expect(startedRounds, [1]);
      expect(director.currentRound?.number, 1);

      director.update(
        1,
        activeEnemyCount: 1,
        isPaused: false,
        resultsVisible: false,
      );
      expect(startedRounds, [1]);

      director.update(
        0.3,
        activeEnemyCount: 0,
        isPaused: false,
        resultsVisible: false,
      );
      director.update(
        1,
        activeEnemyCount: 0,
        isPaused: true,
        resultsVisible: false,
      );
      director.update(
        1,
        activeEnemyCount: 0,
        isPaused: false,
        resultsVisible: true,
      );
      expect(startedRounds, [1]);

      director.update(
        0.2,
        activeEnemyCount: 0,
        isPaused: false,
        resultsVisible: false,
      );
      expect(startedRounds, [1, 2]);
      expect(director.currentRound?.isBoss, isTrue);

      director.update(
        0.5,
        activeEnemyCount: 0,
        isPaused: false,
        resultsVisible: false,
      );
      director.update(
        0.5,
        activeEnemyCount: 0,
        isPaused: false,
        resultsVisible: false,
      );
      director.update(
        1,
        activeEnemyCount: 0,
        isPaused: false,
        resultsVisible: false,
      );

      expect(completionCount, 1);
      expect(director.isFinished, isTrue);
    },
  );

  test(
    'resets the clear wait if enemies remain and stop prevents another round',
    () {
      final startedRounds = <int>[];
      final director = RoundDirector(
        rounds: _rounds(),
        intermissionDuration: const Duration(milliseconds: 500),
        onRoundStarted: (round) => startedRounds.add(round.number),
        onStageCompleted: () {},
      );
      director.start();
      director.update(
        0.4,
        activeEnemyCount: 0,
        isPaused: false,
        resultsVisible: false,
      );
      director.update(
        0.1,
        activeEnemyCount: 1,
        isPaused: false,
        resultsVisible: false,
      );
      director.update(
        0.4,
        activeEnemyCount: 0,
        isPaused: false,
        resultsVisible: false,
      );
      director.stop();
      director.update(
        1,
        activeEnemyCount: 0,
        isPaused: false,
        resultsVisible: false,
      );

      expect(startedRounds, [1]);
    },
  );

  test('rejects an empty round list', () {
    expect(
      () => RoundDirector(
        rounds: const [],
        onRoundStarted: (_) {},
        onStageCompleted: () {},
      ),
      throwsArgumentError,
    );
  });

  test('Stage 1 spawn markers exist in its loaded Tiled map', () async {
    final stage = await CampaignRepository(AssetCampaignContentDataSource())
        .getStage('stage_1');
    final originalPrefix = Flame.images.prefix;
    final mapImages = TiledMapAssetImages();
    TiledAtlas.clearCache();
    Flame.images.prefix = '';
    try {
      final tiled = await TiledComponent.load(
        '${stage.map!.name}.tmx',
        Vector2.all(GameConstants.tileSize),
        images: mapImages,
      );
      final spawnPoints = tiled.tileMap.getLayer<ObjectGroup>(
        GameLayers.spawnPoints.name,
      );
      final markerNames = spawnPoints!.objects
          .where((point) => point.class_ == GameComponents.monster)
          .map((point) => point.name)
          .toSet();
      final configuredMarkers = stage.rounds
          .expand((round) => round.encounters)
          .map((encounter) => encounter.spawnMarker)
          .toSet();

      expect(markerNames, containsAll(configuredMarkers));
      expect(
        () => validateCampaignSpawnMarkers(stage, markerNames),
        returnsNormally,
      );
      final missingMarkerNames = Set<String>.of(markerNames)
        ..remove(configuredMarkers.first);
      expect(
        () => validateCampaignSpawnMarkers(stage, missingMarkerNames),
        throwsA(isA<CampaignContentException>()),
      );
      expect(mapImages.containsKey('../images/terrain/elevation.png'), isTrue);
    } finally {
      mapImages.clearCache();
      TiledAtlas.clearCache();
      Flame.images.prefix = originalPrefix;
    }
  });
}

List<StageRoundModel> _rounds() => const [
  StageRoundModel(id: 'round_1', number: 1),
  StageRoundModel(id: 'round_2', number: 2, isBoss: true),
];
