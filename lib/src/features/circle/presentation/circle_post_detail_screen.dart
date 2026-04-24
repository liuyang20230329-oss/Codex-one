import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/brand/app_brand.dart';
import '../../../core/theme/user_tone_palette.dart';
import '../../auth/domain/app_user.dart';
import '../domain/circle_post.dart';
import 'bloc/circle_bloc.dart';

class CirclePostDetailScreen extends StatefulWidget {
  const CirclePostDetailScreen({
    super.key,
    required this.user,
    required this.post,
  });

  final AppUser user;
  final CirclePost post;

  @override
  State<CirclePostDetailScreen> createState() => _CirclePostDetailScreenState();
}

class _CirclePostDetailScreenState extends State<CirclePostDetailScreen> {
  final TextEditingController _commentController = TextEditingController();
  final FocusNode _commentFocusNode = FocusNode();
  String? _replyToCommentId;
  String? _replyToAuthorName;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CircleBloc>().add(CirclePostDetailLoaded(widget.post.id));
    });
  }

  @override
  void dispose() {
    _commentController.dispose();
    _commentFocusNode.dispose();
    super.dispose();
  }

  Future<void> _submitComment() async {
    final content = _commentController.text.trim();
    if (content.isEmpty) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(const SnackBar(content: Text('先写点评论内容再发送。')));
      return;
    }

    context.read<CircleBloc>().add(CircleCommentAdded(
          postId: widget.post.id,
          content: content,
          parentCommentId: _replyToCommentId,
        ));

    final state = await context.read<CircleBloc>().stream.firstWhere((s) => !s.isSubmittingComment);
    if (!mounted) return;
    if (state.detailFor(widget.post.id) == null) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(content: Text(state.detailErrorMessage ?? '评论发送失败，请稍后再试。')),
        );
      return;
    }

    _commentController.clear();
    setState(() {
      _replyToCommentId = null;
      _replyToAuthorName = null;
    });
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(const SnackBar(content: Text('评论已发送。')));
  }

  Future<void> _reportPost() async {
    final reason = await showModalBottomSheet<String>(
      context: context,
      showDragHandle: true,
      builder: (context) {
        return const _CircleReportReasonSheet();
      },
    );
    if (!mounted || reason == null) return;

    final bloc = context.read<CircleBloc>();
    bloc.add(CirclePostReported(postId: widget.post.id, reason: reason));
    final state = await bloc.stream.firstWhere((s) => !s.isReporting);
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(state.detailErrorMessage != null ? '举报提交失败，请稍后再试。' : '举报已提交，我们会尽快核查。'),
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    final palette = tonePaletteFor(widget.user.gender);
    return BlocBuilder<CircleBloc, CircleState>(
      builder: (context, circleState) {
        final detail = circleState.detailFor(widget.post.id) ??
            CirclePostDetail(post: widget.post, comments: const <CircleComment>[]);
        final post = detail.post;

        return Scaffold(
          key: ValueKey<String>('circle-detail-screen-${widget.post.id}'),
          backgroundColor: palette.canvas,
          appBar: AppBar(
            backgroundColor: palette.canvas,
            surfaceTintColor: Colors.transparent,
            title: const Text('动态详情'),
            actions: <Widget>[
              IconButton(
                key: const ValueKey<String>('circle-detail-report'),
                tooltip: '举报',
                onPressed: circleState.isReporting ? null : _reportPost,
                icon: const Icon(Icons.flag_outlined),
              ),
            ],
          ),
          body: Column(
            children: <Widget>[
              if (circleState.isDetailLoading && circleState.detailFor(widget.post.id) == null)
                const LinearProgressIndicator(minHeight: 2),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
                  children: <Widget>[
                    _CircleDetailPostCard(palette: palette, post: post),
                    const SizedBox(height: 18),
                    _CircleCommentHeader(count: detail.comments.length, palette: palette),
                    const SizedBox(height: 12),
                    if (circleState.detailErrorMessage != null)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _InlineErrorBanner(
                          message: circleState.detailErrorMessage!,
                          onRetry: () => context.read<CircleBloc>().add(CirclePostDetailLoaded(widget.post.id)),
                        ),
                      ),
                    if (detail.comments.isEmpty)
                      _EmptyCommentsCard(palette: palette)
                    else
                      ...detail.comments.map((comment) {
                        CircleComment? replyTarget;
                        for (final item in detail.comments) {
                          if (item.id == comment.parentCommentId) {
                            replyTarget = item;
                            break;
                          }
                        }
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: _CircleCommentCard(
                            comment: comment,
                            replyTargetName: replyTarget?.authorName,
                            palette: palette,
                            onReply: () {
                              setState(() {
                                _replyToCommentId = comment.id;
                                _replyToAuthorName = comment.authorName;
                              });
                              _commentFocusNode.requestFocus();
                            },
                          ),
                        );
                      }),
                  ],
                ),
              ),
              SafeArea(
                top: false,
                child: Container(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                  decoration: BoxDecoration(
                    color: palette.cardBackground,
                    border: Border(top: BorderSide(color: palette.outline)),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      if (_replyToCommentId != null)
                        Container(
                          margin: const EdgeInsets.only(bottom: 10),
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                          decoration: BoxDecoration(color: palette.surface, borderRadius: BorderRadius.circular(16)),
                          child: Row(
                            children: <Widget>[
                              Expanded(
                                child: Text(
                                  '正在回复 ${_replyToAuthorName ?? '这条评论'}',
                                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
                                ),
                              ),
                              IconButton(
                                onPressed: () {
                                  setState(() {
                                    _replyToCommentId = null;
                                    _replyToAuthorName = null;
                                  });
                                },
                                icon: const Icon(Icons.close),
                              ),
                            ],
                          ),
                        ),
                      Row(
                        children: <Widget>[
                          Expanded(
                            child: TextField(
                              key: const ValueKey<String>('circle-detail-comment-input'),
                              controller: _commentController,
                              focusNode: _commentFocusNode,
                              minLines: 1,
                              maxLines: 4,
                              textInputAction: TextInputAction.send,
                              onSubmitted: (_) {
                                if (!circleState.isSubmittingComment) _submitComment();
                              },
                              decoration: InputDecoration(
                                hintText: _replyToCommentId == null ? '说点什么，让这条动态热起来' : '继续补充你的回复',
                                filled: true,
                                fillColor: palette.surface,
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(18), borderSide: BorderSide.none),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          FilledButton(
                            key: const ValueKey<String>('circle-detail-comment-submit'),
                            onPressed: circleState.isSubmittingComment ? null : _submitComment,
                            style: FilledButton.styleFrom(
                              backgroundColor: palette.primary,
                              foregroundColor: palette.foreground,
                              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
                            ),
                            child: circleState.isSubmittingComment
                                ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                                : const Text('发送'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _CircleDetailPostCard extends StatelessWidget {
  const _CircleDetailPostCard({required this.palette, required this.post});

  final UserTonePalette palette;
  final CirclePost post;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: palette.cardBackground,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: palette.outline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              CircleAvatar(
                backgroundColor: palette.surface,
                foregroundColor: palette.primary,
                child: Text(post.authorName.characters.take(1).toString()),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(post.authorName, style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 4),
                    Text(
                      '${post.location} · ${post.distance} · ${post.createdAtLabel}',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppBrand.ink.withValues(alpha: 0.68)),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(color: palette.highlight, borderRadius: BorderRadius.circular(999)),
                child: Text(post.verificationLabel),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(post.content, style: Theme.of(context).textTheme.bodyLarge),
          if (post.attachments.isNotEmpty) ...<Widget>[
            const SizedBox(height: 14),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: post.attachments.map((attachment) {
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(color: palette.surface, borderRadius: BorderRadius.circular(999)),
                  child: Text(attachment.label),
                );
              }).toList(),
            ),
          ],
          const SizedBox(height: 14),
          Row(
            children: <Widget>[
              const Icon(Icons.favorite_border, size: 18),
              const SizedBox(width: 6),
              Text('${post.likes}'),
              const SizedBox(width: 18),
              const Icon(Icons.mode_comment_outlined, size: 18),
              const SizedBox(width: 6),
              Text('${post.comments}'),
            ],
          ),
        ],
      ),
    );
  }
}

class _CircleCommentHeader extends StatelessWidget {
  const _CircleCommentHeader({required this.count, required this.palette});

  final int count;
  final UserTonePalette palette;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Text('评论 $count', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800)),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(color: palette.highlight, borderRadius: BorderRadius.circular(999)),
          child: const Text('支持回复与举报'),
        ),
      ],
    );
  }
}

class _CircleCommentCard extends StatelessWidget {
  const _CircleCommentCard({
    required this.comment,
    required this.palette,
    required this.onReply,
    this.replyTargetName,
  });

  final CircleComment comment;
  final String? replyTargetName;
  final UserTonePalette palette;
  final VoidCallback onReply;

  @override
  Widget build(BuildContext context) {
    return Container(
      key: ValueKey<String>('circle-comment-${comment.id}'),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: palette.cardBackground,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: palette.outline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              CircleAvatar(
                radius: 18,
                backgroundColor: palette.surface,
                foregroundColor: palette.primary,
                child: Text(comment.authorName.characters.take(1).toString()),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(comment.authorName, style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700)),
                    const SizedBox(height: 2),
                    Text(comment.createdAtLabel, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppBrand.ink.withValues(alpha: 0.56))),
                  ],
                ),
              ),
              TextButton(onPressed: onReply, child: const Text('回复')),
            ],
          ),
          const SizedBox(height: 10),
          if (replyTargetName != null && replyTargetName!.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Text('回复 $replyTargetName', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppBrand.ink.withValues(alpha: 0.56))),
            ),
          Text(comment.content),
        ],
      ),
    );
  }
}

class _EmptyCommentsCard extends StatelessWidget {
  const _EmptyCommentsCard({required this.palette});

  final UserTonePalette palette;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: palette.cardBackground,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: palette.outline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text('这条动态还没有评论', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          Text(
            '你可以先说一句打招呼的话，让互动从这里开始。',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppBrand.ink.withValues(alpha: 0.68)),
          ),
        ],
      ),
    );
  }
}

class _InlineErrorBanner extends StatelessWidget {
  const _InlineErrorBanner({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: const BoxDecoration(color: Color(0xFFFFF1F2), borderRadius: BorderRadius.all(Radius.circular(16))),
      child: Row(
        children: <Widget>[
          const Icon(Icons.info_outline),
          const SizedBox(width: 10),
          Expanded(child: Text(message)),
          TextButton(onPressed: onRetry, child: const Text('重试')),
        ],
      ),
    );
  }
}

class _CircleReportReasonSheet extends StatelessWidget {
  const _CircleReportReasonSheet();

  static const List<String> _reasons = <String>[
    '骚扰或冒犯',
    '低俗或不适内容',
    '疑似诈骗',
    '虚假信息',
    '其他',
  ];

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text('选择举报原因', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 8),
              const Text('提交后这条举报会进入平台审核流。'),
              const SizedBox(height: 12),
              ..._reasons.map((reason) {
                return ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.flag_outlined),
                  title: Text(reason),
                  onTap: () => Navigator.of(context).pop(reason),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }
}
