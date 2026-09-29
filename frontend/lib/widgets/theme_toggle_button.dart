import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/theme_controller.dart';

class ThemeToggleButton extends StatefulWidget {
  const ThemeToggleButton({
    super.key,
  });

  @override
  State<ThemeToggleButton> createState() =>
      _ThemeToggleButtonState();
}

class _ThemeToggleButtonState
    extends State<ThemeToggleButton> {
  bool _isHovered = false;
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final bool isDark =
        Theme.of(context).brightness ==
            Brightness.dark;

    return MouseRegion(
      cursor: SystemMouseCursors.click,

      onEnter: (_) {
        setState(() {
          _isHovered = true;
        });
      },

      onExit: (_) {
        setState(() {
          _isHovered = false;
          _isPressed = false;
        });
      },

      child: GestureDetector(
        onTapDown: (_) {
          setState(() {
            _isPressed = true;
          });
        },

        onTapUp: (_) {
          setState(() {
            _isPressed = false;
          });

          ThemeController.instance.toggleTheme();
        },

        onTapCancel: () {
          setState(() {
            _isPressed = false;
          });
        },

        child: AnimatedContainer(
          duration:
              const Duration(milliseconds: 180),

          curve: Curves.easeOutCubic,

          width: _isHovered ? 38 : 36,
          height: _isHovered ? 38 : 36,

          transform:
              Matrix4.translationValues(
            0,
            _isPressed
                ? 1
                : _isHovered
                    ? -1
                    : 0,
            0,
          ),

          decoration: BoxDecoration(
            color: _isHovered
                ? AppColors.slateGray
                    .withOpacity(
                    isDark ? 0.20 : 0.30,
                  )
                : Colors.transparent,

            borderRadius:
                BorderRadius.circular(9),

            border: Border.all(
              color: _isHovered
                  ? AppColors.slateGray
                      .withOpacity(
                      isDark ? 0.40 : 0.55,
                    )
                  : Colors.transparent,

              width: 0.8,
            ),

            boxShadow: _isHovered
                ? [
                    BoxShadow(
                      color: Colors.black
                          .withOpacity(
                        isDark ? 0.25 : 0.08,
                      ),
                      blurRadius: 5,
                      offset:
                          const Offset(0, 2),
                    ),
                  ]
                : [],
          ),

          child: Center(
            child: AnimatedSwitcher(
              duration:
                  const Duration(milliseconds: 220),

              transitionBuilder:
                  (child, animation) {
                return ScaleTransition(
                  scale: animation,
                  child: RotationTransition(
                    turns: animation,
                    child: child,
                  ),
                );
              },

              child: Icon(
                isDark
                    ? Icons.dark_mode_rounded
                    : Icons.light_mode_rounded,

                key: ValueKey(isDark),

                size: 19,

                color:
                    AppColors.signalOrange,
              ),
            ),
          ),
        ),
      ),
    );
  }
}