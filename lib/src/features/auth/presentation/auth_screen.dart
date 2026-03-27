import 'package:flutter/material.dart';

import 'auth_controller.dart';
import 'widgets/sign_in_form.dart';
import 'widgets/sign_up_form.dart';

enum AuthMode {
  signIn,
  signUp,
}

class AuthScreen extends StatefulWidget {
  const AuthScreen({
    super.key,
    required this.controller,
  });

  final AuthController controller;

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  AuthMode _mode = AuthMode.signIn;

  void _switchMode(AuthMode mode) {
    setState(() {
      _mode = mode;
    });
    widget.controller.clearError();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: <Color>[
              Color(0xFF083344),
              Color(0xFF0F766E),
              Color(0xFFF8FAFC),
            ],
            stops: <double>[0, 0.45, 1],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 520),
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: AnimatedBuilder(
                      animation: widget.controller,
                      builder: (context, _) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: <Widget>[
                            Container(
                              padding: const EdgeInsets.all(18),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFFF7ED),
                                borderRadius: BorderRadius.circular(24),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Text(
                                    'Connect through text, voice, and video',
                                    style: theme.textTheme.headlineMedium,
                                  ),
                                  const SizedBox(height: 10),
                                  Text(
                                    'This starter focuses on a reliable sign-in and sign-up flow first, then leaves room for chat, voice rooms, and video calls.',
                                    style: theme.textTheme.bodyLarge,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 24),
                            SegmentedButton<AuthMode>(
                              showSelectedIcon: false,
                              segments: const <ButtonSegment<AuthMode>>[
                                ButtonSegment<AuthMode>(
                                  value: AuthMode.signIn,
                                  label: Text('Sign in'),
                                ),
                                ButtonSegment<AuthMode>(
                                  value: AuthMode.signUp,
                                  label: Text('Sign up'),
                                ),
                              ],
                              selected: <AuthMode>{_mode},
                              onSelectionChanged: (selection) {
                                _switchMode(selection.first);
                              },
                            ),
                            const SizedBox(height: 20),
                            if (widget.controller.errorMessage != null) ...<Widget>[
                              _ErrorBanner(message: widget.controller.errorMessage!),
                              const SizedBox(height: 16),
                            ],
                            const _DemoAccountCard(),
                            const SizedBox(height: 24),
                            if (_mode == AuthMode.signIn)
                              SignInForm(
                                isBusy: widget.controller.isBusy,
                                onSubmit: widget.controller.signIn,
                                onSwitchMode: () => _switchMode(AuthMode.signUp),
                              )
                            else
                              SignUpForm(
                                isBusy: widget.controller.isBusy,
                                onSubmit: ({
                                  required String name,
                                  required String email,
                                  required String password,
                                }) {
                                  return widget.controller.signUp(
                                    name: name,
                                    email: email,
                                    password: password,
                                  );
                                },
                                onSwitchMode: () => _switchMode(AuthMode.signIn),
                              ),
                          ],
                        );
                      },
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ErrorBanner extends StatelessWidget {
  const _ErrorBanner({
    required this.message,
  });

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFFEF2F2),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFFCA5A5)),
      ),
      child: Row(
        children: <Widget>[
          const Icon(Icons.error_outline, color: Color(0xFFB91C1C)),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }
}

class _DemoAccountCard extends StatelessWidget {
  const _DemoAccountCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF0FDFA),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF99F6E4)),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text('Demo account'),
          SizedBox(height: 8),
          Text('Email: demo@codex.one'),
          SizedBox(height: 6),
          Text('Password: Password123!'),
        ],
      ),
    );
  }
}
