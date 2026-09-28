import 'dart:async';

import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

class HelpMenu extends StatefulWidget {
  final HelpHoverController controller;
  final ValueChanged<String>? onCommand;

  const HelpMenu({
    super.key,
    required this.controller,
    this.onCommand,
  });

  @override
  State<HelpMenu> createState() => _HelpMenuState();
}

class _HelpMenuState extends State<HelpMenu>
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
        (index * 0.045).clamp(0.0, 0.65),
        ((index * 0.045) + 0.38).clamp(0.0, 1.0),
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

    return _HelpMenuSurface(
      width: 220,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _animatedItem(
            index: index++,
            child: _HelpMenuRow(
              icon: Icons.menu_book_outlined,
              title: 'Tutorials',
              onTap: () {
                _command('Help: Tutorials');
              },
            ),
          ),

          _animatedItem(
            index: index++,
            child: _HelpMenuRow(
              icon: Icons.contact_support_outlined,
              title: 'Contact',
              onTap: () {
                _command('Help: Contact');
              },
            ),
          ),

          _animatedItem(
            index: index++,
            child: _HelpMenuRow(
              icon: Icons.info_outline_rounded,
              title: 'About',
              onTap: () {
                _command('Help: About');
              },
            ),
          ),

          _animatedItem(
            index: index++,
            child: _HelpMenuRow(
              icon: Icons.videocam_outlined,
              title: 'Video Capture',
              onTap: () {
                _command('Help: Video Capture');
              },
            ),
          ),

          _animatedItem(
            index: index++,
            child: _HelpMenuRow(
              icon: Icons.speed_rounded,
              title: 'Performance Diagnostic',
              onTap: () {
                _command(
                  'Help: Performance Diagnostic',
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _HelpMenuSurface extends StatefulWidget {
  final double width;
  final Widget child;

  const _HelpMenuSurface({
    required this.width,
    required this.child,
  });

  @override
  State<_HelpMenuSurface> createState() =>
      _HelpMenuSurfaceState();
}

class _HelpMenuSurfaceState
    extends State<_HelpMenuSurface>
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
        final double value =
            Curves.easeOutBack.transform(
          _controller.value,
        );

        return Opacity(
          opacity:
              Curves.easeOut.transform(
            _controller.value,
          ),
          child: Transform.translate(
            offset: Offset(
              0,
              -8 * (1 - _controller.value),
            ),
            child: Transform.scale(
              alignment: Alignment.topLeft,
              scale:
                  0.96 + (0.04 * value),
              child: child,
            ),
          ),
        );
      },
      child: Material(
        color: Colors.transparent,
        child: Container(
          width: widget.width,
          constraints:
              const BoxConstraints(
            maxHeight: 480,
          ),
          decoration: BoxDecoration(
            color: const Color(0xFFFDFDFD),
            borderRadius:
                BorderRadius.circular(8),
            border: Border.all(
              color:
                  const Color(0xFFB9C1C7),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color:
                    Colors.black.withOpacity(
                  0.22,
                ),
                blurRadius: 24,
                spreadRadius: 2,
                offset:
                    const Offset(0, 9),
              ),
              BoxShadow(
                color: AppColors
                    .signalOrange
                    .withOpacity(0.06),
                blurRadius: 20,
                spreadRadius: -2,
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius:
                BorderRadius.circular(8),
            child: SingleChildScrollView(
              padding:
                  const EdgeInsets.symmetric(
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

class _HelpMenuRow extends StatefulWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  const _HelpMenuRow({
    required this.icon,
    required this.title,
    required this.onTap,
  });

  @override
  State<_HelpMenuRow> createState() =>
      _HelpMenuRowState();
}

class _HelpMenuRowState
    extends State<_HelpMenuRow> {
  bool hovered = false;
  bool pressed = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor:
          SystemMouseCursors.click,

      onEnter: (_) {
        setState(() {
          hovered = true;
        });
      },

      onExit: (_) {
        setState(() {
          hovered = false;
          pressed = false;
        });
      },

      child: GestureDetector(
        behavior:
            HitTestBehavior.opaque,

        onTapDown: (_) {
          setState(() {
            pressed = true;
          });
        },

        onTapUp: (_) {
          setState(() {
            pressed = false;
          });

          widget.onTap();
        },

        onTapCancel: () {
          setState(() {
            pressed = false;
          });
        },

        child: AnimatedContainer(
          duration:
              const Duration(
            milliseconds: 130,
          ),
          curve:
              Curves.easeOutCubic,

          height: 30,

          margin:
              const EdgeInsets.symmetric(
            horizontal: 3,
          ),

          padding:
              const EdgeInsets.symmetric(
            horizontal: 5,
          ),

          transform:
              Matrix4.identity()
                ..translate(
                  hovered ? 3.0 : 0.0,
                  pressed ? 1.0 : 0.0,
                ),

          decoration:
              BoxDecoration(
            color: pressed
                ? AppColors
                    .signalOrange
                    .withOpacity(0.20)
                : hovered
                    ? AppColors
                        .signalOrange
                        .withOpacity(
                        0.095,
                      )
                    : Colors.transparent,

            borderRadius:
                BorderRadius.circular(5),
          ),

          child: Row(
            children: [
              SizedBox(
                width: 21,
                child: Icon(
                  widget.icon,
                  size: 14,
                  color: hovered
                      ? AppColors
                          .signalOrange
                      : const Color(
                          0xFF596066,
                        ),
                ),
              ),

              const SizedBox(width: 5),

              Expanded(
                child:
                    AnimatedDefaultTextStyle(
                  duration:
                      const Duration(
                    milliseconds: 100,
                  ),

                  style: TextStyle(
                    fontSize: 11.5,
                    fontWeight: hovered
                        ? FontWeight.w600
                        : FontWeight.w500,
                    color:
                        const Color(
                      0xFF30353A,
                    ),
                  ),

                  child: Text(
                    widget.title,
                    maxLines: 1,
                    overflow:
                        TextOverflow.ellipsis,
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

class HelpHoverController {
  bool helpButtonHovered = false;
  bool helpDropdownHovered = false;

  Timer? _closeTimer;

  bool get isInsideHelpSystem {
    return helpButtonHovered ||
        helpDropdownHovered;
  }

  void enterHelpButton() {
    cancelClose();
    helpButtonHovered = true;
  }

  void exitHelpButton() {
    helpButtonHovered = false;
  }

  void enterHelpDropdown() {
    cancelClose();
    helpDropdownHovered = true;
  }

  void exitHelpDropdown() {
    helpDropdownHovered = false;
  }

  void scheduleClose({
    required VoidCallback onClose,
  }) {
    cancelClose();

    _closeTimer = Timer(
      const Duration(
        milliseconds: 220,
      ),
      () {
        _closeTimer = null;

        if (!isInsideHelpSystem) {
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

    helpButtonHovered = false;
    helpDropdownHovered = false;
  }

  void dispose() {
    cancelClose();
  }
}