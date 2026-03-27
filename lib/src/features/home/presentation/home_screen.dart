import 'package:flutter/material.dart';

import '../../auth/domain/app_user.dart';
import '../../auth/presentation/auth_controller.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({
    super.key,
    required this.controller,
    required this.user,
    required this.statusLabel,
    required this.statusMessage,
  });

  final AuthController controller;
  final AppUser user;
  final String statusLabel;
  final String statusMessage;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Codex One'),
        backgroundColor: Colors.transparent,
      ),
      body: SafeArea(
        child: ListView(
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
                  Text(
                    'Hello, ${user.name}',
                    style: theme.textTheme.headlineMedium?.copyWith(
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Your auth flow is ready. The next step is to expand this into chat, voice rooms, video calls, and user profiles.',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: Colors.white.withValues(alpha: 0.92),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            _StatusCard(
              label: statusLabel,
              message: statusMessage,
            ),
            const SizedBox(height: 20),
            const _FeatureCard(
              icon: Icons.chat_bubble_outline,
              title: 'Text chat',
              description: 'A place for one-to-one messaging, group chat, read states, and conversation lists.',
            ),
            const SizedBox(height: 14),
            const _FeatureCard(
              icon: Icons.graphic_eq,
              title: 'Voice rooms',
              description: 'A good extension point for live voice rooms, voice matching, and mic seat controls.',
            ),
            const SizedBox(height: 14),
            const _FeatureCard(
              icon: Icons.videocam_outlined,
              title: 'Video calls',
              description: 'Reserved for one-to-one calls, multi-user rooms, and future live streaming.',
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
