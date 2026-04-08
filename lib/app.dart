import 'package:flutter/material.dart';

import 'src/core/brand/app_brand.dart';
import 'src/core/bootstrap/app_bootstrap.dart';
import 'src/core/theme/app_theme.dart';
import 'src/features/auth/presentation/auth_controller.dart';
import 'src/features/auth/presentation/auth_gate.dart';
import 'src/features/chat/presentation/chat_controller.dart';
import 'src/features/circle/presentation/circle_controller.dart';

/// Top-level application shell that wires bootstrap dependencies into the
/// auth, chat, and circle flows.
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
  late final ChatController _chatController;
  late final CircleController _circleController;

  @override
  void initState() {
    super.initState();
    // Keep one controller per domain alive for the full app session so state
    // survives tab switches and auth-driven rebuilds.
    _authController = AuthController(
      repository: widget.bootstrap.repository,
    );
    _chatController = ChatController(
      repository: widget.bootstrap.chatRepository,
    );
    _circleController = CircleController(
      repository: widget.bootstrap.circleRepository,
    );
  }

  @override
  void dispose() {
    _circleController.dispose();
    _chatController.dispose();
    _authController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppBrand.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      home: AuthGate(
        controller: _authController,
        chatController: _chatController,
        circleController: _circleController,
        backend: widget.bootstrap.backend,
        statusLabel: widget.bootstrap.statusLabel,
        statusMessage: widget.bootstrap.statusMessage,
      ),
    );
  }
}
