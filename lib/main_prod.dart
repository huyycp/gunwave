import 'package:flame/flame.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gunwave/app.dart';
import 'package:gunwave/data/data_sources/local/local_app_initializer.dart';
import 'package:gunwave/data/database/app_database.dart';
import 'package:gunwave/localization/app_locale_controller.dart';
import 'package:gunwave/theme/theme_provider.dart';

Future<void> main() => startApp();

Future<void> startApp() async {
  WidgetsFlutterBinding.ensureInitialized();

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.landscapeRight,
  ]);
  await Flame.device.fullScreen();
  await Flame.device.setLandscape();

  final database = AppDatabase();
  final localeController = await LocalAppInitializer(database).initialize();

  runApp(
    ProviderScope(
      overrides: [
        appDatabaseProvider.overrideWith((ref) {
          ref.onDispose(database.close);
          return database;
        }),
        themeProvider.overrideWith((ref) => ThemeProvider()),
        appLocaleControllerProvider.overrideWith((ref) => localeController),
      ],
      child: const GunwaveApp(),
    ),
  );
}
