import 'package:flutter/material.dart';

import '../../../core/bootstrap/app_bootstrap.dart';
import '../../home/presentation/home_screen.dart';
import 'auth_controller.dart';
import 'auth_screen.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({
    super.key,
    required this.controller,
    required this.backend,
    required this.statusLabel,
    required this.statusMessage,
  });

  final AuthController controller;
  final AuthBackend backend;
  final String statusLabel;
  final String statusMessage;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        return AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: controller.currentUser == null
              ? AuthScreen(
                  key: const ValueKey('auth-screen'),
                  controller: controller,
                  statusLabel: statusLabel,
                  statusMessage: statusMessage,
                  showDemoAccount: backend == AuthBackend.demo,
                )
              : HomeScreen(
                  key: const ValueKey('home-screen'),
                  controller: controller,
                  user: controller.currentUser!,
                  statusLabel: statusLabel,
                  statusMessage: statusMessage,
                ),
        );
      },
    );
  }
}
