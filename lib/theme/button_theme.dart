import 'package:gunwave/theme/app_colors.dart';
import 'package:gunwave/theme/theme_provider.dart';
import 'package:gunwave/widgets/app_button.dart';

Map<ButtonSize, dynamic> BUTTON_SIZE = {
  ButtonSize.large: (
    height: 44.0,
    width: 86.0,
    borderRadius: 14.0,
    padding: (top: 12.0, right: 24.0, bottom: 12.0, left: 24.0)
  ),
  ButtonSize.medium: (
    height: 36.0,
    width: 70.0,
    borderRadius: 12.0,
    padding: (top: 8.0, right: 16.0, bottom: 8.0, left: 16.0)
  ),
  ButtonSize.small: (
    height: 28.0,
    width: 62.0,
    borderRadius: 8.0,
    padding: (top: 4.0, right: 12.0, bottom: 4.0, left: 12.0)
  )
};

Map<ButtonType, dynamic> BUTTON_STYLE = {
  ButtonType.elevated: (
    backgroundColor: kColorPrimary,
    foregroundColor: kColorButton,
    disabledBackgroundColor: ThemeProvider.instance.colors.border,
    disabledForegroundColor: ThemeProvider.instance.colors.alternate,
    shadowColor: kColorPrimary,
  ),
  ButtonType.outlined: (
    backgroundColor: kColorSurface,
    foregroundColor: kColorButton,
    disabledBackgroundColor: kColorSurface,
    disabledForegroundColor: ThemeProvider.instance.colors.alternate,
    outlineBorder: kColorPrimary,
    disableOutlineBorder: ThemeProvider.instance.colors.alternate,
    shadowColor: kColorPrimary
  ),
  ButtonType.text: (
    backgroundColor: kColorSurface,
    foregroundColor: kColorButton,
    disabledBackgroundColor: kColorSurface,
    disabledForegroundColor: ThemeProvider.instance.colors.alternate,
  )
};