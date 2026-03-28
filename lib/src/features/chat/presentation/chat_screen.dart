import 'package:flutter/material.dart';

import '../../../core/theme/user_tone_palette.dart';
import '../../../core/widgets/app_profile_avatar.dart';
import '../../auth/domain/app_user.dart';
import '../domain/chat_conversation.dart';
import '../domain/chat_inbox_segment.dart';
import 'chat_controller.dart';

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

  void _syncComposerWithConversation(String conversationId) {
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
        final selectedConversation = widget.controller.selectedConversation;
        if (selectedConversation == null) {
          _lastConversationId = null;
          return _ConversationListView(
            controller: widget.controller,
            user: widget.user,
            palette: palette,
            selectedSegment: _selectedSegment,
            onSegmentChanged: (segment) {
              setState(() {
                _selectedSegment = _selectedSegment == segment ? null : segment;
              });
            },
          );
        }
        _syncComposerWithConversation(selectedConversation.id);

        return Column(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
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
                        Text(selectedConversation.subtitle),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: widget.controller.messages.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final message = widget.controller.messages[index];
                  final isMine = message.senderId == widget.user.id;
                  return Align(
                    alignment:
                        isMine ? Alignment.centerRight : Alignment.centerLeft,
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 320),
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          color: isMine ? palette.primary : Colors.white,
                          borderRadius: BorderRadius.circular(22),
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
                                      color: isMine ? Colors.white70 : null,
                                    ),
                              ),
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
                    Row(
                      children: <Widget>[
                        Expanded(
                          child: TextField(
                            controller: _composerController,
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
                            onSubmitted: (_) => _send(),
                            maxLength: 280,
                            decoration: InputDecoration(
                              hintText: '输入消息',
                              prefixIcon: const Icon(Icons.chat_bubble_outline),
                              helperText:
                                  '${_composerController.text.length}/280 字',
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        FilledButton(
                          onPressed: widget.controller.isBusy ? null : _send,
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
                        '草稿会按会话暂存，在 App 打开期间不会丢失。',
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
    switch (conversation.id) {
      case 'concierge':
        return const <String>[
          '我刚完成了一项新的认证。',
          '告诉我下一步该测什么。',
          '我现在可以开始体验聊天了。',
        ];
      case 'night-owls':
        return const <String>[
          '我今晚正在测试新手引导流程。',
          '现在账号中心顺畅多了。',
          '下一步我想试试语音房。',
        ];
      default:
        return const <String>[
          '你好，很高兴认识你。',
          '你那边测试得怎么样？',
          '晚点我们继续在这里聊吧？',
        ];
    }
  }

  String _deliveryStatusLabel(String value) {
    if (value == 'Delivered') {
      return '已送达';
    }
    return value;
  }
}

class _ConversationListView extends StatelessWidget {
  const _ConversationListView({
    required this.controller,
    required this.user,
    required this.palette,
    required this.selectedSegment,
    required this.onSegmentChanged,
  });

  final ChatController controller;
  final AppUser user;
  final UserTonePalette palette;
  final ChatInboxSegment? selectedSegment;
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
      padding: const EdgeInsets.all(20),
      children: <Widget>[
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: palette.surface,
            borderRadius: BorderRadius.circular(26),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                '消息列表',
                style: Theme.of(context).textTheme.titleLarge,
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
                      '上方是关系分类，下面是聊天对话消息。有新消息时会显示红点提醒。',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
                ],
              ),
            ],
          ),
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
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
            ),
            child: const Text('当前分类下还没有对话，先去广场或圈子里认识新朋友吧。'),
          ),
        for (final conversation in visibleConversations) ...<Widget>[
          _ConversationCard(
            conversation: conversation,
            palette: palette,
            onTap: () => controller.openConversation(conversation.id),
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
    required this.palette,
    required this.onTap,
  });

  final ChatConversation conversation;
  final UserTonePalette palette;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(24),
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
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: palette.surface,
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Text(conversation.categoryLabel),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      conversation.subtitle,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 8),
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
    );
  }
}
