import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import '../theme/theme_controller.dart';
import 'main_shell.dart';

class VolturaApp extends StatelessWidget {
  const VolturaApp({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = ThemeController.instance;

    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Voltura',
          theme: AppTheme.light,
          darkTheme: AppTheme.dark,
          themeMode: controller.themeMode,
          home: const MainShell(),
        );
      },
    );
  }
}