import 'dart:async';

import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

class LibraryMenu extends StatefulWidget {
  final LibraryHoverController controller;
  final ValueChanged<String>? onCommand;

  const LibraryMenu({
    super.key,
    required this.controller,
    this.onCommand,
  });

  @override
  State<LibraryMenu> createState() => _LibraryMenuState();
}

class _LibraryMenuState extends State<LibraryMenu>
    with SingleTickerProviderStateMixin {
  late final AnimationController _entranceController;

  @override
  void initState() {
    super.initState();

    _entranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 280),
    )..forward();
  }

  @override
  void dispose() {
    _entranceController.dispose();
    super.dispose();
  }

  void _command(String command) {
    widget.onCommand?.call(command);
  }

  Widget _animatedItem({
    required int index,
    required Widget child,
  }) {
    final Animation<double> animation = CurvedAnimation(
      parent: _entranceController,
      curve: Interval(
        (index * 0.06).clamp(0.0, 0.65),
        ((index * 0.06) + 0.42).clamp(0.0, 1.0),
        curve: Curves.easeOutCubic,
      ),
    );

    return AnimatedBuilder(
      animation: animation,
      child: child,
      builder: (context, child) {
        final double value = animation.value;

        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(
              -18 * (1 - value),
              0,
            ),
            child: child,
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    int index = 0;

    return _LibraryMenuSurface(
      width: 205,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _animatedItem(
            index: index++,
            child: _LibraryMenuRow(
              icon: Icons.folder_copy_outlined,
              title: 'Common Library',
              onTap: () {
                _command('Library: Common Library');
              },
            ),
          ),

          _animatedItem(
            index: index++,
            child: _LibraryMenuRow(
              icon: Icons.search_rounded,
              title: 'Search in Library',
              onTap: () {
                _command('Library: Search in Library');
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// LIBRARY SURFACE
// ============================================================================

class _LibraryMenuSurface extends StatefulWidget {
  final double width;
  final Widget child;

  const _LibraryMenuSurface({
    required this.width,
    required this.child,
  });

  @override
  State<_LibraryMenuSurface> createState() =>
      _LibraryMenuSurfaceState();
}

class _LibraryMenuSurfaceState
    extends State<_LibraryMenuSurface>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 240),
    )..forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final double value = Curves.easeOutBack.transform(
          _controller.value,
        );

        return Opacity(
          opacity: Curves.easeOut.transform(
            _controller.value,
          ),
          child: Transform.translate(
            offset: Offset(
              0,
              -8 * (1 - _controller.value),
            ),
            child: Transform.scale(
              alignment: Alignment.topLeft,
              scale: 0.96 + (0.04 * value),
              child: child,
            ),
          ),
        );
      },
      child: Material(
        color: Colors.transparent,
        child: Container(
          width: widget.width,
          constraints: const BoxConstraints(
            maxHeight: 480,
          ),
          decoration: BoxDecoration(
            color: const Color(0xFFFDFDFD),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: const Color(0xFFB9C1C7),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.22),
                blurRadius: 24,
                spreadRadius: 2,
                offset: const Offset(0, 9),
              ),
              BoxShadow(
                color: AppColors.signalOrange.withOpacity(0.06),
                blurRadius: 20,
                spreadRadius: -2,
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(
                vertical: 4,
              ),
              child: widget.child,
            ),
          ),
        ),
      ),
    );
  }
}

// ============================================================================
// LIBRARY ROW
// ============================================================================

class _LibraryMenuRow extends StatefulWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  const _LibraryMenuRow({
    required this.icon,
    required this.title,
    required this.onTap,
  });

  @override
  State<_LibraryMenuRow> createState() =>
      _LibraryMenuRowState();
}

class _LibraryMenuRowState
    extends State<_LibraryMenuRow> {
  bool hovered = false;
  bool pressed = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) {
        if (!mounted) return;

        setState(() {
          hovered = true;
        });
      },
      onExit: (_) {
        if (!mounted) return;

        setState(() {
          hovered = false;
          pressed = false;
        });
      },
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapDown: (_) {
          if (!mounted) return;

          setState(() {
            pressed = true;
          });
        },
        onTapUp: (_) {
          if (!mounted) return;

          setState(() {
            pressed = false;
          });

          widget.onTap();
        },
        onTapCancel: () {
          if (!mounted) return;

          setState(() {
            pressed = false;
          });
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 130),
          curve: Curves.easeOutCubic,
          height: 30,
          margin: const EdgeInsets.symmetric(
            horizontal: 3,
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: 5,
          ),
          transform: Matrix4.identity()
            ..translate(
              hovered ? 3.0 : 0.0,
              pressed ? 1.0 : 0.0,
            ),
          decoration: BoxDecoration(
            color: pressed
                ? AppColors.signalOrange.withOpacity(0.20)
                : hovered
                    ? AppColors.signalOrange.withOpacity(0.095)
                    : Colors.transparent,
            borderRadius: BorderRadius.circular(5),
            border: Border.all(
              color: Colors.transparent,
            ),
            boxShadow: hovered
                ? [
                    BoxShadow(
                      color: AppColors.signalOrange.withOpacity(0.09),
                      blurRadius: 9,
                      spreadRadius: -1,
                    ),
                  ]
                : null,
          ),
          child: Row(
            children: [
              SizedBox(
                width: 21,
                child: TweenAnimationBuilder<double>(
                  tween: Tween<double>(
                    begin: 0,
                    end: hovered ? 1 : 0,
                  ),
                  duration: const Duration(
                    milliseconds: 120,
                  ),
                  curve: Curves.easeOutCubic,
                  builder: (
                    context,
                    value,
                    child,
                  ) {
                    return Transform.scale(
                      scale: 0.94 + (0.06 * value),
                      child: Icon(
                        widget.icon,
                        size: 14,
                        color: Color.lerp(
                          const Color(0xFF596066),
                          AppColors.signalOrange,
                          value,
                        ),
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(width: 5),

              Expanded(
                child: AnimatedDefaultTextStyle(
                  duration: const Duration(
                    milliseconds: 100,
                  ),
                  curve: Curves.easeOutCubic,
                  style: TextStyle(
                    fontSize: 11.5,
                    fontWeight: hovered
                        ? FontWeight.w600
                        : FontWeight.w500,
                    color: const Color(0xFF30353A),
                  ),
                  child: Text(
                    widget.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ============================================================================
// LIBRARY HOVER CONTROLLER
//
// IMPORTANT:
// This is the ONLY LibraryHoverController definition.
// Do NOT define another LibraryHoverController in menu_bar.dart.
// ============================================================================

class LibraryHoverController {
  bool libraryButtonHovered = false;
  bool libraryDropdownHovered = false;

  Timer? _closeTimer;

  bool get isInsideLibrarySystem {
    return libraryButtonHovered ||
        libraryDropdownHovered;
  }

  void enterLibraryButton() {
    cancelClose();
    libraryButtonHovered = true;
  }

  void exitLibraryButton() {
    libraryButtonHovered = false;
  }

  void enterLibraryDropdown() {
    cancelClose();
    libraryDropdownHovered = true;
  }

  void exitLibraryDropdown() {
    libraryDropdownHovered = false;
  }

  void scheduleClose({
    required VoidCallback onClose,
  }) {
    cancelClose();

    _closeTimer = Timer(
      const Duration(milliseconds: 220),
      () {
        _closeTimer = null;

        if (!isInsideLibrarySystem) {
          onClose();
        }
      },
    );
  }

  void cancelClose() {
    _closeTimer?.cancel();
    _closeTimer = null;
  }

  void reset() {
    cancelClose();

    libraryButtonHovered = false;
    libraryDropdownHovered = false;
  }

  void dispose() {
    cancelClose();
  }
}
