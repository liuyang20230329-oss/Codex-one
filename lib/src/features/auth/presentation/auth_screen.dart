import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/brand/app_brand.dart';
import '../domain/social_login_provider.dart';
import 'bloc/auth_bloc.dart';
import 'widgets/sign_in_form.dart';
import 'widgets/sign_up_form.dart';

enum AuthMode {
  signIn,
  signUp,
}

class AuthScreen extends StatefulWidget {
  const AuthScreen({
    super.key,
    required this.statusLabel,
    required this.statusMessage,
    required this.showDemoAccount,
  });

  final String statusLabel;
  final String statusMessage;
  final bool showDemoAccount;

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  AuthMode _mode = AuthMode.signIn;

  void _switchMode(AuthMode mode) {
    setState(() {
      _mode = mode;
    });
    context.read<AuthBloc>().add(const AuthErrorCleared());
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
              AppBrand.ink,
              AppBrand.inkSoft,
              Color(0xFF2A2522),
            ],
            stops: <double>[0, 0.56, 1],
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
                    child: BlocBuilder<AuthBloc, AuthState>(
                      builder: (context, state) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: <Widget>[
                            Container(
                              padding: const EdgeInsets.all(22),
                              decoration: BoxDecoration(
                                color: AppBrand.ink,
                                borderRadius: BorderRadius.circular(28),
                              ),
                              child: const AppBrandLockup(),
                            ),
                            const SizedBox(height: 20),
                            Text(
                              '先用手机号登录，再逐步完成手机号、实名认证与本人认证。未完成认证前仍可先浏览与体验系统引导。',
                              style: theme.textTheme.bodyLarge?.copyWith(
                                color: const Color(0xFF525866),
                              ),
                            ),
                            const SizedBox(height: 20),
                            _StatusCard(
                              label: widget.statusLabel,
                              message: widget.statusMessage,
                            ),
                            const SizedBox(height: 24),
                            SegmentedButton<AuthMode>(
                              showSelectedIcon: false,
                              segments: const <ButtonSegment<AuthMode>>[
                                ButtonSegment<AuthMode>(
                                  value: AuthMode.signIn,
                                  label: Text('登录'),
                                ),
                                ButtonSegment<AuthMode>(
                                  value: AuthMode.signUp,
                                  label: Text('注册'),
                                ),
                              ],
                              selected: <AuthMode>{_mode},
                              onSelectionChanged: (selection) {
                                _switchMode(selection.first);
                              },
                            ),
                            const SizedBox(height: 20),
                            if (state.errorMessage != null) ...<Widget>[
                              _ErrorBanner(message: state.errorMessage!),
                              const SizedBox(height: 16),
                            ],
                            if (widget.showDemoAccount) ...<Widget>[
                              const _DemoAccountCard(),
                              const SizedBox(height: 24),
                            ],
                            if (_mode == AuthMode.signIn)
                              SignInForm(
                                isBusy: state.isBusy,
                                onSubmit: ({
                                  required String phoneNumber,
                                  required String password,
                                }) async {
                                  context.read<AuthBloc>().add(
                                        AuthSignInRequested(
                                          phoneNumber: phoneNumber,
                                          password: password,
                                        ),
                                      );
                                  await context.read<AuthBloc>().stream.firstWhere(
                                        (s) => !s.isBusy,
                                      );
                                },
                                onSwitchMode: () => _switchMode(AuthMode.signUp),
                                onWechatLogin: () {
                                  context.read<AuthBloc>().add(
                                        const AuthSocialLoginTriggered(
                                          SocialLoginProvider.wechat,
                                        ),
                                      );
                                },
                                onQqLogin: () {
                                  context.read<AuthBloc>().add(
                                        const AuthSocialLoginTriggered(
                                          SocialLoginProvider.qq,
                                        ),
                                      );
                                },
                              )
                            else
                              SignUpForm(
                                isBusy: state.isBusy,
                                onSubmit: ({
                                  required String name,
                                  required String phoneNumber,
                                  required String password,
                                }) async {
                                  context.read<AuthBloc>().add(
                                        AuthSignUpRequested(
                                          name: name,
                                          phoneNumber: phoneNumber,
                                          password: password,
                                        ),
                                      );
                                  await context.read<AuthBloc>().stream.firstWhere(
                                        (s) => !s.isBusy,
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

class _StatusCard extends StatelessWidget {
  const _StatusCard({
    required this.label,
    required this.message,
  });

  final String label;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F2EC),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2D8C7)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            label,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 6),
          Text(message),
        ],
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
        color: const Color(0xFFF7F4EE),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2D8C7)),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text('演示账号'),
          SizedBox(height: 8),
          Text('手机号：13800138000'),
          SizedBox(height: 6),
          Text('密码：Password123!'),
          SizedBox(height: 6),
          Text('登录后可在"我的"里继续完成手机号、实名和本人认证。'),
        ],
      ),
    );
  }
}
