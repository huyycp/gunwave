import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gunwave/app.dart';
import 'package:gunwave/build_config.dart';
import 'package:gunwave/theme/theme_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // await dotenv.load(fileName: "dev.env");
  BuildConfig.instance.dev();
  runApp(ProviderScope(overrides: [
    themeProvider.overrideWith((ref) => ThemeProvider()),
  ], child: const GunwaveApp()));
}
