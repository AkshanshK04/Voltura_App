import 'dart:async';

import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

// ============================================================================
// TOOLS MENU
// ============================================================================
//
// Structure:
//
// Tools
// ├── Log
// ├── Footprint Manager
// ├── Device Manager
// ├── Device Standardization
// ├── Assembly Variants
// ├── IPC/DAC-2552 Properties
// ├── Netlist Comparison
// └── Schematic Comparison
//
// ============================================================================

// ============================================================================
// TOOLS MENU
// ============================================================================

class ToolsMenu extends StatefulWidget {
  final ToolsHoverController controller;

  /// Called whenever a Tools command is selected.
  ///
  /// Examples:
  ///   Tools: Log
  ///   Tools: Footprint Manager
  ///   Tools: Device Manager
  ///   Tools: Device Standardization
  ///   Tools: Assembly Variants
  ///   Tools: IPC/DAC-2552 Properties
  ///   Tools: Netlist Comparison
  ///   Tools: Schematic Comparison
  final ValueChanged<String>? onCommand;

  const ToolsMenu({
    super.key,
    required this.controller,
    this.onCommand,
  });

  @override
  State<ToolsMenu> createState() => _ToolsMenuState();
}

// ============================================================================
// TOOLS MENU STATE
// ============================================================================

class _ToolsMenuState extends State<ToolsMenu>
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
  // ANIMATED ITEM
  // ==========================================================================

  Widget _animatedItem({
    required int index,
    required Widget child,
  }) {
    final Animation<double> animation = CurvedAnimation(
      parent: _entranceController,
      curve: Interval(
        (index * 0.045).clamp(0.0, 0.65),
        ((index * 0.045) + 0.42).clamp(0.0, 1.0),
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
    return _ToolsMenuSurface(
      width: 255,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // ==================================================================
          // LOG
          // ==================================================================

          _animatedItem(
            index: 0,
            child: _ToolsMenuRow(
              icon: Icons.article_outlined,
              title: 'Log',
              onTap: () {
                _command('Tools: Log');
              },
            ),
          ),

          // ==================================================================
          // FOOTPRINT MANAGER
          // ==================================================================

          _animatedItem(
            index: 1,
            child: _ToolsMenuRow(
              icon: Icons.memory_rounded,
              title: 'Footprint Manager',
              onTap: () {
                _command('Tools: Footprint Manager');
              },
            ),
          ),

          // ==================================================================
          // DEVICE MANAGER
          // ==================================================================

          _animatedItem(
            index: 2,
            child: _ToolsMenuRow(
              icon: Icons.developer_board_rounded,
              title: 'Device Manager',
              onTap: () {
                _command('Tools: Device Manager');
              },
            ),
          ),

          // ==================================================================
          // DEVICE STANDARDIZATION
          // ==================================================================

          _animatedItem(
            index: 3,
            child: _ToolsMenuRow(
              icon: Icons.rule_rounded,
              title: 'Device Standardization',
              onTap: () {
                _command('Tools: Device Standardization');
              },
            ),
          ),

          // ==================================================================
          // ASSEMBLY VARIANTS
          // ==================================================================

          _animatedItem(
            index: 4,
            child: _ToolsMenuRow(
              icon: Icons.account_tree_rounded,
              title: 'Assembly Variants',
              onTap: () {
                _command('Tools: Assembly Variants');
              },
            ),
          ),

          // ==================================================================
          // IPC/DAC-2552 PROPERTIES
          // ==================================================================

          _animatedItem(
            index: 5,
            child: _ToolsMenuRow(
              icon: Icons.tune_rounded,
              title: 'IPC/DAC-2552 Properties',
              onTap: () {
                _command(
                  'Tools: IPC/DAC-2552 Properties',
                );
              },
            ),
          ),

          const _ToolsDivider(),

          // ==================================================================
          // NETLIST COMPARISON
          // ==================================================================

          _animatedItem(
            index: 6,
            child: _ToolsMenuRow(
              icon: Icons.compare_arrows_rounded,
              title: 'Netlist Comparison',
              onTap: () {
                _command('Tools: Netlist Comparison');
              },
            ),
          ),

          // ==================================================================
          // SCHEMATIC COMPARISON
          // ==================================================================

          _animatedItem(
            index: 7,
            child: _ToolsMenuRow(
              icon: Icons.schema_rounded,
              title: 'Schematic Comparison',
              onTap: () {
                _command('Tools: Schematic Comparison');
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// TOOLS MENU SURFACE
// ============================================================================

class _ToolsMenuSurface extends StatefulWidget {
  final double width;
  final Widget child;

  const _ToolsMenuSurface({
    required this.width,
    required this.child,
  });

  @override
  State<_ToolsMenuSurface> createState() =>
      _ToolsMenuSurfaceState();
}

class _ToolsMenuSurfaceState
    extends State<_ToolsMenuSurface>
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
            maxHeight: 360,
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
// TOOLS MENU ROW
// ============================================================================

class _ToolsMenuRow extends StatefulWidget {
  final IconData? icon;
  final String title;
  final String? shortcut;
  final bool selected;
  final VoidCallback onTap;

  const _ToolsMenuRow({
    this.icon,
    required this.title,
    this.shortcut,
    this.selected = false,
    required this.onTap,
  });

  @override
  State<_ToolsMenuRow> createState() =>
      _ToolsMenuRowState();
}

class _ToolsMenuRowState
    extends State<_ToolsMenuRow> {
  bool hovered = false;
  bool pressed = false;

  // ==========================================================================
  // BUILD
  // ==========================================================================

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
          duration: const Duration(
            milliseconds: 130,
          ),
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
              // ==============================================================
              // ICON
              // ==============================================================

              SizedBox(
                width: 21,
                child: AnimatedSwitcher(
                  duration: const Duration(
                    milliseconds: 170,
                  ),

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
                          key: const ValueKey(
                            'selected',
                          ),
                          size: 15,
                          color:
                              AppColors.signalOrange,
                        )
                      : widget.icon == null
                          ? const SizedBox(
                              key: ValueKey(
                                'empty',
                              ),
                            )
                          : Icon(
                              widget.icon,
                              key: ValueKey(
                                widget.icon,
                              ),
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

              // ==============================================================
              // TITLE
              // ==============================================================

              Expanded(
                child: Text(
                  widget.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 11.5,
                    fontWeight:
                        hovered || widget.selected
                            ? FontWeight.w600
                            : FontWeight.w500,
                    color:
                        const Color(0xFF30353A),
                  ),
                ),
              ),

              // ==============================================================
              // SHORTCUT
              // ==============================================================

              if (widget.shortcut != null)
                AnimatedOpacity(
                  duration: const Duration(
                    milliseconds: 120,
                  ),
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
// DIVIDER
// ============================================================================

class _ToolsDivider extends StatelessWidget {
  const _ToolsDivider();

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

// ============================================================================
// TOOLS HOVER CONTROLLER
// ============================================================================

class ToolsHoverController {
  bool menuHovered = false;
  bool dropdownHovered = false;

  int submenuHoverCount = 0;

  Timer? _closeTimer;

  // ==========================================================================
  // INSIDE SYSTEM
  // ==========================================================================

  bool get isInsideToolsSystem {
    return menuHovered ||
        dropdownHovered ||
        submenuHoverCount > 0;
  }

  // ==========================================================================
  // MENU
  // ==========================================================================

  void enterMenu() {
    cancelClose();
    menuHovered = true;
  }

  void exitMenu() {
    menuHovered = false;
  }

  // ==========================================================================
  // DROPDOWN
  // ==========================================================================

  void enterDropdown() {
    cancelClose();
    dropdownHovered = true;
  }

  void exitDropdown() {
    dropdownHovered = false;
  }

  // ==========================================================================
  // SUBMENU
  // ==========================================================================

  void enterSubmenu() {
    cancelClose();
    submenuHoverCount++;
  }

  void exitSubmenu() {
    if (submenuHoverCount > 0) {
      submenuHoverCount--;
    }
  }

  // ==========================================================================
  // CLOSE
  // ==========================================================================

  void scheduleClose({
    required VoidCallback onClose,
  }) {
    cancelClose();

    _closeTimer = Timer(
      const Duration(milliseconds: 240),
      () {
        if (!isInsideToolsSystem) {
          onClose();
        }
      },
    );
  }

  // ==========================================================================
  // CANCEL
  // ==========================================================================

  void cancelClose() {
    _closeTimer?.cancel();
    _closeTimer = null;
  }

  // ==========================================================================
  // RESET
  // ==========================================================================

  void reset() {
    cancelClose();

    menuHovered = false;
    dropdownHovered = false;
    submenuHoverCount = 0;
  }

  // ==========================================================================
  // DISPOSE
  // ==========================================================================

  void dispose() {
    cancelClose();
  }
}
