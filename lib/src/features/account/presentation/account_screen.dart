import 'package:flutter/material.dart';

import '../../../core/theme/user_tone_palette.dart';
import '../../../core/widgets/app_profile_avatar.dart';
import '../../auth/domain/app_user.dart';
import '../../auth/domain/profile_media_work.dart';
import '../../auth/domain/user_gender.dart';
import '../../auth/domain/verification_status.dart';
import '../../auth/presentation/auth_controller.dart';
import '../../auth/presentation/widgets/auth_validators.dart';

class AccountScreen extends StatefulWidget {
  const AccountScreen({
    super.key,
    required this.controller,
    required this.user,
  });

  final AuthController controller;
  final AppUser user;

  @override
  State<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  bool _preferVerifiedUsers = true;
  bool _receiveSystemNotices = true;
  bool _allowNearbyExposure = true;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.controller,
      builder: (context, _) {
        final currentUser = widget.controller.currentUser ?? widget.user;
        final verification = currentUser.verification;
        final palette = tonePaletteFor(currentUser.gender);
        final progressText = '已完成 ${verification.verifiedCount}/3 项认证';
        final profileCompletionText =
            '资料完成度 ${currentUser.profileCompletionPercent}%';

        return ListView(
          padding: const EdgeInsets.all(20),
          children: <Widget>[
            _AccountHeroCard(
              user: currentUser,
              palette: palette,
              progressText: progressText,
              profileCompletionText: profileCompletionText,
              onEdit: () => _openProfileEditor(context, currentUser),
            ),
            const SizedBox(height: 18),
            _InfoNoticeCard(
              palette: palette,
              title: '认证、私聊与曝光规则',
              message:
                  '当前版本支持手机号、身份证和本人头像认证。未完成手机号认证前，你仍可继续和系统引导会话互动；完成手机号认证后可正式私聊；完成本人认证后会在广场和圈子里获得更稳定的推荐曝光。',
            ),
            const SizedBox(height: 18),
            _ProfileSectionCard(
              user: currentUser,
              palette: palette,
              onEdit: () => _openProfileEditor(context, currentUser),
            ),
            const SizedBox(height: 16),
            _IntroVideoCard(
              user: currentUser,
              palette: palette,
              onEdit: () => _openIntroVideoEditor(context, currentUser),
            ),
            const SizedBox(height: 16),
            _WorksCard(
              user: currentUser,
              palette: palette,
              onAdd: () => _openWorkEditor(context, currentUser),
              onRemove: (work) => _removeWork(context, currentUser, work),
            ),
            const SizedBox(height: 18),
            Text(
              '认证中心',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 12),
            _VerificationActionCard(
              title: '手机号认证',
              subtitle: verification.phoneNumber ?? '绑定手机号，用于账号找回与基础信任判断。',
              description: '当前版本会在界面直接展示演示验证码，方便你先完整验证流程。',
              status: verification.phoneStatus,
              actionLabel:
                  verification.phoneStatus.isVerified ? '重新认证' : '立即认证',
              icon: Icons.smartphone_outlined,
              palette: palette,
              onPressed: () => _openPhoneVerification(context),
            ),
            const SizedBox(height: 14),
            _VerificationActionCard(
              title: '身份证认证',
              subtitle: verification.legalName == null
                  ? '提交真实姓名与身份证号。'
                  : '${verification.legalName} / ${verification.maskedIdNumber}',
              description: '交互、脱敏展示和状态流转已经打通，后续可以直接替换成合规实名服务。',
              status: verification.identityStatus,
              actionLabel:
                  verification.identityStatus.isVerified ? '更新实名' : '提交认证',
              icon: Icons.badge_outlined,
              palette: palette,
              onPressed: () => _openIdentityVerification(context),
            ),
            const SizedBox(height: 14),
            _VerificationActionCard(
              title: '本人头像认证',
              subtitle: verification.faceMatchScore == null
                  ? '通过人脸认证确认当前头像属于账号本人。'
                  : '当前相似度 ${(verification.faceMatchScore! * 100).toStringAsFixed(1)}%',
              description: '更换头像后会自动重置本人头像认证，确保“本人认证”始终对应当前头像。',
              status: verification.faceStatus,
              actionLabel: verification.faceStatus.isVerified ? '重新检测' : '开始认证',
              icon: Icons.verified_user_outlined,
              palette: palette,
              onPressed: verification.canRunFaceVerification
                  ? () => _openFaceVerification(context)
                  : null,
            ),
            const SizedBox(height: 18),
            _SettingsCard(
              palette: palette,
              preferVerifiedUsers: _preferVerifiedUsers,
              receiveSystemNotices: _receiveSystemNotices,
              allowNearbyExposure: _allowNearbyExposure,
              onPreferVerifiedUsersChanged: (value) {
                setState(() {
                  _preferVerifiedUsers = value;
                });
              },
              onReceiveSystemNoticesChanged: (value) {
                setState(() {
                  _receiveSystemNotices = value;
                });
              },
              onAllowNearbyExposureChanged: (value) {
                setState(() {
                  _allowNearbyExposure = value;
                });
              },
            ),
            if (widget.controller.errorMessage != null) ...<Widget>[
              const SizedBox(height: 18),
              Text(
                widget.controller.errorMessage!,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: const Color(0xFFB91C1C),
                    ),
              ),
            ],
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed:
                  widget.controller.isBusy ? null : widget.controller.signOut,
              style: FilledButton.styleFrom(
                backgroundColor: palette.primary,
                foregroundColor: palette.foreground,
              ),
              icon: const Icon(Icons.logout),
              label: const Padding(
                padding: EdgeInsets.symmetric(vertical: 14),
                child: Text('退出登录'),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _openProfileEditor(
    BuildContext context,
    AppUser currentUser,
  ) async {
    final draft = await showModalBottomSheet<_ProfileDraft>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (context) => _ProfileEditorSheet(user: currentUser),
    );
    if (draft == null) {
      return;
    }

    final success = await widget.controller.updateProfile(
      name: draft.name,
      avatarKey: draft.avatarKey,
      gender: draft.gender,
      birthYear: draft.birthYear,
      birthMonth: draft.birthMonth,
      city: draft.city,
      signature: draft.signature,
    );
    if (!context.mounted) {
      return;
    }
    _showResultSnackBar(
      context,
      success: success,
      successMessage: '基础资料已更新。',
    );
  }

  Future<void> _openIntroVideoEditor(
    BuildContext context,
    AppUser currentUser,
  ) async {
    final draft = await showModalBottomSheet<_IntroVideoDraft>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (context) => _IntroVideoEditorSheet(user: currentUser),
    );
    if (draft == null) {
      return;
    }

    final success = await widget.controller.updateProfile(
      introVideoTitle: draft.title,
      introVideoSummary: draft.summary,
    );
    if (!context.mounted) {
      return;
    }
    _showResultSnackBar(
      context,
      success: success,
      successMessage: '视频介绍已更新。',
    );
  }

  Future<void> _openWorkEditor(
    BuildContext context,
    AppUser currentUser,
  ) async {
    final draft = await showModalBottomSheet<_WorkDraft>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (context) => const _WorkEditorSheet(),
    );
    if (draft == null) {
      return;
    }

    final nextWorks = <ProfileMediaWork>[
      ...currentUser.works,
      ProfileMediaWork(
        id: 'work-${DateTime.now().microsecondsSinceEpoch}',
        type: draft.type,
        title: draft.title,
        summary: draft.summary,
      ),
    ];
    final success = await widget.controller.updateProfile(works: nextWorks);
    if (!context.mounted) {
      return;
    }
    _showResultSnackBar(
      context,
      success: success,
      successMessage: '作品已添加。',
    );
  }

  Future<void> _removeWork(
    BuildContext context,
    AppUser currentUser,
    ProfileMediaWork work,
  ) async {
    final nextWorks = currentUser.works
        .where((item) => item.id != work.id)
        .toList(growable: false);
    final success = await widget.controller.updateProfile(works: nextWorks);
    if (!context.mounted) {
      return;
    }
    _showResultSnackBar(
      context,
      success: success,
      successMessage: '作品已移除。',
    );
  }

  Future<void> _openPhoneVerification(BuildContext context) async {
    final completed = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (context) {
        return _PhoneVerificationSheet(controller: widget.controller);
      },
    );
    if (completed != true || !context.mounted) {
      return;
    }
    _showResultSnackBar(
      context,
      success: true,
      successMessage: '手机号认证已完成。',
    );
  }

  Future<void> _openIdentityVerification(BuildContext context) async {
    final completed = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (context) {
        return _IdentityVerificationSheet(controller: widget.controller);
      },
    );
    if (completed != true || !context.mounted) {
      return;
    }
    _showResultSnackBar(
      context,
      success: true,
      successMessage: '身份证认证信息已保存。',
    );
  }

  Future<void> _openFaceVerification(BuildContext context) async {
    final completed = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (context) {
        return _FaceVerificationSheet(controller: widget.controller);
      },
    );
    if (completed != true || !context.mounted) {
      return;
    }
    _showResultSnackBar(
      context,
      success: true,
      successMessage: '本人头像认证已完成。',
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
              : widget.controller.errorMessage ?? '操作失败，请稍后再试。',
        ),
      ),
    );
  }
}

class _AccountHeroCard extends StatelessWidget {
  const _AccountHeroCard({
    required this.user,
    required this.palette,
    required this.progressText,
    required this.profileCompletionText,
    required this.onEdit,
  });

  final AppUser user;
  final UserTonePalette palette;
  final String progressText;
  final String profileCompletionText;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: <Color>[palette.primary, palette.secondary],
        ),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              AppProfileAvatar(
                user: user,
                radius: 34,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      user.name,
                      style:
                          Theme.of(context).textTheme.headlineSmall?.copyWith(
                                color: Colors.white,
                              ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      user.signature,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.white.withValues(alpha: 0.86),
                          ),
                    ),
                  ],
                ),
              ),
              IconButton.filled(
                onPressed: onEdit,
                style: IconButton.styleFrom(
                  backgroundColor: Colors.white.withValues(alpha: 0.16),
                  foregroundColor: Colors.white,
                ),
                icon: const Icon(Icons.edit_outlined),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: <Widget>[
              _HeroPill(label: user.gender.label),
              _HeroPill(label: user.ageLabel),
              _HeroPill(label: user.birthLabel),
              _HeroPill(label: user.city),
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
              value: user.verification.completion,
              backgroundColor: Colors.white24,
              valueColor: AlwaysStoppedAnimation<Color>(palette.badge),
            ),
          ),
          const SizedBox(height: 14),
          Text(
            profileCompletionText,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Colors.white,
                ),
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              minHeight: 10,
              value: user.profileCompletion,
              backgroundColor: Colors.white24,
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: <Widget>[
              _MetricTile(
                label: '作品',
                value: '${user.works.length}',
              ),
              const SizedBox(width: 12),
              _MetricTile(
                label: '视频介绍',
                value: user.introVideoTitle == AppUser.defaultIntroVideoTitle
                    ? '未上传'
                    : '已完善',
              ),
              const SizedBox(width: 12),
              _MetricTile(
                label: '资料完成度',
                value: '${user.profileCompletionPercent}%',
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _HeroPill extends StatelessWidget {
  const _HeroPill({
    required this.label,
  });

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: Colors.white,
            ),
      ),
    );
  }
}

class _MetricTile extends StatelessWidget {
  const _MetricTile({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(22),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.white70,
                  ),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Colors.white,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProfileSectionCard extends StatelessWidget {
  const _ProfileSectionCard({
    required this.user,
    required this.palette,
    required this.onEdit,
  });

  final AppUser user;
  final UserTonePalette palette;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    final avatarOption = avatarOptionFor(user.avatarKey);
    return _SectionCard(
      title: '个人信息',
      actionLabel: '编辑',
      onAction: onEdit,
      child: Column(
        children: <Widget>[
          Row(
            children: <Widget>[
              AppProfileAvatar(user: user, radius: 26),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      user.name,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 4),
                    Text('${user.email} · 头像主题 ${avatarOption.label}'),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: <Widget>[
              _InfoChip(
                icon: Icons.wc_outlined,
                label: '性别 ${user.gender.label}',
                color: palette.surface,
              ),
              _InfoChip(
                icon: Icons.cake_outlined,
                label: '年龄 ${user.ageLabel}',
                color: palette.surface,
              ),
              _InfoChip(
                icon: Icons.calendar_month_outlined,
                label: '出生年月 ${user.birthLabel}',
                color: palette.surface,
              ),
              _InfoChip(
                icon: Icons.location_on_outlined,
                label: '地区 ${user.city}',
                color: palette.surface,
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: palette.surface,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  '个性签名',
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                const SizedBox(height: 8),
                Text(user.signature),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _IntroVideoCard extends StatelessWidget {
  const _IntroVideoCard({
    required this.user,
    required this.palette,
    required this.onEdit,
  });

  final AppUser user;
  final UserTonePalette palette;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    return _SectionCard(
      title: '视频介绍',
      actionLabel: '编辑',
      onAction: onEdit,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: palette.surface,
          borderRadius: BorderRadius.circular(22),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            CircleAvatar(
              radius: 26,
              backgroundColor: palette.primary,
              foregroundColor: palette.foreground,
              child: const Icon(Icons.play_arrow_rounded),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    user.introVideoTitle,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(user.introVideoSummary),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _WorksCard extends StatelessWidget {
  const _WorksCard({
    required this.user,
    required this.palette,
    required this.onAdd,
    required this.onRemove,
  });

  final AppUser user;
  final UserTonePalette palette;
  final VoidCallback onAdd;
  final ValueChanged<ProfileMediaWork> onRemove;

  @override
  Widget build(BuildContext context) {
    return _SectionCard(
      title: '我的作品',
      actionLabel: '新增',
      onAction: onAdd,
      child: Column(
        children: <Widget>[
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: palette.surface,
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Text(
              '支持上传语音、视频、图片和动图作品。当前版本先以结构化资料形式管理，后续可直接接真实上传服务。',
            ),
          ),
          const SizedBox(height: 14),
          if (user.works.isEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: const Text('还没有作品，先添加一条语音、视频或图片内容吧。'),
            ),
          for (final work in user.works) ...<Widget>[
            _WorkItemCard(
              work: work,
              palette: palette,
              onRemove: () => onRemove(work),
            ),
            if (work != user.works.last) const SizedBox(height: 12),
          ],
        ],
      ),
    );
  }
}

class _WorkItemCard extends StatelessWidget {
  const _WorkItemCard({
    required this.work,
    required this.palette,
    required this.onRemove,
  });

  final ProfileMediaWork work;
  final UserTonePalette palette;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          CircleAvatar(
            backgroundColor: palette.surface,
            foregroundColor: palette.primary,
            child: Icon(_iconForType(work.type)),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  work.title,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 6),
                Text(work.summary),
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: palette.surface,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(work.type.label),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: onRemove,
            icon: const Icon(Icons.delete_outline),
          ),
        ],
      ),
    );
  }

  IconData _iconForType(ProfileMediaWorkType type) {
    switch (type) {
      case ProfileMediaWorkType.voice:
        return Icons.graphic_eq_rounded;
      case ProfileMediaWorkType.video:
        return Icons.videocam_outlined;
      case ProfileMediaWorkType.image:
        return Icons.image_outlined;
      case ProfileMediaWorkType.gif:
        return Icons.gif_box_outlined;
    }
  }
}

class _SettingsCard extends StatelessWidget {
  const _SettingsCard({
    required this.palette,
    required this.preferVerifiedUsers,
    required this.receiveSystemNotices,
    required this.allowNearbyExposure,
    required this.onPreferVerifiedUsersChanged,
    required this.onReceiveSystemNoticesChanged,
    required this.onAllowNearbyExposureChanged,
  });

  final UserTonePalette palette;
  final bool preferVerifiedUsers;
  final bool receiveSystemNotices;
  final bool allowNearbyExposure;
  final ValueChanged<bool> onPreferVerifiedUsersChanged;
  final ValueChanged<bool> onReceiveSystemNoticesChanged;
  final ValueChanged<bool> onAllowNearbyExposureChanged;

  @override
  Widget build(BuildContext context) {
    return _SectionCard(
      title: '基础设置',
      child: Column(
        children: <Widget>[
          SwitchListTile.adaptive(
            value: preferVerifiedUsers,
            activeThumbColor: palette.primary,
            contentPadding: EdgeInsets.zero,
            title: const Text('优先展示已认证用户'),
            subtitle: const Text('影响广场和消息推荐排序，便于测试更高信任度用户。'),
            onChanged: onPreferVerifiedUsersChanged,
          ),
          const Divider(),
          SwitchListTile.adaptive(
            value: receiveSystemNotices,
            activeThumbColor: palette.primary,
            contentPadding: EdgeInsets.zero,
            title: const Text('接收系统通知'),
            subtitle: const Text('用于平台通知、审核结果、版本提醒等消息。'),
            onChanged: onReceiveSystemNoticesChanged,
          ),
          const Divider(),
          SwitchListTile.adaptive(
            value: allowNearbyExposure,
            activeThumbColor: palette.primary,
            contentPadding: EdgeInsets.zero,
            title: const Text('开放附近曝光'),
            subtitle: const Text('决定你的资料和圈子动态是否进入附近推荐池。'),
            onChanged: onAllowNearbyExposureChanged,
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
    required this.palette,
    required this.onPressed,
  });

  final String title;
  final String subtitle;
  final String description;
  final VerificationStatus status;
  final String actionLabel;
  final IconData icon;
  final UserTonePalette palette;
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
                backgroundColor: palette.surface,
                foregroundColor: palette.primary,
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
            style: FilledButton.styleFrom(
              foregroundColor: palette.primary,
            ),
            child: Text(actionLabel),
          ),
        ],
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({
    required this.title,
    this.actionLabel,
    this.onAction,
    required this.child,
  });

  final String title;
  final String? actionLabel;
  final VoidCallback? onAction;
  final Widget child;

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
              Text(
                title,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const Spacer(),
              if (actionLabel != null && onAction != null)
                TextButton.icon(
                  onPressed: onAction,
                  icon: const Icon(Icons.edit_outlined),
                  label: Text(actionLabel!),
                ),
            ],
          ),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  const _InfoChip({
    required this.icon,
    required this.label,
    required this.color,
  });

  final IconData icon;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(icon, size: 18),
          const SizedBox(width: 8),
          Text(label),
        ],
      ),
    );
  }
}

class _InfoNoticeCard extends StatelessWidget {
  const _InfoNoticeCard({
    required this.palette,
    required this.title,
    required this.message,
  });

  final UserTonePalette palette;
  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: palette.surface,
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
  late final TextEditingController _cityController;
  late final TextEditingController _signatureController;
  late String _selectedAvatarKey;
  late UserGender _selectedGender;
  int? _selectedBirthYear;
  int? _selectedBirthMonth;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.user.name);
    _cityController = TextEditingController(text: widget.user.city);
    _signatureController = TextEditingController(text: widget.user.signature);
    _selectedAvatarKey = widget.user.avatarKey;
    _selectedGender = widget.user.gender;
    _selectedBirthYear = widget.user.birthYear;
    _selectedBirthMonth = widget.user.birthMonth;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _cityController.dispose();
    _signatureController.dispose();
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
        gender: _selectedGender,
        birthYear: _selectedBirthYear,
        birthMonth: _selectedBirthMonth,
        city: _cityController.text.trim(),
        signature: _signatureController.text.trim(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final years = List<int>.generate(
      33,
      (index) => DateTime.now().year - 18 - index,
    );
    const months = <int>[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12];

    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 12,
        bottom: MediaQuery.viewInsetsOf(context).bottom + 20,
      ),
      child: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                '编辑个人信息',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              const Text('这里可以维护昵称、性别、年龄、出生年月、地区、个性签名和头像主题。'),
              const SizedBox(height: 18),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: '昵称',
                  prefixIcon: Icon(Icons.person_outline),
                ),
                validator: AuthValidators.name,
              ),
              const SizedBox(height: 14),
              DropdownButtonFormField<UserGender>(
                initialValue: _selectedGender,
                decoration: const InputDecoration(
                  labelText: '性别',
                  prefixIcon: Icon(Icons.wc_outlined),
                ),
                items: UserGender.values.map((gender) {
                  return DropdownMenuItem<UserGender>(
                    value: gender,
                    child: Text(gender.label),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value == null) {
                    return;
                  }
                  setState(() {
                    _selectedGender = value;
                  });
                },
              ),
              const SizedBox(height: 14),
              Row(
                children: <Widget>[
                  Expanded(
                    child: DropdownButtonFormField<int?>(
                      initialValue: _selectedBirthYear,
                      decoration: const InputDecoration(
                        labelText: '出生年份',
                        prefixIcon: Icon(Icons.calendar_today_outlined),
                      ),
                      items: <DropdownMenuItem<int?>>[
                        const DropdownMenuItem<int?>(
                          value: null,
                          child: Text('未设置'),
                        ),
                        ...years.map((year) {
                          return DropdownMenuItem<int?>(
                            value: year,
                            child: Text('$year 年'),
                          );
                        }),
                      ],
                      onChanged: (value) {
                        setState(() {
                          _selectedBirthYear = value;
                        });
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: DropdownButtonFormField<int?>(
                      initialValue: _selectedBirthMonth,
                      decoration: const InputDecoration(
                        labelText: '出生月份',
                        prefixIcon: Icon(Icons.date_range_outlined),
                      ),
                      items: <DropdownMenuItem<int?>>[
                        const DropdownMenuItem<int?>(
                          value: null,
                          child: Text('未设置'),
                        ),
                        ...months.map((month) {
                          return DropdownMenuItem<int?>(
                            value: month,
                            child: Text('$month 月'),
                          );
                        }),
                      ],
                      onChanged: (value) {
                        setState(() {
                          _selectedBirthMonth = value;
                        });
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _cityController,
                decoration: const InputDecoration(
                  labelText: '地区',
                  prefixIcon: Icon(Icons.location_on_outlined),
                ),
                validator: (value) {
                  final text = value?.trim() ?? '';
                  if (text.isEmpty) {
                    return '请输入地区。';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _signatureController,
                maxLength: 60,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: '个性签名',
                  prefixIcon: Icon(Icons.edit_note_outlined),
                ),
                validator: (value) {
                  final text = value?.trim() ?? '';
                  if (text.isEmpty) {
                    return '请输入个性签名。';
                  }
                  if (text.length < 6) {
                    return '个性签名至少 6 个字符。';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 8),
              Text(
                '头像主题',
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
                      child: Text(option.label.characters.take(1).toString()),
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
                  child: Text('保存资料'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _IntroVideoEditorSheet extends StatefulWidget {
  const _IntroVideoEditorSheet({
    required this.user,
  });

  final AppUser user;

  @override
  State<_IntroVideoEditorSheet> createState() => _IntroVideoEditorSheetState();
}

class _IntroVideoEditorSheetState extends State<_IntroVideoEditorSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _summaryController;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.user.introVideoTitle);
    _summaryController =
        TextEditingController(text: widget.user.introVideoSummary);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _summaryController.dispose();
    super.dispose();
  }

  void _submit() {
    final isValid = _formKey.currentState?.validate() ?? false;
    if (!isValid) {
      return;
    }

    Navigator.of(context).pop(
      _IntroVideoDraft(
        title: _titleController.text.trim(),
        summary: _summaryController.text.trim(),
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
      child: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                '编辑视频介绍',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              const Text('先用标题和简介管理视频介绍内容，后续可直接接入真实上传。'),
              const SizedBox(height: 18),
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: '视频标题',
                  prefixIcon: Icon(Icons.smart_display_outlined),
                ),
                validator: (value) {
                  final text = value?.trim() ?? '';
                  if (text.isEmpty) {
                    return '请输入视频标题。';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _summaryController,
                maxLines: 4,
                maxLength: 120,
                decoration: const InputDecoration(
                  labelText: '视频简介',
                  prefixIcon: Icon(Icons.notes_outlined),
                ),
                validator: (value) {
                  final text = value?.trim() ?? '';
                  if (text.isEmpty) {
                    return '请输入视频简介。';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 22),
              FilledButton(
                onPressed: _submit,
                child: const Padding(
                  padding: EdgeInsets.symmetric(vertical: 14),
                  child: Text('保存视频介绍'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _WorkEditorSheet extends StatefulWidget {
  const _WorkEditorSheet();

  @override
  State<_WorkEditorSheet> createState() => _WorkEditorSheetState();
}

class _WorkEditorSheetState extends State<_WorkEditorSheet> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _summaryController = TextEditingController();
  ProfileMediaWorkType _selectedType = ProfileMediaWorkType.voice;

  @override
  void dispose() {
    _titleController.dispose();
    _summaryController.dispose();
    super.dispose();
  }

  void _submit() {
    final isValid = _formKey.currentState?.validate() ?? false;
    if (!isValid) {
      return;
    }

    Navigator.of(context).pop(
      _WorkDraft(
        type: _selectedType,
        title: _titleController.text.trim(),
        summary: _summaryController.text.trim(),
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
      child: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                '新增作品',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              const Text('作品支持语音、视频、图片和动图，后续可继续补上传与审核能力。'),
              const SizedBox(height: 18),
              DropdownButtonFormField<ProfileMediaWorkType>(
                initialValue: _selectedType,
                decoration: const InputDecoration(
                  labelText: '作品类型',
                  prefixIcon: Icon(Icons.category_outlined),
                ),
                items: ProfileMediaWorkType.values.map((type) {
                  return DropdownMenuItem<ProfileMediaWorkType>(
                    value: type,
                    child: Text(type.label),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value == null) {
                    return;
                  }
                  setState(() {
                    _selectedType = value;
                  });
                },
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: '作品标题',
                  prefixIcon: Icon(Icons.title_outlined),
                ),
                validator: (value) {
                  final text = value?.trim() ?? '';
                  if (text.isEmpty) {
                    return '请输入作品标题。';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _summaryController,
                maxLines: 4,
                maxLength: 120,
                decoration: const InputDecoration(
                  labelText: '作品说明',
                  prefixIcon: Icon(Icons.description_outlined),
                ),
                validator: (value) {
                  final text = value?.trim() ?? '';
                  if (text.isEmpty) {
                    return '请输入作品说明。';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 22),
              FilledButton(
                onPressed: _submit,
                child: const Padding(
                  padding: EdgeInsets.symmetric(vertical: 14),
                  child: Text('添加作品'),
                ),
              ),
            ],
          ),
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
  State<_PhoneVerificationSheet> createState() =>
      _PhoneVerificationSheetState();
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
          : '演示验证码：${session.debugCode}。后续可替换为真实短信服务。';
    });
  }

  Future<void> _submit() async {
    final codeValidation =
        AuthValidators.verificationCode(_codeController.text);
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
            '手机号认证',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          const Text('当前为演示模式，验证码会直接显示在界面上，方便你完整测试认证闭环。'),
          const SizedBox(height: 18),
          TextField(
            controller: _phoneController,
            keyboardType: TextInputType.phone,
            decoration: const InputDecoration(
              labelText: '手机号',
              prefixIcon: Icon(Icons.phone_android_outlined),
            ),
          ),
          const SizedBox(height: 12),
          FilledButton.tonal(
            onPressed: widget.controller.isBusy ? null : _sendCode,
            child: const Text('发送验证码'),
          ),
          const SizedBox(height: 18),
          TextField(
            controller: _codeController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: '验证码',
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
              child: Text('确认手机号'),
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

class _IdentityVerificationSheetState
    extends State<_IdentityVerificationSheet> {
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
              '身份证认证',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            const Text('后续可以把这里替换成合规实名服务，当前版本已经打通表单、校验和状态变更。'),
            const SizedBox(height: 18),
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: '真实姓名',
                prefixIcon: Icon(Icons.person_pin_outlined),
              ),
              validator: AuthValidators.legalName,
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: _idController,
              textCapitalization: TextCapitalization.characters,
              decoration: const InputDecoration(
                labelText: '身份证号',
                prefixIcon: Icon(Icons.badge_outlined),
              ),
              validator: AuthValidators.idNumber,
            ),
            const SizedBox(height: 22),
            FilledButton(
              onPressed: widget.controller.isBusy ? null : _submit,
              child: const Padding(
                padding: EdgeInsets.symmetric(vertical: 14),
                child: Text('提交身份信息'),
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
            '本人头像认证',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          const Text('当前版本已经把人脸认证的交互和状态流转跑通，后续可直接接入相机采集和活体检测。'),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFEFF6FF),
              borderRadius: BorderRadius.circular(22),
            ),
            child: const Text('规则：如果后续更换头像，本人头像认证会自动重置。'),
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
            title: const Text('我确认当前头像属于账号本人。'),
          ),
          const SizedBox(height: 16),
          FilledButton(
            onPressed: widget.controller.isBusy || !_confirmed ? null : _submit,
            child: const Padding(
              padding: EdgeInsets.symmetric(vertical: 14),
              child: Text('开始人脸认证'),
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
    required this.gender,
    required this.birthYear,
    required this.birthMonth,
    required this.city,
    required this.signature,
  });

  final String name;
  final String avatarKey;
  final UserGender gender;
  final int? birthYear;
  final int? birthMonth;
  final String city;
  final String signature;
}

class _IntroVideoDraft {
  const _IntroVideoDraft({
    required this.title,
    required this.summary,
  });

  final String title;
  final String summary;
}

class _WorkDraft {
  const _WorkDraft({
    required this.type,
    required this.title,
    required this.summary,
  });

  final ProfileMediaWorkType type;
  final String title;
  final String summary;
}
