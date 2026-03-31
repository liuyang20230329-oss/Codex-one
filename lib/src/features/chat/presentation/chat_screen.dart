import 'package:flutter/material.dart';

import '../../../core/brand/app_brand.dart';
import '../../../core/theme/user_tone_palette.dart';
import '../../../core/widgets/app_profile_avatar.dart';
import '../../auth/domain/app_user.dart';
import '../domain/chat_conversation.dart';
import '../domain/chat_inbox_segment.dart';
import '../domain/chat_message_type.dart';
import 'chat_controller.dart';

/// Renders the relationship inbox and the selected conversation detail while
/// keeping composer drafts scoped per conversation.
class ChatScreen extends StatefulWidget {
  const ChatScreen({
    super.key,
    required this.controller,
    required this.user,
  });

  final ChatController controller;
  final AppUser user;

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _composerController = TextEditingController();
  String? _lastConversationId;
  ChatInboxSegment? _selectedSegment;

  @override
  void dispose() {
    _composerController.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    final success = await widget.controller.sendMessage(
      _composerController.text,
    );
    if (!success) {
      return;
    }
    _composerController.clear();
  }

  Future<void> _sendPresetMessage({
    required ChatMessageType type,
    required String text,
    String? metadataLabel,
  }) async {
    final success = await widget.controller.sendMessage(
      text,
      type: type,
      metadataLabel: metadataLabel,
    );
    if (!success) {
      return;
    }
    _composerController.clear();
  }

  Future<void> _openCreateConversationDialog() async {
    final titleController = TextEditingController();
    final subtitleController = TextEditingController(text: '刚刚创建');
    var selectedSegment = ChatInboxSegment.friends;

    final draft = await showDialog<_CreateConversationDraft>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('新建会话'),
              content: SizedBox(
                width: 420,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    TextField(
                      controller: titleController,
                      textInputAction: TextInputAction.next,
                      decoration: const InputDecoration(
                        labelText: '会话标题',
                        hintText: '例如：今晚聊聊语音房',
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: subtitleController,
                      decoration: const InputDecoration(
                        labelText: '副标题',
                        hintText: '例如：刚刚创建',
                      ),
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<ChatInboxSegment>(
                      key: ValueKey<ChatInboxSegment>(selectedSegment),
                      initialValue: selectedSegment,
                      decoration: const InputDecoration(
                        labelText: '关系分类',
                      ),
                      items: ChatInboxSegment.values
                          .where((item) => item != ChatInboxSegment.system)
                          .map(
                            (item) => DropdownMenuItem<ChatInboxSegment>(
                              value: item,
                              child: Text(item.label),
                            ),
                          )
                          .toList(),
                      onChanged: (value) {
                        if (value == null) {
                          return;
                        }
                        setState(() {
                          selectedSegment = value;
                        });
                      },
                    ),
                  ],
                ),
              ),
              actions: <Widget>[
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('取消'),
                ),
                FilledButton(
                  onPressed: () {
                    final title = titleController.text.trim();
                    if (title.isEmpty) {
                      return;
                    }
                    Navigator.of(context).pop(
                      _CreateConversationDraft(
                        title: title,
                        subtitle: subtitleController.text.trim().isEmpty
                            ? '刚刚创建'
                            : subtitleController.text.trim(),
                        segment: selectedSegment,
                      ),
                    );
                  },
                  child: const Text('创建'),
                ),
              ],
            );
          },
        );
      },
    );

    titleController.dispose();
    subtitleController.dispose();

    if (draft == null) {
      return;
    }

    final success = await widget.controller.createConversation(
      title: draft.title,
      subtitle: draft.subtitle,
      categoryLabel: _categoryLabelForSegment(draft.segment),
      segment: draft.segment,
    );
    if (!mounted) {
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(success ? '已创建新的会话。' : '当前无法创建会话，请稍后再试。'),
      ),
    );
  }

  Future<void> _handleConversationAction(
    ChatConversation conversation,
    _ConversationAction action,
  ) async {
    switch (action) {
      case _ConversationAction.pin:
        await widget.controller.togglePinned(conversation.id);
        if (!mounted) {
          return;
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(conversation.isPinned ? '已取消置顶。' : '已置顶该会话。'),
          ),
        );
        return;
      case _ConversationAction.delete:
        final confirmed = await showDialog<bool>(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: const Text('删除会话'),
              content: Text('确定删除“${conversation.title}”吗？删除后聊天记录将从当前设备移除。'),
              actions: <Widget>[
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: const Text('取消'),
                ),
                FilledButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  child: const Text('删除'),
                ),
              ],
            );
          },
        );
        if (confirmed != true) {
          return;
        }
        await widget.controller.deleteConversation(conversation.id);
        if (!mounted) {
          return;
        }
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('会话已删除。')),
        );
        return;
    }
  }

  void _syncComposerWithConversation(String conversationId) {
    // Drafts are stored per conversation so users can switch threads without
    // losing what they were typing.
    if (_lastConversationId == conversationId) {
      return;
    }
    _lastConversationId = conversationId;
    final draft = widget.controller.draftFor(conversationId);
    _composerController.value = TextEditingValue(
      text: draft,
      selection: TextSelection.collapsed(offset: draft.length),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.controller,
      builder: (context, _) {
        final palette = tonePaletteFor(widget.user.gender);
        final currentUser = widget.user;
        final selectedConversation = widget.controller.selectedConversation;
        if (selectedConversation == null) {
          _lastConversationId = null;
          return _ConversationListView(
            controller: widget.controller,
            user: currentUser,
            palette: palette,
            selectedSegment: _selectedSegment,
            onCreateConversation: _openCreateConversationDialog,
            onMarkAllRead: widget.controller.markAllRead,
            onConversationActionSelected: _handleConversationAction,
            onSegmentChanged: (segment) {
              setState(() {
                _selectedSegment = _selectedSegment == segment ? null : segment;
              });
            },
          );
        }
        _syncComposerWithConversation(selectedConversation.id);
        final canSendMessages =
            widget.controller.canSendToSelectedConversation(currentUser);

        return Column(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
              child: Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: palette.cardBackground,
                  borderRadius: BorderRadius.circular(26),
                  border: Border.all(color: palette.outline),
                ),
                child: Row(
                  children: <Widget>[
                    IconButton.filledTonal(
                      onPressed: widget.controller.closeConversation,
                      icon: const Icon(Icons.arrow_back),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            selectedConversation.title,
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            selectedConversation.subtitle,
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(
                                  color: palette.mutedForeground,
                                ),
                          ),
                        ],
                      ),
                    ),
                    if (selectedConversation.isPinned)
                      Icon(
                        Icons.push_pin_rounded,
                        color: palette.primary,
                      ),
                  ],
                ),
              ),
            ),
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: widget.controller.messages.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final message = widget.controller.messages[index];
                  final isMine = message.senderId == currentUser.id;
                  return Align(
                    alignment:
                        isMine ? Alignment.centerRight : Alignment.centerLeft,
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 320),
                      child: Container(
                        decoration: BoxDecoration(
                          color:
                              isMine ? palette.primary : palette.cardBackground,
                          borderRadius: BorderRadius.circular(22),
                          border: isMine
                              ? null
                              : Border.all(color: palette.outline),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text(
                                isMine ? '我' : message.senderName,
                                style: Theme.of(context)
                                    .textTheme
                                    .labelLarge
                                    ?.copyWith(
                                      color: isMine
                                          ? Colors.white70
                                          : AppBrand.ink.withValues(
                                              alpha: 0.64,
                                            ),
                                    ),
                              ),
                              if (message.type !=
                                  ChatMessageType.text) ...<Widget>[
                                const SizedBox(height: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: isMine
                                        ? Colors.white.withValues(alpha: 0.18)
                                        : palette.surface,
                                    borderRadius: BorderRadius.circular(999),
                                  ),
                                  child: Text(
                                    message.type.label,
                                    style: Theme.of(context)
                                        .textTheme
                                        .labelMedium
                                        ?.copyWith(
                                          color: isMine ? Colors.white : null,
                                        ),
                                  ),
                                ),
                              ],
                              const SizedBox(height: 6),
                              Text(
                                message.text,
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyLarge
                                    ?.copyWith(
                                      color: isMine ? Colors.white : null,
                                    ),
                              ),
                              if ((message.metadataLabel ?? message.mediaUrl)
                                  case final String meta) ...<Widget>[
                                const SizedBox(height: 8),
                                Text(
                                  meta,
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodySmall
                                      ?.copyWith(
                                        color: isMine ? Colors.white70 : null,
                                      ),
                                ),
                              ],
                              const SizedBox(height: 8),
                              Text(
                                _deliveryStatusLabel(message.deliveryStatus),
                                style: Theme.of(context)
                                    .textTheme
                                    .labelSmall
                                    ?.copyWith(
                                      color: isMine ? Colors.white70 : null,
                                    ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
                child: Column(
                  children: <Widget>[
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: <Widget>[
                          for (final suggestion in _quickRepliesFor(
                            selectedConversation,
                          )) ...<Widget>[
                            ActionChip(
                              label: Text(suggestion),
                              onPressed: () {
                                _composerController.value = TextEditingValue(
                                  text: suggestion,
                                  selection: TextSelection.collapsed(
                                    offset: suggestion.length,
                                  ),
                                );
                                widget.controller.updateDraft(
                                  conversationId: selectedConversation.id,
                                  value: suggestion,
                                );
                              },
                            ),
                            const SizedBox(width: 8),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),
                    if (canSendMessages) ...<Widget>[
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: <Widget>[
                          ActionChip(
                            avatar: const Icon(Icons.emoji_emotions_outlined),
                            label: const Text('表情'),
                            onPressed: () {
                              _sendPresetMessage(
                                type: ChatMessageType.emoji,
                                text: '送你一个打招呼表情',
                                metadataLabel: '😊 默认表情',
                              );
                            },
                          ),
                          ActionChip(
                            avatar: const Icon(Icons.image_outlined),
                            label: const Text('图片'),
                            onPressed: () {
                              _sendPresetMessage(
                                type: ChatMessageType.image,
                                text: '分享了一张图片占位',
                                metadataLabel: '演示图片素材',
                              );
                            },
                          ),
                          ActionChip(
                            avatar: const Icon(Icons.mic_none_rounded),
                            label: const Text('语音'),
                            onPressed: () {
                              _sendPresetMessage(
                                type: ChatMessageType.voice,
                                text: '分享了一条语音占位',
                                metadataLabel: '15 秒语音片段',
                              );
                            },
                          ),
                          ActionChip(
                            avatar: const Icon(Icons.videocam_outlined),
                            label: const Text('视频'),
                            onPressed: () {
                              _sendPresetMessage(
                                type: ChatMessageType.video,
                                text: '分享了一段视频占位',
                                metadataLabel: '30 秒视频介绍',
                              );
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                    ],
                    if (!canSendMessages) ...<Widget>[
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF5E8DE),
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(color: const Color(0xFFE8C6AD)),
                        ),
                        child: const Text(
                          '当前会话属于私聊或关系对话，请先完成手机号认证后再发送消息。你仍然可以先在系统引导会话里继续体验。',
                        ),
                      ),
                      const SizedBox(height: 10),
                    ],
                    Row(
                      children: <Widget>[
                        Expanded(
                          child: TextField(
                            controller: _composerController,
                            enabled:
                                canSendMessages && !widget.controller.isBusy,
                            minLines: 1,
                            maxLines: 4,
                            textInputAction: TextInputAction.send,
                            onChanged: (value) {
                              setState(() {});
                              widget.controller.updateDraft(
                                conversationId: selectedConversation.id,
                                value: value,
                              );
                            },
                            onSubmitted: (_) {
                              if (canSendMessages) {
                                _send();
                              }
                            },
                            maxLength: 280,
                            decoration: InputDecoration(
                              hintText:
                                  canSendMessages ? '输入消息' : '完成手机号认证后可发送私聊消息',
                              prefixIcon: const Icon(Icons.chat_bubble_outline),
                              helperText: canSendMessages
                                  ? '${_composerController.text.length}/280 字'
                                  : '系统引导会话不受此限制',
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        FilledButton(
                          onPressed:
                              widget.controller.isBusy || !canSendMessages
                                  ? null
                                  : _send,
                          style: FilledButton.styleFrom(
                            backgroundColor: palette.primary,
                            foregroundColor: palette.foreground,
                          ),
                          child: const Padding(
                            padding: EdgeInsets.symmetric(vertical: 16),
                            child: Icon(Icons.send_rounded),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        canSendMessages
                            ? '草稿会按会话暂存，在 App 打开期间不会丢失。'
                            : '完成手机号认证后，当前输入区会自动恢复可发送状态。',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  List<String> _quickRepliesFor(ChatConversation conversation) {
    if (_isGuidedConversationId(conversation.id)) {
      return const <String>[
        '我刚完成了一项新的认证。',
        '告诉我下一步该测什么。',
        '我现在可以开始体验聊天了。',
      ];
    }
    if (conversation.id.startsWith('night-owls')) {
      return const <String>[
        '我今晚正在测试新手引导流程。',
        '现在账号中心顺畅多了。',
        '下一步我想试试语音房。',
      ];
    }
    return const <String>[
      '你好，很高兴认识你。',
      '你那边测试得怎么样？',
      '晚点我们继续在这里聊吧？',
    ];
  }

  String _deliveryStatusLabel(String value) {
    switch (value) {
      case 'Delivered':
        return '已送达';
      case 'Read':
        return '已读';
      case 'Sending':
        return '发送中';
      case 'Failed':
        return '发送失败';
      default:
        return value;
    }
  }
}

class _ConversationListView extends StatelessWidget {
  const _ConversationListView({
    required this.controller,
    required this.user,
    required this.palette,
    required this.selectedSegment,
    required this.onCreateConversation,
    required this.onMarkAllRead,
    required this.onConversationActionSelected,
    required this.onSegmentChanged,
  });

  final ChatController controller;
  final AppUser user;
  final UserTonePalette palette;
  final ChatInboxSegment? selectedSegment;
  final Future<void> Function() onCreateConversation;
  final Future<void> Function() onMarkAllRead;
  final Future<void> Function(
    ChatConversation conversation,
    _ConversationAction action,
  ) onConversationActionSelected;
  final ValueChanged<ChatInboxSegment> onSegmentChanged;

  @override
  Widget build(BuildContext context) {
    if (controller.isBusy && controller.conversations.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    final visibleConversations = selectedSegment == null
        ? controller.conversations
        : controller.conversations
            .where((item) => item.segment == selectedSegment)
            .toList();

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 28),
      children: <Widget>[
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: palette.heroGradient,
            borderRadius: BorderRadius.circular(26),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                '消息列表',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: Colors.white,
                    ),
              ),
              const SizedBox(height: 8),
              Row(
                children: <Widget>[
                  AppProfileAvatar(
                    user: user,
                    radius: 18,
                    showVerificationBadge: true,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      user.canSendPrivateMessages
                          ? '上方是关系分类，下面是聊天对话消息。有新消息时会显示红点提醒。'
                          : '上方是关系分类，下面是聊天对话消息。完成手机号认证后，可正式发起和回复私聊。',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.white.withValues(alpha: 0.84),
                          ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: <Widget>[
            OutlinedButton.icon(
              onPressed: onCreateConversation,
              icon: const Icon(Icons.add_comment_outlined),
              label: const Text('新建会话'),
              style: OutlinedButton.styleFrom(
                backgroundColor: palette.cardBackground,
                side: BorderSide(color: palette.outline),
              ),
            ),
            TextButton.icon(
              onPressed:
                  controller.totalUnreadCount == 0 ? null : onMarkAllRead,
              icon: const Icon(Icons.mark_chat_read_outlined),
              label: Text(
                controller.totalUnreadCount == 0
                    ? '全部已读'
                    : '全部已读 (${controller.totalUnreadCount})',
              ),
            ),
          ],
        ),
        const SizedBox(height: 18),
        Text(
          '关系模块',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: ChatInboxSegment.values
              .where((segment) => segment != ChatInboxSegment.system)
              .map(
                (segment) => _InboxSummaryCard(
                  segment: segment,
                  palette: palette,
                  isSelected: selectedSegment == segment,
                  count: controller.conversationCountForSegment(segment),
                  unreadCount: controller.unreadCountForSegment(segment),
                  onTap: () => onSegmentChanged(segment),
                ),
              )
              .toList(),
        ),
        const SizedBox(height: 20),
        Row(
          children: <Widget>[
            Text(
              selectedSegment == null ? '聊天对话' : '${selectedSegment!.label}对话',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const Spacer(),
            if (selectedSegment != null)
              TextButton(
                onPressed: () => onSegmentChanged(selectedSegment!),
                child: const Text('查看全部'),
              ),
          ],
        ),
        const SizedBox(height: 8),
        if (visibleConversations.isEmpty)
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: palette.cardBackground,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: palette.outline),
            ),
            child: const Text('当前分类下还没有对话，先去广场或圈子里认识新朋友吧。'),
          ),
        for (final conversation in visibleConversations) ...<Widget>[
          _ConversationCard(
            conversation: conversation,
            user: user,
            palette: palette,
            onTap: () => controller.openConversation(conversation.id),
            onActionSelected: (action) {
              onConversationActionSelected(conversation, action);
            },
          ),
          const SizedBox(height: 12),
        ],
        if (controller.errorMessage != null) ...<Widget>[
          const SizedBox(height: 8),
          Text(
            controller.errorMessage!,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: const Color(0xFFB91C1C),
                ),
          ),
        ],
      ],
    );
  }
}

class _InboxSummaryCard extends StatelessWidget {
  const _InboxSummaryCard({
    required this.segment,
    required this.palette,
    required this.isSelected,
    required this.count,
    required this.unreadCount,
    required this.onTap,
  });

  final ChatInboxSegment segment;
  final UserTonePalette palette;
  final bool isSelected;
  final int count;
  final int unreadCount;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(24),
      onTap: onTap,
      child: Ink(
        width: 156,
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: isSelected ? palette.primary : Colors.white,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                Icon(
                  _iconForSegment(segment),
                  color: isSelected ? Colors.white : palette.primary,
                ),
                const Spacer(),
                if (unreadCount > 0)
                  Badge.count(
                    count: unreadCount,
                    backgroundColor: palette.badge,
                  ),
              ],
            ),
            const SizedBox(height: 14),
            Text(
              segment.label,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: isSelected ? Colors.white : null,
                  ),
            ),
            const SizedBox(height: 6),
            Text(
              '$count 个会话',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: isSelected ? Colors.white70 : null,
                  ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _iconForSegment(ChatInboxSegment segment) {
    switch (segment) {
      case ChatInboxSegment.friends:
        return Icons.people_alt_outlined;
      case ChatInboxSegment.hot:
        return Icons.local_fire_department_outlined;
      case ChatInboxSegment.followers:
        return Icons.favorite_border;
      case ChatInboxSegment.following:
        return Icons.visibility_outlined;
      case ChatInboxSegment.system:
        return Icons.notifications_outlined;
    }
  }
}

class _ConversationCard extends StatelessWidget {
  const _ConversationCard({
    required this.conversation,
    required this.user,
    required this.palette,
    required this.onTap,
    required this.onActionSelected,
  });

  final ChatConversation conversation;
  final AppUser user;
  final UserTonePalette palette;
  final VoidCallback onTap;
  final ValueChanged<_ConversationAction> onActionSelected;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: palette.cardBackground,
      borderRadius: BorderRadius.circular(24),
      child: Ink(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: palette.outline),
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: palette.primary.withValues(alpha: 0.05),
              blurRadius: 16,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(24),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Row(
              children: <Widget>[
                Stack(
                  clipBehavior: Clip.none,
                  children: <Widget>[
                    CircleAvatar(
                      radius: 24,
                      backgroundColor: palette.surface,
                      foregroundColor: palette.primary,
                      child: Text(
                        conversation.title.characters.take(1).toString(),
                      ),
                    ),
                    if (conversation.unreadCount > 0)
                      const Positioned(
                        right: -2,
                        top: -2,
                        child: CircleAvatar(
                          radius: 6,
                          backgroundColor: Colors.redAccent,
                        ),
                      ),
                  ],
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Row(
                        children: <Widget>[
                          Expanded(
                            child: Text(
                              conversation.title,
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                          ),
                          Text(
                            _conversationTimeLabel(conversation.updatedAt),
                            style:
                                Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: palette.mutedForeground,
                                    ),
                          ),
                          if (conversation.isPinned) ...<Widget>[
                            const SizedBox(width: 8),
                            Icon(
                              Icons.push_pin_rounded,
                              size: 16,
                              color: palette.primary,
                            ),
                          ],
                          const SizedBox(width: 10),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: palette.highlight,
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: Text(conversation.categoryLabel),
                          ),
                          if (!_canCurrentUserSend(
                              user, conversation)) ...<Widget>[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF5E8DE),
                                borderRadius: BorderRadius.circular(999),
                              ),
                              child: const Text('待认证'),
                            ),
                          ],
                          PopupMenuButton<_ConversationAction>(
                            tooltip: '会话操作',
                            onSelected: onActionSelected,
                            itemBuilder: (context) =>
                                <PopupMenuEntry<_ConversationAction>>[
                              PopupMenuItem<_ConversationAction>(
                                value: _ConversationAction.pin,
                                child: Text(
                                  conversation.isPinned ? '取消置顶' : '置顶会话',
                                ),
                              ),
                              const PopupMenuItem<_ConversationAction>(
                                value: _ConversationAction.delete,
                                child: Text('删除会话'),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: <Widget>[
                          Expanded(
                            child: Text(
                              conversation.subtitle,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(
                                    color: palette.mutedForeground,
                                  ),
                            ),
                          ),
                          if (conversation.isOnline) ...<Widget>[
                            const SizedBox(width: 8),
                            const Icon(
                              Icons.circle,
                              size: 10,
                              color: Color(0xFF16A34A),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '在线',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 10),
                      Text(
                        conversation.lastMessagePreview,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  bool _canCurrentUserSend(AppUser user, ChatConversation conversation) {
    if (conversation.segment == ChatInboxSegment.system ||
        _isGuidedConversationId(conversation.id)) {
      return true;
    }
    return user.canSendPrivateMessages;
  }
}

enum _ConversationAction {
  pin,
  delete,
}

class _CreateConversationDraft {
  const _CreateConversationDraft({
    required this.title,
    required this.subtitle,
    required this.segment,
  });

  final String title;
  final String subtitle;
  final ChatInboxSegment segment;
}

String _categoryLabelForSegment(ChatInboxSegment segment) {
  switch (segment) {
    case ChatInboxSegment.friends:
      return '私聊';
    case ChatInboxSegment.hot:
      return '热聊';
    case ChatInboxSegment.followers:
      return '关注我的';
    case ChatInboxSegment.following:
      return '我关注的';
    case ChatInboxSegment.system:
      return '系统';
  }
}

bool _isGuidedConversationId(String conversationId) {
  return conversationId == 'concierge' ||
      conversationId.startsWith('concierge-');
}

String _conversationTimeLabel(DateTime value) {
  final now = DateTime.now();
  final difference = now.difference(value);
  if (difference.inMinutes < 1) {
    return '刚刚';
  }
  if (difference.inMinutes < 60) {
    return '${difference.inMinutes}分钟前';
  }
  if (difference.inHours < 24) {
    return '${difference.inHours}小时前';
  }
  if (difference.inDays == 1) {
    return '昨天';
  }
  if (difference.inDays < 7) {
    return '${difference.inDays}天前';
  }
  return '${value.month}月${value.day}日';
}
