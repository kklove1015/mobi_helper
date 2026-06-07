import 'dart:io';

import 'package:flutter/material.dart';
import 'package:window_manager/window_manager.dart';

Future<void> setupWindow() async {
  if (!Platform.isWindows && !Platform.isMacOS && !Platform.isLinux) {
    return;
  }

  await windowManager.ensureInitialized();

  const windowOptions = WindowOptions(
    size: Size(1280, 720),
    minimumSize: Size(960, 640),
    center: true,
    backgroundColor: Color(0xFFF6F7FB),
    title: 'Mobi Helper',
  );

  await windowManager.waitUntilReadyToShow(windowOptions, () async {
    await windowManager.setTitleBarStyle(TitleBarStyle.hidden);
    await windowManager.setAsFrameless();

    await windowManager.show();
    await windowManager.focus();
  });
}
