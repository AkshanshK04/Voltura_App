import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class WindowButton extends StatefulWidget {
  final IconData icon;
  final VoidCallback onPressed;
  final bool isClose;

  const WindowButton({
    super.key,
    required this.icon,
    required this.onPressed,
    this.isClose = false,
  });

  @override
  State<WindowButton> createState() => _WindowButtonState();
}

class _WindowButtonState extends State<WindowButton> {
  bool _isHovered = false;
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final bool isCloseHover = widget.isClose && _isHovered;

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

          widget.onPressed();
        },

        onTapCancel: () {
          setState(() {
            _isPressed = false;
          });
        },

        child: AnimatedScale(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOutCubic,

          scale: _isPressed
              ? 0.92
              : _isHovered
                  ? 1.04
                  : 1.0,

          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOutCubic,

            width: _isHovered ? 37 : 36,
            height: _isHovered ? 37 : 36,

            decoration: BoxDecoration(
              color: isCloseHover
                  ? AppColors.closeRed
                  : _isHovered
                      ? AppColors.slateGray.withOpacity(0.35)
                      : Colors.transparent,

              borderRadius: BorderRadius.circular(9),

              border: Border.all(
                color: isCloseHover
                    ? AppColors.closeRed
                    : _isHovered
                        ? AppColors.slateGray.withOpacity(0.65)
                        : Colors.transparent,
                width: 0.8,
              ),

              boxShadow: _isHovered
                  ? [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.08),
                        blurRadius: 5,
                        offset: const Offset(0, 2),
                      ),
                    ]
                  : [],
            ),

            child: Center(
              child: AnimatedScale(
                duration: const Duration(milliseconds: 180),
                curve: Curves.easeOutBack,

                scale: _isPressed
                    ? 0.88
                    : _isHovered
                        ? 1.08
                        : 1.0,

                child: Icon(
                  widget.icon,
                  size: 17,

                  color: isCloseHover
                      ? AppColors.white
                      : AppColors.signalOrange,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
