import 'package:flutter/material.dart';
import 'package:gunwave/theme/app_colors.dart';
import 'package:gunwave/theme/theme_provider.dart';
import 'package:gunwave/theme/text_theme.dart';

class SnackBarService {
  static final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();

  SnackBarService._internal();

  static void showSnackBar({
    required String message,
    MessageTypes type = MessageTypes.info,
  }) {

    Color color;
    switch (type) {
      case MessageTypes.success:
        color = kColorSuccess;
        break;
      case MessageTypes.warning:
        color = kColorWarning;
        break;
      case MessageTypes.error:
        color = kColorError;
        break;
      default:
        color = ThemeProvider.instance.colors.alternate;
    }
    scaffoldMessengerKey.currentState?.showSnackBar(SnackBar(
      backgroundColor: ThemeProvider.instance.colors.secondaryBackground,
      behavior: SnackBarBehavior.floating,
      duration: const Duration(seconds: 1),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide.none,
      ),
      padding: EdgeInsets.zero,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      content: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: color,
              width: 3,
            ),
          ),
        ),
        child: Text(
          message,
          style: BaseTextTheme.TITLE_SMALL.copyWith(
            color: color,
          ),
          softWrap: true,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    ));
  }
}

enum MessageTypes {
  success,
  warning,
  error,
  info,
}