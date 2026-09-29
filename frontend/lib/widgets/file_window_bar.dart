import 'package:flutter/material.dart';
import 'package:window_manager/window_manager.dart';

import 'window_button.dart';

class FileWindowBar extends StatelessWidget {
  const FileWindowBar({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 50,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          WindowButton(
            icon: Icons.remove_rounded,
            onPressed: () {
              windowManager.minimize();
            },
          ),

          const SizedBox(width: 6),

          WindowButton(
            icon: Icons.crop_square_rounded,
            onPressed: () async {
              final bool maximized =
                  await windowManager.isMaximized();

              if (maximized) {
                await windowManager.unmaximize();
              } else {
                await windowManager.maximize();
              }
            },
          ),

          const SizedBox(width: 6),

          WindowButton(
            icon: Icons.close_rounded,
            isClose: true,
            onPressed: () {
              windowManager.close();
            },
          ),

          const SizedBox(width: 8),
        ],
      ),
    );
  }
}