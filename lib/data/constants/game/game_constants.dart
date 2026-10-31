class GameConstants {
  GameConstants._();

  static const double tileSize = 64;

  static const double fps = 60;
  // Long enough to recognize an instant cast without obscuring gameplay.
  static const double abilityFeedbackDuration = .7;
  static double refreshRate = 1 / fps;
}
