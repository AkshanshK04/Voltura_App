import 'dart:async';

import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import 'custom_window_bar.dart';
import 'edit_ribbon.dart';
import 'view_menu.dart';
import 'place_menu.dart';
import 'tools_menu.dart';
import 'library_menu.dart';
import 'help_menu.dart';

class MenuBarWidget extends StatefulWidget {
  final String? activeMenu;
  final ValueChanged<String> onMenuChanged;
  final ValueChanged<String>? onCommand;
  final VoidCallback onFullscreenPressed;

  /// Optional shared ViewSettings owned by the parent editor.
  /// If omitted, ViewSettings() resolves to the editor-wide shared instance.
  final ViewSettings? viewSettings;

  const MenuBarWidget({
    super.key,
    required this.activeMenu,
    required this.onMenuChanged,
    this.onCommand,
    required this.onFullscreenPressed,
    this.viewSettings,
  });

  @override
  State<MenuBarWidget> createState() =>
      _MenuBarWidgetState();
}

class _MenuBarWidgetState extends State<MenuBarWidget> {
  String? hoveredMenu;
  bool arrowHovered = false;

  OverlayEntry? _editOverlay;
  OverlayEntry? _viewOverlay;
  OverlayEntry? _placeOverlay;
  OverlayEntry? _toolsOverlay;
  OverlayEntry? _libraryOverlay;
  OverlayEntry? _helpOverlay;

  final EditHoverController _editHoverController =
      EditHoverController();

  final ViewHoverController _viewHoverController =
      ViewHoverController();

  final PlaceHoverController _placeHoverController =
      PlaceHoverController();

  final ToolsHoverController _toolsHoverController =
      ToolsHoverController();

  final LibraryHoverController _libraryHoverController =
      LibraryHoverController();

  final HelpHoverController _helpHoverController =
      HelpHoverController();

  final GlobalKey _libraryMenuKey = GlobalKey();
  final GlobalKey _helpMenuKey = GlobalKey();

  late final ViewSettings _viewSettings;

  @override
  void initState() {
    super.initState();
    _viewSettings = widget.viewSettings ?? ViewSettings();
  }

  final List<String> menus = const [
    'File',
    'Edit',
    'View',
    'Place',
    'Tools',
    'Library',
    'Help',
  ];

  // ==========================================================================
  // EDIT
  // ==========================================================================

  void _editEnter() {
    _closeLibraryOverlay();
    _closeHelpOverlay();
    _closeViewOverlay();
    _closePlaceOverlay();
    _closeToolsOverlay();

    _editHoverController.enterEditButton();

    if (!mounted) return;

    setState(() {
      hoveredMenu = 'Edit';
    });

    _openEditOverlay();
  }

  void _editExit() {
    _editHoverController.exitEditButton();

    if (!mounted) return;

    setState(() {
      if (!_editHoverController.isInsideEditSystem) {
        hoveredMenu = null;
      }
    });

    _scheduleEditOverlayClose();
  }

  void _dropdownEnter() {
    _editHoverController.enterEditDropdown();

    if (!mounted) return;

    setState(() {
      hoveredMenu = 'Edit';
    });
  }

  void _dropdownExit() {
    _editHoverController.exitEditDropdown();

    if (!mounted) return;

    setState(() {
      if (!_editHoverController.isInsideEditSystem) {
        hoveredMenu = null;
      }
    });

    _scheduleEditOverlayClose();
  }

  void _submenuHoverChanged() {
    if (mounted) {
      setState(() {
        if (_editHoverController.isInsideEditSystem) {
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

        if (!_editHoverController.isInsideEditSystem) {
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
        context.findRenderObject() as RenderBox?;

    if (renderBox == null) return;

    final Offset menuBarPosition =
        renderBox.localToGlobal(Offset.zero);

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
            widget.onCommand?.call(command);
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
    _closeLibraryOverlay();
    _closeHelpOverlay();
    _closeEditOverlay();
    _closePlaceOverlay();
    _closeToolsOverlay();

    _viewHoverController.enterMenu();

    if (!mounted) return;

    setState(() {
      hoveredMenu = 'View';
    });

    _openViewOverlay();
  }

  void _viewExit() {
    _viewHoverController.exitMenu();

    if (!mounted) return;

    setState(() {
      if (!_viewHoverController.isInsideViewSystem) {
        hoveredMenu = null;
      }
    });

    _scheduleViewOverlayClose();
  }

  void _viewDropdownEnter() {
    _viewHoverController.enterDropdown();

    if (!mounted) return;

    setState(() {
      hoveredMenu = 'View';
    });
  }

  void _viewDropdownExit() {
    _viewHoverController.exitDropdown();

    if (!mounted) return;

    setState(() {
      if (!_viewHoverController.isInsideViewSystem) {
        hoveredMenu = null;
      }
    });

    _scheduleViewOverlayClose();
  }

  void _scheduleViewOverlayClose() {
    _viewHoverController.scheduleClose(
      onClose: () {
        if (!mounted) return;

        if (!_viewHoverController.isInsideViewSystem) {
          _closeViewOverlay();
        }
      },
    );
  }

  bool _isViewSettingCommand(String command) {
    return command.startsWith('View: Unit:') ||
        command.startsWith('View: Grid Size:') ||
        command.startsWith('View: Grid Type:') ||
        command.startsWith('View: Highlight Net:');
  }

  void _refreshViewOverlay() {
    _viewOverlay?.markNeedsBuild();

    if (mounted) {
      setState(() {});
    }
  }

  void _viewUnitChanged(ViewUnit unit) {
    _refreshViewOverlay();
  }

  void _viewGridSizeChanged(double inches) {
    _refreshViewOverlay();
  }

  void _viewGridTypeChanged(GridType type) {
    _refreshViewOverlay();
  }

  void _viewHighlightNetChanged(
    HighlightNetMode mode,
  ) {
    _refreshViewOverlay();
  }

  void _openViewOverlay() {
    if (_viewOverlay != null) {
      _viewOverlay!.markNeedsBuild();
      return;
    }

    final RenderBox? renderBox =
        context.findRenderObject() as RenderBox?;

    if (renderBox == null) return;

    final Offset menuBarPosition =
        renderBox.localToGlobal(Offset.zero);

    final OverlayState overlay =
        Overlay.of(context);

    _viewOverlay = OverlayEntry(
      builder: (context) {
        return _ViewDropdownOverlay(
          left: menuBarPosition.dx +
              CustomWindowBar.leftAlignment +
              2,
          top: menuBarPosition.dy + 44,
          controller: _viewHoverController,
          settings: _viewSettings,
          onEnter: _viewDropdownEnter,
          onExit: _viewDropdownExit,
          onUnitChanged: _viewUnitChanged,
          onGridSizeChanged: _viewGridSizeChanged,
          onGridTypeChanged: _viewGridTypeChanged,
          onHighlightNetChanged:
              _viewHighlightNetChanged,
          onCommand: (command) {
            widget.onCommand?.call(command);

            if (!_isViewSettingCommand(command)) {
              _closeViewOverlay();
            }
          },
        );
      },
    );

    overlay.insert(_viewOverlay!);
  }

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
  // PLACE
  // ==========================================================================

  void _placeEnter() {
    _closeLibraryOverlay();
    _closeHelpOverlay();
    _closeEditOverlay();
    _closeViewOverlay();
    _closeToolsOverlay();

    _placeHoverController.enterMenu();

    if (!mounted) return;

    setState(() {
      hoveredMenu = 'Place';
    });

    _openPlaceOverlay();
  }

  void _placeExit() {
    _placeHoverController.exitMenu();

    if (!mounted) return;

    setState(() {
      if (!_placeHoverController.isInsidePlaceSystem) {
        hoveredMenu = null;
      }
    });

    _schedulePlaceOverlayClose();
  }

  void _placeDropdownEnter() {
    _placeHoverController.enterDropdown();

    if (!mounted) return;

    setState(() {
      hoveredMenu = 'Place';
    });
  }

  void _placeDropdownExit() {
    _placeHoverController.exitDropdown();

    if (!mounted) return;

    setState(() {
      if (!_placeHoverController.isInsidePlaceSystem) {
        hoveredMenu = null;
      }
    });

    _schedulePlaceOverlayClose();
  }

  void _placeSubmenuHoverChanged() {
    if (mounted) {
      setState(() {
        if (_placeHoverController.isInsidePlaceSystem) {
          hoveredMenu = 'Place';
        }
      });
    }

    _schedulePlaceOverlayClose();
  }

  void _schedulePlaceOverlayClose() {
    _placeHoverController.scheduleClose(
      onClose: () {
        if (!mounted) return;

        if (!_placeHoverController.isInsidePlaceSystem) {
          _closePlaceOverlay();
        }
      },
    );
  }

  void _openPlaceOverlay() {
    if (_placeOverlay != null) {
      _placeOverlay!.markNeedsBuild();
      return;
    }

    final RenderBox? renderBox =
        context.findRenderObject() as RenderBox?;

    if (renderBox == null) return;

    final Offset menuBarPosition =
        renderBox.localToGlobal(Offset.zero);

    final OverlayState overlay =
        Overlay.of(context);

    _placeOverlay = OverlayEntry(
      builder: (context) {
        return _PlaceDropdownOverlay(
          left: menuBarPosition.dx +
              CustomWindowBar.leftAlignment +
              2,
          top: menuBarPosition.dy + 44,
          controller: _placeHoverController,
          onEnter: _placeDropdownEnter,
          onExit: _placeDropdownExit,
          onSubmenuHoverChanged:
              _placeSubmenuHoverChanged,
          onCommand: (command) {
            widget.onCommand?.call(command);
            _closePlaceOverlay();
          },
        );
      },
    );

    overlay.insert(_placeOverlay!);
  }

  void _closePlaceOverlay() {
    _placeHoverController.cancelClose();

    _placeOverlay?.remove();
    _placeOverlay = null;

    if (mounted) {
      setState(() {
        if (hoveredMenu == 'Place') {
          hoveredMenu = null;
        }
      });
    }

    _placeHoverController.reset();
  }

  // ==========================================================================
  // TOOLS
  // ==========================================================================

  void _toolsEnter() {
    _closeLibraryOverlay();
    _closeHelpOverlay();
    _closeEditOverlay();
    _closeViewOverlay();
    _closePlaceOverlay();

    _toolsHoverController.enterMenu();

    if (!mounted) return;

    setState(() {
      hoveredMenu = 'Tools';
    });

    _openToolsOverlay();
  }

  void _toolsExit() {
    _toolsHoverController.exitMenu();

    if (!mounted) return;

    setState(() {
      if (!_toolsHoverController.isInsideToolsSystem) {
        hoveredMenu = null;
      }
    });

    _scheduleToolsOverlayClose();
  }

  void _toolsDropdownEnter() {
    _toolsHoverController.enterDropdown();

    if (!mounted) return;

    setState(() {
      hoveredMenu = 'Tools';
    });
  }

  void _toolsDropdownExit() {
    _toolsHoverController.exitDropdown();

    if (!mounted) return;

    setState(() {
      if (!_toolsHoverController.isInsideToolsSystem) {
        hoveredMenu = null;
      }
    });

    _scheduleToolsOverlayClose();
  }

  void _scheduleToolsOverlayClose() {
    _toolsHoverController.scheduleClose(
      onClose: () {
        if (!mounted) return;

        if (!_toolsHoverController.isInsideToolsSystem) {
          _closeToolsOverlay();
        }
      },
    );
  }

  void _openToolsOverlay() {
    if (_toolsOverlay != null) {
      _toolsOverlay!.markNeedsBuild();
      return;
    }

    final RenderBox? renderBox =
        context.findRenderObject() as RenderBox?;

    if (renderBox == null) return;

    final Offset menuBarPosition =
        renderBox.localToGlobal(Offset.zero);

    final OverlayState overlay =
        Overlay.of(context);

    _toolsOverlay = OverlayEntry(
      builder: (context) {
        return _ToolsDropdownOverlay(
          left: menuBarPosition.dx +
              CustomWindowBar.leftAlignment +
              2,
          top: menuBarPosition.dy + 44,
          controller: _toolsHoverController,
          onEnter: _toolsDropdownEnter,
          onExit: _toolsDropdownExit,
          onCommand: (command) {
            widget.onCommand?.call(command);
            _closeToolsOverlay();
          },
        );
      },
    );

    overlay.insert(_toolsOverlay!);
  }

  void _closeToolsOverlay() {
    _toolsHoverController.cancelClose();

    _toolsOverlay?.remove();
    _toolsOverlay = null;

    if (mounted) {
      setState(() {
        if (hoveredMenu == 'Tools') {
          hoveredMenu = null;
        }
      });
    }

    _toolsHoverController.reset();
  }

  // ==========================================================================
  // LIBRARY
  // ==========================================================================

  void _libraryEnter() {
    _closeEditOverlay();
    _closeViewOverlay();
    _closePlaceOverlay();
    _closeToolsOverlay();
    _closeHelpOverlay();

    _libraryHoverController.enterLibraryButton();

    if (!mounted) return;

    setState(() {
      hoveredMenu = 'Library';
    });

    _openLibraryOverlay();
  }

  void _libraryExit() {
    _libraryHoverController.exitLibraryButton();
    _scheduleLibraryOverlayClose();
  }

  void _libraryDropdownEnter() {
    _libraryHoverController.enterLibraryDropdown();

    if (!mounted) return;

    setState(() {
      hoveredMenu = 'Library';
    });
  }

  void _libraryDropdownExit() {
    _libraryHoverController.exitLibraryDropdown();
    _scheduleLibraryOverlayClose();
  }

  void _scheduleLibraryOverlayClose() {
    _libraryHoverController.scheduleClose(
      onClose: () {
        if (!mounted) return;

        if (!_libraryHoverController.isInsideLibrarySystem) {
          _closeLibraryOverlay();
        }
      },
    );
  }

  void _openLibraryOverlay() {
    if (_libraryOverlay != null) {
      _libraryOverlay!.markNeedsBuild();
      return;
    }

    final RenderBox? menuBox =
        _libraryMenuKey.currentContext
            ?.findRenderObject() as RenderBox?;

    if (menuBox == null) return;

    final Offset position =
        menuBox.localToGlobal(Offset.zero);

    final OverlayState overlay =
        Overlay.of(context);

    _libraryOverlay = OverlayEntry(
      builder: (context) {
        return _LibraryDropdownOverlay(
          left: position.dx,
          top: position.dy +
              menuBox.size.height +
              2,
          controller:
              _libraryHoverController,
          onEnter:
              _libraryDropdownEnter,
          onExit:
              _libraryDropdownExit,
          onCommand: (command) {
            widget.onCommand?.call(command);
            _closeLibraryOverlay();
          },
        );
      },
    );

    overlay.insert(_libraryOverlay!);
  }

  void _closeLibraryOverlay() {
    _libraryHoverController.cancelClose();

    _libraryOverlay?.remove();
    _libraryOverlay = null;

    if (mounted &&
        hoveredMenu == 'Library') {
      setState(() {
        hoveredMenu = null;
      });
    }

    _libraryHoverController.reset();
  }

  // ==========================================================================
  // HELP
  // ==========================================================================

  void _helpEnter() {
    _closeEditOverlay();
    _closeViewOverlay();
    _closePlaceOverlay();
    _closeToolsOverlay();
    _closeLibraryOverlay();

    _helpHoverController.enterHelpButton();

    if (!mounted) return;

    setState(() {
      hoveredMenu = 'Help';
    });

    _openHelpOverlay();
  }

  void _helpExit() {
    _helpHoverController.exitHelpButton();
    _scheduleHelpOverlayClose();
  }

  void _helpDropdownEnter() {
    _helpHoverController.enterHelpDropdown();

    if (!mounted) return;

    setState(() {
      hoveredMenu = 'Help';
    });
  }

  void _helpDropdownExit() {
    _helpHoverController.exitHelpDropdown();
    _scheduleHelpOverlayClose();
  }

  void _scheduleHelpOverlayClose() {
    _helpHoverController.scheduleClose(
      onClose: () {
        if (!mounted) return;

        if (!_helpHoverController.isInsideHelpSystem) {
          _closeHelpOverlay();
        }
      },
    );
  }

  void _openHelpOverlay() {
    if (_helpOverlay != null) {
      _helpOverlay!.markNeedsBuild();
      return;
    }

    final RenderBox? menuBox =
        _helpMenuKey.currentContext
            ?.findRenderObject() as RenderBox?;

    if (menuBox == null) return;

    final Offset position =
        menuBox.localToGlobal(Offset.zero);

    final OverlayState overlay =
        Overlay.of(context);

    _helpOverlay = OverlayEntry(
      builder: (context) {
        return _HelpDropdownOverlay(
          left: position.dx,
          top: position.dy +
              menuBox.size.height +
              2,
          controller:
              _helpHoverController,
          onEnter:
              _helpDropdownEnter,
          onExit:
              _helpDropdownExit,
          onCommand: (command) {
            widget.onCommand?.call(command);
            _closeHelpOverlay();
          },
        );
      },
    );

    overlay.insert(_helpOverlay!);
  }

  void _closeHelpOverlay() {
    _helpHoverController.cancelClose();

    _helpOverlay?.remove();
    _helpOverlay = null;

    if (mounted &&
        hoveredMenu == 'Help') {
      setState(() {
        hoveredMenu = null;
      });
    }

    _helpHoverController.reset();
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

    if (menu == 'Place') {
      _placeEnter();
      return;
    }

    if (menu == 'Tools') {
      _toolsEnter();
      return;
    }

    if (menu == 'Library') {
      _libraryEnter();
      return;
    }

    if (menu == 'Help') {
      _helpEnter();
      return;
    }

    _closeEditOverlay();
    _closeViewOverlay();
    _closePlaceOverlay();
    _closeToolsOverlay();
    _closeLibraryOverlay();
    _closeHelpOverlay();

    if (!mounted) return;

    setState(() {
      hoveredMenu = menu;
    });
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

    if (menu == 'Place') {
      _placeExit();
      return;
    }

    if (menu == 'Tools') {
      _toolsExit();
      return;
    }

    if (menu == 'Library') {
      _libraryExit();
      return;
    }

    if (menu == 'Help') {
      _helpExit();
      return;
    }

    if (!mounted) return;

    if (hoveredMenu == menu) {
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

    if (menu == 'Place') {
      _openPlaceOverlay();
      return;
    }

    if (menu == 'Tools') {
      _openToolsOverlay();
      return;
    }

    if (menu == 'Library') {
      _openLibraryOverlay();
      return;
    }

    if (menu == 'Help') {
      _openHelpOverlay();
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
    _placeHoverController.dispose();
    _toolsHoverController.dispose();
    _libraryHoverController.dispose();
    _helpHoverController.dispose();

    _editOverlay?.remove();
    _editOverlay = null;

    _viewOverlay?.remove();
    _viewOverlay = null;

    _placeOverlay?.remove();
    _placeOverlay = null;

    _toolsOverlay?.remove();
    _toolsOverlay = null;

    _libraryOverlay?.remove();
    _libraryOverlay = null;

    _helpOverlay?.remove();
    _helpOverlay = null;

    super.dispose();
  }

  // ==========================================================================
  // BUILD
  // ==========================================================================

  @override
  Widget build(BuildContext context) {
    final bool isDark =
        Theme.of(context).brightness ==
            Brightness.dark;

    // ==========================================================
    // MENU BAR THEME
    // ==========================================================

    final Color menuBarBackground = isDark
        ? AppColors.darkBackground
        : const Color(0xFF0E4635);

    final Color menuBarTopBorder = isDark
        ? AppColors.darkBorder
        : const Color(0xFF174F40);

    final Color menuBarBottomBorder = isDark
        ? AppColors.darkBorder
        : AppColors.slateGray;

    return Material(
      color: Colors.transparent,

      child: SizedBox(
        height: 44,

        child: Container(
          decoration: BoxDecoration(
            color: menuBarBackground,

            border: Border(
              top: BorderSide(
                color: menuBarTopBorder,
                width: 1,
              ),

              bottom: BorderSide(
                color: menuBarBottomBorder,
                width: 1,
              ),
            ),
          ),

          child: Stack(
            alignment: Alignment.center,
            clipBehavior: Clip.none,

            children: [

              // =================================================
              // MENU ITEMS
              // =================================================

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
                        key: menu == 'Library'
                            ? _libraryMenuKey
                            : menu == 'Help'
                                ? _helpMenuKey
                                : null,

                        label: menu,

                        active:
                            widget.activeMenu ==
                                menu,

                        hovered:
                            hoveredMenu ==
                                menu,

                        isDark:
                            isDark,

                        onEnter: () =>
                            _menuEnter(menu),

                        onExit: () =>
                            _menuExit(menu),

                        onTap: () =>
                            _menuTap(menu),
                      ),
                  ],
                ),
              ),

              // =================================================
              // FULLSCREEN ARROW
              // =================================================

              Center(
                child: MouseRegion(
                  cursor:
                      SystemMouseCursors.click,

                  onEnter: (_) {
                    if (!mounted) return;

                    setState(() {
                      arrowHovered = true;
                    });
                  },

                  onExit: (_) {
                    if (!mounted) return;

                    setState(() {
                      arrowHovered = false;
                    });
                  },

                  child: GestureDetector(
                    behavior:
                        HitTestBehavior.opaque,

                    onTap:
                        widget
                            .onFullscreenPressed,

                    child:
                        TweenAnimationBuilder<
                            double>(
                      tween:
                          Tween<double>(
                        begin: 0,
                        end:
                            arrowHovered
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
                          offset:
                              Offset(
                            0,
                            -3 * value,
                          ),

                          child:
                              Transform.scale(
                            scale:
                                1 +
                                    (0.07 *
                                        value),

                            child:
                                Container(
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
                                    isDark
                                        ? 0.35
                                        : 0.82,
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
                                    Colors.transparent,
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
                                  isDark
                                      ? AppColors
                                          .darkText
                                      : Colors
                                          .white
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
// LIBRARY DROPDOWN
// ============================================================================

class _LibraryDropdownOverlay
    extends StatelessWidget {
  final double left;
  final double top;
  final LibraryHoverController controller;
  final VoidCallback onEnter;
  final VoidCallback onExit;
  final ValueChanged<String> onCommand;

  const _LibraryDropdownOverlay({
    required this.left,
    required this.top,
    required this.controller,
    required this.onEnter,
    required this.onExit,
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

          child: LibraryMenu(
            controller: controller,
            onCommand: onCommand,
          ),
        ),
      ),
    );
  }
}

// ============================================================================
// HELP DROPDOWN
// ============================================================================

class _HelpDropdownOverlay
    extends StatelessWidget {
  final double left;
  final double top;
  final HelpHoverController controller;
  final VoidCallback onEnter;
  final VoidCallback onExit;
  final ValueChanged<String> onCommand;

  const _HelpDropdownOverlay({
    required this.left,
    required this.top,
    required this.controller,
    required this.onEnter,
    required this.onExit,
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

          child: HelpMenu(
            controller: controller,
            onCommand: onCommand,
          ),
        ),
      ),
    );
  }
}

// ============================================================================
// EDIT DROPDOWN
// ============================================================================

class _EditDropdownOverlay
    extends StatelessWidget {
  final double left;
  final double top;
  final EditHoverController controller;
  final VoidCallback onEnter;
  final VoidCallback onExit;
  final VoidCallback onSubmenuHoverChanged;
  final ValueChanged<String> onCommand;

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
// VIEW DROPDOWN
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

            onCommand: onCommand,
          ),
        ),
      ),
    );
  }
}

// ============================================================================
// PLACE DROPDOWN
// ============================================================================

class _PlaceDropdownOverlay
    extends StatelessWidget {
  final double left;
  final double top;
  final PlaceHoverController controller;
  final VoidCallback onEnter;
  final VoidCallback onExit;
  final VoidCallback onSubmenuHoverChanged;
  final ValueChanged<String> onCommand;

  const _PlaceDropdownOverlay({
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

          child: PlaceMenu(
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
// TOOLS DROPDOWN
// ============================================================================

class _ToolsDropdownOverlay
    extends StatelessWidget {
  final double left;
  final double top;
  final ToolsHoverController controller;
  final VoidCallback onEnter;
  final VoidCallback onExit;
  final ValueChanged<String> onCommand;

  const _ToolsDropdownOverlay({
    required this.left,
    required this.top,
    required this.controller,
    required this.onEnter,
    required this.onExit,
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

          child: ToolsMenu(
            controller: controller,
            onCommand: onCommand,
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
  final bool isDark;

  final VoidCallback onEnter;
  final VoidCallback onExit;
  final VoidCallback onTap;

  const _TopLevelMenuItem({
    super.key,
    required this.label,
    required this.active,
    required this.hovered,
    required this.isDark,
    required this.onEnter,
    required this.onExit,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final bool highlighted =
        active || hovered;

    final Color normalTextColor = isDark
        ? AppColors.darkText
        : Colors.white;

    final Color activeBackground =
        isDark
            ? AppColors.darkSurface
                .withOpacity(0.95)
            : AppColors.slateGray
                .withOpacity(0.68);

    final Color hoverBackground =
        isDark
            ? AppColors.darkSurface
                .withOpacity(0.70)
            : AppColors.slateGray
                .withOpacity(0.34);

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
              const Duration(
            milliseconds: 170,
          ),

          curve:
              Curves.easeOutCubic,

          height: 32,

          margin:
              const EdgeInsets.only(
            right: 3,
          ),

          padding:
              const EdgeInsets.symmetric(
            horizontal: 13,
          ),

          decoration:
              BoxDecoration(
            color: active
                ? activeBackground
                : hovered
                    ? hoverBackground
                    : Colors.transparent,

            borderRadius:
                BorderRadius.circular(5),

            border:
                Border.all(
              color: active
                  ? AppColors.signalOrange
                      .withOpacity(
                      isDark
                          ? 0.65
                          : 0.48,
                    )
                  : Colors.transparent,

              width: 1,
            ),

            boxShadow:
                hovered
                    ? [
                        BoxShadow(
                          color: AppColors
                              .signalOrange
                              .withOpacity(
                            isDark
                                ? 0.12
                                : 0.08,
                          ),

                          blurRadius: 9,
                        ),
                      ]
                    : null,
          ),

          child: Stack(
            alignment:
                Alignment.center,

            children: [

              // =================================================
              // MENU TEXT
              // =================================================

              Padding(
                padding:
                    const EdgeInsets.only(
                  bottom: 3,
                ),

                child: Text(
                  label,

                  style: TextStyle(
                    color:
                        normalTextColor,

                    fontSize: 13.5,

                    fontWeight:
                        active
                            ? FontWeight.w600
                            : FontWeight.w500,

                    height: 1,
                  ),
                ),
              ),

              // =================================================
              // ORANGE UNDERLINE
              // =================================================

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
                    end:
                        highlighted
                            ? 1
                            : 0,
                  ),

                  duration:
                      const Duration(
                    milliseconds: 200,
                  ),

                  curve:
                      Curves.easeOutCubic,

                  builder: (
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
                          color: AppColors
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
