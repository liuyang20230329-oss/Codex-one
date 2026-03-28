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
    required String phoneNumber,
    required String password,
  }) onSubmit;
  final VoidCallback onSwitchMode;

  @override
  State<SignUpForm> createState() => _SignUpFormState();
}

class _SignUpFormState extends State<SignUpForm> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _agreedToTerms = false;
  bool _showAgreementError = false;

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final isValid = _formKey.currentState?.validate() ?? false;
    if (!isValid) {
      return;
    }
    if (!_agreedToTerms) {
      setState(() {
        _showAgreementError = true;
      });
      return;
    }

    await widget.onSubmit(
      name: _nameController.text.trim(),
      phoneNumber: _phoneController.text.trim(),
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
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              textInputAction: TextInputAction.next,
              autofillHints: const <String>[AutofillHints.telephoneNumber],
              decoration: const InputDecoration(
                labelText: '注册手机号',
                prefixIcon: Icon(Icons.smartphone_outlined),
              ),
              validator: AuthValidators.phoneNumber,
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
            CheckboxListTile(
              contentPadding: EdgeInsets.zero,
              value: _agreedToTerms,
              controlAffinity: ListTileControlAffinity.leading,
              title: const Text('我已阅读并同意用户协议与隐私政策'),
              subtitle: const Text('后续可继续接入正式协议页面和未成年人规则说明。'),
              onChanged: widget.isBusy
                  ? null
                  : (value) {
                      setState(() {
                        _agreedToTerms = value ?? false;
                        _showAgreementError = false;
                      });
                    },
            ),
            if (_showAgreementError)
              const Padding(
                padding: EdgeInsets.only(bottom: 12),
                child: Text(
                  '请先同意用户协议与隐私政策。',
                  style: TextStyle(color: Color(0xFFB91C1C)),
                ),
              ),
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
