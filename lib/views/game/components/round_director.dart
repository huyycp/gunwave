import 'package:gunwave/data/models/stage_round_model.dart';

/// Starts ordered rounds and completes the stage after a clear intermission.
class RoundDirector {
  /// Default delay that lets a round-clear transition be perceived.
  static const defaultIntermissionDuration = Duration(seconds: 1);

  /// Creates a director for [rounds].
  RoundDirector({
    required List<StageRoundModel> rounds,
    required this.onRoundStarted,
    required this.onStageCompleted,
    this.intermissionDuration = defaultIntermissionDuration,
  }) : rounds = List.unmodifiable(rounds) {
    if (this.rounds.isEmpty) {
      throw ArgumentError.value(rounds, 'rounds', 'must not be empty');
    }
    if (intermissionDuration.isNegative) {
      throw ArgumentError.value(
        intermissionDuration,
        'intermissionDuration',
        'must not be negative',
      );
    }
  }

  /// Ordered stage rounds.
  final List<StageRoundModel> rounds;

  /// Called once when a new round becomes active.
  final void Function(StageRoundModel round) onRoundStarted;

  /// Called once after the final round has been cleared.
  final void Function() onStageCompleted;

  /// Time between clearing a round and starting its successor.
  final Duration intermissionDuration;

  int _currentIndex = -1;
  Duration _clearDuration = Duration.zero;
  bool _hasStarted = false;
  bool _isStopped = false;
  bool _isCompleted = false;

  /// The active round, or the final round after the stage has been cleared.
  StageRoundModel? get currentRound =>
      _currentIndex >= 0 && _currentIndex < rounds.length
      ? rounds[_currentIndex]
      : null;

  /// Whether [start] has been called successfully.
  bool get hasStarted => _hasStarted;

  /// Whether the director has been stopped or completed.
  bool get isFinished => _isStopped || _isCompleted;

  /// Starts the first round; repeated calls are ignored.
  void start() {
    if (_hasStarted || _isStopped || _isCompleted) return;
    _hasStarted = true;
    _currentIndex = 0;
    onRoundStarted(rounds.first);
  }

  /// Advances only while the game is active and the current wave is cleared.
  void update(
    double dt, {
    required int activeEnemyCount,
    required bool isPaused,
    required bool resultsVisible,
  }) {
    if (!_hasStarted ||
        _isStopped ||
        _isCompleted ||
        isPaused ||
        resultsVisible) {
      return;
    }
    if (activeEnemyCount > 0) {
      _clearDuration = Duration.zero;
      return;
    }
    if (!dt.isFinite || dt <= 0) return;

    _clearDuration += Duration(
      microseconds: (dt * Duration.microsecondsPerSecond).round(),
    );
    if (_clearDuration < intermissionDuration) return;

    _clearDuration = Duration.zero;
    if (_currentIndex == rounds.length - 1) {
      _isCompleted = true;
      onStageCompleted();
      return;
    }

    _currentIndex++;
    onRoundStarted(rounds[_currentIndex]);
  }

  /// Prevents future round starts, for example after player defeat or exit.
  void stop() {
    _isStopped = true;
    _clearDuration = Duration.zero;
  }
}
