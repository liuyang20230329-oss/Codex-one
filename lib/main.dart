import 'package:flutter/material.dart';

import 'app.dart';
import 'src/core/bootstrap/app_bootstrap.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final bootstrap = await AppBootstrap.initialize();
  runApp(CodexOneApp(bootstrap: bootstrap));
}
