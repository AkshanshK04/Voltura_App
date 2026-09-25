import 'package:flutter/material.dart';
import 'package:window_manager/window_manager.dart';

import '../theme/app_colors.dart';
import 'window_button.dart';

class CustomWindowBar extends StatelessWidget {
  const CustomWindowBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
      color: AppColors.pcbBackground,

      child: Row(
        children: [
          // Logo
          const SizedBox(width: 14),

          Image.asset(
            'assets/images/voltura_logo.png',
            width: 30,
            height: 30,
            fit: BoxFit.contain,
          ),

          const Spacer(),

          // Minimize
          WindowButton(
            icon: Icons.remove,
            onPressed: () async {
              await windowManager.minimize();
            },
          ),

          const SizedBox(width: 10),

          // Maximize
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

          // Close
          WindowButton(
            icon: Icons.close,
            isClose: true,
            onPressed: () async {
              await windowManager.close();
            },
          ),

          const SizedBox(width: 10),
        ],
      ),
    );
  }
}
