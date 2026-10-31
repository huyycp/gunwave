import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gunwave/data/constants/app_constant.dart';
import 'package:gunwave/l10n/app_localizations.dart';
import 'package:gunwave/localization/app_locale_controller.dart';
import 'package:gunwave/routes.dart';
import 'package:gunwave/theme/theme_provider.dart';
import 'package:gunwave/utils/ui/snackbar.dart';

class GunwaveApp extends ConsumerWidget {
  const GunwaveApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = ref.watch(appLocaleControllerProvider).locale;

    return MaterialApp.router(
      scaffoldMessengerKey: SnackBarService.scaffoldMessengerKey,
      title: AppConstant.appName,
      theme: ref.watch(themeProvider).themeData,
      locale: locale,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      routerConfig: Routes.config,
      debugShowCheckedModeBanner: false,
    );
  }
}
