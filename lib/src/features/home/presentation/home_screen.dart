import 'package:flutter/material.dart';

import '../../../core/brand/app_brand.dart';
import '../../../core/theme/user_tone_palette.dart';
import '../../account/presentation/account_screen.dart';
import '../../auth/domain/app_user.dart';
import '../../auth/domain/user_gender.dart';
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
        previous.gender != next.gender ||
        previous.birthYear != next.birthYear ||
        previous.birthMonth != next.birthMonth ||
        previous.city != next.city ||
        previous.signature != next.signature ||
        previous.introVideoTitle != next.introVideoTitle ||
        previous.works.length != next.works.length ||
        previous.verification.phoneStatus != next.verification.phoneStatus ||
        previous.verification.identityStatus !=
            next.verification.identityStatus ||
        previous.verification.faceStatus != next.verification.faceStatus;
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge(
        <Listenable>[widget.controller, widget.chatController],
      ),
      builder: (context, _) {
        final user = widget.controller.currentUser ?? widget.user;
        final unreadCount = widget.chatController.totalUnreadCount;
        final screens = <Widget>[
          PlazaTab(
            user: user,
            statusLabel: widget.statusLabel,
            statusMessage: widget.statusMessage,
          ),
          CircleTab(user: user),
          ChatScreen(
            controller: widget.chatController,
            user: user,
          ),
          AccountScreen(
            controller: widget.controller,
            user: user,
          ),
        ];
        final titles = <String>['广场', '圈子', '消息', '我的'];
        final palette = tonePaletteFor(user.gender);

        return Scaffold(
          backgroundColor: AppBrand.paper,
          appBar: AppBar(
            titleSpacing: 20,
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  AppBrand.appName,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.8,
                      ),
                ),
                Text(
                  titles[_selectedIndex],
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.white70,
                      ),
                ),
              ],
            ),
            backgroundColor: AppBrand.ink,
            foregroundColor: Colors.white,
            surfaceTintColor: Colors.transparent,
          ),
          body: SafeArea(
            child: IndexedStack(
              index: _selectedIndex,
              children: screens,
            ),
          ),
          bottomNavigationBar: NavigationBar(
            backgroundColor: Colors.white,
            indicatorColor: palette.surface,
            selectedIndex: _selectedIndex,
            onDestinationSelected: (index) {
              setState(() {
                _selectedIndex = index;
              });
            },
            destinations: <Widget>[
              const NavigationDestination(
                icon: Icon(Icons.explore_outlined),
                selectedIcon: Icon(Icons.explore),
                label: '广场',
              ),
              const NavigationDestination(
                icon: Icon(Icons.bubble_chart_outlined),
                selectedIcon: Icon(Icons.bubble_chart),
                label: '圈子',
              ),
              NavigationDestination(
                icon: unreadCount > 0
                    ? Badge.count(
                        count: unreadCount,
                        child: const Icon(Icons.chat_bubble_outline),
                      )
                    : const Icon(Icons.chat_bubble_outline),
                selectedIcon: unreadCount > 0
                    ? Badge.count(
                        count: unreadCount,
                        child: const Icon(Icons.chat_bubble),
                      )
                    : const Icon(Icons.chat_bubble),
                label: '消息',
              ),
              const NavigationDestination(
                icon: Icon(Icons.person_outline),
                selectedIcon: Icon(Icons.person),
                label: '我的',
              ),
            ],
          ),
        );
      },
    );
  }
}

class PlazaTab extends StatefulWidget {
  const PlazaTab({
    super.key,
    required this.user,
    required this.statusLabel,
    required this.statusMessage,
  });

  final AppUser user;
  final String statusLabel;
  final String statusMessage;

  @override
  State<PlazaTab> createState() => _PlazaTabState();
}

class _PlazaTabState extends State<PlazaTab> {
  String _selectedRegion = '全部';
  String _selectedAge = '全部';
  UserGender? _selectedGender;

  static const List<String> _regions = <String>[
    '全部',
    '上海',
    '杭州',
    '苏州',
    '南京',
  ];

  static const List<String> _ageRanges = <String>[
    '全部',
    '18-22',
    '23-27',
    '28-35',
  ];

  final List<_PlazaUserCardData> _profiles = const <_PlazaUserCardData>[
    _PlazaUserCardData(
      name: '林雾',
      gender: UserGender.female,
      age: 23,
      city: '上海',
      distance: '1.2km',
      signature: '喜欢电影、手账和夜晚慢慢聊。',
      tags: <String>['视频', '聊天', '附近'],
      trustLabel: '真人',
      isVerified: true,
      isOnline: true,
    ),
    _PlazaUserCardData(
      name: '阿泽',
      gender: UserGender.male,
      age: 26,
      city: '杭州',
      distance: '3.8km',
      signature: '最近在找一起连麦打游戏和聊音乐的人。',
      tags: <String>['语音', '游戏', '热聊'],
      trustLabel: '实名',
      isVerified: true,
      isOnline: true,
    ),
    _PlazaUserCardData(
      name: '若梨',
      gender: UserGender.female,
      age: 28,
      city: '苏州',
      distance: '6.4km',
      signature: '喜欢拍照、旅行，也想认识更多有趣灵魂。',
      tags: <String>['图片', '旅行', '同城'],
      trustLabel: '真人',
      isVerified: true,
      isOnline: false,
    ),
    _PlazaUserCardData(
      name: '北川',
      gender: UserGender.male,
      age: 21,
      city: '南京',
      distance: '2.1km',
      signature: '想找可以一起语音、一起散步的人。',
      tags: <String>['陪伴', '散步', '新朋友'],
      trustLabel: '待认证',
      isVerified: false,
      isOnline: true,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final palette = tonePaletteFor(widget.user.gender);
    final visibleProfiles = _profiles.where((profile) {
      final matchesRegion =
          _selectedRegion == '全部' || profile.city == _selectedRegion;
      final matchesGender =
          _selectedGender == null || profile.gender == _selectedGender;
      final matchesAge = switch (_selectedAge) {
        '18-22' => profile.age >= 18 && profile.age <= 22,
        '23-27' => profile.age >= 23 && profile.age <= 27,
        '28-35' => profile.age >= 28 && profile.age <= 35,
        _ => true,
      };
      return matchesRegion && matchesGender && matchesAge;
    }).toList()
      ..sort((left, right) {
        final leftScore =
            (left.isVerified ? 100 : 0) + (left.isOnline ? 10 : 0) - left.age;
        final rightScore = (right.isVerified ? 100 : 0) +
            (right.isOnline ? 10 : 0) -
            right.age;
        return rightScore.compareTo(leftScore);
      });

    return ListView(
      padding: const EdgeInsets.all(20),
      children: <Widget>[
        SizedBox(
          height: 170,
          child: PageView(
            children: <Widget>[
              _BannerCard(
                palette: palette,
                title: '37° 广场正在更新可信推荐',
                description: '先看推荐卡片，再决定要不要继续聊天、语音或见面认识。',
              ),
              _BannerCard(
                palette: palette,
                title: '认证越完整，曝光越稳定',
                description: '手机号、实名和本人认证会共同影响推荐顺位与广场展示权重。',
              ),
              _BannerCard(
                palette: palette,
                title: '资料越完整，越容易被认真看见',
                description: '完善视频介绍、作品和个性签名，会更容易获得高质量回应。',
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        _StatusCard(
          label: widget.statusLabel,
          message: widget.statusMessage,
        ),
        const SizedBox(height: 16),
        _NoticeCard(
          notices: const <String>[
            '平台通知：今日推荐优先展示资料完整、活跃度高、认证更充分的用户。',
            '系统提醒：圈子动态支持文案、定位、图片、语音、动图和网址。',
            '版本更新：消息页已拆分为关系模块和对话列表，红点提醒已同步生效。',
          ],
        ),
        const SizedBox(height: 20),
        Text(
          '筛选用户',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _regions.map((region) {
            return ChoiceChip(
              label: Text(region),
              selected: _selectedRegion == region,
              onSelected: (_) {
                setState(() {
                  _selectedRegion = region;
                });
              },
            );
          }).toList(),
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _ageRanges.map((range) {
            return ChoiceChip(
              label: Text(range),
              selected: _selectedAge == range,
              onSelected: (_) {
                setState(() {
                  _selectedAge = range;
                });
              },
            );
          }).toList(),
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: <Widget>[
            FilterChip(
              label: const Text('男生'),
              selected: _selectedGender == UserGender.male,
              onSelected: (_) {
                setState(() {
                  _selectedGender = _selectedGender == UserGender.male
                      ? null
                      : UserGender.male;
                });
              },
            ),
            FilterChip(
              label: const Text('女生'),
              selected: _selectedGender == UserGender.female,
              onSelected: (_) {
                setState(() {
                  _selectedGender = _selectedGender == UserGender.female
                      ? null
                      : UserGender.female;
                });
              },
            ),
            FilterChip(
              label: const Text('多元'),
              selected: _selectedGender == UserGender.nonBinary,
              onSelected: (_) {
                setState(() {
                  _selectedGender = _selectedGender == UserGender.nonBinary
                      ? null
                      : UserGender.nonBinary;
                });
              },
            ),
          ],
        ),
        const SizedBox(height: 20),
        Text(
          '用户信息列表',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 12),
        if (visibleProfiles.isEmpty)
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
            ),
            child: const Text('当前筛选条件下还没有匹配用户，换个地区或年龄看看。'),
          ),
        for (final profile in visibleProfiles) ...<Widget>[
          _PlazaUserCard(profile: profile),
          const SizedBox(height: 12),
        ],
      ],
    );
  }
}

class CircleTab extends StatefulWidget {
  const CircleTab({
    super.key,
    required this.user,
  });

  final AppUser user;

  @override
  State<CircleTab> createState() => _CircleTabState();
}

class _CircleTabState extends State<CircleTab> {
  late final List<_CirclePost> _posts = <_CirclePost>[
    const _CirclePost(
      id: 'circle-1',
      authorName: '小川',
      location: '上海·徐汇',
      content: '今晚在武康路散步，拍到了很舒服的夜景，想找人一起语音聊聊天。',
      createdAtLabel: '5分钟前',
      attachments: <String>['图片', '定位'],
      verificationLabel: '真人',
      distance: '0.8km',
      likes: 26,
      comments: 8,
    ),
    const _CirclePost(
      id: 'circle-2',
      authorName: '林雾',
      location: '杭州·西湖',
      content: '刚刚录了一段晚安语音，适合睡前听，欢迎来圈子里互动。',
      createdAtLabel: '18分钟前',
      attachments: <String>['语音'],
      verificationLabel: '实名',
      distance: '2.4km',
      likes: 15,
      comments: 4,
    ),
    const _CirclePost(
      id: 'circle-3',
      authorName: '桃桃',
      location: '苏州·园区',
      content: '发现一组超适合做聊天开场白的动图，晚点整理成合集。',
      createdAtLabel: '1小时前',
      attachments: <String>['动图', '网址'],
      verificationLabel: '真人',
      distance: '4.1km',
      likes: 34,
      comments: 12,
    ),
  ];

  Future<void> _openPublishSheet() async {
    final draft = await showModalBottomSheet<_CirclePostDraft>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (context) {
        return const _CreateCirclePostSheet();
      },
    );
    if (draft == null) {
      return;
    }

    setState(() {
      _posts.insert(
        0,
        _CirclePost(
          id: 'circle-${DateTime.now().microsecondsSinceEpoch}',
          authorName: widget.user.name,
          location: draft.location,
          content: draft.content,
          createdAtLabel: '刚刚',
          attachments: draft.attachments,
          verificationLabel:
              widget.user.canAppearInRecommendations ? '真人' : '待认证',
          distance: '附近',
          likes: 0,
          comments: 0,
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final palette = tonePaletteFor(widget.user.gender);

    return Stack(
      children: <Widget>[
        ListView(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
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
                    '附近圈子动态',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '这里展示附近的人发布的动态内容。支持文案、定位、图片、语音、动图和网址，悬浮按钮可直接发布。',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            for (final post in _posts) ...<Widget>[
              _CirclePostCard(post: post),
              const SizedBox(height: 12),
            ],
          ],
        ),
        Positioned(
          right: 20,
          bottom: 20,
          child: FloatingActionButton.extended(
            onPressed: _openPublishSheet,
            backgroundColor: palette.primary,
            foregroundColor: palette.foreground,
            icon: const Icon(Icons.add),
            label: const Text('发布动态'),
          ),
        ),
      ],
    );
  }
}

class _BannerCard extends StatelessWidget {
  const _BannerCard({
    required this.palette,
    required this.title,
    required this.description,
  });

  final UserTonePalette palette;
  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 12),
      child: Container(
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
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.18),
                borderRadius: BorderRadius.circular(999),
              ),
              child: const Text(
                '37° 广场',
                style: TextStyle(color: Colors.white),
              ),
            ),
            const Spacer(),
            Text(
              title,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: Colors.white,
                  ),
            ),
            const SizedBox(height: 10),
            Text(
              description,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.white.withValues(alpha: 0.88),
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

class _NoticeCard extends StatelessWidget {
  const _NoticeCard({
    required this.notices,
  });

  final List<String> notices;

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
            '平台系统通知',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 12),
          for (final notice in notices) ...<Widget>[
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const Padding(
                  padding: EdgeInsets.only(top: 6),
                  child: CircleAvatar(
                    radius: 3,
                    backgroundColor: AppBrand.ink,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(child: Text(notice)),
              ],
            ),
            if (notice != notices.last) const SizedBox(height: 10),
          ],
        ],
      ),
    );
  }
}

class _PlazaUserCard extends StatelessWidget {
  const _PlazaUserCard({
    required this.profile,
  });

  final _PlazaUserCardData profile;

  @override
  Widget build(BuildContext context) {
    final palette = tonePaletteFor(profile.gender);

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
              Stack(
                clipBehavior: Clip.none,
                children: <Widget>[
                  CircleAvatar(
                    radius: 24,
                    backgroundColor: palette.surface,
                    foregroundColor: palette.primary,
                    child: Text(profile.name.characters.take(1).toString()),
                  ),
                  Positioned(
                    right: -1,
                    bottom: -1,
                    child: CircleAvatar(
                      radius: 6,
                      backgroundColor: profile.isOnline
                          ? const Color(0xFF16A34A)
                          : const Color(0xFF94A3B8),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      profile.name,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${profile.gender.label} · ${profile.age}岁 · ${profile.city}',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: <Widget>[
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: palette.surface,
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(profile.distance),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: profile.isVerified
                          ? palette.surface
                          : const Color(0xFFF6EDE5),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(profile.trustLabel),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(profile.signature),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: profile.tags.map((tag) {
              return Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: palette.surface,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(tag),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

class _CirclePostCard extends StatelessWidget {
  const _CirclePostCard({
    required this.post,
  });

  final _CirclePost post;

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
          Row(
            children: <Widget>[
              CircleAvatar(
                backgroundColor: const Color(0xFFFFF7ED),
                foregroundColor: const Color(0xFFF97316),
                child: Text(post.authorName.characters.take(1).toString()),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      post.authorName,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${post.location} · ${post.distance} · ${post.createdAtLabel}',
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFF5E8DE),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(post.verificationLabel),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(post.content),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: post.attachments.map((attachment) {
              return Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(attachment),
              );
            }).toList(),
          ),
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
              const Spacer(),
              const Icon(Icons.share_outlined, size: 18),
              const SizedBox(width: 16),
              const Icon(Icons.flag_outlined, size: 18),
            ],
          ),
        ],
      ),
    );
  }
}

class _CreateCirclePostSheet extends StatefulWidget {
  const _CreateCirclePostSheet();

  @override
  State<_CreateCirclePostSheet> createState() => _CreateCirclePostSheetState();
}

class _CreateCirclePostSheetState extends State<_CreateCirclePostSheet> {
  final _contentController = TextEditingController();
  final _locationController = TextEditingController(text: '上海');
  final _attachmentNoteController = TextEditingController();
  final Set<String> _attachments = <String>{};

  @override
  void dispose() {
    _contentController.dispose();
    _locationController.dispose();
    _attachmentNoteController.dispose();
    super.dispose();
  }

  void _submit() {
    final content = _contentController.text.trim();
    final location = _locationController.text.trim();
    final attachmentNote = _attachmentNoteController.text.trim();
    if (content.isEmpty && _attachments.isEmpty) {
      return;
    }

    final attachments = _attachments.toList();
    if (attachmentNote.isNotEmpty) {
      final label = attachmentNote.startsWith('http')
          ? '链接: $attachmentNote'
          : '素材: $attachmentNote';
      attachments.add(label);
    }

    Navigator.of(context).pop(
      _CirclePostDraft(
        content: content.isEmpty ? '分享了一条新的圈子动态。' : content,
        location: location.isEmpty ? '未设置定位' : location,
        attachments: attachments,
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
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            '发布圈子动态',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          const Text('发布字段包含文案、定位，以及图片、语音、动图、网址等内容类型。'),
          const SizedBox(height: 18),
          TextField(
            controller: _contentController,
            maxLines: 4,
            decoration: const InputDecoration(
              labelText: '文案',
              hintText: '说说你此刻想分享的内容',
            ),
          ),
          const SizedBox(height: 14),
          TextField(
            controller: _locationController,
            decoration: const InputDecoration(
              labelText: '定位',
              hintText: '输入你当前的位置',
            ),
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: const <String>['图片', '语音', '动图', '网址'].map((type) {
              return FilterChip(
                label: Text(type),
                selected: _attachments.contains(type),
                onSelected: (selected) {
                  setState(() {
                    if (selected) {
                      _attachments.add(type);
                    } else {
                      _attachments.remove(type);
                    }
                  });
                },
              );
            }).toList(),
          ),
          const SizedBox(height: 14),
          TextField(
            controller: _attachmentNoteController,
            decoration: const InputDecoration(
              labelText: '素材说明或网址',
              hintText: '可填写图片说明、语音备注或链接地址',
            ),
          ),
          const SizedBox(height: 20),
          FilledButton(
            onPressed: _submit,
            child: const Padding(
              padding: EdgeInsets.symmetric(vertical: 14),
              child: Text('立即发布'),
            ),
          ),
        ],
      ),
    );
  }
}

class _PlazaUserCardData {
  const _PlazaUserCardData({
    required this.name,
    required this.gender,
    required this.age,
    required this.city,
    required this.distance,
    required this.signature,
    required this.tags,
    required this.trustLabel,
    required this.isVerified,
    required this.isOnline,
  });

  final String name;
  final UserGender gender;
  final int age;
  final String city;
  final String distance;
  final String signature;
  final List<String> tags;
  final String trustLabel;
  final bool isVerified;
  final bool isOnline;
}

class _CirclePost {
  const _CirclePost({
    required this.id,
    required this.authorName,
    required this.location,
    required this.content,
    required this.createdAtLabel,
    required this.attachments,
    required this.verificationLabel,
    required this.distance,
    required this.likes,
    required this.comments,
  });

  final String id;
  final String authorName;
  final String location;
  final String content;
  final String createdAtLabel;
  final List<String> attachments;
  final String verificationLabel;
  final String distance;
  final int likes;
  final int comments;
}

class _CirclePostDraft {
  const _CirclePostDraft({
    required this.content,
    required this.location,
    required this.attachments,
  });

  final String content;
  final String location;
  final List<String> attachments;
}
