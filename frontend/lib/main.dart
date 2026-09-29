import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:window_manager/window_manager.dart';

import 'app/app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (!kIsWeb) {
    await windowManager.ensureInitialized();

    const WindowOptions windowOptions = WindowOptions(
      center: true,
      backgroundColor: Colors.transparent,
      skipTaskbar: false,
      titleBarStyle: TitleBarStyle.hidden,
      title: 'Voltura',
    );

    windowManager.waitUntilReadyToShow(
      windowOptions,
      () async {
        await windowManager.show();
        await windowManager.focus();
      },
    );
  }

  runApp(const VolturaApp());
}