import 'package:flutter/material.dart';

import 'app.dart';
import 'core/window/window_setup.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await setupWindow();

  runApp(const MobiHelperApp());
}
