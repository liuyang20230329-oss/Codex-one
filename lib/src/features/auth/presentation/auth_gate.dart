import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/bootstrap/app_bootstrap.dart';
import '../../home/presentation/home_screen.dart';
import 'auth_screen.dart';
import 'bloc/auth_bloc.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({
    super.key,
    required this.backend,
    required this.statusLabel,
    required this.statusMessage,
  });

  final AuthBackend backend;
  final String statusLabel;
  final String statusMessage;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        return AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: state.currentUser == null
              ? AuthScreen(
                  key: const ValueKey('auth-screen'),
                  statusLabel: statusLabel,
                  statusMessage: statusMessage,
                  showDemoAccount: backend == AuthBackend.demo,
                )
              : HomeScreen(
                  key: const ValueKey('home-screen'),
                  user: state.currentUser!,
                  statusLabel: statusLabel,
                  statusMessage: statusMessage,
                ),
        );
      },
    );
  }
}
