import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:gunwave/data/constants/game/game_color.dart';
import 'package:gunwave/routes.dart';
import 'package:gunwave/theme/app_colors.dart';
import 'package:gunwave/theme/theme_provider.dart';
import 'base_widget_model.dart';

abstract class BaseWidget extends ConsumerStatefulWidget {
  const BaseWidget({super.key});
}

abstract class BaseWidgetState<T extends BaseWidget,
V extends BaseWidgetModel<dynamic>> extends ConsumerState<T>
    with AutomaticKeepAliveClientMixin<T> {
  late V model;

  bool isFullscreenLoading = false;

  @override
  void initState() {
    model = getWidgetModel();
    model.attachView(this);
    super.initState();
    SchedulerBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        onReady();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    ref.watch(themeProvider.select((selector) => selector.isDarkMode));
    return getWidget();
  }

  @override
  void dispose() {
    model.detachView();
    super.dispose();
  }

  void onReady() {}

  Widget getWidget();

  V getWidgetModel();

  @override
  bool get wantKeepAlive => shouldKeepState();

  bool shouldKeepState() => false;

  AppColors get colors => ref.read(themeProvider).colors;
  TextTheme get textStyles => ref.read(themeProvider).textStyles;

  void showFullScreenLoading() {
    if (isFullscreenLoading) return;
    isFullscreenLoading = true;
    showDialog(
      context: navigatorKey.currentContext!,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(
          color: GameColors.primary,
        ),
      ),
    );
  }

  void hideFullScreenLoading() {
    if (!isFullscreenLoading) return;
    isFullscreenLoading = false;
    context.pop();
  }
}