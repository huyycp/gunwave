import 'package:flutter/widgets.dart';
import 'package:gunwave/views/rpg_ui/rpg_menu_host.dart';
import 'package:gunwave/views/rpg_ui/rpg_menu_models.dart';

/// Hosts the Flame-rendered Campaign Map at the existing `/map` route.
class CampaignMapView extends StatelessWidget {
  const CampaignMapView({super.key});

  @override
  Widget build(BuildContext context) =>
      const RpgMenuHost(initialPage: RpgMenuPage.campaignMap);
}
