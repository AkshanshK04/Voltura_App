import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:window_manager/window_manager.dart';

import '../theme/app_colors.dart';
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

    return Container(
      height: 50,
      color: AppColors.pcbBackground,
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

          SizedBox(
            width: 30,
            height: 30,
            child: Image.asset(
              'assets/images/voltura_logo.png',
              fit: BoxFit.contain,
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
          ),

          const SizedBox(width: 4),

          // =====================================================
          // UNDO
          // =====================================================

          _TopBarAction(
            icon: Icons.undo_rounded,
            tooltip: 'Undo',
            onPressed: () {},
          ),

          const SizedBox(width: 4),

          // =====================================================
          // REDO
          // =====================================================

          _TopBarAction(
            icon: Icons.redo_rounded,
            tooltip: 'Redo',
            onPressed: () {},
          ),

          // =====================================================
          // GAP BETWEEN ACTIONS AND SEARCH
          // =====================================================

          const SizedBox(width: 40),

          // =====================================================
          // SEARCH
          // =====================================================

          MouseRegion(
            cursor: SystemMouseCursors.text,
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
              duration: const Duration(
                milliseconds: 220,
              ),
              curve: Curves.easeOutCubic,
              width: searchFocused || searchHovered
                  ? 330
                  : 290,
              height: 32,
              decoration: BoxDecoration(
                color: searchFocused || searchHovered
                    ? const Color(0xFFF9FAFB)
                    : const Color(0xFFF1F3F4),
                borderRadius:
                    BorderRadius.circular(8),
                border: Border.all(
                  color: searchFocused
                      ? AppColors.signalOrange
                      : searchHovered
                          ? AppColors.slateGray
                              .withOpacity(0.75)
                          : const Color(0xFFCBD0D4),
                  width: searchFocused ? 1.3 : 1,
                ),
                boxShadow: searchFocused
                    ? [
                        BoxShadow(
                          color: AppColors.signalOrange
                              .withOpacity(0.15),
                          blurRadius: 11,
                          offset:
                              const Offset(0, 2),
                        ),
                      ]
                    : [],
              ),
              child: TextField(
                onTap: () {
                  setState(() {
                    searchFocused = true;
                  });
                },
                onTapOutside: (_) {
                  setState(() {
                    searchFocused = false;
                  });
                },
                cursorColor:
                    AppColors.signalOrange,
                style: const TextStyle(
                  color: Color(0xFF30343A),
                  fontSize: 13,
                ),
                decoration: InputDecoration(
                  hintText:
                      'Search schematic, components...',
                  hintStyle: const TextStyle(
                    color: Color(0xFF858B91),
                    fontSize: 12.5,
                  ),
                  prefixIcon: Icon(
                    Icons.search_rounded,
                    size: 19,
                    color: searchFocused
                        ? AppColors.signalOrange
                        : const Color(0xFF697078),
                  ),
                  border: InputBorder.none,
                  contentPadding:
                      const EdgeInsets.symmetric(
                    vertical: 7,
                    horizontal: 4,
                  ),
                ),
              ),
            ),
          ),

          // =====================================================
          // FLEXIBLE SPACE
          // =====================================================

          const Spacer(),

          // =====================================================
          // WINDOWS-ONLY CONTROLS
          //
          // Chrome/browser already has its own window controls.
          // Therefore these must NOT appear on Web.
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
                if (await windowManager.isMaximized()) {
                  await windowManager.restore();
                } else {
                  await windowManager.maximize();
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

  const _TopBarAction({
    required this.icon,
    required this.tooltip,
    required this.onPressed,
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
          const Duration(milliseconds: 400),
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
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
                const Duration(milliseconds: 150),
            curve: Curves.easeOutCubic,
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
                      .withOpacity(0.30)
                  : Colors.transparent,
              borderRadius:
                  BorderRadius.circular(6),
              border: Border.all(
                color: hovered
                    ? AppColors.slateGray
                        .withOpacity(0.45)
                    : Colors.transparent,
                width: 1,
              ),
            ),
            child: Center(
              child: AnimatedScale(
                duration:
                    const Duration(milliseconds: 140),
                scale: hovered ? 1.08 : 1.0,
                child: Icon(
                  widget.icon,
                  size: 20,
                  color: hovered
                      ? AppColors.signalOrange
                      : const Color(0xFFD9DDE0),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
