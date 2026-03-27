import 'package:flutter/material.dart';

import 'src/core/bootstrap/app_bootstrap.dart';
import 'src/core/theme/app_theme.dart';
import 'src/features/auth/presentation/auth_controller.dart';
import 'src/features/auth/presentation/auth_gate.dart';

class CodexOneApp extends StatefulWidget {
  const CodexOneApp({
    super.key,
    required this.bootstrap,
  });

  final AppBootstrapResult bootstrap;

  @override
  State<CodexOneApp> createState() => _CodexOneAppState();
}

class _CodexOneAppState extends State<CodexOneApp> {
  late final AuthController _authController;

  @override
  void initState() {
    super.initState();
    // Keep one auth controller alive for the full app session.
    _authController = AuthController(
      repository: widget.bootstrap.repository,
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
      home: AuthGate(
        controller: _authController,
        backend: widget.bootstrap.backend,
        statusLabel: widget.bootstrap.statusLabel,
        statusMessage: widget.bootstrap.statusMessage,
      ),
    );
  }
}
