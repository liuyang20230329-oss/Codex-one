import 'package:flutter/material.dart';

import 'auth_validators.dart';

class SignUpForm extends StatefulWidget {
  const SignUpForm({
    super.key,
    required this.isBusy,
    required this.onSubmit,
    required this.onSwitchMode,
  });

  final bool isBusy;
  final Future<void> Function({
    required String name,
    required String email,
    required String password,
  }) onSubmit;
  final VoidCallback onSwitchMode;

  @override
  State<SignUpForm> createState() => _SignUpFormState();
}

class _SignUpFormState extends State<SignUpForm> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final isValid = _formKey.currentState?.validate() ?? false;
    if (!isValid) {
      return;
    }

    await widget.onSubmit(
      name: _nameController.text.trim(),
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
              controller: _nameController,
              textInputAction: TextInputAction.next,
              autofillHints: const <String>[AutofillHints.name],
              decoration: const InputDecoration(
                labelText: '昵称',
                prefixIcon: Icon(Icons.person_outline),
              ),
              validator: AuthValidators.name,
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
              autofillHints: const <String>[AutofillHints.newUsername],
              decoration: const InputDecoration(
                labelText: '邮箱',
                prefixIcon: Icon(Icons.mail_outline),
              ),
              validator: AuthValidators.email,
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: _passwordController,
              obscureText: true,
              textInputAction: TextInputAction.next,
              autofillHints: const <String>[AutofillHints.newPassword],
              decoration: const InputDecoration(
                labelText: '密码',
                prefixIcon: Icon(Icons.lock_outline),
                helperText: '至少 8 位',
              ),
              validator: AuthValidators.password,
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: _confirmPasswordController,
              obscureText: true,
              autofillHints: const <String>[AutofillHints.newPassword],
              decoration: const InputDecoration(
                labelText: '确认密码',
                prefixIcon: Icon(Icons.verified_user_outlined),
              ),
              validator: (value) {
                return AuthValidators.confirmPassword(
                  password: _passwordController.text,
                  confirmPassword: value,
                );
              },
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
                    : const Text('创建账号'),
              ),
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: widget.isBusy ? null : widget.onSwitchMode,
              child: const Text('已有账号？去登录'),
            ),
          ],
        ),
      ),
    );
  }
}
