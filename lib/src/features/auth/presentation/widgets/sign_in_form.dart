import 'package:flutter/material.dart';

import 'auth_validators.dart';

class SignInForm extends StatefulWidget {
  const SignInForm({
    super.key,
    required this.isBusy,
    required this.onSubmit,
    required this.onSwitchMode,
  });

  final bool isBusy;
  final Future<void> Function({
    required String email,
    required String password,
  }) onSubmit;
  final VoidCallback onSwitchMode;

  @override
  State<SignInForm> createState() => _SignInFormState();
}

class _SignInFormState extends State<SignInForm> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final isValid = _formKey.currentState?.validate() ?? false;
    if (!isValid) {
      return;
    }

    await widget.onSubmit(
      email: _emailController.text.trim(),
      password: _passwordController.text,
    );
  }

  @override
  Widget build(BuildContext context) {
    return AbsorbPointer(
      absorbing: widget.isBusy,
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            TextFormField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              autofillHints: const <String>[AutofillHints.email],
              decoration: const InputDecoration(
                labelText: '邮箱',
                prefixIcon: Icon(Icons.alternate_email),
              ),
              validator: AuthValidators.email,
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: _passwordController,
              obscureText: true,
              autofillHints: const <String>[AutofillHints.password],
              decoration: const InputDecoration(
                labelText: '密码',
                prefixIcon: Icon(Icons.lock_outline),
              ),
              validator: AuthValidators.password,
            ),
            const SizedBox(height: 20),
            FilledButton(
              onPressed: widget.isBusy ? null : _submit,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 14),
                child: widget.isBusy
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('登录'),
              ),
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: widget.isBusy ? null : widget.onSwitchMode,
              child: const Text('还没有账号？去注册'),
            ),
          ],
        ),
      ),
    );
  }
}
