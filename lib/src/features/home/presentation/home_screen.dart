import 'package:flutter/material.dart';

import '../../../core/widgets/app_profile_avatar.dart';
import '../../account/presentation/account_screen.dart';
import '../../auth/domain/app_user.dart';
import '../../auth/domain/verification_status.dart';
import '../../auth/presentation/auth_controller.dart';
import '../../chat/presentation/chat_controller.dart';
import '../../chat/presentation/chat_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({
    super.key,
    required this.controller,
    required this.chatController,
    required this.user,
    required this.statusLabel,
    required this.statusMessage,
  });

  final AuthController controller;
  final ChatController chatController;
  final AppUser user;
  final String statusLabel;
  final String statusMessage;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    widget.chatController.syncUser(widget.user);
  }

  @override
  void didUpdateWidget(covariant HomeScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_didUserContextChange(oldWidget.user, widget.user)) {
      widget.chatController.syncUser(widget.user);
    }
  }

  bool _didUserContextChange(AppUser previous, AppUser next) {
    return previous.id != next.id ||
        previous.name != next.name ||
        previous.avatarKey != next.avatarKey ||
        previous.verification.phoneStatus != next.verification.phoneStatus ||
        previous.verification.identityStatus !=
            next.verification.identityStatus ||
        previous.verification.faceStatus != next.verification.faceStatus;
  }

  @override
  Widget build(BuildContext context) {
    final screens = <Widget>[
      _OverviewTab(
        user: widget.user,
        statusLabel: widget.statusLabel,
        statusMessage: widget.statusMessage,
        onOpenAccount: () {
          setState(() {
            _selectedIndex = 2;
          });
        },
        onOpenChats: () {
          setState(() {
            _selectedIndex = 1;
          });
        },
      ),
      ChatScreen(
        controller: widget.chatController,
        user: widget.user,
      ),
      AccountScreen(
        controller: widget.controller,
        user: widget.user,
      ),
    ];
    final titles = <String>['Overview', 'Chats', 'Account'];

    return Scaffold(
      appBar: AppBar(
        title: Text(titles[_selectedIndex]),
        backgroundColor: Colors.transparent,
      ),
      body: SafeArea(
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 280),
          child: screens[_selectedIndex],
        ),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        destinations: const <Widget>[
          NavigationDestination(
            icon: Icon(Icons.space_dashboard_outlined),
            selectedIcon: Icon(Icons.space_dashboard_rounded),
            label: 'Overview',
          ),
          NavigationDestination(
            icon: Icon(Icons.chat_bubble_outline),
            selectedIcon: Icon(Icons.chat_bubble),
            label: 'Chats',
          ),
          NavigationDestination(
            icon: Icon(Icons.manage_accounts_outlined),
            selectedIcon: Icon(Icons.manage_accounts),
            label: 'Account',
          ),
        ],
      ),
    );
  }
}

class _OverviewTab extends StatelessWidget {
  const _OverviewTab({
    required this.user,
    required this.statusLabel,
    required this.statusMessage,
    required this.onOpenAccount,
    required this.onOpenChats,
  });

  final AppUser user;
  final String statusLabel;
  final String statusMessage;
  final VoidCallback onOpenAccount;
  final VoidCallback onOpenChats;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final verification = user.verification;

    return ListView(
      padding: const EdgeInsets.all(20),
      children: <Widget>[
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: <Color>[
                Color(0xFF0F766E),
                Color(0xFFF97316),
              ],
            ),
            borderRadius: BorderRadius.circular(30),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                children: <Widget>[
                  AppProfileAvatar(user: user, radius: 30),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Text(
                      'Hello, ${user.name}',
                      style: theme.textTheme.headlineMedium?.copyWith(
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Text(
                'Your account system now includes phone, identity, and face ownership verification, while text chat remains available even before every step is finished.',
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: Colors.white.withValues(alpha: 0.92),
                ),
              ),
              const SizedBox(height: 18),
              Row(
                children: <Widget>[
                  FilledButton.tonal(
                    onPressed: onOpenAccount,
                    child: const Text('Open account center'),
                  ),
                  const SizedBox(width: 12),
                  OutlinedButton(
                    onPressed: onOpenChats,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.white,
                      side: const BorderSide(color: Colors.white54),
                    ),
                    child: const Text('Go to chats'),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        _StatusCard(
          label: statusLabel,
          message: statusMessage,
        ),
        const SizedBox(height: 16),
        _VerificationSummaryCard(
          user: user,
          onOpenAccount: onOpenAccount,
        ),
        const SizedBox(height: 16),
        const _FeatureCard(
          icon: Icons.chat_bubble_outline,
          title: 'Text chat MVP',
          description:
              'Conversation list, seeded threads, direct message detail, and message composer are ready for on-device testing.',
        ),
        const SizedBox(height: 14),
        const _FeatureCard(
          icon: Icons.graphic_eq,
          title: 'Voice rooms next',
          description:
              'Voice social flows stay planned as the next capability after the account system and chat MVP stabilize.',
        ),
        const SizedBox(height: 14),
        const _FeatureCard(
          icon: Icons.videocam_outlined,
          title: 'Video trust hooks reserved',
          description:
              'Face ownership verification is already modeled now so later video entry checks can reuse it.',
        ),
        const SizedBox(height: 14),
        _InfoCard(
          icon: Icons.alternate_email,
          title: 'Signed-in email',
          value: user.email,
        ),
        const SizedBox(height: 14),
        _InfoCard(
          icon: Icons.badge_outlined,
          title: 'User ID',
          value: user.id,
        ),
        if (verification.faceStatus != VerificationStatus.verified) ...<Widget>[
          const SizedBox(height: 18),
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF7ED),
              borderRadius: BorderRadius.circular(24),
            ),
            child: const Text(
              'Your avatar can be updated now, but its verified-owner badge only appears after face verification completes.',
            ),
          ),
        ],
      ],
    );
  }
}

class _VerificationSummaryCard extends StatelessWidget {
  const _VerificationSummaryCard({
    required this.user,
    required this.onOpenAccount,
  });

  final AppUser user;
  final VoidCallback onOpenAccount;

  @override
  Widget build(BuildContext context) {
    final verification = user.verification;
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Text(
                'Verification progress',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const Spacer(),
              TextButton(
                onPressed: onOpenAccount,
                child: const Text('Manage'),
              ),
            ],
          ),
          const SizedBox(height: 10),
          _VerificationRow(
            title: 'Phone',
            status: verification.phoneStatus,
          ),
          const SizedBox(height: 10),
          _VerificationRow(
            title: 'Identity',
            status: verification.identityStatus,
          ),
          const SizedBox(height: 10),
          _VerificationRow(
            title: 'Face ownership',
            status: verification.faceStatus,
          ),
        ],
      ),
    );
  }
}

class _VerificationRow extends StatelessWidget {
  const _VerificationRow({
    required this.title,
    required this.status,
  });

  final String title;
  final VerificationStatus status;

  @override
  Widget build(BuildContext context) {
    final color = switch (status) {
      VerificationStatus.notStarted => const Color(0xFF64748B),
      VerificationStatus.pending => const Color(0xFF0369A1),
      VerificationStatus.verified => const Color(0xFF15803D),
      VerificationStatus.rejected => const Color(0xFFBE123C),
    };
    return Row(
      children: <Widget>[
        Expanded(child: Text(title)),
        Text(
          status.label,
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
                color: color,
              ),
        ),
      ],
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
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
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

class _FeatureCard extends StatelessWidget {
  const _FeatureCard({
    required this.icon,
    required this.title,
    required this.description,
  });

  final IconData icon;
  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          CircleAvatar(
            backgroundColor: const Color(0xFFE6FFFB),
            foregroundColor: const Color(0xFF0F766E),
            child: Icon(icon),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 6),
                Text(description),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({
    required this.icon,
    required this.title,
    required this.value,
  });

  final IconData icon;
  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        children: <Widget>[
          CircleAvatar(
            backgroundColor: const Color(0xFFFFF7ED),
            foregroundColor: const Color(0xFFF97316),
            child: Icon(icon),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 4),
                Text(value),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
