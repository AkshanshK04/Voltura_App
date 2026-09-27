import 'dart:async';

import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import 'menu_bar.dart';

// ============================================================================
// EDIT MENU
// ============================================================================

class EditMenu extends StatefulWidget {
  final EditHoverController controller;
  final VoidCallback? onSubmenuHoverChanged;
  final ValueChanged<String>? onCommand;

  const EditMenu({
    super.key,
    required this.controller,
    this.onSubmenuHoverChanged,
    this.onCommand,
  });

  @override
  State<EditMenu> createState() => _EditMenuState();
}

class _EditMenuState extends State<EditMenu>
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

  // ==========================================================================
  // COMMAND
  // ==========================================================================

  void _command(String value) {
    widget.onCommand?.call(value);
  }

  // ==========================================================================
  // STAGGERED ENTRANCE
  // ==========================================================================

  Widget _animatedItem({
    required int index,
    required Widget child,
  }) {
    final Animation<double> animation =
        CurvedAnimation(
      parent: _entranceController,
      curve: Interval(
        (index * 0.035).clamp(0.0, 0.65),
        ((index * 0.035) + 0.42)
            .clamp(0.0, 1.0),
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

  // ==========================================================================
  // BUILD
  // ==========================================================================

  @override
  Widget build(BuildContext context) {
    int index = 0;

    return _EditMenuSurface(
      width: 205,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // ==================================================================
          // UNDO / REDO
          // ==================================================================

          _animatedItem(
            index: index++,
            child: _EditMenuRow(
              icon: Icons.undo_rounded,
              title: 'Undo',
              shortcut: 'Ctrl + Z',
              onTap: () => _command('Undo'),
            ),
          ),

          _animatedItem(
            index: index++,
            child: _EditMenuRow(
              icon: Icons.redo_rounded,
              title: 'Redo',
              shortcut: 'Ctrl + Y',
              onTap: () => _command('Redo'),
            ),
          ),

          _animatedItem(
            index: index++,
            child: _EditMenuRow(
              icon: Icons.refresh_rounded,
              title: 'Repeat',
              shortcut: 'Ctrl + R',
              onTap: () => _command('Repeat'),
            ),
          ),

          _animatedItem(
            index: index++,
            child: const _EditDivider(),
          ),

          // ==================================================================
          // COPY
          // ==================================================================

          _animatedItem(
            index: index++,
            child: _EditMenuRow(
              icon: Icons.copy_rounded,
              title: 'Copy',
              shortcut: 'Ctrl + C',
              onTap: () => _command('Copy'),
            ),
          ),

          _animatedItem(
            index: index++,
            child: _EditSubmenu(
              controller: widget.controller,
              onHoverChanged:
                  widget.onSubmenuHoverChanged,
              icon: Icons.image_outlined,
              title: 'Copy as Image',
              children: [
                _EditMenuRow(
                  icon: Icons.code_rounded,
                  title: 'Copy as SVG',
                  onTap: () =>
                      _command('Copy as SVG'),
                ),
                _EditMenuRow(
                  icon: Icons.image_outlined,
                  title: 'Copy as PNG',
                  onTap: () =>
                      _command('Copy as PNG'),
                ),
              ],
            ),
          ),

          _animatedItem(
            index: index++,
            child: _EditMenuRow(
              icon: Icons.content_cut_rounded,
              title: 'Cut',
              shortcut: 'Ctrl + X',
              onTap: () => _command('Cut'),
            ),
          ),

          _animatedItem(
            index: index++,
            child: _EditMenuRow(
              icon: Icons.content_paste_rounded,
              title: 'Paste',
              shortcut: 'Ctrl + V',
              onTap: () => _command('Paste'),
            ),
          ),

          _animatedItem(
            index: index++,
            child: const _EditDivider(),
          ),

          // ==================================================================
          // MOVE
          // ==================================================================

          _animatedItem(
            index: index++,
            child: _EditSubmenu(
              controller: widget.controller,
              onHoverChanged:
                  widget.onSubmenuHoverChanged,
              icon: Icons.open_with_rounded,
              title: 'Move',
              children: [
                _EditMenuRow(
                  icon:
                      Icons.center_focus_strong_rounded,
                  title: 'Move by Center Point',
                  onTap: () => _command(
                    'Move by Center Point',
                  ),
                ),
                _EditMenuRow(
                  icon: Icons.my_location_rounded,
                  title: 'Move by Origin Point',
                  onTap: () => _command(
                    'Move by Origin Point',
                  ),
                ),
                _EditMenuRow(
                  icon: Icons.control_point_rounded,
                  title: 'Move by Reference Point',
                  onTap: () => _command(
                    'Move by Reference Point',
                  ),
                ),
              ],
            ),
          ),

          // ==================================================================
          // DELETE
          // ==================================================================

          _animatedItem(
            index: index++,
            child: _EditSubmenu(
              controller: widget.controller,
              onHoverChanged:
                  widget.onSubmenuHoverChanged,
              icon: Icons.delete_outline_rounded,
              title: 'Delete',
              children: [
                _EditMenuRow(
                  icon:
                      Icons.check_circle_outline_rounded,
                  title: 'Selected',
                  onTap: () => _command(
                    'Delete: Selected',
                  ),
                ),
                _EditMenuRow(
                  icon:
                      Icons.layers_clear_outlined,
                  title: 'Objects',
                  onTap: () => _command(
                    'Delete: Objects',
                  ),
                ),
                _EditMenuRow(
                  icon: Icons.delete_sweep_outlined,
                  title: 'All',
                  onTap: () => _command(
                    'Delete: All',
                  ),
                ),
              ],
            ),
          ),

          _animatedItem(
            index: index++,
            child: const _EditDivider(),
          ),

          // ==================================================================
          // SNAP
          // ==================================================================

          _animatedItem(
            index: index++,
            child: _EditMenuRow(
              icon: Icons.grid_on_rounded,
              title: 'Snap',
              onTap: () => _command('Snap'),
            ),
          ),

          // ==================================================================
          // SELECT OBJECTS
          // ==================================================================

          _animatedItem(
            index: index++,
            child: _EditSubmenu(
              controller: widget.controller,
              onHoverChanged:
                  widget.onSubmenuHoverChanged,
              icon: Icons.select_all_rounded,
              title: 'Select Objects',
              children: [
                _EditMenuRow(
                  icon: Icons.select_all_rounded,
                  title: 'All',
                  onTap: () => _command(
                    'Select Objects: All',
                  ),
                ),
                _EditMenuRow(
                  icon: Icons.crop_square_rounded,
                  title: 'Rectangle Inside',
                  onTap: () => _command(
                    'Select Objects: Rectangle Inside',
                  ),
                ),
                _EditMenuRow(
                  icon: Icons.crop_free_rounded,
                  title: 'Rectangle Outside',
                  onTap: () => _command(
                    'Select Objects: Rectangle Outside',
                  ),
                ),
                _EditMenuRow(
                  icon: Icons.pentagon_outlined,
                  title: 'Polygon Inside',
                  onTap: () => _command(
                    'Select Objects: Polygon Inside',
                  ),
                ),
                _EditMenuRow(
                  icon: Icons.pentagon_rounded,
                  title: 'Polygon Outside',
                  onTap: () => _command(
                    'Select Objects: Polygon Outside',
                  ),
                ),
                _EditMenuRow(
                  icon: Icons.timeline_rounded,
                  title: 'Line Touched',
                  onTap: () => _command(
                    'Select Objects: Line Touched',
                  ),
                ),
                _EditMenuRow(
                  icon: Icons.toggle_on_outlined,
                  title: 'Toggle Section',
                  onTap: () => _command(
                    'Select Objects: Toggle Section',
                  ),
                ),
              ],
            ),
          ),

          _animatedItem(
            index: index++,
            child: const _EditDivider(),
          ),

          // ==================================================================
          // ARRAY
          // ==================================================================

          _animatedItem(
            index: index++,
            child: _EditMenuRow(
              icon: Icons.grid_view_rounded,
              title: 'Array Objects',
              onTap: () => _command(
                'Array Objects',
              ),
            ),
          ),

          _animatedItem(
            index: index++,
            child: const _EditDivider(),
          ),

          // ==================================================================
          // FIND
          // ==================================================================

          _animatedItem(
            index: index++,
            child: _EditMenuRow(
              icon: Icons.find_replace_rounded,
              title: 'Find & Replace',
              onTap: () => _command(
                'Find and Replace',
              ),
            ),
          ),

          _animatedItem(
            index: index++,
            child: _EditMenuRow(
              icon: Icons.search_rounded,
              title: 'Find Similar',
              onTap: () => _command(
                'Find Similar Objects',
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// MENU SURFACE
// ============================================================================

class _EditMenuSurface extends StatefulWidget {
  final double width;
  final Widget child;

  const _EditMenuSurface({
    required this.width,
    required this.child,
  });

  @override
  State<_EditMenuSurface> createState() =>
      _EditMenuSurfaceState();
}

class _EditMenuSurfaceState
    extends State<_EditMenuSurface>
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

        final double opacity =
            Curves.easeOut.transform(
          _controller.value,
        );

        return Opacity(
          opacity: opacity,
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
                color: AppColors.signalOrange
                    .withOpacity(0.06),
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
// NORMAL MENU ROW
// ============================================================================

class _EditMenuRow extends StatefulWidget {
  final IconData? icon;
  final String title;
  final String? shortcut;

  final VoidCallback onTap;

  const _EditMenuRow({
    this.icon,
    required this.title,
    this.shortcut,
    required this.onTap,
  });

  @override
  State<_EditMenuRow> createState() =>
      _EditMenuRowState();
}

class _EditMenuRowState
    extends State<_EditMenuRow> {
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
          duration:
              const Duration(milliseconds: 130),
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
                ? AppColors.signalOrange
                    .withOpacity(0.20)
                : hovered
                    ? AppColors.signalOrange
                        .withOpacity(0.095)
                    : Colors.transparent,

            borderRadius:
                BorderRadius.circular(5),

            border: Border.all(
              color: Colors.transparent,
            ),

            boxShadow: hovered
                ? [
                    BoxShadow(
                      color: AppColors.signalOrange
                          .withOpacity(0.09),
                      blurRadius: 9,
                      spreadRadius: -1,
                    ),
                  ]
                : null,
          ),

          child: Row(
            children: [
              // --------------------------------------------------------------
              // ICON
              // --------------------------------------------------------------

              SizedBox(
                width: 21,
                child: TweenAnimationBuilder<double>(
                  tween: Tween<double>(
                    begin: 0,
                    end: hovered ? 1 : 0,
                  ),
                  duration:
                      const Duration(milliseconds: 120),
                  curve: Curves.easeOutCubic,
                  builder: (
                    context,
                    value,
                    child,
                  ) {
                    return Transform.scale(
                      scale:
                          0.94 + (0.06 * value),
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

              // --------------------------------------------------------------
              // TITLE
              // --------------------------------------------------------------

              Expanded(
                child: AnimatedDefaultTextStyle(
                  duration:
                      const Duration(milliseconds: 100),
                  curve: Curves.easeOutCubic,
                  style: TextStyle(
                    fontSize: 11.5,
                    fontWeight: hovered
                        ? FontWeight.w600
                        : FontWeight.w500,
                    color:
                        const Color(0xFF30353A),
                  ),
                  child: Text(
                    widget.title,
                    maxLines: 1,
                    overflow:
                        TextOverflow.ellipsis,
                  ),
                ),
              ),

              // --------------------------------------------------------------
              // SHORTCUT
              // --------------------------------------------------------------

              if (widget.shortcut != null)
                AnimatedOpacity(
                  duration:
                      const Duration(milliseconds: 120),
                  opacity: hovered ? 1.0 : 0.72,
                  child: Text(
                    widget.shortcut!,
                    style: const TextStyle(
                      fontSize: 9.5,
                      color: Color(0xFF8A9095),
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
// SUBMENU
// ============================================================================

class _EditSubmenu extends StatefulWidget {
  final EditHoverController controller;

  final VoidCallback? onHoverChanged;

  final IconData? icon;
  final String title;
  final List<Widget> children;

  const _EditSubmenu({
    required this.controller,
    this.onHoverChanged,
    this.icon,
    required this.title,
    required this.children,
  });

  @override
  State<_EditSubmenu> createState() =>
      _EditSubmenuState();
}

class _EditSubmenuState
    extends State<_EditSubmenu>
    with SingleTickerProviderStateMixin {
  final GlobalKey _key = GlobalKey();

  OverlayEntry? _overlayEntry;

  Timer? _closeTimer;

  bool hovered = false;
  bool submenuHovered = false;

  bool _registered = false;

  late final AnimationController _arrowController;

  @override
  void initState() {
    super.initState();

    _arrowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 180),
    );
  }

  // ==========================================================================
  // CANCEL CLOSE
  // ==========================================================================

  void _cancelClose() {
    _closeTimer?.cancel();
    _closeTimer = null;
  }

  // ==========================================================================
  // ENTER PARENT
  // ==========================================================================

  void _enterParent() {
    if (!mounted) return;

    _cancelClose();

    setState(() {
      hovered = true;
    });

    _arrowController.forward();

    if (!_registered) {
      _registered = true;
      widget.controller.enterSubmenu();
    }

    widget.controller.cancelClose();

    widget.onHoverChanged?.call();

    _openSubmenu();
  }

  // ==========================================================================
  // EXIT PARENT
  // ==========================================================================

  void _exitParent() {
    if (!mounted) return;

    setState(() {
      hovered = false;
    });

    _arrowController.reverse();

    widget.onHoverChanged?.call();

    _scheduleClose();
  }

  // ==========================================================================
  // ENTER CHILD
  // ==========================================================================

  void _enterChild() {
    _cancelClose();

    widget.controller.cancelClose();

    submenuHovered = true;

    if (!_registered) {
      _registered = true;
      widget.controller.enterSubmenu();
    }

    widget.onHoverChanged?.call();
  }

  // ==========================================================================
  // EXIT CHILD
  // ==========================================================================

  void _exitChild() {
    submenuHovered = false;

    widget.onHoverChanged?.call();

    _scheduleClose();
  }

  // ==========================================================================
  // SCHEDULE CLOSE
  // ==========================================================================

  void _scheduleClose() {
    _cancelClose();

    _closeTimer = Timer(
      const Duration(milliseconds: 150),
      () {
        if (!mounted) return;

        if (!hovered && !submenuHovered) {
          if (_registered) {
            _registered = false;
            widget.controller.exitSubmenu();
          }

          widget.onHoverChanged?.call();

          _closeSubmenu();
        }
      },
    );
  }

  // ==========================================================================
  // OPEN SUBMENU
  // ==========================================================================

  void _openSubmenu() {
    _cancelClose();

    if (_overlayEntry != null) {
      return;
    }

    final RenderBox? renderBox =
        _key.currentContext
                ?.findRenderObject()
            as RenderBox?;

    if (renderBox == null) {
      return;
    }

    final Offset position =
        renderBox.localToGlobal(
      Offset.zero,
    );

    final Size size = renderBox.size;

    final OverlayState overlay =
        Overlay.of(context);

    _overlayEntry = OverlayEntry(
      builder: (context) {
        return _EditSubmenuOverlay(
          left: position.dx +
              size.width -
              1,
          top: position.dy,
          width: 200,
          children: widget.children,
          onEnter: _enterChild,
          onExit: _exitChild,
        );
      },
    );

    overlay.insert(_overlayEntry!);
  }

  // ==========================================================================
  // CLOSE
  // ==========================================================================

  void _closeSubmenu() {
    _cancelClose();

    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  // ==========================================================================
  // DISPOSE
  // ==========================================================================

  @override
  void dispose() {
    _cancelClose();
    _arrowController.dispose();

    if (_registered) {
      widget.controller.exitSubmenu();
    }

    _closeSubmenu();

    super.dispose();
  }

  // ==========================================================================
  // BUILD
  // ==========================================================================

  @override
  Widget build(BuildContext context) {
    return Container(
      key: _key,

      height: 30,

      margin: const EdgeInsets.symmetric(
        horizontal: 3,
      ),

      child: MouseRegion(
        cursor: SystemMouseCursors.click,

        onEnter: (_) {
          _enterParent();
        },

        onExit: (_) {
          _exitParent();
        },

        child: AnimatedContainer(
          duration:
              const Duration(milliseconds: 140),
          curve: Curves.easeOutCubic,

          padding: const EdgeInsets.symmetric(
            horizontal: 5,
          ),

          transform: Matrix4.identity()
            ..translate(
              hovered ? 3.0 : 0.0,
            ),

          decoration: BoxDecoration(
            color: hovered
                ? AppColors.signalOrange
                    .withOpacity(0.095)
                : Colors.transparent,

            borderRadius:
                BorderRadius.circular(5),

            border: Border.all(
              color: hovered
                  ? AppColors.signalOrange
                      .withOpacity(0.18)
                  : Colors.transparent,
            ),

            boxShadow: hovered
                ? [
                    BoxShadow(
                      color: AppColors.signalOrange
                          .withOpacity(0.08),
                      blurRadius: 9,
                    ),
                  ]
                : null,
          ),

          child: Row(
            children: [
              // --------------------------------------------------------------
              // ICON
              // --------------------------------------------------------------

              SizedBox(
                width: 21,
                child: TweenAnimationBuilder<double>(
                  tween: Tween<double>(
                    begin: 0,
                    end: hovered ? 1 : 0,
                  ),
                  duration:
                      const Duration(milliseconds: 120),
                  curve: Curves.easeOutCubic,
                  builder: (
                    context,
                    value,
                    child,
                  ) {
                    return Transform.scale(
                      scale:
                          0.94 + (0.06 * value),
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

              // --------------------------------------------------------------
              // TITLE
              // --------------------------------------------------------------

              Expanded(
                child: AnimatedDefaultTextStyle(
                  duration:
                      const Duration(milliseconds: 100),
                  curve: Curves.easeOutCubic,
                  style: TextStyle(
                    fontSize: 11.5,
                    fontWeight: hovered
                        ? FontWeight.w600
                        : FontWeight.w500,
                    color:
                        const Color(0xFF30353A),
                  ),
                  child: Text(
                    widget.title,
                    maxLines: 1,
                    overflow:
                        TextOverflow.ellipsis,
                  ),
                ),
              ),

              // --------------------------------------------------------------
              // CHEVRON
              // --------------------------------------------------------------

              AnimatedBuilder(
                animation: _arrowController,
                builder: (context, child) {
                  final double value =
                      _arrowController.value;

                  return Transform.translate(
                    offset: Offset(
                      3 * value,
                      0,
                    ),
                    child: Transform.scale(
                      scale: 1 +
                          (0.10 * value),
                      child: Icon(
                        Icons.chevron_right_rounded,
                        size: 16,
                        color: Color.lerp(
                          const Color(0xFF777D82),
                          AppColors.signalOrange,
                          value,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ============================================================================
// SUBMENU OVERLAY
// ============================================================================

class _EditSubmenuOverlay
    extends StatefulWidget {
  final double left;
  final double top;
  final double width;

  final List<Widget> children;

  final VoidCallback onEnter;
  final VoidCallback onExit;

  const _EditSubmenuOverlay({
    required this.left,
    required this.top,
    required this.width,
    required this.children,
    required this.onEnter,
    required this.onExit,
  });

  @override
  State<_EditSubmenuOverlay> createState() =>
      _EditSubmenuOverlayState();
}

class _EditSubmenuOverlayState
    extends State<_EditSubmenuOverlay>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 220),
    )..forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: widget.left,
      top: widget.top,

      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // ==================================================================
          // HOVER BRIDGE
          // ==================================================================

          Positioned(
            left: -22,
            top: 0,
            bottom: 0,
            width: 24,
            child: MouseRegion(
              onEnter: (_) {
                widget.onEnter();
              },
              child: const SizedBox.expand(),
            ),
          ),

          // ==================================================================
          // SUBMENU
          // ==================================================================

          AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              final double value =
                  Curves.easeOutBack.transform(
                _controller.value,
              );

              return Opacity(
                opacity: _controller.value,

                child: Transform.translate(
                  offset: Offset(
                    -9 *
                        (1 - _controller.value),
                    0,
                  ),

                  child: Transform.scale(
                    alignment:
                        Alignment.centerLeft,
                    scale:
                        0.96 +
                            (0.04 * value),
                    child: child,
                  ),
                ),
              );
            },

            child: MouseRegion(
              cursor:
                  SystemMouseCursors.click,

              onEnter: (_) {
                widget.onEnter();
              },

              onExit: (_) {
                widget.onExit();
              },

              child: Material(
                color: Colors.transparent,

                child: Container(
                  width: widget.width,

                  constraints:
                      const BoxConstraints(
                    maxHeight: 320,
                  ),

                  padding:
                      const EdgeInsets.symmetric(
                    vertical: 4,
                  ),

                  decoration:
                      BoxDecoration(
                    color: Colors.white,

                    borderRadius:
                        BorderRadius.circular(8),

                    border: Border.all(
                      color:
                          const Color(0xFFCBD1D6),
                    ),

                    boxShadow: [
                      BoxShadow(
                        color:
                            Colors.black.withOpacity(
                          0.22,
                        ),
                        blurRadius: 20,
                        spreadRadius: 1,
                        offset:
                            const Offset(0, 7),
                      ),
                      BoxShadow(
                        color: AppColors
                            .signalOrange
                            .withOpacity(0.07),
                        blurRadius: 15,
                      ),
                    ],
                  ),

                  child:
                      SingleChildScrollView(
                    child: Column(
                      mainAxisSize:
                          MainAxisSize.min,
                      children:
                          widget.children,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// DIVIDER
// ============================================================================

class _EditDivider
    extends StatelessWidget {
  const _EditDivider();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 1,

      margin:
          const EdgeInsets.symmetric(
        horizontal: 9,
        vertical: 4,
      ),

      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.transparent,
            Color(0xFFD8DDE1),
            Colors.transparent,
          ],
        ),
      ),
    );
  }
}
