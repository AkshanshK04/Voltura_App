import 'dart:async';

import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import 'custom_window_bar.dart';
import 'edit_ribbon.dart';
import 'view_menu.dart';

class MenuBarWidget extends StatefulWidget {
  final String? activeMenu;
  final ValueChanged<String> onMenuChanged;
  final ValueChanged<String>? onCommand;
  final VoidCallback onFullscreenPressed;

  const MenuBarWidget({
    super.key,
    required this.activeMenu,
    required this.onMenuChanged,
    this.onCommand,
    required this.onFullscreenPressed,
  });

  @override
  State<MenuBarWidget> createState() =>
      _MenuBarWidgetState();
}

class _MenuBarWidgetState
    extends State<MenuBarWidget> {
  String? hoveredMenu;

  bool arrowHovered = false;

  OverlayEntry? _editOverlay;
  OverlayEntry? _viewOverlay;

  final EditHoverController
      _editHoverController =
      EditHoverController();

  final ViewHoverController
      _viewHoverController =
      ViewHoverController();

  // ==========================================================================
  // PERSISTENT VIEW SETTINGS
  // ==========================================================================

  final ViewSettings _viewSettings =
      ViewSettings();

  final List<String> menus = const [
    'File',
    'Edit',
    'View',
    'Place',
    'Tools',
    'Help',
  ];

  // ==========================================================================
  // EDIT
  // ==========================================================================

  void _editEnter() {
    _closeViewOverlay();

    _editHoverController.enterEditButton();

    if (mounted) {
      setState(() {
        hoveredMenu = 'Edit';
      });
    }

    _openEditOverlay();
  }

  void _editExit() {
    _editHoverController.exitEditButton();

    if (mounted) {
      setState(() {
        if (!_editHoverController
            .isInsideEditSystem) {
          hoveredMenu = null;
        }
      });
    }

    _scheduleEditOverlayClose();
  }

  void _dropdownEnter() {
    _editHoverController
        .enterEditDropdown();

    if (mounted) {
      setState(() {
        hoveredMenu = 'Edit';
      });
    }
  }

  void _dropdownExit() {
    _editHoverController
        .exitEditDropdown();

    if (mounted) {
      setState(() {
        if (!_editHoverController
            .isInsideEditSystem) {
          hoveredMenu = null;
        }
      });
    }

    _scheduleEditOverlayClose();
  }

  void _submenuHoverChanged() {
    if (mounted) {
      setState(() {
        if (_editHoverController
            .isInsideEditSystem) {
          hoveredMenu = 'Edit';
        }
      });
    }

    _scheduleEditOverlayClose();
  }

  void _scheduleEditOverlayClose() {
    _editHoverController.scheduleClose(
      onClose: () {
        if (!mounted) return;

        if (!_editHoverController
            .isInsideEditSystem) {
          _closeEditOverlay();
        }
      },
    );
  }

  void _openEditOverlay() {
    if (_editOverlay != null) {
      return;
    }

    final RenderBox? renderBox =
        context.findRenderObject()
            as RenderBox?;

    if (renderBox == null) {
      return;
    }

    final Offset menuBarPosition =
        renderBox.localToGlobal(
      Offset.zero,
    );

    final OverlayState overlay =
        Overlay.of(context);

    _editOverlay = OverlayEntry(
      builder: (context) {
        return _EditDropdownOverlay(
          left: menuBarPosition.dx +
              CustomWindowBar.leftAlignment +
              2,
          top: menuBarPosition.dy + 44,
          controller: _editHoverController,
          onEnter: _dropdownEnter,
          onExit: _dropdownExit,
          onSubmenuHoverChanged:
              _submenuHoverChanged,
          onCommand: (command) {
            widget.onCommand
                ?.call(command);

            _closeEditOverlay();
          },
        );
      },
    );

    overlay.insert(_editOverlay!);
  }

  void _closeEditOverlay() {
    _editHoverController.cancelClose();

    _editOverlay?.remove();
    _editOverlay = null;

    if (mounted) {
      setState(() {
        if (hoveredMenu == 'Edit') {
          hoveredMenu = null;
        }
      });
    }

    _editHoverController.reset();
  }

  // ==========================================================================
  // VIEW
  // ==========================================================================

  void _viewEnter() {
    _closeEditOverlay();

    _viewHoverController.enterMenu();

    if (mounted) {
      setState(() {
        hoveredMenu = 'View';
      });
    }

    _openViewOverlay();
  }

  void _viewExit() {
    _viewHoverController.exitMenu();

    if (mounted) {
      setState(() {
        if (!_viewHoverController
            .isInsideViewSystem) {
          hoveredMenu = null;
        }
      });
    }

    _scheduleViewOverlayClose();
  }

  void _viewDropdownEnter() {
    _viewHoverController.enterDropdown();

    if (mounted) {
      setState(() {
        hoveredMenu = 'View';
      });
    }
  }

  void _viewDropdownExit() {
    _viewHoverController.exitDropdown();

    if (mounted) {
      setState(() {
        if (!_viewHoverController
            .isInsideViewSystem) {
          hoveredMenu = null;
        }
      });
    }

    _scheduleViewOverlayClose();
  }

  void _scheduleViewOverlayClose() {
    _viewHoverController.scheduleClose(
      onClose: () {
        if (!mounted) return;

        if (!_viewHoverController
            .isInsideViewSystem) {
          _closeViewOverlay();
        }
      },
    );
  }

  // ==========================================================================
  // VIEW SETTING COMMAND
  // ==========================================================================

  bool _isViewSettingCommand(
    String command,
  ) {
    return command.startsWith(
          'View: Unit:',
        ) ||
        command.startsWith(
          'View: Grid Size:',
        ) ||
        command.startsWith(
          'View: Grid Type:',
        ) ||
        command.startsWith(
          'View: Highlight Net:',
        );
  }

  // ==========================================================================
  // FORCE VIEW OVERLAY REBUILD
  // ==========================================================================

  void _refreshViewOverlay() {
    _viewOverlay?.markNeedsBuild();

    if (mounted) {
      setState(() {});
    }
  }

  // ==========================================================================
  // VIEW UNIT
  // ==========================================================================

  void _viewUnitChanged(
    ViewUnit unit,
  ) {
    _viewSettings.unit = unit;

    _refreshViewOverlay();
  }

  // ==========================================================================
  // VIEW GRID SIZE
  // ==========================================================================

  void _viewGridSizeChanged(
    double inches,
  ) {
    _viewSettings.gridSizeInches =
        inches;

    _refreshViewOverlay();
  }

  // ==========================================================================
  // VIEW GRID TYPE
  // ==========================================================================

  void _viewGridTypeChanged(
    GridType type,
  ) {
    _viewSettings.gridType = type;

    _refreshViewOverlay();
  }

  // ==========================================================================
  // VIEW HIGHLIGHT
  // ==========================================================================

  void _viewHighlightNetChanged(
    HighlightNetMode mode,
  ) {
    _viewSettings.highlightNetMode =
        mode;

    _refreshViewOverlay();
  }

  // ==========================================================================
  // OPEN VIEW OVERLAY
  // ==========================================================================

  void _openViewOverlay() {
    if (_viewOverlay != null) {
      _viewOverlay!.markNeedsBuild();
      return;
    }

    final RenderBox? renderBox =
        context.findRenderObject()
            as RenderBox?;

    if (renderBox == null) {
      return;
    }

    final Offset menuBarPosition =
        renderBox.localToGlobal(
      Offset.zero,
    );

    final OverlayState overlay =
        Overlay.of(context);

    _viewOverlay = OverlayEntry(
      builder: (context) {
        return _ViewDropdownOverlay(
          left: menuBarPosition.dx +
              CustomWindowBar.leftAlignment +
              2,
          top: menuBarPosition.dy + 44,
          controller:
              _viewHoverController,
          settings: _viewSettings,
          onEnter:
              _viewDropdownEnter,
          onExit:
              _viewDropdownExit,
          onUnitChanged:
              _viewUnitChanged,
          onGridSizeChanged:
              _viewGridSizeChanged,
          onGridTypeChanged:
              _viewGridTypeChanged,
          onHighlightNetChanged:
              _viewHighlightNetChanged,
          onCommand: (command) {
            widget.onCommand
                ?.call(command);

            if (!_isViewSettingCommand(
              command,
            )) {
              _closeViewOverlay();
            }
          },
        );
      },
    );

    overlay.insert(_viewOverlay!);
  }

  // ==========================================================================
  // CLOSE VIEW OVERLAY
  // ==========================================================================

  void _closeViewOverlay() {
    _viewHoverController.cancelClose();

    _viewOverlay?.remove();
    _viewOverlay = null;

    if (mounted) {
      setState(() {
        if (hoveredMenu == 'View') {
          hoveredMenu = null;
        }
      });
    }

    _viewHoverController.reset();
  }

  // ==========================================================================
  // TOP LEVEL MENU
  // ==========================================================================

  void _menuEnter(String menu) {
    if (menu == 'Edit') {
      _editEnter();
      return;
    }

    if (menu == 'View') {
      _viewEnter();
      return;
    }

    _closeEditOverlay();
    _closeViewOverlay();

    if (mounted) {
      setState(() {
        hoveredMenu = menu;
      });
    }
  }

  void _menuExit(String menu) {
    if (menu == 'Edit') {
      _editExit();
      return;
    }

    if (menu == 'View') {
      _viewExit();
      return;
    }

    if (mounted &&
        hoveredMenu == menu) {
      setState(() {
        hoveredMenu = null;
      });
    }
  }

  void _menuTap(String menu) {
    if (menu == 'Edit') {
      _openEditOverlay();
      return;
    }

    if (menu == 'View') {
      _openViewOverlay();
      return;
    }

    widget.onMenuChanged(menu);
  }

  // ==========================================================================
  // DISPOSE
  // ==========================================================================

  @override
  void dispose() {
    _editHoverController.dispose();
    _viewHoverController.dispose();

    _editOverlay?.remove();
    _editOverlay = null;

    _viewOverlay?.remove();
    _viewOverlay = null;

    super.dispose();
  }

  // ==========================================================================
  // BUILD
  // ==========================================================================

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: SizedBox(
        height: 44,
        child: Container(
          decoration: const BoxDecoration(
            color: Color(0xFF0E4635),
            border: Border(
              top: BorderSide(
                color: Color(0xFF174F40),
                width: 1,
              ),
              bottom: BorderSide(
                color: Color(0xFF708090),
                width: 1,
              ),
            ),
          ),
          child: Stack(
            alignment: Alignment.center,
            clipBehavior: Clip.none,
            children: [
              Positioned(
                top: 6,
                left: 0,
                right: 0,
                height: 32,
                child: Row(
                  children: [
                    const SizedBox(
                      width:
                          CustomWindowBar
                              .leftAlignment,
                    ),
                    for (final menu in menus)
                      _TopLevelMenuItem(
                        label: menu,
                        active:
                            widget.activeMenu ==
                                menu,
                        hovered:
                            hoveredMenu ==
                                menu,
                        onEnter: () {
                          _menuEnter(menu);
                        },
                        onExit: () {
                          _menuExit(menu);
                        },
                        onTap: () {
                          _menuTap(menu);
                        },
                      ),
                  ],
                ),
              ),

              // ==============================================================
              // FULLSCREEN ARROW
              // ==============================================================

              Center(
                child: MouseRegion(
                  cursor:
                      SystemMouseCursors.click,
                  onEnter: (_) {
                    setState(() {
                      arrowHovered = true;
                    });
                  },
                  onExit: (_) {
                    setState(() {
                      arrowHovered = false;
                    });
                  },
                  child: GestureDetector(
                    behavior:
                        HitTestBehavior.opaque,
                    onTap:
                        widget.onFullscreenPressed,
                    child:
                        TweenAnimationBuilder<
                            double>(
                      tween: Tween<double>(
                        begin: 0,
                        end: arrowHovered
                            ? 1
                            : 0,
                      ),
                      duration:
                          const Duration(
                        milliseconds: 220,
                      ),
                      curve:
                          Curves.easeOutBack,
                      builder: (
                        context,
                        value,
                        child,
                      ) {
                        return Transform.translate(
                          offset: Offset(
                            0,
                            -3 * value,
                          ),
                          child: Transform.scale(
                            scale:
                                1 +
                                    (0.07 *
                                        value),
                            child: Container(
                              width: 38,
                              height: 27,
                              decoration:
                                  BoxDecoration(
                                color:
                                    Color.lerp(
                                  Colors.transparent,
                                  AppColors
                                      .slateGray
                                      .withOpacity(
                                    0.82,
                                  ),
                                  value,
                                ),
                                borderRadius:
                                    BorderRadius
                                        .circular(
                                  6,
                                ),
                                border:
                                    Border.all(
                                  color:
                                      Color.lerp(
                                    Colors
                                        .transparent,
                                    AppColors
                                        .signalOrange,
                                    value,
                                  )!,
                                  width: 1,
                                ),
                                boxShadow:
                                    value > 0
                                        ? [
                                            BoxShadow(
                                              color: AppColors
                                                  .signalOrange
                                                  .withOpacity(
                                                0.18 *
                                                    value,
                                              ),
                                              blurRadius:
                                                  12,
                                              spreadRadius:
                                                  1,
                                              offset:
                                                  const Offset(
                                                0,
                                                2,
                                              ),
                                            ),
                                          ]
                                        : null,
                              ),
                              child: Icon(
                                Icons
                                    .keyboard_arrow_up_rounded,
                                size: 23,
                                color:
                                    Color.lerp(
                                  Colors.white
                                      .withOpacity(
                                    0.72,
                                  ),
                                  Colors.white,
                                  value,
                                ),
                              ),
                            ),
                          ),
                        );
                      },
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
// EDIT HOVER CONTROLLER
// ============================================================================

class EditHoverController {
  bool editButtonHovered = false;
  bool editDropdownHovered = false;

  int submenuHoverCount = 0;

  Timer? _closeTimer;

  bool get isInsideEditSystem {
    return editButtonHovered ||
        editDropdownHovered ||
        submenuHoverCount > 0;
  }

  void enterEditButton() {
    cancelClose();
    editButtonHovered = true;
  }

  void exitEditButton() {
    editButtonHovered = false;
  }

  void enterEditDropdown() {
    cancelClose();
    editDropdownHovered = true;
  }

  void exitEditDropdown() {
    editDropdownHovered = false;
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
        if (!isInsideEditSystem) {
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

    editButtonHovered = false;
    editDropdownHovered = false;
    submenuHoverCount = 0;
  }

  void dispose() {
    cancelClose();
  }
}

// ============================================================================
// TOP LEVEL MENU ITEM
// ============================================================================

class _TopLevelMenuItem
    extends StatelessWidget {
  final String label;
  final bool active;
  final bool hovered;

  final VoidCallback onEnter;
  final VoidCallback onExit;
  final VoidCallback onTap;

  const _TopLevelMenuItem({
    required this.label,
    required this.active,
    required this.hovered,
    required this.onEnter,
    required this.onExit,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final bool highlighted =
        active || hovered;

    return MouseRegion(
      cursor:
          SystemMouseCursors.click,
      onEnter: (_) => onEnter(),
      onExit: (_) => onExit(),
      child: GestureDetector(
        behavior:
            HitTestBehavior.opaque,
        onTap: onTap,
        child: AnimatedContainer(
          duration:
              const Duration(milliseconds: 170),
          curve:
              Curves.easeOutCubic,
          height: 32,
          margin:
              const EdgeInsets.only(right: 3),
          padding:
              const EdgeInsets.symmetric(
            horizontal: 13,
          ),
          decoration:
              BoxDecoration(
            color: active
                ? AppColors.slateGray
                    .withOpacity(0.68)
                : hovered
                    ? AppColors.slateGray
                        .withOpacity(0.34)
                    : Colors.transparent,
            borderRadius:
                BorderRadius.circular(5),
            border: Border.all(
              color: active
                  ? AppColors.signalOrange
                      .withOpacity(0.48)
                  : Colors.transparent,
              width: 1,
            ),
            boxShadow: hovered
                ? [
                    BoxShadow(
                      color: AppColors
                          .signalOrange
                          .withOpacity(0.08),
                      blurRadius: 9,
                    ),
                  ]
                : null,
          ),
          child: Stack(
            alignment:
                Alignment.center,
            children: [
              Padding(
                padding:
                    const EdgeInsets.only(
                  bottom: 3,
                ),
                child: Text(
                  label,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 13.5,
                    fontWeight:
                        active
                            ? FontWeight.w600
                            : FontWeight.w500,
                    height: 1,
                  ),
                ),
              ),
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child:
                    TweenAnimationBuilder<
                        double>(
                  tween:
                      Tween<double>(
                    begin: 0,
                    end: highlighted
                        ? 1
                        : 0,
                  ),
                  duration:
                      const Duration(
                    milliseconds: 200,
                  ),
                  curve:
                      Curves.easeOutCubic,
                  builder:
                      (
                    context,
                    value,
                    child,
                  ) {
                    return Center(
                      child:
                          Container(
                        width:
                            34 * value,
                        height:
                            active
                                ? 2.5
                                : 2,
                        decoration:
                            BoxDecoration(
                          color:
                              AppColors
                                  .signalOrange,
                          borderRadius:
                              BorderRadius
                                  .circular(
                            10,
                          ),
                          boxShadow:
                              value > 0
                                  ? [
                                      BoxShadow(
                                        color: AppColors
                                            .signalOrange
                                            .withOpacity(
                                          0.45 *
                                              value,
                                        ),
                                        blurRadius:
                                            5,
                                      ),
                                    ]
                                  : null,
                        ),
                      ),
                    );
                  },
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
// EDIT DROPDOWN OVERLAY
// ============================================================================

class _EditDropdownOverlay
    extends StatelessWidget {
  final double left;
  final double top;

  final EditHoverController controller;

  final VoidCallback onEnter;
  final VoidCallback onExit;
  final VoidCallback
      onSubmenuHoverChanged;

  final ValueChanged<String>
      onCommand;

  const _EditDropdownOverlay({
    required this.left,
    required this.top,
    required this.controller,
    required this.onEnter,
    required this.onExit,
    required this.onSubmenuHoverChanged,
    required this.onCommand,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: left,
      top: top,
      child: MouseRegion(
        cursor:
            SystemMouseCursors.basic,
        onEnter: (_) => onEnter(),
        onExit: (_) => onExit(),
        child: Material(
          color: Colors.transparent,
          child: EditMenu(
            controller: controller,
            onSubmenuHoverChanged:
                onSubmenuHoverChanged,
            onCommand: onCommand,
          ),
        ),
      ),
    );
  }
}

// ============================================================================
// VIEW DROPDOWN OVERLAY
// ============================================================================

class _ViewDropdownOverlay
    extends StatelessWidget {
  final double left;
  final double top;

  final ViewHoverController controller;

  final ViewSettings settings;

  final VoidCallback onEnter;
  final VoidCallback onExit;

  final ValueChanged<ViewUnit>
      onUnitChanged;

  final ValueChanged<double>
      onGridSizeChanged;

  final ValueChanged<GridType>
      onGridTypeChanged;

  final ValueChanged<HighlightNetMode>
      onHighlightNetChanged;

  final ValueChanged<String>
      onCommand;

  const _ViewDropdownOverlay({
    required this.left,
    required this.top,
    required this.controller,
    required this.settings,
    required this.onEnter,
    required this.onExit,
    required this.onUnitChanged,
    required this.onGridSizeChanged,
    required this.onGridTypeChanged,
    required this.onHighlightNetChanged,
    required this.onCommand,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: left,
      top: top,
      child: MouseRegion(
        cursor:
            SystemMouseCursors.basic,
        onEnter: (_) => onEnter(),
        onExit: (_) => onExit(),
        child: Material(
          color: Colors.transparent,
          child: ViewMenu(
            controller: controller,
            settings: settings,
            onUnitChanged:
                onUnitChanged,
            onGridSizeChanged:
                onGridSizeChanged,
            onGridTypeChanged:
                onGridTypeChanged,
            onHighlightNetChanged:
                onHighlightNetChanged,
            onCommand:
                onCommand,
          ),
        ),
      ),
    );
  }
}
