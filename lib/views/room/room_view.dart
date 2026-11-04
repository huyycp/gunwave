import 'package:flutter/widgets.dart';
import 'package:gunwave/views/rpg_ui/rpg_menu_host.dart';
import 'package:gunwave/views/rpg_ui/rpg_menu_models.dart';

/// Campaign map route retained at the existing map URL for deep-link stability.
class RoomView extends StatelessWidget {
  const RoomView({super.key});

  @override
  Widget build(BuildContext context) =>
      const RpgMenuHost(initialPage: RpgMenuPage.campaignMap);
}
