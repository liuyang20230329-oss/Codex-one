import 'package:flutter/material.dart';

import 'app.dart';
import 'src/core/bootstrap/app_bootstrap.dart';
import 'src/core/persistence/hive_init.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeHive();
  final bootstrap = await AppBootstrap.initialize();
  runApp(CodexOneApp(bootstrap: bootstrap));
}
