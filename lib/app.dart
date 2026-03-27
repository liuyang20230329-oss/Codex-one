import 'package:flutter/material.dart';

import 'src/core/theme/app_theme.dart';
import 'src/features/auth/data/demo_auth_repository.dart';
import 'src/features/auth/presentation/auth_controller.dart';
import 'src/features/auth/presentation/auth_gate.dart';

class CodexOneApp extends StatefulWidget {
  const CodexOneApp({super.key});

  @override
  State<CodexOneApp> createState() => _CodexOneAppState();
}

class _CodexOneAppState extends State<CodexOneApp> {
  late final AuthController _authController;

  @override
  void initState() {
    super.initState();
    _authController = AuthController(
      repository: DemoAuthRepository.seeded(),
    );
  }

  @override
  void dispose() {
    _authController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Codex One',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      home: AuthGate(controller: _authController),
    );
  }
}
