import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('pins the Flutter SDK version with FVM', () async {
    final config =
        jsonDecode(await File('.fvmrc').readAsString()) as Map<String, dynamic>;

    expect(config['flutter'], '3.47.4');
  });

  test(
    'configures the iOS app for Flutter scene lifecycle',
    () async {
      final result = await Process.run(
        'plutil',
        ['-convert', 'json', '-o', '-', 'ios/Runner/Info.plist'],
      );
      expect(result.exitCode, 0, reason: result.stderr.toString());

      final infoPlist =
          jsonDecode(result.stdout as String) as Map<String, dynamic>;
      final manifest =
          infoPlist['UIApplicationSceneManifest'] as Map<String, dynamic>;
      final configurations =
          manifest['UISceneConfigurations'] as Map<String, dynamic>;
      final appConfiguration =
          (configurations['UIWindowSceneSessionRoleApplication'] as List).single
              as Map<String, dynamic>;

      expect(manifest['UIApplicationSupportsMultipleScenes'], isFalse);
      expect(appConfiguration['UISceneClassName'], 'UIWindowScene');
      expect(
          appConfiguration['UISceneDelegateClassName'], 'FlutterSceneDelegate');
      expect(appConfiguration['UISceneStoryboardFile'], 'Main');
    },
    skip: !Platform.isMacOS,
  );
}
