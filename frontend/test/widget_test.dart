// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/app/app.dart';
import 'package:frontend/theme/theme_controller.dart';

void main() {
  testWidgets('VolturaApp mounts and toggles logo in light and dark mode', (WidgetTester tester) async {
    ThemeController.instance.setLight();
    await tester.pumpWidget(const VolturaApp());
    await tester.pumpAndSettle();

    expect(find.byType(VolturaApp), findsOneWidget);

    // Light mode should show voltura_logo.png
    final lightLogoFinder = find.byWidgetPredicate(
      (widget) =>
          widget is Image &&
          widget.image is AssetImage &&
          (widget.image as AssetImage).assetName ==
              'assets/images/voltura_logo.png',
    );
    expect(lightLogoFinder, findsOneWidget);

    // Switch to dark mode
    ThemeController.instance.setDark();
    await tester.pumpAndSettle();

    // Dark mode should show voltura_logo_dark.png
    final darkLogoFinder = find.byWidgetPredicate(
      (widget) =>
          widget is Image &&
          widget.image is AssetImage &&
          (widget.image as AssetImage).assetName ==
              'assets/images/voltura_logo_dark.png',
    );
    expect(darkLogoFinder, findsOneWidget);

    // Switch back to light mode
    ThemeController.instance.setLight();
    await tester.pumpAndSettle();
    expect(lightLogoFinder, findsOneWidget);
  });
}
