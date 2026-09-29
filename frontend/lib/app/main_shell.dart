import 'package:flutter/material.dart';

import '../screens/file_screen.dart';
import '../screens/schematic_main_screen.dart';
import '../theme/app_colors.dart';
import '../widgets/custom_window_bar.dart';
import '../widgets/file_window_bar.dart';
import '../widgets/menu_bar.dart';
import 'app_router.dart';

class MainShell extends StatefulWidget {
const MainShell({super.key});

@override
State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
static const double windowBarHeight = 50;
static const double menuBarHeight = 44;

bool _schematicFullscreen = false;

void _enterSchematicFullscreen() {
if (!mounted) return;

 
setState(() {
  _schematicFullscreen = true;
});
 

}

void _exitSchematicFullscreen() {
if (!mounted) return;

 
setState(() {
  _schematicFullscreen = false;
});
 

}

void _handleMenu(String menu) {
if (menu == 'File') {
_exitSchematicFullscreen();
AppRouter.instance.goToFile();
}
}

void _handleCommand(String command) {
if (command == 'Full Screen') {
_enterSchematicFullscreen();
}
}

@override
Widget build(BuildContext context) {
final router = AppRouter.instance;

 
return AnimatedBuilder(
  animation: router,
  builder: (context, child) {
    final bool isSchematic =
        router.currentScreen == AppScreen.schematic;

    final bool isFile =
        router.currentScreen == AppScreen.file;

    final bool isDark =
        Theme.of(context).brightness == Brightness.dark;

    final Color background = isDark
        ? AppColors.darkBackground
        : AppColors.pcbBackground;

    final Color borderColor = isDark
        ? AppColors.darkBorder
        : AppColors.slateGray;

    // ================================================================
    // SCHEMATIC FULLSCREEN
    // ================================================================

    if (_schematicFullscreen && isSchematic) {
      return Scaffold(
        backgroundColor: background,
        body: Stack(
          fit: StackFit.expand,
          children: [
            const SchematicScreen(),

            Positioned(
              top: 6,
              right: 8,
              child: _FullscreenExitButton(
                onPressed: _exitSchematicFullscreen,
              ),
            ),
          ],
        ),
      );
    }

    // ================================================================
    // NORMAL APPLICATION SHELL
    // ================================================================

    return Scaffold(
      backgroundColor: background,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          border: Border(
            left: BorderSide(
              color: borderColor,
              width: 2,
            ),
            right: BorderSide(
              color: borderColor,
              width: 2,
            ),
            bottom: BorderSide(
              color: borderColor,
              width: 2,
            ),
          ),
        ),
        child: Column(
          children: [
            SizedBox(
              height: windowBarHeight,
              child: isFile
                  ? const FileWindowBar()
                  : const CustomWindowBar(),
            ),

            if (!isFile)
              SizedBox(
                height: menuBarHeight,
                child: MenuBarWidget(
                  activeMenu: null,
                  onMenuChanged: _handleMenu,
                  onCommand: _handleCommand,
                  onFullscreenPressed:
                      _enterSchematicFullscreen,
                ),
              ),

            Expanded(
              child: AnimatedSwitcher(
                duration: const Duration(
                  milliseconds: 220,
                ),
                switchInCurve: Curves.easeOutCubic,
                switchOutCurve: Curves.easeInCubic,
                transitionBuilder:
                    (child, animation) {
                  return FadeTransition(
                    opacity: animation,
                    child: child,
                  );
                },
                child: _buildScreen(
                  router.currentScreen,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  },
);
 

}

Widget _buildScreen(AppScreen screen) {
switch (screen) {
case AppScreen.schematic:
return const SchematicScreen(
key: ValueKey('schematic-screen'),
);

 
  case AppScreen.file:
    return const FileScreen(
      key: ValueKey('file-screen'),
    );
}
 

}
}

// ============================================================================
// FULLSCREEN EXIT BUTTON
// ============================================================================

class _FullscreenExitButton extends StatefulWidget {
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
bool _hovered = false;
bool _pressed = false;

@override
Widget build(BuildContext context) {
final bool isDark =
Theme.of(context).brightness == Brightness.dark;

 
return MouseRegion(
  cursor: SystemMouseCursors.click,
  onEnter: (_) {
    setState(() {
      _hovered = true;
    });
  },
  onExit: (_) {
    setState(() {
      _hovered = false;
      _pressed = false;
    });
  },
  child: GestureDetector(
    onTapDown: (_) {
      setState(() {
        _pressed = true;
      });
    },
    onTapUp: (_) {
      setState(() {
        _pressed = false;
      });

      widget.onPressed();
    },
    onTapCancel: () {
      setState(() {
        _pressed = false;
      });
    },
    child: AnimatedScale(
      duration: const Duration(
        milliseconds: 160,
      ),
      curve: Curves.easeOutCubic,
      scale: _pressed
          ? 0.92
          : _hovered
              ? 1.06
              : 1.0,
      child: AnimatedContainer(
        duration: const Duration(
          milliseconds: 180,
        ),
        curve: Curves.easeOutCubic,
        width: _hovered ? 34 : 32,
        height: _hovered ? 34 : 32,
        decoration: BoxDecoration(
          color: _hovered
              ? AppColors.signalOrange.withOpacity(
                  isDark ? 0.22 : 0.90,
                )
              : isDark
                  ? AppColors.darkSurface.withOpacity(0.94)
                  : AppColors.pcbBackground
                      .withOpacity(0.94),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: _hovered
                ? AppColors.signalOrange
                : isDark
                    ? AppColors.darkBorder
                    : AppColors.slateGray,
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(
                isDark ? 0.40 : 0.20,
              ),
              blurRadius: 14,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: AnimatedScale(
          duration: const Duration(
            milliseconds: 160,
          ),
          scale: _pressed ? 0.88 : 1.0,
          child: Icon(
            Icons.fullscreen_exit_rounded,
            size: 20,
            color: _hovered
                ? Colors.white
                : AppColors.signalOrange,
          ),
        ),
      ),
    ),
  ),
);
 

}
}
