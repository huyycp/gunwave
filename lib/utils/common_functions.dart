import 'package:flutter/material.dart';
import 'package:gunwave/data/constants/game/game_button.dart';
import 'package:gunwave/data/constants/game/game_character.dart';
import 'package:gunwave/data/constants/game/game_map.dart';
import 'package:gunwave/data/constants/game/game_monster.dart';
import 'package:gunwave/theme/theme_provider.dart';
import 'package:random_avatar/random_avatar.dart';
import 'package:flutter/services.dart';

Widget randomAvatar({String? seed, double? width, double? height, bool border = true}) 
  => Container(
    decoration: BoxDecoration(
      border: border ? Border.all(color: ThemeProvider.instance.colors.secondaryBackground, width: 2) : null,
      shape: BoxShape.circle,
    ),
    child: RandomAvatar(seed ?? DateTime.now().toIso8601String(), trBackground: true, width: width, height: height),
  );

String uuidToHex(String? uuid) {
  if (uuid == null || uuid.isEmpty) return '';
  return '0x${uuid.replaceAll('-', '')}';
}

Future<void> copyToClipboard(String? text) async {
  await Clipboard.setData(ClipboardData(text: text ?? ''));
}

Future<String> pasteFromClipBoard() async {
  final clipboardData = await Clipboard.getData(Clipboard.kTextPlain);
  return clipboardData?.text ?? '';
}

void showAppModalBottomSheet(BuildContext context, Widget child, {bool isDismissale = true}) {
  showModalBottomSheet(
    context: context, 
    isDismissible: isDismissale,
    showDragHandle: true,
    enableDrag: true,
    useSafeArea: true,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => child
  );
}

String getGameButtonPath(GameButtonState state, GameButtonSize size) {
  final sizeText = size.text.isNotEmpty ? '_${size.text}' : '';
  final stateText = state.text.isNotEmpty ? '_${state.text}' : '';
  return 'assets/images/ui/buttons/button$sizeText$stateText.png';
}

// Handle api response
int intFromJson(dynamic json, {int defaultValue = 0}) {
  return json != null ? (int.tryParse(json.toString()) ?? defaultValue) : defaultValue;
}

GameCharacters? characterFromFile(String filename, {GameCharacters? defaultFile}) {
  return GameCharacters.values.firstWhere(
    (character) => character.name == filename,
    orElse: () => defaultFile ?? GameCharacters.blueWarrior,
  );
}

GameMonsters? monsterFromFile(String filename, {GameMonsters? defaultFile}) {
  return GameMonsters.values.firstWhere(
    (monster) => monster.name == filename,
    orElse: () => defaultFile ?? GameMonsters.blueTorch,
  );
}

GameMaps? mapFromFile(String filename, {GameMaps? defaultFile}) {
  return GameMaps.values.firstWhere(
    (map) => map.name == filename,
    orElse: () => defaultFile ?? GameMaps.forest,
  );
}