import 'package:flutter/material.dart';

import '../../../core/widgets/app_profile_avatar.dart';
import '../../auth/domain/app_user.dart';
import '../../auth/domain/verification_status.dart';
import '../../auth/presentation/auth_controller.dart';
import '../../auth/presentation/widgets/auth_validators.dart';

class AccountScreen extends StatelessWidget {
  const AccountScreen({
    super.key,
    required this.controller,
    required this.user,
  });

  final AuthController controller;
  final AppUser user;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        final currentUser = controller.currentUser ?? user;
        final verification = currentUser.verification;
        final progressText =
            '${verification.verifiedCount}/3 verification steps completed';

        return ListView(
          padding: const EdgeInsets.all(20),
          children: <Widget>[
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: <Color>[
                    Color(0xFF0F766E),
                    Color(0xFF0F172A),
                  ],
                ),
                borderRadius: BorderRadius.circular(30),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      AppProfileAvatar(
                        user: currentUser,
                        radius: 34,
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              currentUser.name,
                              style: Theme.of(context)
                                  .textTheme
                                  .headlineMedium
                                  ?.copyWith(
                                    color: Colors.white,
                                  ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              currentUser.email,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyLarge
                                  ?.copyWith(
                                    color: Colors.white70,
                                  ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  Text(
                    progressText,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: Colors.white,
                        ),
                  ),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(999),
                    child: LinearProgressIndicator(
                      minHeight: 10,
                      value: verification.completion,
                      backgroundColor: Colors.white24,
                      valueColor: const AlwaysStoppedAnimation<Color>(
                        Color(0xFFF97316),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            const _InfoNoticeCard(
              title: 'Chat is available before verification completes',
              message:
                  'Users can still use text chat before phone, identity, or face checks finish. Later we can add exposure and trust restrictions without redesigning this account center.',
            ),
            const SizedBox(height: 18),
            _ProfileSectionCard(
              user: currentUser,
              onEdit: () => _openProfileEditor(context, currentUser),
            ),
            const SizedBox(height: 18),
            _VerificationActionCard(
              title: 'Phone verification',
              subtitle: verification.phoneNumber ??
                  'Bind a mobile number for recovery and trust scoring.',
              description:
                  'This starter uses a demo SMS code on screen. A real SMS provider can be attached later.',
              status: verification.phoneStatus,
              actionLabel: verification.phoneStatus.isVerified
                  ? 'Reverify phone'
                  : 'Verify phone',
              icon: Icons.smartphone_outlined,
              onPressed: () => _openPhoneVerification(context),
            ),
            const SizedBox(height: 14),
            _VerificationActionCard(
              title: 'Identity verification',
              subtitle: verification.legalName == null
                  ? 'Submit your legal name and ID number.'
                  : '${verification.legalName} · ${verification.maskedIdNumber}',
              description:
                  'The UI and validation are ready now. Replace the demo approval with a compliant identity partner later.',
              status: verification.identityStatus,
              actionLabel: verification.identityStatus.isVerified
                  ? 'Update identity'
                  : 'Submit identity',
              icon: Icons.badge_outlined,
              onPressed: () => _openIdentityVerification(context),
            ),
            const SizedBox(height: 14),
            _VerificationActionCard(
              title: 'Face and avatar ownership',
              subtitle: verification.faceMatchScore == null
                  ? 'Confirm the profile avatar belongs to the account owner.'
                  : 'Similarity ${(
                        verification.faceMatchScore! * 100
                      ).toStringAsFixed(1)}%',
              description:
                  'Changing the avatar will reset face verification, which keeps avatar trust tied to the current profile image.',
              status: verification.faceStatus,
              actionLabel: verification.faceStatus.isVerified
                  ? 'Run again'
                  : 'Start face check',
              icon: Icons.verified_user_outlined,
              onPressed: verification.canRunFaceVerification
                  ? () => _openFaceVerification(context)
                  : null,
            ),
            if (controller.errorMessage != null) ...<Widget>[
              const SizedBox(height: 18),
              Text(
                controller.errorMessage!,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: const Color(0xFFB91C1C),
                    ),
              ),
            ],
            const SizedBox(height: 24),
            FilledButton.tonalIcon(
              onPressed: controller.isBusy ? null : controller.signOut,
              icon: const Icon(Icons.logout),
              label: const Padding(
                padding: EdgeInsets.symmetric(vertical: 14),
                child: Text('Sign out'),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _openProfileEditor(BuildContext context, AppUser currentUser) async {
    final draft = await showModalBottomSheet<_ProfileDraft>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (context) {
        return _ProfileEditorSheet(user: currentUser);
      },
    );
    if (draft == null) {
      return;
    }

    final success = await controller.updateProfile(
      name: draft.name,
      avatarKey: draft.avatarKey,
    );
    if (!context.mounted) {
      return;
    }
    _showResultSnackBar(
      context,
      success: success,
      successMessage: 'Profile updated.',
    );
  }

  Future<void> _openPhoneVerification(BuildContext context) async {
    final completed = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (context) {
        return _PhoneVerificationSheet(controller: controller);
      },
    );
    if (completed != true || !context.mounted) {
      return;
    }
    _showResultSnackBar(
      context,
      success: true,
      successMessage: 'Phone verification completed.',
    );
  }

  Future<void> _openIdentityVerification(BuildContext context) async {
    final completed = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (context) {
        return _IdentityVerificationSheet(controller: controller);
      },
    );
    if (completed != true || !context.mounted) {
      return;
    }
    _showResultSnackBar(
      context,
      success: true,
      successMessage: 'Identity information saved.',
    );
  }

  Future<void> _openFaceVerification(BuildContext context) async {
    final completed = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (context) {
        return _FaceVerificationSheet(controller: controller);
      },
    );
    if (completed != true || !context.mounted) {
      return;
    }
    _showResultSnackBar(
      context,
      success: true,
      successMessage: 'Face verification completed.',
    );
  }

  void _showResultSnackBar(
    BuildContext context, {
    required bool success,
    required String successMessage,
  }) {
    final messenger = ScaffoldMessenger.of(context);
    messenger.hideCurrentSnackBar();
    messenger.showSnackBar(
      SnackBar(
        content: Text(
          success
              ? successMessage
              : controller.errorMessage ?? 'Something went wrong.',
        ),
      ),
    );
  }
}

class _ProfileSectionCard extends StatelessWidget {
  const _ProfileSectionCard({
    required this.user,
    required this.onEdit,
  });

  final AppUser user;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    final avatarOption = avatarOptionFor(user.avatarKey);
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(26),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Text(
                'Profile basics',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const Spacer(),
              TextButton.icon(
                onPressed: onEdit,
                icon: const Icon(Icons.edit_outlined),
                label: const Text('Edit'),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: <Widget>[
              AppProfileAvatar(user: user, radius: 26),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(user.name),
                    const SizedBox(height: 4),
                    Text(user.email),
                    const SizedBox(height: 4),
                    Text('Avatar theme: ${avatarOption.label}'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _VerificationActionCard extends StatelessWidget {
  const _VerificationActionCard({
    required this.title,
    required this.subtitle,
    required this.description,
    required this.status,
    required this.actionLabel,
    required this.icon,
    required this.onPressed,
  });

  final String title;
  final String subtitle;
  final String description;
  final VerificationStatus status;
  final String actionLabel;
  final IconData icon;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(26),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              CircleAvatar(
                backgroundColor: const Color(0xFFEFF6FF),
                foregroundColor: const Color(0xFF0F766E),
                child: Icon(icon),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              _StatusPill(status: status),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            subtitle,
            style: Theme.of(context).textTheme.titleSmall,
          ),
          const SizedBox(height: 8),
          Text(description),
          const SizedBox(height: 16),
          FilledButton.tonal(
            onPressed: onPressed,
            child: Text(actionLabel),
          ),
        ],
      ),
    );
  }
}

class _InfoNoticeCard extends StatelessWidget {
  const _InfoNoticeCard({
    required this.title,
    required this.message,
  });

  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF7ED),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            title,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Text(message),
        ],
      ),
    );
  }
}

class _StatusPill extends StatelessWidget {
  const _StatusPill({
    required this.status,
  });

  final VerificationStatus status;

  @override
  Widget build(BuildContext context) {
    final background = switch (status) {
      VerificationStatus.notStarted => const Color(0xFFF1F5F9),
      VerificationStatus.pending => const Color(0xFFE0F2FE),
      VerificationStatus.verified => const Color(0xFFDCFCE7),
      VerificationStatus.rejected => const Color(0xFFFFE4E6),
    };
    final foreground = switch (status) {
      VerificationStatus.notStarted => const Color(0xFF334155),
      VerificationStatus.pending => const Color(0xFF0369A1),
      VerificationStatus.verified => const Color(0xFF15803D),
      VerificationStatus.rejected => const Color(0xFFBE123C),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        status.label,
        style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: foreground,
            ),
      ),
    );
  }
}

class _ProfileEditorSheet extends StatefulWidget {
  const _ProfileEditorSheet({
    required this.user,
  });

  final AppUser user;

  @override
  State<_ProfileEditorSheet> createState() => _ProfileEditorSheetState();
}

class _ProfileEditorSheetState extends State<_ProfileEditorSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late String _selectedAvatarKey;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.user.name);
    _selectedAvatarKey = widget.user.avatarKey;
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _submit() {
    final isValid = _formKey.currentState?.validate() ?? false;
    if (!isValid) {
      return;
    }

    Navigator.of(context).pop(
      _ProfileDraft(
        name: _nameController.text.trim(),
        avatarKey: _selectedAvatarKey,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 12,
        bottom: MediaQuery.viewInsetsOf(context).bottom + 20,
      ),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              'Edit profile basics',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            const Text(
              'Changing the avatar resets face verification so the verified badge always matches the current profile image.',
            ),
            const SizedBox(height: 18),
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Display name',
                prefixIcon: Icon(Icons.person_outline),
              ),
              validator: AuthValidators.name,
            ),
            const SizedBox(height: 18),
            Text(
              'Avatar theme',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: avatarOptions.map((option) {
                final selected = option.key == _selectedAvatarKey;
                return ChoiceChip(
                  label: Text(option.label),
                  selected: selected,
                  avatar: CircleAvatar(
                    backgroundColor: option.background,
                    foregroundColor: option.foreground,
                    child: const Text('A'),
                  ),
                  onSelected: (_) {
                    setState(() {
                      _selectedAvatarKey = option.key;
                    });
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 22),
            FilledButton(
              onPressed: _submit,
              child: const Padding(
                padding: EdgeInsets.symmetric(vertical: 14),
                child: Text('Save profile'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PhoneVerificationSheet extends StatefulWidget {
  const _PhoneVerificationSheet({
    required this.controller,
  });

  final AuthController controller;

  @override
  State<_PhoneVerificationSheet> createState() => _PhoneVerificationSheetState();
}

class _PhoneVerificationSheetState extends State<_PhoneVerificationSheet> {
  final _phoneController = TextEditingController();
  final _codeController = TextEditingController();
  String? _message;

  @override
  void dispose() {
    _phoneController.dispose();
    _codeController.dispose();
    super.dispose();
  }

  Future<void> _sendCode() async {
    final validation = AuthValidators.phoneNumber(_phoneController.text);
    if (validation != null) {
      setState(() {
        _message = validation;
      });
      return;
    }

    final session = await widget.controller.requestPhoneVerification(
      phoneNumber: _phoneController.text,
    );
    if (!mounted) {
      return;
    }

    setState(() {
      _message = session == null
          ? widget.controller.errorMessage
          : 'Demo code: ${session.debugCode}. Replace this with real SMS later.';
    });
  }

  Future<void> _submit() async {
    final codeValidation = AuthValidators.verificationCode(_codeController.text);
    if (codeValidation != null) {
      setState(() {
        _message = codeValidation;
      });
      return;
    }

    final success = await widget.controller.confirmPhoneVerification(
      code: _codeController.text,
    );
    if (!mounted) {
      return;
    }
    if (success) {
      Navigator.of(context).pop(true);
      return;
    }

    setState(() {
      _message = widget.controller.errorMessage;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 12,
        bottom: MediaQuery.viewInsetsOf(context).bottom + 20,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            'Phone verification',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          const Text(
            'This flow is wired for product testing right now. The code is shown on screen in demo mode so you can validate the full experience without an SMS provider.',
          ),
          const SizedBox(height: 18),
          TextField(
            controller: _phoneController,
            keyboardType: TextInputType.phone,
            decoration: const InputDecoration(
              labelText: 'Mobile number',
              prefixIcon: Icon(Icons.phone_android_outlined),
            ),
          ),
          const SizedBox(height: 12),
          FilledButton.tonal(
            onPressed: widget.controller.isBusy ? null : _sendCode,
            child: const Text('Send verification code'),
          ),
          const SizedBox(height: 18),
          TextField(
            controller: _codeController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Verification code',
              prefixIcon: Icon(Icons.password_outlined),
            ),
          ),
          if (_message != null) ...<Widget>[
            const SizedBox(height: 12),
            Text(
              _message!,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: const Color(0xFF0F766E),
                  ),
            ),
          ],
          const SizedBox(height: 20),
          FilledButton(
            onPressed: widget.controller.isBusy ? null : _submit,
            child: const Padding(
              padding: EdgeInsets.symmetric(vertical: 14),
              child: Text('Confirm phone'),
            ),
          ),
        ],
      ),
    );
  }
}

class _IdentityVerificationSheet extends StatefulWidget {
  const _IdentityVerificationSheet({
    required this.controller,
  });

  final AuthController controller;

  @override
  State<_IdentityVerificationSheet> createState() =>
      _IdentityVerificationSheetState();
}

class _IdentityVerificationSheetState extends State<_IdentityVerificationSheet> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _idController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _idController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final isValid = _formKey.currentState?.validate() ?? false;
    if (!isValid) {
      return;
    }

    final success = await widget.controller.submitIdentityVerification(
      legalName: _nameController.text,
      idNumber: _idController.text,
    );
    if (!mounted) {
      return;
    }
    if (success) {
      Navigator.of(context).pop(true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 12,
        bottom: MediaQuery.viewInsetsOf(context).bottom + 20,
      ),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              'Identity verification',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            const Text(
              'The compliance-grade backend can replace this demo approval flow later. For now, the product journey, masking, validation, and status updates are already in place.',
            ),
            const SizedBox(height: 18),
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Legal name',
                prefixIcon: Icon(Icons.person_pin_outlined),
              ),
              validator: AuthValidators.legalName,
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: _idController,
              textCapitalization: TextCapitalization.characters,
              decoration: const InputDecoration(
                labelText: 'ID number',
                prefixIcon: Icon(Icons.badge_outlined),
              ),
              validator: AuthValidators.idNumber,
            ),
            const SizedBox(height: 22),
            FilledButton(
              onPressed: widget.controller.isBusy ? null : _submit,
              child: const Padding(
                padding: EdgeInsets.symmetric(vertical: 14),
                child: Text('Submit identity information'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FaceVerificationSheet extends StatefulWidget {
  const _FaceVerificationSheet({
    required this.controller,
  });

  final AuthController controller;

  @override
  State<_FaceVerificationSheet> createState() => _FaceVerificationSheetState();
}

class _FaceVerificationSheetState extends State<_FaceVerificationSheet> {
  bool _confirmed = false;

  Future<void> _submit() async {
    if (!_confirmed) {
      return;
    }
    final success = await widget.controller.completeFaceVerification();
    if (!mounted) {
      return;
    }
    if (success) {
      Navigator.of(context).pop(true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 12,
        bottom: MediaQuery.viewInsetsOf(context).bottom + 20,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            'Face and avatar ownership',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          const Text(
            'This starter completes the interaction and state transition for face verification. A real version can connect to camera capture, liveness detection, and a face matching provider.',
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFEFF6FF),
              borderRadius: BorderRadius.circular(22),
            ),
            child: const Text(
              'Rule: if the profile avatar changes later, face verification will reset automatically.',
            ),
          ),
          const SizedBox(height: 16),
          CheckboxListTile(
            value: _confirmed,
            onChanged: (value) {
              setState(() {
                _confirmed = value ?? false;
              });
            },
            contentPadding: EdgeInsets.zero,
            title: const Text(
              'I confirm the current profile avatar belongs to the real account owner.',
            ),
          ),
          const SizedBox(height: 16),
          FilledButton(
            onPressed: widget.controller.isBusy || !_confirmed ? null : _submit,
            child: const Padding(
              padding: EdgeInsets.symmetric(vertical: 14),
              child: Text('Run face verification'),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileDraft {
  const _ProfileDraft({
    required this.name,
    required this.avatarKey,
  });

  final String name;
  final String avatarKey;
}
