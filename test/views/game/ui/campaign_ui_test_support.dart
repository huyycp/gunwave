import 'package:gunwave/views/game/ui/campaign_ui_labels.dart';

CampaignUiLabels testCampaignUiLabels() => CampaignUiLabels(
  health: 'HP',
  boss: 'Boss',
  specialAbility: 'Special',
  ready: 'Ready',
  paused: 'Paused',
  resume: 'Resume',
  exitStage: 'Exit stage',
  exitConfirmation: 'Leave this stage?',
  completed: 'Completed',
  failed: 'Failed',
  rewards: 'Rewards',
  retry: 'Retry',
  continueCampaign: 'Continue',
  campaign: 'Campaign',
  keyboardGuide: 'WASD: Move',
  keyboardAbilityGuide: 'WASD: Move, K: Special',
  gestureInputUnavailable: 'Gesture input unavailable',
  abilityCooldown: (seconds) => 'Ready in ${seconds}s',
  abilityActive: (seconds) => 'Active ${seconds}s',
  roundProgress: (round, total) => 'Round $round / $total',
);
