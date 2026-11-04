import 'package:flutter/widgets.dart';
import 'package:gunwave/views/rpg_ui/rpg_menu_host.dart';
import 'package:gunwave/views/rpg_ui/rpg_menu_models.dart';

/// Hero shop route rendered by the shared Flame menu game.
class ShopView extends StatelessWidget {
  const ShopView({super.key});

  @override
  Widget build(BuildContext context) =>
      const RpgMenuHost(initialPage: RpgMenuPage.shop);
}
