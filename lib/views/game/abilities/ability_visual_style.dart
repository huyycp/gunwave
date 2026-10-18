import 'package:flutter/material.dart';

/// Shares each ability's visual identity between world effects and the HUD.
enum AbilityVisualStyle {
  bulwark('bulwark', Colors.cyanAccent, Icons.shield),
  powerBreak('power_break', Colors.deepOrangeAccent, Icons.sports_martial_arts),
  thunderCrash('thunder_crash', Colors.yellowAccent, Icons.bolt),
  riftSlash('rift_slash', Colors.purpleAccent, Icons.content_cut),
  firstAid('first_aid', Colors.greenAccent, Icons.healing),
  flameBrand('flame_brand', Colors.orangeAccent, Icons.local_fire_department),
  quickstep('quickstep', Colors.lightBlueAccent, Icons.speed),
  hexSeal('hex_seal', Colors.pinkAccent, Icons.auto_awesome);

  const AbilityVisualStyle(this.key, this.color, this.icon);
  final String key;
  final Color color;
  final IconData icon;

  static AbilityVisualStyle? forKey(String key) {
    for (final style in values) {
      if (style.key == key) return style;
    }
    return null;
  }
}
