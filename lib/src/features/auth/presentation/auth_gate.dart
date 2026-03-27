import 'package:flutter/material.dart';

import '../../home/presentation/home_screen.dart';
import 'auth_controller.dart';
import 'auth_screen.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({
    super.key,
    required this.controller,
  });

  final AuthController controller;

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
                )
              : HomeScreen(
                  key: const ValueKey('home-screen'),
                  controller: controller,
                  user: controller.currentUser!,
                ),
        );
      },
    );
  }
}
