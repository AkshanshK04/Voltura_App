import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class MenuBarWidget extends StatefulWidget {
  final ValueChanged<String>? onMenuChanged;

  const MenuBarWidget({
    super.key,
    this.onMenuChanged,
  });

  static const List<String> menuItems = [
    'File',
    'Edit',
    'View',
    'Place',
    'Design',
    'Layout',
    'Tools',
    'Export',
    'Advanced',
    'Settings',
    'Help',
  ];

  @override
  State<MenuBarWidget> createState() => _MenuBarWidgetState();
}

class _MenuBarWidgetState extends State<MenuBarWidget> {
  String? hoveredItem;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 49,
      decoration: BoxDecoration(
        color: Colors.transparent,
        border: Border(
          bottom: BorderSide(
            color: Colors.black.withOpacity(0.18),
            width: 2,
          ),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(width: 14),

          for (final item in MenuBarWidget.menuItems)
            _MenuItem(
              label: item,
              isHovered: hoveredItem == item,
              onHover: (value) {
                setState(() {
                  hoveredItem = value ? item : null;
                });
              },
              onTap: () {
                if (item == 'File') {
                  widget.onMenuChanged?.call('File');
                } else {
                  widget.onMenuChanged?.call(item);
                }
              },
            ),
        ],
      ),
    );
  }
}

class _MenuItem extends StatefulWidget {
  final String label;
  final bool isHovered;
  final ValueChanged<bool> onHover;
  final VoidCallback onTap;

  const _MenuItem({
    required this.label,
    required this.isHovered,
    required this.onHover,
    required this.onTap,
  });

  @override
  State<_MenuItem> createState() => _MenuItemState();
}

class _MenuItemState extends State<_MenuItem> {
  bool isPressed = false;

  @override
  Widget build(BuildContext context) {
    final bool active = widget.isHovered || isPressed;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => widget.onHover(true),
      onExit: (_) {
        widget.onHover(false);
        setState(() {
          isPressed = false;
        });
      },
      child: GestureDetector(
        onTapDown: (_) {
          setState(() {
            isPressed = true;
          });
        },
        onTapUp: (_) {
          setState(() {
            isPressed = false;
          });
          widget.onTap();
        },
        onTapCancel: () {
          setState(() {
            isPressed = false;
          });
        },
        child: AnimatedScale(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOutBack,
          scale: isPressed
              ? 0.96
              : widget.isHovered
                  ? 1.025
                  : 1.0,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            curve: Curves.easeOutCubic,
            margin: const EdgeInsets.symmetric(
              horizontal: 2,
              vertical: 5,
            ),
            padding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 5,
            ),
            decoration: BoxDecoration(
              color: active
                  ? AppColors.signalOrange.withOpacity(0.075)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(9),
              border: Border.all(
                color: active
                    ? AppColors.signalOrange.withOpacity(0.14)
                    : Colors.transparent,
                width: 0.7,
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                AnimatedDefaultTextStyle(
                  duration: const Duration(milliseconds: 160),
                  curve: Curves.easeOutCubic,
                  style: TextStyle(
                    fontSize: 15,
                    height: 1.1,
                    fontWeight: active
                        ? FontWeight.w600
                        : FontWeight.w500,
                    color: AppColors.signalOrange,
                  ),
                  child: Text(widget.label),
                ),

                const SizedBox(height: 2),

                // Orange animated underline.
                ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 240),
                    curve: Curves.easeOutCubic,
                    width: widget.isHovered ? 20 : 0,
                    height: 2,
                    color: AppColors.signalOrange,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
