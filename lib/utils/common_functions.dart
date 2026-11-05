import 'package:flutter/material.dart';
import 'package:gunwave/data/constants/game/game_button.dart';
import 'package:gunwave/data/constants/game/game_character.dart';
import 'package:gunwave/data/constants/game/game_monster.dart';
import 'package:flutter/services.dart';

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
