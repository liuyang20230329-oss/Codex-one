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
    final titles = <String>['总览', '聊天', '账号'];

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
            label: '总览',
          ),
          NavigationDestination(
            icon: Icon(Icons.chat_bubble_outline),
            selectedIcon: Icon(Icons.chat_bubble),
            label: '聊天',
          ),
          NavigationDestination(
            icon: Icon(Icons.manage_accounts_outlined),
            selectedIcon: Icon(Icons.manage_accounts),
            label: '账号',
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
                      '你好，${user.name}',
                      style: theme.textTheme.headlineMedium?.copyWith(
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Text(
                '当前账号体系已经接入手机号、身份证和本人头像/人脸认证；即使还没全部完成，你也可以先开始文字聊天。',
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: Colors.white.withValues(alpha: 0.92),
                ),
              ),
              const SizedBox(height: 18),
              Row(
                children: <Widget>[
                  FilledButton.tonal(
                    onPressed: onOpenAccount,
                    child: const Text('打开账号中心'),
                  ),
                  const SizedBox(width: 12),
                  OutlinedButton(
                    onPressed: onOpenChats,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.white,
                      side: const BorderSide(color: Colors.white54),
                    ),
                    child: const Text('前往聊天'),
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
          title: '文字聊天 MVP',
          description: '会话列表、示例会话、私聊详情页和消息输入框都已经可用，适合直接上手机测试。',
        ),
        const SizedBox(height: 14),
        const _FeatureCard(
          icon: Icons.graphic_eq,
          title: '语音房下一步',
          description: '等账号体系和文字聊天稳定后，下一阶段就会优先推进语音社交能力。',
        ),
        const SizedBox(height: 14),
        const _FeatureCard(
          icon: Icons.videocam_outlined,
          title: '视频信任链已预留',
          description: '本人头像/人脸认证已经建模完成，后续做视频准入校验时可以直接复用。',
        ),
        const SizedBox(height: 14),
        _InfoCard(
          icon: Icons.alternate_email,
          title: '当前登录邮箱',
          value: user.email,
        ),
        const SizedBox(height: 14),
        _InfoCard(
          icon: Icons.badge_outlined,
          title: '用户 ID',
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
              '你现在可以先更换头像，但只有完成人脸认证后，头像才会显示“本人认证”标记。',
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
                '认证进度',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const Spacer(),
              TextButton(
                onPressed: onOpenAccount,
                child: const Text('去管理'),
              ),
            ],
          ),
          const SizedBox(height: 10),
          _VerificationRow(
            title: '手机号',
            status: verification.phoneStatus,
          ),
          const SizedBox(height: 10),
          _VerificationRow(
            title: '身份证',
            status: verification.identityStatus,
          ),
          const SizedBox(height: 10),
          _VerificationRow(
            title: '本人头像',
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
