import 'package:flutter/material.dart';
import 'package:gradient_borders/gradient_borders.dart';
import 'package:gunwave/theme/app_colors.dart';
import 'package:gunwave/theme/button_theme.dart';
import 'package:gunwave/theme/text_theme.dart';
import 'package:gunwave/utils/extensions/build_context_ex.dart';
import 'package:gunwave/widgets/app_image.dart';

class AppButton extends StatelessWidget{
  const AppButton({
    required this.onPressed,
    this.onIconPressed,
    this.type = ButtonType.elevated,
    this.size = ButtonSize.small,
    this.foregroundColor,
    this.backgroundColor = const [],
    this.padding,
    this.iconPath,
    this.iconSize = 18,
    this.isOnlyIconVisible = false,
    this.iconAlignment = IconAlignment.start,
    required this.child,
    super.key,
  });

  final VoidCallback? onPressed;

  final VoidCallback? onIconPressed;
  
  final ButtonType type;
  
  final ButtonSize size;
  
  final Color? foregroundColor;
  
  /// If length = 0, it will use default background color
  /// If length is 1, it will be used as background color
  /// If length ≧ 2, it will be used as gradient color
  final List<Color> backgroundColor;
  
  final EdgeInsets? padding;
  
  final bool isOnlyIconVisible;
  
  final String? iconPath;

  final double iconSize;

  final IconAlignment iconAlignment;
  
  final Widget child;

  bool get isDisabled => onPressed == null;

  @override
  Widget build(BuildContext context) {
    final appColors = context.appColors;
    final colors = _resolveColors(appColors);
    Widget? icon = _resolveIcon(colors);
    Widget displayChild = child;
    if (isOnlyIconVisible && icon != null) {
      displayChild = icon;
      icon = null;
    }
    final style = _resolveStyle(colors);

    final Widget button;
    switch (type) {
      case ButtonType.elevated:
        button = ElevatedButton.icon(
          onPressed: onPressed,
          style: style,
          icon: icon,
          iconAlignment: iconAlignment,
          label: displayChild,
        );
      case ButtonType.outlined:
        button = OutlinedButton.icon(
          onPressed: onPressed,
          style: style,
          icon: icon,
          iconAlignment: iconAlignment,
          label: displayChild,
        );
      case ButtonType.text:
        button = TextButton.icon(
          onPressed: onPressed,
          style: style,
          icon: icon,
          iconAlignment: iconAlignment,
          label: displayChild,
        );
    }

    final colorBg = type == ButtonType.elevated && backgroundColor.length <= 1
      ? isDisabled
        ? colors.disabledBackgroundColor
        : backgroundColor.isNotEmpty
          ? backgroundColor.first
          : null
      : type == ButtonType.outlined
        ? appColors.primaryBackground
        : null;
    final gradientBg = isDisabled
      ? null
      : backgroundColor.length > 1 
        ? LinearGradient(
          colors: backgroundColor,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        )
        : backgroundColor.isEmpty
          ? kGradient1
          : null;
    final gradientBorder = type == ButtonType.outlined
      ?  gradientBg != null
          ? GradientBoxBorder(
            gradient: gradientBg
          )
          : Border.all(color: colors.disabledForegroundColor)
      : null;
    return Container(
      constraints: const BoxConstraints.tightFor() ,
      height: BUTTON_SIZE[size].height,
      decoration: BoxDecoration(
        color: colorBg,
        gradient: type == ButtonType.elevated ? gradientBg : null,
        border: gradientBorder,
        borderRadius: BorderRadius.circular(BUTTON_SIZE[size].borderRadius),
      ),
      child: button,
    );
  }

  ButtonColors _resolveColors(AppColors colors) {
    return ButtonColors(
      effectiveForegroundColor: colors.primaryText,
      effectiveBackgroundColor: Colors.transparent,
      disabledForegroundColor: colors.alternate,
      disabledBackgroundColor: colors.secondaryBackground,
    );
  }

  Widget? _resolveIcon(ButtonColors colors) {
    if (iconPath == null) return null;
    return AppImage(
      iconPath!,
      width: iconSize,
      height: iconSize,
      color: isDisabled ? colors.disabledForegroundColor : colors.effectiveForegroundColor,
    );
  }

  ButtonStyle _resolveStyle(ButtonColors colors) {
    final buttonFigures = BUTTON_SIZE[size];
    final buttonSize = Size(buttonFigures.width, buttonFigures.height);
    final padding = EdgeInsets.only(
      // top: buttonFigures.padding.top,
      right: buttonFigures.padding.right,
      // bottom: buttonFigures.padding.bottom,
      left: buttonFigures.padding.left
    );
    final backgroundColor = colors.effectiveBackgroundColor;
    final foregroundColor = colors.effectiveForegroundColor;
    final disabledBackgroundColor = colors.disabledBackgroundColor;
    final disabledForegroundColor = colors.disabledForegroundColor;
    final shadowColor = colors.shadowColor ?? Colors.transparent;
    final textStyle = BaseTextTheme.LABEL_BUTTON;
    final shape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(buttonFigures.borderRadius),
      side: BorderSide.none
    );

    switch (type) {
      case ButtonType.elevated:
        return ElevatedButton.styleFrom(
          minimumSize: buttonSize,
          padding: padding,
          backgroundColor: backgroundColor,
          foregroundColor: foregroundColor,
          disabledBackgroundColor: disabledBackgroundColor,
          disabledForegroundColor: disabledForegroundColor,
          shadowColor: shadowColor,
          textStyle: textStyle,
          shape: shape,
        );
      case ButtonType.outlined:
        return OutlinedButton.styleFrom(
          minimumSize: buttonSize,
          padding: padding,
          side: const BorderSide(color: Colors.transparent),
          backgroundColor: backgroundColor,
          foregroundColor: foregroundColor,
          disabledBackgroundColor: disabledBackgroundColor,
          disabledForegroundColor: disabledForegroundColor,
          shadowColor: shadowColor,
          textStyle: textStyle,
          shape: shape,
        );
      case ButtonType.text:
        return TextButton.styleFrom(
          minimumSize: buttonSize,
          padding: padding,
          backgroundColor: backgroundColor,
          foregroundColor: foregroundColor,
          disabledBackgroundColor: disabledBackgroundColor,
          disabledForegroundColor: disabledForegroundColor,
          textStyle: textStyle,
          shape: shape,
        );
    }
  }
}

enum ButtonSize {
  large, 
  medium,
  small,
}

enum ButtonType {
  elevated,
  outlined,
  text
}

class ButtonColors {
  const ButtonColors({
    required this.effectiveForegroundColor,
    required this.effectiveBackgroundColor,
    required this.disabledForegroundColor,
    required this.disabledBackgroundColor,
    this.shadowColor ,
  });

  final Color effectiveForegroundColor;
  final Color effectiveBackgroundColor;
  final Color disabledForegroundColor;
  final Color disabledBackgroundColor;
  final Color? shadowColor;
}