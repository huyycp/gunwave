import 'package:flame/flame.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gunwave/app.dart';
import 'package:gunwave/build_config.dart';
import 'package:gunwave/data/data_sources/remote/api/supabase_api.dart';
import 'package:gunwave/theme/theme_provider.dart';
// import 'package:sentry_flutter/sentry_flutter.dart';

void main() async {
  startApp(BuildEnv.prod);
}

void startApp(BuildEnv env) async {
  WidgetsFlutterBinding.ensureInitialized();

  switch (env) {
    case BuildEnv.dev:
      await dotenv.load(fileName: "dev.env");
      BuildConfig.instance.dev();
      break;
    case BuildEnv.prod:
      await dotenv.load(fileName: "prod.env");
      await initSentry();
      BuildConfig.instance.prod();
      break;
  }

  if (kReleaseMode) debugPrint = (String? message, {int? wrapWidth}) {};
  
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.landscapeRight,
  ]);
  await Flame.device.fullScreen();
  await Flame.device.setLandscape();
  
  await SupabaseApi().init();
  
  runApp(ProviderScope(overrides: [
    themeProvider.overrideWith((ref) => ThemeProvider()),
  ], child: const GunwaveApp()));
}

Future<void> initSentry() async {
  // await SentryFlutter.init(
  //   (options) {
  //     options
  //       ..dsn = dotenv.env['SENTRY_DSN']
  //       ..environment = dotenv.env['SENTRY_ENVIRONMENT']
  //       ..tracesSampleRate = 1.0
  //       ..profilesSampleRate = 1.0;
  //   },
  //   appRunner: () => runApp(ProviderScope(overrides: [
  //     themeProvider.overrideWith((ref) => ThemeProvider()),
  //   ], child: const MyApp())),
  // );
}