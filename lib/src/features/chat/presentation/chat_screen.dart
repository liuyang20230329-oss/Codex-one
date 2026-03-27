import 'package:flutter/material.dart';

import '../../auth/domain/app_user.dart';
import '../domain/chat_conversation.dart';
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

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.controller,
      builder: (context, _) {
        final selectedConversation = widget.controller.selectedConversation;
        if (selectedConversation == null) {
          return _ConversationListView(
            controller: widget.controller,
            user: widget.user,
          );
        }

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
                reverse: false,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: widget.controller.messages.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final message = widget.controller.messages[index];
                  final isMine = message.senderId == widget.user.id;
                  return Align(
                    alignment: isMine
                        ? Alignment.centerRight
                        : Alignment.centerLeft,
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 320),
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          color: isMine
                              ? const Color(0xFF0F766E)
                              : Colors.white,
                          borderRadius: BorderRadius.circular(22),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text(
                                isMine ? 'You' : message.senderName,
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
                                message.deliveryStatus,
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
                child: Row(
                  children: <Widget>[
                    Expanded(
                      child: TextField(
                        controller: _composerController,
                        minLines: 1,
                        maxLines: 4,
                        decoration: const InputDecoration(
                          hintText: 'Type your message',
                          prefixIcon: Icon(Icons.chat_bubble_outline),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    FilledButton(
                      onPressed: widget.controller.isBusy ? null : _send,
                      child: const Padding(
                        padding: EdgeInsets.symmetric(vertical: 16),
                        child: Icon(Icons.send_rounded),
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
}

class _ConversationListView extends StatelessWidget {
  const _ConversationListView({
    required this.controller,
    required this.user,
  });

  final ChatController controller;
  final AppUser user;

  @override
  Widget build(BuildContext context) {
    if (controller.isBusy && controller.conversations.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    return ListView(
      padding: const EdgeInsets.all(20),
      children: <Widget>[
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: const Color(0xFFEFF6FF),
            borderRadius: BorderRadius.circular(26),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                'Text chat MVP',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              Text(
                'Unverified users can already chat. Later we can layer in exposure limits, trust rules, and moderation weights without changing this navigation.',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),
        for (final conversation in controller.conversations) ...<Widget>[
          _ConversationCard(
            conversation: conversation,
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

class _ConversationCard extends StatelessWidget {
  const _ConversationCard({
    required this.conversation,
    required this.onTap,
  });

  final ChatConversation conversation;
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
              CircleAvatar(
                backgroundColor: const Color(0xFFFFF7ED),
                foregroundColor: const Color(0xFFF97316),
                child: Text(conversation.title.characters.take(1).toString()),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      conversation.title,
                      style: Theme.of(context).textTheme.titleMedium,
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
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: <Widget>[
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE6FFFB),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(conversation.categoryLabel),
                  ),
                  if (conversation.unreadCount > 0) ...<Widget>[
                    const SizedBox(height: 10),
                    CircleAvatar(
                      radius: 11,
                      backgroundColor: const Color(0xFF0F766E),
                      foregroundColor: Colors.white,
                      child: Text(
                        '${conversation.unreadCount}',
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                              color: Colors.white,
                            ),
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
