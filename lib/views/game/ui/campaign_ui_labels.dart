/// Localized labels and formatting callbacks used by the Flame campaign UI.
///
/// Keeping these values outside Flame lets the game components stay independent
/// of Flutter's localization and widget layers.
class CampaignUiLabels {
  const CampaignUiLabels({
    required this.health,
    required this.boss,
    required this.specialAbility,
    required this.ready,
    required this.paused,
    required this.resume,
    required this.exitStage,
    required this.exitConfirmation,
    required this.completed,
    required this.failed,
    required this.rewards,
    required this.rewardsAlreadyClaimed,
    required this.progressSaveFailed,
    required this.retry,
    required this.continueCampaign,
    required this.campaign,
    required this.keyboardGuide,
    required this.keyboardAbilityGuide,
    required this.gestureInputUnavailable,
    required this.abilityCooldown,
    required this.abilityActive,
    required this.roundProgress,
  });

  final String health;
  final String boss;
  final String specialAbility;
  final String ready;
  final String paused;
  final String resume;
  final String exitStage;
  final String exitConfirmation;
  final String completed;
  final String failed;
  final String rewards;
  final String rewardsAlreadyClaimed;
  final String progressSaveFailed;
  final String retry;
  final String continueCampaign;
  final String campaign;
  final String keyboardGuide;
  final String keyboardAbilityGuide;
  final String gestureInputUnavailable;
  final String Function(int seconds) abilityCooldown;
  final String Function(int seconds) abilityActive;
  final String Function(int round, int total) roundProgress;
}
