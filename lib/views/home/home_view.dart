import 'package:flutter/widgets.dart';
import 'package:gunwave/views/rpg_ui/rpg_menu_host.dart';
import 'package:gunwave/views/rpg_ui/rpg_menu_models.dart';

/// Opens the local RPG hub directly; no account or guest identity is needed.
class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) =>
      const RpgMenuHost(initialPage: RpgMenuPage.homeHub);
}
