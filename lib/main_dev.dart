import 'package:flame/flame.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gunwave/app.dart';
import 'package:gunwave/build_config.dart';
import 'package:gunwave/theme/theme_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // await dotenv.load(fileName: "dev.env");
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.landscapeRight,
  ]);
  await Flame.device.fullScreen();
  await Flame.device.setLandscape();
  BuildConfig.instance.dev();
  runApp(ProviderScope(overrides: [
    themeProvider.overrideWith((ref) => ThemeProvider()),
  ], child: const GunwaveApp()));
}
