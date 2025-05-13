import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gunwave/data/constants/game/game_button.dart';
import 'package:gunwave/data/constants/game/game_color.dart';
import 'package:gunwave/utils/common_functions.dart';

class GameButton extends StatefulWidget {
  const GameButton({
    super.key,
    this.onPressed,
    required this.child,
    this.size = GameButtonSize.medium,
  });

  final VoidCallback? onPressed;
  final Widget child;
  final GameButtonSize size;

  @override
  State<GameButton> createState() => _GameButtonState();
}

class _GameButtonState extends State<GameButton> {
  late GameButtonState state = widget.onPressed != null ? GameButtonState.enabled : GameButtonState.disabled;

  bool get isEnabled => state == GameButtonState.enabled;
  bool get isHovered => state == GameButtonState.hovered;
  bool get isPressed => state == GameButtonState.pressed;
  bool get isDisabled => state == GameButtonState.disabled;

  Size _getButtonSize() {
    switch (widget.size) {
      case GameButtonSize.small:
        return const Size(64, 64);
      case GameButtonSize.medium:
        return const Size(192, 64);
      case GameButtonSize.large:
        return const Size(192, 192);
    }
  }

  EdgeInsets _getButtonPadding() {
    // Base padding based on size
    EdgeInsets basePadding;
    
    switch (widget.size) {
      case GameButtonSize.small:
        basePadding = const EdgeInsets.only(left: 16, right: 16, bottom: 16);
        break;
      case GameButtonSize.medium:
        basePadding = const EdgeInsets.only(left: 8, right: 8, bottom: 12);
        break;
      case GameButtonSize.large:
        basePadding = const EdgeInsets.only(left: 16, right: 8, bottom: 24);
        break;
    }
    
    // Add 4px top padding when pressed to move text down
    if (isPressed) {
      return EdgeInsets.only(
        left: basePadding.left,
        right: basePadding.right,
        bottom: basePadding.bottom - 4, // Reduce bottom to compensate
        top: 4, // Add top padding to move text down
      );
    }
    
    return basePadding;
  }

  String _getButtonImage() {
    return getGameButtonPath(state, widget.size);
  }

  @override
  Widget build(BuildContext context) {
    if (widget.onPressed == null) {
      state = GameButtonState.disabled;
    }

    final buttonSize = _getButtonSize();
    final buttonPadding = _getButtonPadding();
    
    return AbsorbPointer(
      absorbing: isDisabled,
      child: MouseRegion(
        onEnter: (_) => setState(() => state = GameButtonState.hovered),
        onExit: (_) => setState(() {
          state = GameButtonState.enabled;
        }),
        cursor: isEnabled 
          ? SystemMouseCursors.click 
          : SystemMouseCursors.forbidden,
        child: GestureDetector(
          onTapDown: (_) => setState(() => state = GameButtonState.pressed),
          onTapUp: (_) => setState(() => state = GameButtonState.enabled),
          onTapCancel: () => setState(() => state = GameButtonState.enabled),
          onTap: widget.onPressed,
          child: Container(
            width: buttonSize.width,
            height: buttonSize.height,
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage(_getButtonImage()),
                fit: BoxFit.fill,
              ),
            ),
            child: Center(
              child: Padding(
                padding: buttonPadding,
                child: DefaultTextStyle(
                  style: GoogleFonts.pressStart2p(
                    color: isEnabled ? GameColors.primary : Colors.brown.withOpacity(0.5),
                    fontSize: widget.size == GameButtonSize.small ? 14 : 
                             widget.size == GameButtonSize.medium ? 18 : 24,
                    fontWeight: FontWeight.bold,
                  ),
                  child: widget.child,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
