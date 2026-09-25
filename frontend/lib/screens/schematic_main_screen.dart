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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.pcbBackground,
      body: Container(
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
            // ===================================================
            // WINDOW BAR
            // ===================================================

            const CustomWindowBar(),

            // ===================================================
            // TOP MENU BAR
            // ===================================================

            MenuBarWidget(
              onMenuChanged: (menu) {
                if (menu == 'File') {
                  setState(() {
                    fileViewOpen = true;
                  });
                }
              },
            ),

            // ===================================================
            // MAIN AREA
            // ===================================================

            Expanded(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 240),
                switchInCurve: Curves.easeOutCubic,
                switchOutCurve: Curves.easeInCubic,
                transitionBuilder: (child, animation) {
                  return FadeTransition(
                    opacity: animation,
                    child: child,
                  );
                },
                child: fileViewOpen
                    ? FileBackstageView(
                        key: const ValueKey('file'),
                        onBack: () {
                          setState(() {
                            fileViewOpen = false;
                          });
                        },
                      )
                    : const SchematicSheet(
                        key: ValueKey('schematic'),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
