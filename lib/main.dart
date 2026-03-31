import 'package:flutter/material.dart';

import 'app.dart';
import 'src/core/bootstrap/app_bootstrap.dart';

Future<void> main() async {
  // Startup awaits bootstrap so the first frame already knows which backend
  // mode and repositories should be used.
  WidgetsFlutterBinding.ensureInitialized();
  final bootstrap = await AppBootstrap.initialize();
  runApp(CodexOneApp(bootstrap: bootstrap));
}
