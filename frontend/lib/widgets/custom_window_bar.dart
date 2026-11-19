import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:window_manager/window_manager.dart';

import '../theme/app_colors.dart';
import 'theme_toggle_button.dart';
import 'window_button.dart';

class CustomWindowBar extends StatefulWidget {
  static const double leftAlignment = 14.0;

  const CustomWindowBar({
    super.key,
  });

  @override
  State<CustomWindowBar> createState() =>
      _CustomWindowBarState();
}

class _CustomWindowBarState
    extends State<CustomWindowBar> {
  bool searchFocused = false;
  bool searchHovered = false;

  @override
  Widget build(BuildContext context) {
    final bool isWeb = kIsWeb;

    final bool isDark =
        Theme.of(context).brightness ==
            Brightness.dark;

    // ==========================================================
    // THEME COLORS
    // ==========================================================

    // ----------------------------------------------------------
    // TOP BAR
    // ----------------------------------------------------------

    final Color backgroundColor = isDark
        ? AppColors.darkBackground
        : AppColors.pcbBackground;

    // ----------------------------------------------------------
    // SEARCH BAR
    // ----------------------------------------------------------
    // Translucent glassmorphic search bar for increased transparency.

    final Color searchBackground =
        Colors.white.withOpacity(0.12);

    final Color searchFocusedBackground =
        Colors.white.withOpacity(0.20);

    final Color searchBorder =
        Colors.white.withOpacity(0.20);

    final Color searchHoveredBorder =
        Colors.white.withOpacity(0.40);

    final Color searchText =
        Colors.white;

    final Color searchHint =
        Colors.white.withOpacity(0.65);

    final Color searchIcon =
        Colors.white.withOpacity(0.70);

    return Container(
      height: 50,
      color: backgroundColor,

      child: Row(
        children: [

          // =====================================================
          // LEFT PADDING
          // =====================================================

          const SizedBox(
            width: CustomWindowBar.leftAlignment,
          ),

          // =====================================================
          // VOLTURA LOGO
          // =====================================================

          AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            child: SizedBox(
              key: ValueKey<bool>(isDark),
              height: 28,
              child: Image.asset(
                isDark
                    ? 'assets/images/voltura_logo_dark.png'
                    : 'assets/images/voltura_logo.png',
                fit: BoxFit.contain,
                filterQuality: FilterQuality.medium,
              ),
            ),
          ),

          const SizedBox(width: 12),

          // =====================================================
          // SAVE
          // =====================================================

          _TopBarAction(
            icon: Icons.save_rounded,
            tooltip: 'Save',
            onPressed: () {},
            isDark: isDark,
          ),

          const SizedBox(width: 4),

          // =====================================================
          // UNDO
          // =====================================================

          _TopBarAction(
            icon: Icons.undo_rounded,
            tooltip: 'Undo',
            onPressed: () {},
            isDark: isDark,
          ),

          const SizedBox(width: 4),

          // =====================================================
          // REDO
          // =====================================================

          _TopBarAction(
            icon: Icons.redo_rounded,
            tooltip: 'Redo',
            onPressed: () {},
            isDark: isDark,
          ),

          // =====================================================
          // GAP BETWEEN ACTIONS AND SEARCH
          // =====================================================

          const SizedBox(width: 40),

          // =====================================================
          // SEARCH
          // =====================================================

          MouseRegion(
            cursor:
                SystemMouseCursors.text,

            onEnter: (_) {
              setState(() {
                searchHovered = true;
              });
            },

            onExit: (_) {
              setState(() {
                searchHovered = false;
              });
            },

            child: AnimatedContainer(
              duration:
                  const Duration(
                milliseconds: 220,
              ),

              curve:
                  Curves.easeOutCubic,

              width:
                  searchFocused ||
                          searchHovered
                      ? 330
                      : 290,

              height: 32,

              decoration:
                  BoxDecoration(
                // WHITE IN BOTH LIGHT AND DARK
                color:
                    searchFocused ||
                            searchHovered
                        ? searchFocusedBackground
                        : searchBackground,

                borderRadius:
                    BorderRadius.circular(8),

                border:
                    Border.all(
                  color:
                      searchFocused
                          ? AppColors.signalOrange
                          : searchHovered
                              ? searchHoveredBorder
                              : searchBorder,

                  width:
                      searchFocused
                          ? 1.3
                          : 1,
                ),

                boxShadow:
                    searchFocused
                        ? [
                            BoxShadow(
                              color: AppColors
                                  .signalOrange
                                  .withOpacity(
                                isDark
                                    ? 0.12
                                    : 0.15,
                              ),

                              blurRadius: 11,

                              offset:
                                  const Offset(
                                0,
                                2,
                              ),
                            ),
                          ]
                        : [],
              ),

              child:
                  TextField(
                textAlign:
                    TextAlign.center,

                textAlignVertical:
                    TextAlignVertical.center,

                onTap: () {
                  setState(() {
                    searchFocused =
                        true;
                  });
                },

                onTapOutside: (_) {
                  setState(() {
                    searchFocused =
                        false;
                  });
                },

                cursorColor:
                    AppColors.signalOrange,

                style: TextStyle(
                  color: searchText,
                  fontSize: 13,
                ),

                decoration:
                    InputDecoration(
                  isDense: true,

                  hintText:
                      'Schematic, Components...',

                  hintStyle:
                      TextStyle(
                    color: searchHint,
                    fontSize: 12.5,
                  ),

                  prefixIconConstraints:
                      const BoxConstraints(
                    minWidth: 36,
                    minHeight: 32,
                  ),

                  prefixIcon:
                      Icon(
                    Icons.search_rounded,

                    size: 18,

                    color:
                        searchFocused
                            ? AppColors
                                .signalOrange
                            : searchIcon,
                  ),

                  suffixIconConstraints:
                      const BoxConstraints(
                    minWidth: 36,
                    minHeight: 32,
                  ),

                  suffixIcon:
                      const SizedBox(
                    width: 36,
                    height: 32,
                  ),

                  border:
                      InputBorder.none,

                  contentPadding:
                      const EdgeInsets
                          .symmetric(
                    vertical: 6,
                    horizontal: 0,
                  ),
                ),
              ),
            ),
          ),

          // =====================================================
          // FLEXIBLE SPACE
          // =====================================================

          const Spacer(),


          // ---------------------------------------------------
            // THEME TOGGLE
            // ---------------------------------------------------

            const ThemeToggleButton(),

            const SizedBox(width: 10),
          // =====================================================
          // WINDOWS-ONLY CONTROLS
          // =====================================================

          if (!isWeb) ...[

            

            // ---------------------------------------------------
            // MINIMIZE
            // ---------------------------------------------------

            WindowButton(
              icon: Icons.remove,

              onPressed: () async {
                await windowManager.minimize();
              },
            ),

            const SizedBox(width: 10),

            // ---------------------------------------------------
            // MAXIMIZE / RESTORE
            // ---------------------------------------------------

            WindowButton(
              icon: Icons.crop_square,

              onPressed: () async {
                if (await windowManager
                    .isMaximized()) {
                  await windowManager
                      .restore();
                } else {
                  await windowManager
                      .maximize();
                }
              },
            ),

            const SizedBox(width: 10),

            // ---------------------------------------------------
            // CLOSE
            // ---------------------------------------------------

            WindowButton(
              icon: Icons.close,

              isClose: true,

              onPressed: () async {
                await windowManager.close();
              },
            ),

            const SizedBox(width: 10),
          ],
        ],
      ),
    );
  }
}


// ============================================================================
// TOP BAR ACTION
// ============================================================================

class _TopBarAction extends StatefulWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback onPressed;
  final bool isDark;

  const _TopBarAction({
    required this.icon,
    required this.tooltip,
    required this.onPressed,
    required this.isDark,
  });

  @override
  State<_TopBarAction> createState() =>
      _TopBarActionState();
}

class _TopBarActionState
    extends State<_TopBarAction> {
  bool hovered = false;
  bool pressed = false;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: widget.tooltip,

      waitDuration:
          const Duration(
        milliseconds: 400,
      ),

      child: MouseRegion(
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
          });
        },

        child: GestureDetector(
          onTapDown: (_) {
            setState(() {
              pressed = true;
            });
          },

          onTapUp: (_) {
            setState(() {
              pressed = false;
            });

            widget.onPressed();
          },

          onTapCancel: () {
            setState(() {
              pressed = false;
            });
          },

          child: AnimatedContainer(
            duration:
                const Duration(
              milliseconds: 150,
            ),

            curve:
                Curves.easeOutCubic,

            width: 34,
            height: 34,

            transform:
                Matrix4.translationValues(
              0,

              pressed
                  ? 1
                  : hovered
                      ? -1
                      : 0,

              0,
            ),

            decoration:
                BoxDecoration(
              color: hovered
                  ? AppColors.slateGray
                      .withOpacity(
                      widget.isDark
                          ? 0.20
                          : 0.30,
                    )
                  : Colors.transparent,

              borderRadius:
                  BorderRadius.circular(6),

              border:
                  Border.all(
                color: hovered
                    ? AppColors
                        .slateGray
                        .withOpacity(
                        widget.isDark
                            ? 0.35
                            : 0.45,
                      )
                    : Colors.transparent,

                width: 1,
              ),
            ),

            child: Center(
              child: AnimatedScale(
                duration:
                    const Duration(
                  milliseconds: 140,
                ),

                scale:
                    hovered ? 1.08 : 1.0,

                child: Icon(
                  widget.icon,

                  size: 20,

                  color: hovered
                      ? AppColors
                          .signalOrange
                      : widget.isDark
                          ? AppColors
                              .darkText
                          : const Color(
                              0xFFD9DDE0,
                            ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

