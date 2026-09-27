import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../widgets/custom_window_bar.dart';
import '../widgets/file_backstage_view.dart';
import '../widgets/menu_bar.dart';
import '../widgets/schematic_sheet.dart';

class SchematicMainScreen extends StatefulWidget {
  const SchematicMainScreen({super.key});

  @override
  State<SchematicMainScreen> createState() =>
      _SchematicMainScreenState();
}

class _SchematicMainScreenState
    extends State<SchematicMainScreen> {
  bool fileViewOpen = false;
  bool schematicFullscreen = false;

  String? activeMenu;

  static const double windowBarHeight = 50;
  static const double menuBarHeight = 44;

  void _onMenuChanged(String menu) {
    if (!mounted) return;

    if (menu.isEmpty) {
      setState(() {
        activeMenu = null;
        fileViewOpen = false;
      });
      return;
    }

    if (menu == 'File') {
      setState(() {
        activeMenu = 'File';
        fileViewOpen = true;
      });
      return;
    }

    setState(() {
      activeMenu = menu;
      fileViewOpen = false;
    });
  }

  void _closeFileView() {
    if (!mounted) return;

    setState(() {
      fileViewOpen = false;
      activeMenu = null;
    });
  }

  void _enterSchematicFullscreen() {
    if (!mounted) return;

    setState(() {
      schematicFullscreen = true;
      fileViewOpen = false;
      activeMenu = null;
    });
  }

  void _exitSchematicFullscreen() {
    if (!mounted) return;

    setState(() {
      schematicFullscreen = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final showChrome = !schematicFullscreen;

    return Scaffold(
      backgroundColor: AppColors.pcbBackground,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          border: Border(
            left: BorderSide(
              color: Color(0xFF708090),
              width: 2,
            ),
            right: BorderSide(
              color: Color(0xFF708090),
              width: 2,
            ),
            bottom: BorderSide(
              color: Color(0xFF708090),
              width: 2,
            ),
          ),
        ),
        child: Column(
          children: [
            if (showChrome)
              const SizedBox(
                height: windowBarHeight,
                child: CustomWindowBar(),
              ),

            if (showChrome)
              SizedBox(
                height: menuBarHeight,
                child: MenuBarWidget(
                  activeMenu: activeMenu,
                  onMenuChanged: _onMenuChanged,
                  onFullscreenPressed:
                      _enterSchematicFullscreen,
                ),
              ),

            Expanded(
              child: ClipRect(
                child: AnimatedSwitcher(
                  duration: const Duration(
                    milliseconds: 200,
                  ),
                  switchInCurve:
                      Curves.easeOutCubic,
                  switchOutCurve:
                      Curves.easeInCubic,
                  transitionBuilder:
                      (child, animation) {
                    return FadeTransition(
                      opacity: animation,
                      child: child,
                    );
                  },
                  child: _buildMainContent(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMainContent() {
    if (schematicFullscreen) {
      return _FullscreenSchematic(
        key: const ValueKey(
          'fullscreen-schematic',
        ),
        onExit: _exitSchematicFullscreen,
      );
    }

    if (fileViewOpen) {
      return FileBackstageView(
        key: const ValueKey('file'),
        onBack: _closeFileView,
      );
    }

    return const _SchematicContent(
      key: ValueKey('schematic'),
    );
  }
}

class _SchematicContent extends StatelessWidget {
  const _SchematicContent({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return const ClipRect(
      child: SizedBox.expand(
        child: SchematicSheet(),
      ),
    );
  }
}

class _FullscreenSchematic
    extends StatelessWidget {
  final VoidCallback onExit;

  const _FullscreenSchematic({
    super.key,
    required this.onExit,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox.expand(
      child: Stack(
        fit: StackFit.expand,
        children: [
          const SchematicSheet(),

          Positioned(
            top: 8,
            left: 0,
            right: 0,
            child: Center(
              child: _FullscreenExitButton(
                onPressed: onExit,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FullscreenExitButton
    extends StatefulWidget {
  final VoidCallback onPressed;

  const _FullscreenExitButton({
    required this.onPressed,
  });

  @override
  State<_FullscreenExitButton> createState() =>
      _FullscreenExitButtonState();
}

class _FullscreenExitButtonState
    extends State<_FullscreenExitButton> {
  bool hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) {
        setState(() => hovered = true);
      },
      onExit: (_) {
        setState(() => hovered = false);
      },
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: widget.onPressed,
        child: AnimatedContainer(
          duration: const Duration(
            milliseconds: 160,
          ),
          curve: Curves.easeOutCubic,
          width: hovered ? 42 : 36,
          height: hovered ? 30 : 26,
          decoration: BoxDecoration(
            color: hovered
                ? AppColors.slateGray
                    .withOpacity(0.96)
                : Colors.white.withOpacity(0.95),
            borderRadius:
                BorderRadius.circular(7),
            border: Border.all(
              color: hovered
                  ? AppColors.signalOrange
                  : const Color(0xFFD0D0D0),
              width: hovered ? 1.2 : 1,
            ),
            boxShadow: [
              BoxShadow(
                color: hovered
                    ? AppColors.signalOrange
                        .withOpacity(0.20)
                    : Colors.black.withOpacity(0.14),
                blurRadius: hovered ? 12 : 7,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: AnimatedScale(
            duration: const Duration(
              milliseconds: 140,
            ),
            scale: hovered ? 1.08 : 1,
            child: Icon(
              Icons.keyboard_arrow_down,
              size: 21,
              color: hovered
                  ? Colors.white
                  : const Color(0xFF555555),
            ),
          ),
        ),
      ),
    );
  }
}
