import 'dart:async';

import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

// ============================================================================
// PLACE HOVER CONTROLLER
// ============================================================================

class PlaceHoverController {
  bool menuHovered = false;
  bool dropdownHovered = false;

  int submenuHoverCount = 0;

  Timer? _closeTimer;

  bool get isInsidePlaceSystem {
    return menuHovered ||
        dropdownHovered ||
        submenuHoverCount > 0;
  }

  void enterMenu() {
    cancelClose();
    menuHovered = true;
  }

  void exitMenu() {
    menuHovered = false;
  }

  void enterDropdown() {
    cancelClose();
    dropdownHovered = true;
  }

  void exitDropdown() {
    dropdownHovered = false;
  }

  void enterSubmenu() {
    cancelClose();
    submenuHoverCount++;
  }

  void exitSubmenu() {
    if (submenuHoverCount > 0) {
      submenuHoverCount--;
    }
  }

  void scheduleClose({
    required VoidCallback onClose,
  }) {
    cancelClose();

    _closeTimer = Timer(
      const Duration(milliseconds: 220),
      () {
        if (!isInsidePlaceSystem) {
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

    menuHovered = false;
    dropdownHovered = false;
    submenuHoverCount = 0;
  }

  void dispose() {
    cancelClose();
  }
}

// ============================================================================
// PLACE MENU
// ============================================================================

class PlaceMenu extends StatefulWidget {
  final PlaceHoverController controller;
  final VoidCallback? onSubmenuHoverChanged;
  final ValueChanged<String>? onCommand;

  const PlaceMenu({
    super.key,
    required this.controller,
    this.onSubmenuHoverChanged,
    this.onCommand,
  });

  @override
  State<PlaceMenu> createState() => _PlaceMenuState();
}

class _PlaceMenuState extends State<PlaceMenu>
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

  void _command(String value) {
    widget.onCommand?.call(value);
  }

  Widget _animatedItem({
    required int index,
    required Widget child,
  }) {
    final Animation<double> animation = CurvedAnimation(
      parent: _entranceController,
      curve: Interval(
        (index * 0.025).clamp(0.0, 0.65),
        ((index * 0.025) + 0.40).clamp(0.0, 1.0),
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

    return _PlaceMenuSurface(
      width: 225,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _animatedItem(
            index: index++,
            child: _PlaceMenuRow(
              icon: Icons.memory,
              title: 'Device / Reuse Block',
              onTap: () => _command(
                'Place: Device / Reuse Block',
              ),
            ),
          ),

          _animatedItem(
            index: index++,
            child: _PlaceSubmenu(
              controller: widget.controller,
              onHoverChanged:
                  widget.onSubmenuHoverChanged,
              icon: Icons.developer_board,
              title: 'Shortcut Device',
              children: [
                _PlaceMenuRow(
                  icon: Icons.linear_scale,
                  title: 'Resistor',
                  onTap: () => _command(
                    'Place: Shortcut Device: Resistor',
                  ),
                ),
                _PlaceMenuRow(
                  icon: Icons.circle_outlined,
                  title: 'Capacitor',
                  onTap: () => _command(
                    'Place: Shortcut Device: Capacitor',
                  ),
                ),
                _PlaceMenuRow(
                  icon: Icons.lightbulb_outline,
                  title: 'Indicator',
                  onTap: () => _command(
                    'Place: Shortcut Device: Indicator',
                  ),
                ),
                _PlaceMenuRow(
                  icon: Icons.flash_on,
                  title: 'Diode',
                  onTap: () => _command(
                    'Place: Shortcut Device: Diode',
                  ),
                ),
              ],
            ),
          ),

          _animatedItem(
            index: index++,
            child: const _PlaceDivider(),
          ),

          _animatedItem(
            index: index++,
            child: _PlaceMenuRow(
              icon: Icons.timeline,
              title: 'Wire',
              onTap: () => _command('Place: Wire'),
            ),
          ),

          _animatedItem(
            index: index++,
            child: _PlaceMenuRow(
              icon: Icons.account_tree_outlined,
              title: 'Bus',
              onTap: () => _command('Place: Bus'),
            ),
          ),

          _animatedItem(
            index: index++,
            child: _PlaceMenuRow(
              icon: Icons.label_outline,
              title: 'Net Label',
              onTap: () => _command('Place: Net Label'),
            ),
          ),

          _animatedItem(
            index: index++,
            child: _PlaceMenuRow(
              icon: Icons.flag_outlined,
              title: 'Short Flag',
              onTap: () => _command('Place: Short Flag'),
            ),
          ),

          _animatedItem(
            index: index++,
            child: _PlaceSubmenu(
              controller: widget.controller,
              onHoverChanged:
                  widget.onSubmenuHoverChanged,
              icon: Icons.power,
              title: 'Net Flag',
              children: [
                _PlaceMenuRow(
                  icon: Icons.power,
                  title: 'VCC',
                  onTap: () => _command(
                    'Place: Net Flag: VCC',
                  ),
                ),
                _PlaceMenuRow(
                  icon: Icons.add,
                  title: '+5V',
                  onTap: () => _command(
                    'Place: Net Flag: +5V',
                  ),
                ),
                _PlaceMenuRow(
                  icon: Icons.power,
                  title: 'GND',
                  onTap: () => _command(
                    'Place: Net Flag: GND',
                  ),
                ),
                _PlaceMenuRow(
                  icon: Icons.power_outlined,
                  title: 'AGND',
                  onTap: () => _command(
                    'Place: Net Flag: AGND',
                  ),
                ),
                _PlaceMenuRow(
                  icon: Icons.power_settings_new,
                  title: 'PGND',
                  onTap: () => _command(
                    'Place: Net Flag: PGND',
                  ),
                ),
              ],
            ),
          ),

          _animatedItem(
            index: index++,
            child: _PlaceSubmenu(
              controller: widget.controller,
              onHoverChanged:
                  widget.onSubmenuHoverChanged,
              icon: Icons.input,
              title: 'Net Port',
              children: [
                _PlaceMenuRow(
                  icon: Icons.arrow_back,
                  title: 'IN',
                  onTap: () => _command(
                    'Place: Net Port: IN',
                  ),
                ),
                _PlaceMenuRow(
                  icon: Icons.arrow_forward,
                  title: 'OUT',
                  onTap: () => _command(
                    'Place: Net Port: OUT',
                  ),
                ),
                _PlaceMenuRow(
                  icon: Icons.swap_horiz,
                  title: 'BI',
                  onTap: () => _command(
                    'Place: Net Port: BI',
                  ),
                ),
              ],
            ),
          ),

          _animatedItem(
            index: index++,
            child: _PlaceSubmenu(
              controller: widget.controller,
              onHoverChanged:
                  widget.onSubmenuHoverChanged,
              icon: Icons.open_in_new,
              title: 'Off Page Connector',
              children: [
                _PlaceMenuRow(
                  icon: Icons.arrow_back,
                  title: 'IN',
                  onTap: () => _command(
                    'Place: Off Page Connector: IN',
                  ),
                ),
                _PlaceMenuRow(
                  icon: Icons.arrow_forward,
                  title: 'OUT',
                  onTap: () => _command(
                    'Place: Off Page Connector: OUT',
                  ),
                ),
                _PlaceMenuRow(
                  icon: Icons.swap_horiz,
                  title: 'BI',
                  onTap: () => _command(
                    'Place: Off Page Connector: BI',
                  ),
                ),
              ],
            ),
          ),

          _animatedItem(
            index: index++,
            child: const _PlaceDivider(),
          ),

          _animatedItem(
            index: index++,
            child: _PlaceMenuRow(
              icon: Icons.block,
              title: 'No Connect Flag',
              onTap: () => _command(
                'Place: No Connect Flag',
              ),
            ),
          ),

          _animatedItem(
            index: index++,
            child: _PlaceMenuRow(
              icon: Icons.add_circle_outline,
              title: 'Junction Flag',
              onTap: () => _command(
                'Place: Junction Flag',
              ),
            ),
          ),

          _animatedItem(
            index: index++,
            child: _PlaceMenuRow(
              icon: Icons.compare_arrows,
              title: 'Differential Pairs Flag',
              onTap: () => _command(
                'Place: Differential Pairs Flag',
              ),
            ),
          ),

          _animatedItem(
            index: index++,
            child: _PlaceMenuRow(
              icon: Icons.flag,
              title: 'Test Flag',
              onTap: () => _command(
                'Place: Test Flag',
              ),
            ),
          ),

          _animatedItem(
            index: index++,
            child: _PlaceMenuRow(
              icon: Icons.crop_free,
              title: 'Mask Region',
              onTap: () => _command(
                'Place: Mask Region',
              ),
            ),
          ),

          _animatedItem(
            index: index++,
            child: _PlaceMenuRow(
              icon: Icons.layers_outlined,
              title: 'Component Mask',
              onTap: () => _command(
                'Place: Component Mask',
              ),
            ),
          ),

          _animatedItem(
            index: index++,
            child: _PlaceMenuRow(
              icon: Icons.memory,
              title: 'Reuse Block',
              onTap: () => _command(
                'Place: Reuse Block',
              ),
            ),
          ),

          _animatedItem(
            index: index++,
            child: const _PlaceDivider(),
          ),

          _animatedItem(
            index: index++,
            child: _PlaceMenuRow(
              icon: Icons.show_chart,
              title: 'Polyline',
              onTap: () => _command(
                'Place: Polyline',
              ),
            ),
          ),

          _animatedItem(
            index: index++,
            child: _PlaceMenuRow(
              icon: Icons.architecture,
              title: 'Arc',
              onTap: () => _command(
                'Place: Arc',
              ),
            ),
          ),

          _animatedItem(
            index: index++,
            child: _PlaceMenuRow(
              icon: Icons.gesture,
              title: 'Bezier',
              onTap: () => _command(
                'Place: Bezier',
              ),
            ),
          ),

          _animatedItem(
            index: index++,
            child: _PlaceMenuRow(
              icon: Icons.circle_outlined,
              title: 'Circle',
              onTap: () => _command(
                'Place: Circle',
              ),
            ),
          ),

          _animatedItem(
            index: index++,
            child: _PlaceMenuRow(
              icon: Icons.radio_button_unchecked,
              title: 'Ellipse',
              onTap: () => _command(
                'Place: Ellipse',
              ),
            ),
          ),

          _animatedItem(
            index: index++,
            child: _PlaceMenuRow(
              icon: Icons.crop_square,
              title: 'Rectangle',
              onTap: () => _command(
                'Place: Rectangle',
              ),
            ),
          ),

          _animatedItem(
            index: index++,
            child: _PlaceMenuRow(
              icon: Icons.text_fields,
              title: 'Text',
              onTap: () => _command(
                'Place: Text',
              ),
            ),
          ),

          _animatedItem(
            index: index++,
            child: _PlaceMenuRow(
              icon: Icons.image_outlined,
              title: 'Image',
              onTap: () => _command(
                'Place: Image',
              ),
            ),
          ),

          _animatedItem(
            index: index++,
            child: _PlaceMenuRow(
              icon: Icons.table_chart_outlined,
              title: 'Table',
              onTap: () => _command(
                'Place: Table',
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

class _PlaceMenuSurface extends StatefulWidget {
  final double width;
  final Widget child;

  const _PlaceMenuSurface({
    required this.width,
    required this.child,
  });

  @override
  State<_PlaceMenuSurface> createState() =>
      _PlaceMenuSurfaceState();
}

class _PlaceMenuSurfaceState
    extends State<_PlaceMenuSurface>
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
            maxHeight: 600,
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

class _PlaceMenuRow extends StatefulWidget {
  final IconData? icon;
  final String title;
  final String? shortcut;
  final VoidCallback onTap;

  const _PlaceMenuRow({
    this.icon,
    required this.title,
    this.shortcut,
    required this.onTap,
  });

  @override
  State<_PlaceMenuRow> createState() =>
      _PlaceMenuRowState();
}

class _PlaceMenuRowState extends State<_PlaceMenuRow> {
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
                    ? AppColors.signalOrange
                        .withOpacity(0.095)
                    : Colors.transparent,
            borderRadius: BorderRadius.circular(5),
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
                  duration:
                      const Duration(milliseconds: 100),
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

class _PlaceSubmenu extends StatefulWidget {
  final PlaceHoverController controller;
  final VoidCallback? onHoverChanged;

  final IconData? icon;
  final String title;
  final List<Widget> children;

  const _PlaceSubmenu({
    required this.controller,
    this.onHoverChanged,
    this.icon,
    required this.title,
    required this.children,
  });

  @override
  State<_PlaceSubmenu> createState() =>
      _PlaceSubmenuState();
}

class _PlaceSubmenuState
    extends State<_PlaceSubmenu>
    with SingleTickerProviderStateMixin {
  final GlobalKey _key = GlobalKey();

  OverlayEntry? _overlayEntry;

  bool hovered = false;
  bool childHovered = false;

  Timer? _submenuCloseTimer;

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
  // OPEN
  // ==========================================================================

  void _openSubmenu() {
    if (_overlayEntry != null) {
      return;
    }

    final RenderBox? renderBox =
        _key.currentContext?.findRenderObject()
            as RenderBox?;

    if (renderBox == null) {
      return;
    }

    final Offset position =
        renderBox.localToGlobal(Offset.zero);

    final Size size = renderBox.size;

    final OverlayState overlay =
        Overlay.of(context);

    _submenuCloseTimer?.cancel();
    _submenuCloseTimer = null;

    widget.controller.enterSubmenu();

    _overlayEntry = OverlayEntry(
      builder: (context) {
        return _PlaceSubmenuOverlay(
          left: position.dx + size.width - 1,
          top: position.dy,
          width: 205,
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
    _submenuCloseTimer?.cancel();
    _submenuCloseTimer = null;

    if (_overlayEntry != null) {
      _overlayEntry!.remove();
      _overlayEntry = null;

      widget.controller.exitSubmenu();
    }

    childHovered = false;
  }

  void _scheduleSubmenuClose() {
    _submenuCloseTimer?.cancel();

    _submenuCloseTimer = Timer(
      const Duration(milliseconds: 180),
      () {
        if (!mounted) return;

        if (!hovered && !childHovered) {
          _closeSubmenu();
          _arrowController.reverse();
        }
      },
    );
  }

  // ==========================================================================
  // ENTER PARENT
  // ==========================================================================

  void _enterParent() {
    if (!mounted) return;

    _submenuCloseTimer?.cancel();
    _submenuCloseTimer = null;

    setState(() {
      hovered = true;
    });

    _arrowController.forward();

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

    widget.onHoverChanged?.call();

    if (!childHovered) {
      _scheduleSubmenuClose();
    }
  }

  // ==========================================================================
  // ENTER CHILD
  // ==========================================================================

  void _enterChild() {
    if (!mounted) return;

    _submenuCloseTimer?.cancel();
    _submenuCloseTimer = null;

    childHovered = true;

    widget.controller.cancelClose();
    widget.onHoverChanged?.call();
  }

  // ==========================================================================
  // EXIT CHILD
  // ==========================================================================

  void _exitChild() {
    if (!mounted) return;

    childHovered = false;

    widget.onHoverChanged?.call();

    if (!hovered) {
      _scheduleSubmenuClose();
    }
  }

  // ==========================================================================
  // DISPOSE
  // ==========================================================================

  @override
  void dispose() {
    _submenuCloseTimer?.cancel();
    _submenuCloseTimer = null;

    if (_overlayEntry != null) {
      _overlayEntry!.remove();
      _overlayEntry = null;

      widget.controller.exitSubmenu();
    }

    _arrowController.dispose();

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
        onEnter: (_) => _enterParent(),
        onExit: (_) => _exitParent(),
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
            borderRadius: BorderRadius.circular(5),
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
                  duration:
                      const Duration(milliseconds: 100),
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
                      scale: 1 + (0.10 * value),
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

class _PlaceSubmenuOverlay extends StatefulWidget {
  final double left;
  final double top;
  final double width;

  final List<Widget> children;

  final VoidCallback onEnter;
  final VoidCallback onExit;

  const _PlaceSubmenuOverlay({
    required this.left,
    required this.top,
    required this.width,
    required this.children,
    required this.onEnter,
    required this.onExit,
  });

  @override
  State<_PlaceSubmenuOverlay> createState() =>
      _PlaceSubmenuOverlayState();
}

class _PlaceSubmenuOverlayState
    extends State<_PlaceSubmenuOverlay>
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
          // ------------------------------------------------------------------
          // HOVER BRIDGE
          // ------------------------------------------------------------------

          Positioned(
            left: -24,
            top: -4,
            bottom: -4,
            width: 28,
            child: MouseRegion(
              onEnter: (_) {
                widget.onEnter();
              },
              child: const SizedBox.expand(),
            ),
          ),

          // ------------------------------------------------------------------
          // SUBMENU
          // ------------------------------------------------------------------

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
                    -9 * (1 - _controller.value),
                    0,
                  ),
                  child: Transform.scale(
                    alignment: Alignment.centerLeft,
                    scale: 0.96 + (0.04 * value),
                    child: child,
                  ),
                ),
              );
            },
            child: MouseRegion(
              cursor: SystemMouseCursors.click,
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
                  constraints: const BoxConstraints(
                    maxHeight: 320,
                  ),
                  padding: const EdgeInsets.symmetric(
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius:
                        BorderRadius.circular(8),
                    border: Border.all(
                      color: const Color(0xFFCBD1D6),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color:
                            Colors.black.withOpacity(0.22),
                        blurRadius: 20,
                        spreadRadius: 1,
                        offset: const Offset(0, 7),
                      ),
                      BoxShadow(
                        color: AppColors.signalOrange
                            .withOpacity(0.07),
                        blurRadius: 15,
                      ),
                    ],
                  ),
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: widget.children,
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

class _PlaceDivider extends StatelessWidget {
  const _PlaceDivider();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 1,
      margin: const EdgeInsets.symmetric(
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
