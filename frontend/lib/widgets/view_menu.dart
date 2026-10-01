import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

// ============================================================================
// ENUMS
// ============================================================================

enum ViewUnit {
  inch,
  mm,
}

enum GridType {
  dot,
  grid,
  none,
}

enum HighlightNetMode {
  highlight,
  unhighlight,
  hoverWire,
}

// ============================================================================
// VIEW SETTINGS
// ============================================================================

class ViewSettings extends ChangeNotifier {
  ViewSettings._internal();

  static final ViewSettings _shared = ViewSettings._internal();

  /// Every part of the editor that uses ViewSettings() gets the same
  /// source-of-truth instance. This keeps the View menu, schematic,
  /// rulers, grid and status bar synchronized.
  factory ViewSettings() => _shared;

  ViewUnit _unit = ViewUnit.inch;

  // Canonical value is ALWAYS inches.
  double _gridSizeInches = 0.1;

  GridType _gridType = GridType.grid;

  HighlightNetMode _highlightNetMode =
      HighlightNetMode.highlight;

  ViewUnit get unit => _unit;
  double get gridSizeInches => _gridSizeInches;
  GridType get gridType => _gridType;
  HighlightNetMode get highlightNetMode => _highlightNetMode;

  // Public setters are kept for compatibility with MenuBarWidget and any
  // other widget that uses ViewSettings as the shared source of truth.
  set unit(ViewUnit value) => setUnit(value);
  set gridSizeInches(double value) => setGridSizeInches(value);
  set gridType(GridType value) => setGridType(value);
  set highlightNetMode(HighlightNetMode value) =>
      setHighlightNetMode(value);

  void setUnit(ViewUnit value) {
    if (_unit == value) return;
    _unit = value;
    notifyListeners();
  }

  void setGridSizeInches(double value) {
    if ((_gridSizeInches - value).abs() < 0.0000001) return;
    _gridSizeInches = value;
    notifyListeners();
  }

  void setGridType(GridType value) {
    if (_gridType == value) return;
    _gridType = value;
    notifyListeners();
  }

  void setHighlightNetMode(HighlightNetMode value) {
    if (_highlightNetMode == value) return;
    _highlightNetMode = value;
    notifyListeners();
  }

  // ViewSettings is a shared editor-wide object, so individual widgets
  // must never dispose it.

  // --------------------------------------------------------------------------
  // GRID SIZE OPTIONS
  // --------------------------------------------------------------------------

  static const List<double> gridSizesInches = [
    0.1,
    0.05,
    0.02,
    0.01,
  ];

  // --------------------------------------------------------------------------
  // DISPLAY VALUE
  // --------------------------------------------------------------------------

  double displayGridSize(double inches) {
    if (unit == ViewUnit.mm) {
      return inches * 25.4;
    }

    return inches;
  }

  // --------------------------------------------------------------------------
  // DISPLAY LABEL
  // --------------------------------------------------------------------------

  String gridSizeLabel(double inches) {
    final double value = displayGridSize(inches);

    return '${_formatNumber(value)} '
        '${unit == ViewUnit.mm ? 'mm' : 'inch'}';
  }

  // --------------------------------------------------------------------------
  // NUMBER FORMAT
  // --------------------------------------------------------------------------

  static String _formatNumber(double value) {
    if (value == value.roundToDouble()) {
      return value.toStringAsFixed(0);
    }

    if ((value * 10).roundToDouble() == value * 10) {
      return value.toStringAsFixed(1);
    }

    if ((value * 100).roundToDouble() == value * 100) {
      return value.toStringAsFixed(2);
    }

    if ((value * 1000).roundToDouble() == value * 1000) {
      return value.toStringAsFixed(3);
    }

    return value
        .toStringAsFixed(4)
        .replaceFirst(RegExp(r'0+$'), '')
        .replaceFirst(RegExp(r'\.$'), '');
  }
}

// ============================================================================
// VIEW MENU
// ============================================================================

class ViewMenu extends StatefulWidget {
  final ViewHoverController controller;

  final ViewSettings settings;

  final ValueChanged<ViewUnit>? onUnitChanged;
  final ValueChanged<double>? onGridSizeChanged;
  final ValueChanged<GridType>? onGridTypeChanged;
  final ValueChanged<HighlightNetMode>? onHighlightNetChanged;

  final ValueChanged<String>? onCommand;

  const ViewMenu({
    super.key,
    required this.controller,
    required this.settings,
    this.onUnitChanged,
    this.onGridSizeChanged,
    this.onGridTypeChanged,
    this.onHighlightNetChanged,
    this.onCommand,
  });

  @override
  State<ViewMenu> createState() => _ViewMenuState();
}

class _ViewMenuState extends State<ViewMenu>
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
  // UNIT
  // ==========================================================================

  void _setUnit(ViewUnit unit) {
    if (widget.settings.unit == unit) {
      return;
    }

    widget.settings.setUnit(unit);

    if (mounted) setState(() {});

    widget.onUnitChanged?.call(unit);

    _command(
      unit == ViewUnit.inch
          ? 'View: Unit: Inch'
          : 'View: Unit: mm',
    );
  }

  // ==========================================================================
  // GRID SIZE
  // ==========================================================================

  void _setGridSize(double inches) {
    if (widget.settings.gridSizeInches == inches) {
      return;
    }

    widget.settings.setGridSizeInches(inches);

    if (mounted) setState(() {});

    widget.onGridSizeChanged?.call(inches);

    _command(
      'View: Grid Size: '
      '${_formatCommandValue(inches)} inch',
    );
  }

  // ==========================================================================
  // GRID TYPE
  // ==========================================================================

  void _setGridType(GridType type) {
    if (widget.settings.gridType == type) {
      return;
    }

    widget.settings.setGridType(type);

    if (mounted) setState(() {});

    widget.onGridTypeChanged?.call(type);

    switch (type) {
      case GridType.dot:
        _command('View: Grid Type: Grid Dot');
        break;

      case GridType.grid:
        _command('View: Grid Type: Grid');
        break;

      case GridType.none:
        _command('View: Grid Type: None');
        break;
    }
  }

  // ==========================================================================
  // HIGHLIGHT NET
  // ==========================================================================

  void _setHighlightNet(
    HighlightNetMode mode,
  ) {
    if (widget.settings.highlightNetMode == mode) {
      return;
    }

    widget.settings.setHighlightNetMode(mode);

    if (mounted) setState(() {});

    widget.onHighlightNetChanged?.call(mode);

    switch (mode) {
      case HighlightNetMode.highlight:
        _command(
          'View: Highlight Net: Highlight Net',
        );
        break;

      case HighlightNetMode.unhighlight:
        _command(
          'View: Highlight Net: Unhighlight Net',
        );
        break;

      case HighlightNetMode.hoverWire:
        _command(
          'View: Highlight Net: '
          'Highlight Net While Hovering Wire',
        );
        break;
    }
  }

  // ==========================================================================
  // COMMAND NUMBER
  // ==========================================================================

  String _formatCommandValue(double value) {
    if (value == value.roundToDouble()) {
      return value.toStringAsFixed(0);
    }

    if ((value * 100).roundToDouble() == value * 100) {
      return value.toStringAsFixed(2);
    }

    return value
        .toStringAsFixed(4)
        .replaceFirst(RegExp(r'0+$'), '')
        .replaceFirst(RegExp(r'\.$'), '');
  }

  // ==========================================================================
  // ENTRANCE ANIMATION
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
        ((index * 0.035) + 0.42).clamp(0.0, 1.0),
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
    final ViewSettings settings = widget.settings;

    return _ViewMenuSurface(
      width: 238,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _animatedItem(
            index: 0,
            child: _ViewMenuRow(
              icon: Icons.zoom_in_rounded,
              title: 'Zoom In',
              shortcut: 'Ctrl + +',
              onTap: () {
                _command('View: Zoom In');
              },
            ),
          ),

          _animatedItem(
            index: 1,
            child: _ViewMenuRow(
              icon: Icons.zoom_out_rounded,
              title: 'Zoom Out',
              shortcut: 'Ctrl + -',
              onTap: () {
                _command('View: Zoom Out');
              },
            ),
          ),

          _animatedItem(
            index: 2,
            child: _ViewMenuRow(
              icon: Icons.fit_screen_rounded,
              title: 'Fit All in Window',
              onTap: () {
                _command('View: Fit All in Window');
              },
            ),
          ),

          _animatedItem(
            index: 3,
            child: _ViewMenuRow(
              icon: Icons.center_focus_strong_rounded,
              title: 'Fit Selection',
              onTap: () {
                _command('View: Fit Selection');
              },
            ),
          ),

          _animatedItem(
            index: 4,
            child: _ViewMenuRow(
              icon: Icons.crop_free_rounded,
              title: 'Fit Area Selection',
              onTap: () {
                _command('View: Fit Area Selection');
              },
            ),
          ),

          _animatedItem(
            index: 5,
            child: _ViewMenuRow(
              icon: Icons.fullscreen_rounded,
              title: 'Full Screen',
              onTap: () {
                _command('View: Full Screen');
              },
            ),
          ),

          const _ViewDivider(),

          // ==================================================================
          // UNIT
          // ==================================================================

          _animatedItem(
            index: 6,
            child: _ViewSubmenu(
              controller: widget.controller,
              icon: Icons.straighten_rounded,
              title: 'Unit',
              children: [
                _ViewMenuRow(
                  icon: Icons.straighten_rounded,
                  title: 'Inch',
                  selected:
                      settings.unit == ViewUnit.inch,
                  onTap: () {
                    _setUnit(ViewUnit.inch);
                  },
                ),
                _ViewMenuRow(
                  icon: Icons.straighten_rounded,
                  title: 'mm',
                  selected:
                      settings.unit == ViewUnit.mm,
                  onTap: () {
                    _setUnit(ViewUnit.mm);
                  },
                ),
              ],
            ),
          ),

          // ==================================================================
          // GRID SIZE
          // ==================================================================

          _animatedItem(
            index: 7,
            child: _ViewSubmenu(
              controller: widget.controller,
              icon: Icons.grid_4x4_rounded,
              title: 'Grid Size',
              children: [
                for (final double size
                    in ViewSettings.gridSizesInches)
                  _ViewGridSizeRow(
                    key: ValueKey(
                      '${settings.unit.name}-$size',
                    ),
                    title: settings.gridSizeLabel(size),
                    selected:
                        settings.gridSizeInches == size,
                    onTap: () {
                      _setGridSize(size);
                    },
                  ),
              ],
            ),
          ),

          // ==================================================================
          // GRID TYPE
          // ==================================================================

          _animatedItem(
            index: 8,
            child: _ViewSubmenu(
              controller: widget.controller,
              icon: Icons.grid_on_rounded,
              title: 'Grid Type',
              children: [
                _ViewMenuRow(
                  icon: Icons.blur_on_rounded,
                  title: 'Grid Dot',
                  selected:
                      settings.gridType == GridType.dot,
                  onTap: () {
                    _setGridType(GridType.dot);
                  },
                ),
                _ViewMenuRow(
                  icon: Icons.grid_on_rounded,
                  title: 'Grid',
                  selected:
                      settings.gridType == GridType.grid,
                  onTap: () {
                    _setGridType(GridType.grid);
                  },
                ),
                _ViewMenuRow(
                  icon: Icons.grid_off_rounded,
                  title: 'None',
                  selected:
                      settings.gridType == GridType.none,
                  onTap: () {
                    _setGridType(GridType.none);
                  },
                ),
              ],
            ),
          ),

          // ==================================================================
          // HIGHLIGHT NET
          // ==================================================================

          _animatedItem(
            index: 9,
            child: _ViewSubmenu(
              controller: widget.controller,
              icon: Icons.highlight_alt_rounded,
              title: 'Highlight Net',
              children: [
                _ViewMenuRow(
                  icon: Icons.highlight_rounded,
                  title: 'Highlight Net',
                  selected:
                      settings.highlightNetMode ==
                          HighlightNetMode.highlight,
                  onTap: () {
                    _setHighlightNet(
                      HighlightNetMode.highlight,
                    );
                  },
                ),
                _ViewMenuRow(
                  icon: Icons.highlight_off_rounded,
                  title: 'Unhighlight Net',
                  selected:
                      settings.highlightNetMode ==
                          HighlightNetMode.unhighlight,
                  onTap: () {
                    _setHighlightNet(
                      HighlightNetMode.unhighlight,
                    );
                  },
                ),
                _ViewMenuRow(
                  icon: Icons.cable_rounded,
                  title:
                      'Highlight Net While Hovering Wire',
                  selected:
                      settings.highlightNetMode ==
                          HighlightNetMode.hoverWire,
                  onTap: () {
                    _setHighlightNet(
                      HighlightNetMode.hoverWire,
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// GRID SIZE ROW
// ============================================================================

class _ViewGridSizeRow extends StatefulWidget {
  final String title;
  final bool selected;
  final VoidCallback onTap;

  const _ViewGridSizeRow({
    super.key,
    required this.title,
    required this.selected,
    required this.onTap,
  });

  @override
  State<_ViewGridSizeRow> createState() =>
      _ViewGridSizeRowState();
}

class _ViewGridSizeRowState
    extends State<_ViewGridSizeRow> {
  bool hovered = false;
  bool pressed = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
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
        behavior: HitTestBehavior.opaque,
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
          duration: const Duration(milliseconds: 150),
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
            ),
          decoration: BoxDecoration(
            color: pressed
                ? AppColors.signalOrange
                    .withOpacity(0.22)
                : hovered
                    ? AppColors.signalOrange
                        .withOpacity(0.11)
                    : Colors.transparent,
            borderRadius: BorderRadius.circular(5),
            border: Border.all(
              color: widget.selected
                  ? AppColors.signalOrange
                      .withOpacity(
                      hovered ? 0.55 : 0.25,
                    )
                  : Colors.transparent,
            ),
            boxShadow: hovered
                ? [
                    BoxShadow(
                      color: AppColors.signalOrange
                          .withOpacity(0.10),
                      blurRadius: 8,
                    ),
                  ]
                : null,
          ),
          child: Row(
            children: [
              SizedBox(
                width: 21,
                child: AnimatedSwitcher(
                  duration:
                      const Duration(milliseconds: 180),
                  transitionBuilder:
                      (child, animation) {
                    return ScaleTransition(
                      scale: animation,
                      child: FadeTransition(
                        opacity: animation,
                        child: child,
                      ),
                    );
                  },
                  child: widget.selected
                      ? Icon(
                          Icons.check_rounded,
                          key: const ValueKey('check'),
                          size: 15,
                          color:
                              AppColors.signalOrange,
                        )
                      : const Icon(
                          Icons.grid_4x4_rounded,
                          key: ValueKey('grid'),
                          size: 14,
                          color: Color(0xFF697178),
                        ),
                ),
              ),
              const SizedBox(width: 5),
              Expanded(
                child: AnimatedSwitcher(
                  duration:
                      const Duration(milliseconds: 220),
                  transitionBuilder:
                      (child, animation) {
                    return FadeTransition(
                      opacity: animation,
                      child: SlideTransition(
                        position: Tween<Offset>(
                          begin: const Offset(0.08, 0),
                          end: Offset.zero,
                        ).animate(animation),
                        child: child,
                      ),
                    );
                  },
                  child: Text(
                    widget.title,
                    key: ValueKey(widget.title),
                    maxLines: 1,
                    overflow:
                        TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 11.5,
                      fontWeight: hovered ||
                              widget.selected
                          ? FontWeight.w600
                          : FontWeight.w500,
                      color:
                          const Color(0xFF30353A),
                    ),
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
// MENU SURFACE
// ============================================================================

class _ViewMenuSurface extends StatefulWidget {
  final double width;
  final Widget child;

  const _ViewMenuSurface({
    required this.width,
    required this.child,
  });

  @override
  State<_ViewMenuSurface> createState() =>
      _ViewMenuSurfaceState();
}

class _ViewMenuSurfaceState
    extends State<_ViewMenuSurface>
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
        final double value = Curves.easeOutBack
            .transform(_controller.value);

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
            maxHeight: 500,
          ),
          decoration: BoxDecoration(
            color: const Color(0xFFFDFDFE),
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
// MENU ROW
// ============================================================================

class _ViewMenuRow extends StatefulWidget {
  final IconData? icon;
  final String title;
  final String? shortcut;
  final bool selected;
  final VoidCallback onTap;

  const _ViewMenuRow({
    this.icon,
    required this.title,
    this.shortcut,
    this.selected = false,
    required this.onTap,
  });

  @override
  State<_ViewMenuRow> createState() =>
      _ViewMenuRowState();
}

class _ViewMenuRowState
    extends State<_ViewMenuRow> {
  bool hovered = false;
  bool pressed = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
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
        behavior: HitTestBehavior.opaque,
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
            borderRadius: BorderRadius.circular(5),
            border: Border.all(
              color: widget.selected
                  ? AppColors.signalOrange
                      .withOpacity(
                      hovered ? 0.58 : 0.22,
                    )
                  : Colors.transparent,
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
                child: AnimatedSwitcher(
                  duration:
                      const Duration(milliseconds: 170),
                  transitionBuilder:
                      (child, animation) {
                    return ScaleTransition(
                      scale: animation,
                      child: FadeTransition(
                        opacity: animation,
                        child: child,
                      ),
                    );
                  },
                  child: widget.selected
                      ? Icon(
                          Icons.check_rounded,
                          key: const ValueKey('selected'),
                          size: 15,
                          color:
                              AppColors.signalOrange,
                        )
                      : widget.icon == null
                          ? const SizedBox(
                              key: ValueKey('empty'),
                            )
                          : Icon(
                              widget.icon,
                              key: ValueKey(widget.icon),
                              size: 14,
                              color: hovered
                                  ? AppColors
                                      .signalOrange
                                  : const Color(
                                      0xFF596066,
                                    ),
                            ),
                ),
              ),
              const SizedBox(width: 5),
              Expanded(
                child: Text(
                  widget.title,
                  maxLines: 1,
                  overflow:
                      TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 11.5,
                    fontWeight: hovered ||
                            widget.selected
                        ? FontWeight.w600
                        : FontWeight.w500,
                    color:
                        const Color(0xFF30353A),
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

class _ViewSubmenu extends StatefulWidget {
  final ViewHoverController controller;

  final IconData? icon;
  final String title;
  final List<Widget> children;

  const _ViewSubmenu({
    required this.controller,
    this.icon,
    required this.title,
    required this.children,
  });

  @override
  State<_ViewSubmenu> createState() =>
      _ViewSubmenuState();
}

class _ViewSubmenuState
    extends State<_ViewSubmenu>
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
  // CANCEL
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
  }

  // ==========================================================================
  // EXIT CHILD
  // ==========================================================================

  void _exitChild() {
    submenuHovered = false;

    _scheduleClose();
  }

  // ==========================================================================
  // CLOSE TIMER
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
      _overlayEntry!.markNeedsBuild();
      return;
    }

    final RenderBox? renderBox =
        _key.currentContext
            ?.findRenderObject() as RenderBox?;

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
        return _ViewSubmenuOverlay(
          left: position.dx + size.width - 1,
          top: position.dy,
          width: 242,
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
              SizedBox(
                width: 21,
                child: Icon(
                  widget.icon,
                  size: 14,
                  color: hovered
                      ? AppColors.signalOrange
                      : const Color(0xFF596066),
                ),
              ),
              const SizedBox(width: 5),
              Expanded(
                child: Text(
                  widget.title,
                  maxLines: 1,
                  overflow:
                      TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 11.5,
                    fontWeight: hovered
                        ? FontWeight.w600
                        : FontWeight.w500,
                    color:
                        const Color(0xFF30353A),
                  ),
                ),
              ),
              AnimatedBuilder(
                animation: _arrowController,
                builder: (context, child) {
                  return Transform.translate(
                    offset: Offset(
                      3 *
                          _arrowController.value,
                      0,
                    ),
                    child: Transform.scale(
                      scale:
                          1 +
                              (0.10 *
                                  _arrowController
                                      .value),
                      child: Icon(
                        Icons
                            .chevron_right_rounded,
                        size: 16,
                        color: Color.lerp(
                          const Color(0xFF777D82),
                          AppColors.signalOrange,
                          _arrowController.value,
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

class _ViewSubmenuOverlay
    extends StatefulWidget {
  final double left;
  final double top;
  final double width;

  final List<Widget> children;

  final VoidCallback onEnter;
  final VoidCallback onExit;

  const _ViewSubmenuOverlay({
    required this.left,
    required this.top,
    required this.width,
    required this.children,
    required this.onEnter,
    required this.onExit,
  });

  @override
  State<_ViewSubmenuOverlay> createState() =>
      _ViewSubmenuOverlayState();
}

class _ViewSubmenuOverlayState
    extends State<_ViewSubmenuOverlay>
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
                        (1 -
                            _controller.value),
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
                  decoration: BoxDecoration(
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

class _ViewDivider extends StatelessWidget {
  const _ViewDivider();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 1,
      margin: const EdgeInsets.symmetric(
        horizontal: 9,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.transparent,
            const Color(0xFFD8DDE1),
            Colors.transparent,
          ],
        ),
      ),
    );
  }
}

// ============================================================================
// VIEW HOVER CONTROLLER
// ============================================================================

class ViewHoverController {
  bool menuHovered = false;
  bool dropdownHovered = false;

  int submenuHoverCount = 0;

  Timer? _closeTimer;

  bool get isInsideViewSystem {
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
      const Duration(milliseconds: 240),
      () {
        if (!isInsideViewSystem) {
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
