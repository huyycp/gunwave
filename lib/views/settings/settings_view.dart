import 'package:flutter/widgets.dart';
import 'package:gunwave/views/rpg_ui/rpg_menu_host.dart';
import 'package:gunwave/views/rpg_ui/rpg_menu_models.dart';

/// Language settings route rendered by the shared Flame menu game.
class SettingsView extends StatelessWidget {
  const SettingsView({super.key});

  @override
  Widget build(BuildContext context) =>
      const RpgMenuHost(initialPage: RpgMenuPage.settings);
}
