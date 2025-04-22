import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gunwave/app.dart';
import 'package:gunwave/build_config.dart';
import 'package:gunwave/theme/theme_provider.dart';
// import 'package:sentry_flutter/sentry_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (kReleaseMode) debugPrint = (String? message, {int? wrapWidth}) {};
  // await dotenv.load(fileName: "prod.env");
  BuildConfig.instance.prod();
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
  runApp(ProviderScope(overrides: [
    themeProvider.overrideWith((ref) => ThemeProvider()),
  ], child: const GunwaveApp()));
}