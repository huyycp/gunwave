import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gunwave/data/constants/app_constant.dart';
import 'package:gunwave/routes.dart';
import 'package:gunwave/theme/theme_provider.dart';
import 'package:gunwave/utils/ui/snackbar.dart';

class GunwaveApp extends ConsumerWidget {
  const GunwaveApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp.router(
      scaffoldMessengerKey: SnackBarService.scaffoldMessengerKey,
      title: AppConstant.appName,
      theme: ref.watch(themeProvider).themeData,
      routerConfig: Routes.config,
      debugShowCheckedModeBanner: false,
    );
  }
}
