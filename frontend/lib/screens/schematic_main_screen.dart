import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../widgets/schematic_sheet.dart';

class SchematicScreen extends StatefulWidget {
const SchematicScreen({
super.key,
});

@override
SchematicScreenState createState() =>
SchematicScreenState();
}

class SchematicScreenState extends State<SchematicScreen> {
bool schematicFullscreen = false;

void enterFullscreen() {
if (!mounted) return;

 
setState(() {
  schematicFullscreen = true;
});
 

}

void exitFullscreen() {
if (!mounted) return;

 
setState(() {
  schematicFullscreen = false;
});
 

}

@override
Widget build(BuildContext context) {
final bool isDark =
Theme.of(context).brightness == Brightness.dark;

 
final Color background = isDark
    ? AppColors.darkBackground
    : AppColors.pcbBackground;

return Container(
  color: background,
  child: AnimatedSwitcher(
    duration: const Duration(
      milliseconds: 300,
    ),
    switchInCurve: Curves.easeOutCubic,
    switchOutCurve: Curves.easeInCubic,
    layoutBuilder: (
      Widget? currentChild,
      List<Widget> previousChildren,
    ) {
      return Stack(
        alignment: Alignment.center,
        children: [
          ...previousChildren,
          if (currentChild != null)
            currentChild,
        ],
      );
    },
    transitionBuilder: (
      Widget child,
      Animation<double> animation,
    ) {
      return FadeTransition(
        opacity: animation,
        child: ScaleTransition(
          scale: Tween<double>(
            begin: 0.985,
            end: 1.0,
          ).animate(
            CurvedAnimation(
              parent: animation,
              curve: Curves.easeOutCubic,
            ),
          ),
          child: child,
        ),
      );
    },
    child: schematicFullscreen
        ? _FullscreenSchematic(
            key: const ValueKey(
              'fullscreen-schematic',
            ),
            onExit: exitFullscreen,
          )
        : const _NormalSchematic(
            key: ValueKey(
              'normal-schematic',
            ),
          ),
  ),
);
 

}
}

class _NormalSchematic extends StatelessWidget {
const _NormalSchematic({
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

class _FullscreenSchematic extends StatelessWidget {
final VoidCallback onExit;

const _FullscreenSchematic({
super.key,
required this.onExit,
});

@override
Widget build(BuildContext context) {
return Stack(
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
);
 

}
}

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
bool hovered = false;
bool pressed = false;

@override
Widget build(BuildContext context) {
final bool isDark =
Theme.of(context).brightness == Brightness.dark;

 
final Color normalBackground = isDark
    ? AppColors.darkSurface
    : Colors.white.withOpacity(0.95);

final Color normalBorder = isDark
    ? AppColors.darkBorder
    : const Color(0xFFD0D0D0);

final Color normalIcon = isDark
    ? AppColors.darkText
    : const Color(0xFF555555);

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

      widget.onPressed();
    },

    onTapCancel: () {
      setState(() {
        pressed = false;
      });
    },

    child: AnimatedScale(
      duration: const Duration(
        milliseconds: 140,
      ),
      curve: Curves.easeOutCubic,
      scale: pressed
          ? 0.92
          : hovered
              ? 1.06
              : 1.0,
      child: AnimatedContainer(
        duration: const Duration(
          milliseconds: 180,
        ),
        curve: Curves.easeOutCubic,

        width: hovered ? 42 : 36,
        height: hovered ? 30 : 26,

        decoration: BoxDecoration(
          color: hovered
              ? AppColors.slateGray.withOpacity(
                  0.96,
                )
              : normalBackground,

          borderRadius:
              BorderRadius.circular(7),

          border: Border.all(
            color: hovered
                ? AppColors.signalOrange
                : normalBorder,
            width: hovered ? 1.2 : 1,
          ),

          boxShadow: [
            BoxShadow(
              color: hovered
                  ? AppColors.signalOrange
                      .withOpacity(0.20)
                  : Colors.black
                      .withOpacity(0.14),
              blurRadius: hovered ? 12 : 7,
              offset: const Offset(0, 3),
            ),
          ],
        ),

        child: AnimatedScale(
          duration: const Duration(
            milliseconds: 140,
          ),
          curve: Curves.easeOutBack,
          scale: hovered ? 1.08 : 1.0,

          child: Icon(
            Icons.keyboard_arrow_down_rounded,
            size: 21,
            color: hovered
                ? Colors.white
                : normalIcon,
          ),
        ),
      ),
    ),
  ),
);
 

}
}