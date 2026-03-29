import 'package:flutter/material.dart';

import '../../../core/brand/app_brand.dart';
import '../../../core/theme/user_tone_palette.dart';
import '../../account/presentation/account_screen.dart';
import '../../auth/domain/app_user.dart';
import '../../auth/domain/profile_media_work.dart';
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
            '系统提醒：圈子动态支持文案、地址、图片、语音和作品，素材统一通过组件选择。',
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
  _CirclePostDraft? _draftCache;

  late final List<_CirclePost> _posts = <_CirclePost>[
    const _CirclePost(
      id: 'circle-1',
      authorName: '小川',
      location: '上海·徐汇',
      content: '今晚在武康路散步，拍到了很舒服的夜景，想找人一起语音聊聊天。',
      createdAtLabel: '5分钟前',
      attachments: <String>['图片 3张', '语音 18秒'],
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
      content: '刚整理好一组最近拍的城市夜色作品，想放进圈子里看看大家更喜欢哪一版。',
      createdAtLabel: '1小时前',
      attachments: <String>['作品 2个'],
      verificationLabel: '真人',
      distance: '4.1km',
      likes: 34,
      comments: 12,
    ),
  ];

  Future<void> _openPublishScreen() async {
    final result = await Navigator.of(context).push<_CircleComposerResult>(
      MaterialPageRoute<_CircleComposerResult>(
        fullscreenDialog: true,
        builder: (context) {
          return _CreateCirclePostScreen(
            user: widget.user,
            initialDraft: _draftCache ?? const _CirclePostDraft(),
          );
        },
      ),
    );
    if (!mounted || result == null) {
      return;
    }

    if (result.savedDraft != null) {
      setState(() {
        _draftCache = result.savedDraft;
      });
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(content: Text('退出后草稿已保存，下次会自动恢复。')),
        );
      return;
    }

    final draft = result.publishedDraft;
    if (draft == null) {
      return;
    }

    setState(() {
      _draftCache = null;
      _posts.insert(
        0,
        _CirclePost(
          id: 'circle-${DateTime.now().microsecondsSinceEpoch}',
          authorName: widget.user.name,
          location: draft.locationOption.address,
          content: draft.displayContent,
          createdAtLabel: '刚刚',
          attachments: draft.attachmentLabels,
          verificationLabel:
              widget.user.canAppearInRecommendations ? '真人' : '待认证',
          distance: '附近',
          likes: 0,
          comments: 0,
        ),
      );
    });

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        const SnackBar(content: Text('动态已发布到圈子，正在进入最新列表。')),
      );
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
                    '这里展示附近的人发布的动态内容。发布页会以全屏方式打开，地址、图片、语音和作品都通过独立组件选择。',
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
            key: const ValueKey<String>('circle-open-publish'),
            onPressed: _openPublishScreen,
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

class _CreateCirclePostScreen extends StatefulWidget {
  const _CreateCirclePostScreen({
    required this.user,
    required this.initialDraft,
  });

  final AppUser user;
  final _CirclePostDraft initialDraft;

  @override
  State<_CreateCirclePostScreen> createState() =>
      _CreateCirclePostScreenState();
}

class _CreateCirclePostScreenState extends State<_CreateCirclePostScreen> {
  late final TextEditingController _contentController;
  late _CircleLocationOption _selectedLocation;
  late List<_CircleImageAsset> _selectedImages;
  late List<ProfileMediaWork> _selectedWorks;
  _CircleVoiceDraft? _selectedVoice;
  bool _isPublishing = false;

  List<ProfileMediaWork> get _availableWorks {
    return widget.user.works
        .where((work) => work.type != ProfileMediaWorkType.gif)
        .toList(growable: false);
  }

  @override
  void initState() {
    super.initState();
    final initialDraft = widget.initialDraft;
    _contentController = TextEditingController(text: initialDraft.content);
    _selectedLocation = initialDraft.locationOption;
    _selectedImages = List<_CircleImageAsset>.from(initialDraft.images);
    _selectedVoice = initialDraft.voiceNote;
    _selectedWorks = List<ProfileMediaWork>.from(initialDraft.selectedWorks);
  }

  @override
  void dispose() {
    _contentController.dispose();
    super.dispose();
  }

  _CirclePostDraft _buildDraft() {
    return _CirclePostDraft(
      content: _contentController.text.trim(),
      location: _selectedLocation,
      images: List<_CircleImageAsset>.unmodifiable(_selectedImages),
      voiceNote: _selectedVoice,
      selectedWorks: List<ProfileMediaWork>.unmodifiable(_selectedWorks),
    );
  }

  Future<bool> _handleBack() async {
    if (_isPublishing) {
      return false;
    }
    final draft = _buildDraft();
    if (!draft.hasAnyContent) {
      Navigator.of(context).pop();
      return false;
    }
    Navigator.of(context).pop(_CircleComposerResult.saved(draft));
    return false;
  }

  Future<void> _selectLocation() async {
    final location = await showModalBottomSheet<_CircleLocationOption>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (context) {
        return _CircleLocationPickerSheet(selected: _selectedLocation);
      },
    );
    if (location == null) {
      return;
    }
    setState(() {
      _selectedLocation = location;
    });
  }

  Future<void> _selectImages() async {
    final images = await showModalBottomSheet<List<_CircleImageAsset>>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (context) {
        return _CircleImagePickerSheet(initialImages: _selectedImages);
      },
    );
    if (images == null) {
      return;
    }
    setState(() {
      _selectedImages = images;
    });
  }

  Future<void> _selectVoice() async {
    final voice = await showModalBottomSheet<_CircleVoiceDraft>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (context) {
        return _CircleVoiceRecorderSheet(selectedVoice: _selectedVoice);
      },
    );
    if (voice == null) {
      return;
    }
    setState(() {
      _selectedVoice = voice;
    });
  }

  Future<void> _selectWorks() async {
    final works = await showModalBottomSheet<List<ProfileMediaWork>>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (context) {
        return _CircleWorkPickerSheet(
          availableWorks: _availableWorks,
          selectedWorks: _selectedWorks,
        );
      },
    );
    if (works == null) {
      return;
    }
    setState(() {
      _selectedWorks = works;
    });
  }

  Future<void> _submit() async {
    final draft = _buildDraft();
    if (!draft.hasAnyContent) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(content: Text('请至少添加一项内容后再发布。')),
        );
      return;
    }

    setState(() {
      _isPublishing = true;
    });
    await Future<void>.delayed(const Duration(milliseconds: 240));
    if (!mounted) {
      return;
    }
    Navigator.of(context).pop(_CircleComposerResult.published(draft));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return PopScope<Object?>(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) {
          return;
        }
        await _handleBack();
      },
      child: Scaffold(
        backgroundColor: AppBrand.paper,
        appBar: AppBar(
          title: const Text('发布动态'),
          leading: IconButton(
            onPressed: _isPublishing ? null : () => _handleBack(),
            icon: const Icon(Icons.close),
          ),
        ),
        bottomNavigationBar: SafeArea(
          minimum: const EdgeInsets.fromLTRB(20, 12, 20, 20),
          child: Row(
            children: <Widget>[
              Expanded(
                child: OutlinedButton(
                  onPressed: _isPublishing ? null : () => _handleBack(),
                  child: const Padding(
                    padding: EdgeInsets.symmetric(vertical: 14),
                    child: Text('保存草稿'),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: FilledButton(
                  key: const ValueKey<String>('circle-submit-post'),
                  onPressed: _isPublishing ? null : _submit,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    child: Text(_isPublishing ? '正在发布...' : '立即发布'),
                  ),
                ),
              ),
            ],
          ),
        ),
        body: SafeArea(
          child: ListView(
            key: const ValueKey<String>('circle-publish-scroll'),
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
            children: <Widget>[
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: const Text(
                  '发布页按全屏方式打开。地址、图片、语音和作品都会通过独立组件选择，退出时会自动保留草稿。',
                ),
              ),
              const SizedBox(height: 16),
              _ComposerSection(
                title: '文案',
                description: '可选填写，最多 500 字；至少需要保留一项内容才可以发布。',
                child: TextField(
                  key: const ValueKey<String>('circle-post-content'),
                  controller: _contentController,
                  maxLines: 6,
                  minLines: 4,
                  maxLength: 500,
                  decoration: const InputDecoration(
                    hintText: '说说你此刻想分享的内容',
                  ),
                ),
              ),
              const SizedBox(height: 16),
              _ComposerSection(
                title: '地址选择',
                description: '默认获取当前位置，也支持手动切换附近地点。',
                child: InkWell(
                  onTap: _selectLocation,
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    key: const ValueKey<String>('circle-select-location'),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      children: <Widget>[
                        const Icon(Icons.place_outlined),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text(
                                _selectedLocation.title,
                                style: theme.textTheme.titleSmall,
                              ),
                              const SizedBox(height: 4),
                              Text(_selectedLocation.address),
                              const SizedBox(height: 2),
                              Text(
                                _selectedLocation.detail,
                                style: theme.textTheme.bodySmall,
                              ),
                            ],
                          ),
                        ),
                        const Icon(Icons.chevron_right),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              _ComposerSection(
                title: '图片',
                description: '通过图片组件选择拍照或相册内容，最多保留 9 张。',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    OutlinedButton.icon(
                      key: const ValueKey<String>('circle-add-images'),
                      onPressed: _selectImages,
                      icon: const Icon(Icons.add_photo_alternate_outlined),
                      label: Text(
                        _selectedImages.isEmpty ? '调用图片组件' : '重新选择图片',
                      ),
                    ),
                    if (_selectedImages.isNotEmpty) ...<Widget>[
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: _selectedImages.map((image) {
                          return InputChip(
                            label:
                                Text('${image.title} · ${image.sourceLabel}'),
                            onDeleted: () {
                              setState(() {
                                _selectedImages.removeWhere(
                                  (item) => item.id == image.id,
                                );
                              });
                            },
                          );
                        }).toList(),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 16),
              _ComposerSection(
                title: '语音',
                description: '通过语音组件录制，保留试听与重录入口；发布时最多带 1 条。',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    OutlinedButton.icon(
                      key: const ValueKey<String>('circle-add-voice'),
                      onPressed: _selectVoice,
                      icon: const Icon(Icons.mic_none_outlined),
                      label: Text(
                        _selectedVoice == null ? '调用语音组件' : '重新录制语音',
                      ),
                    ),
                    if (_selectedVoice != null) ...<Widget>[
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF8FAFC),
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: Row(
                          children: <Widget>[
                            const Icon(Icons.graphic_eq_outlined),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Text(
                                    _selectedVoice!.title,
                                    style: theme.textTheme.titleSmall,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '${_selectedVoice!.durationLabel} · ${_selectedVoice!.summary}',
                                  ),
                                ],
                              ),
                            ),
                            TextButton(
                              onPressed: () {
                                ScaffoldMessenger.of(context)
                                  ..hideCurrentSnackBar()
                                  ..showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        '已打开试听预览：${_selectedVoice!.title}',
                                      ),
                                    ),
                                  );
                              },
                              child: const Text('试听'),
                            ),
                            IconButton(
                              onPressed: () {
                                setState(() {
                                  _selectedVoice = null;
                                });
                              },
                              icon: const Icon(Icons.delete_outline),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 16),
              _ComposerSection(
                title: '作品',
                description: '从“我的作品”里选择要带进动态的内容，当前支持语音、视频和图片作品。',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    OutlinedButton.icon(
                      key: const ValueKey<String>('circle-select-work'),
                      onPressed: _selectWorks,
                      icon: const Icon(Icons.collections_bookmark_outlined),
                      label: Text(
                        _availableWorks.isEmpty ? '暂无可选作品' : '调用作品组件',
                      ),
                    ),
                    if (_availableWorks.isEmpty) ...<Widget>[
                      const SizedBox(height: 12),
                      const Text('你还没有可用于发布的作品，后续可先去“我的”里补充作品。'),
                    ] else if (_selectedWorks.isNotEmpty) ...<Widget>[
                      const SizedBox(height: 12),
                      Column(
                        children: _selectedWorks.map((work) {
                          return Container(
                            margin: const EdgeInsets.only(bottom: 8),
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF8FAFC),
                              borderRadius: BorderRadius.circular(18),
                            ),
                            child: Row(
                              children: <Widget>[
                                CircleAvatar(
                                  radius: 18,
                                  backgroundColor: const Color(0xFFF5E8DE),
                                  foregroundColor: AppBrand.ink,
                                  child: Text(
                                    work.type.label.characters
                                        .take(1)
                                        .toString(),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: <Widget>[
                                      Text(
                                        work.title,
                                        style: theme.textTheme.titleSmall,
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                          '${work.type.label} · ${work.summary}'),
                                    ],
                                  ),
                                ),
                                IconButton(
                                  onPressed: () {
                                    setState(() {
                                      _selectedWorks.removeWhere(
                                        (item) => item.id == work.id,
                                      );
                                    });
                                  },
                                  icon: const Icon(Icons.close),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                    ],
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

class _ComposerSection extends StatelessWidget {
  const _ComposerSection({
    required this.title,
    required this.description,
    required this.child,
  });

  final String title;
  final String description;
  final Widget child;

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
            title,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 6),
          Text(description),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }
}

class _CircleLocationPickerSheet extends StatefulWidget {
  const _CircleLocationPickerSheet({
    required this.selected,
  });

  final _CircleLocationOption selected;

  @override
  State<_CircleLocationPickerSheet> createState() =>
      _CircleLocationPickerSheetState();
}

class _CircleLocationPickerSheetState
    extends State<_CircleLocationPickerSheet> {
  final TextEditingController _searchController = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final options = _CirclePublishCatalog.locationOptions.where((option) {
      final query = _query.trim();
      if (query.isEmpty) {
        return true;
      }
      return option.title.contains(query) ||
          option.address.contains(query) ||
          option.detail.contains(query);
    }).toList(growable: false);

    return FractionallySizedBox(
      heightFactor: 0.78,
      child: Padding(
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
          top: 12,
          bottom: MediaQuery.viewInsetsOf(context).bottom + 20,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              '地址选择',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            const Text('默认优先获取当前位置，也支持手动挑选附近地点。'),
            const SizedBox(height: 16),
            TextField(
              controller: _searchController,
              onChanged: (value) {
                setState(() {
                  _query = value;
                });
              },
              decoration: const InputDecoration(
                hintText: '搜索附近地点',
                prefixIcon: Icon(Icons.search),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.separated(
                itemCount: options.length,
                separatorBuilder: (_, __) => const SizedBox(height: 8),
                itemBuilder: (context, index) {
                  final option = options[index];
                  final selected = option.id == widget.selected.id;
                  return ListTile(
                    key:
                        ValueKey<String>('circle-location-option-${option.id}'),
                    onTap: () => Navigator.of(context).pop(option),
                    tileColor: selected
                        ? const Color(0xFFF5E8DE)
                        : const Color(0xFFF8FAFC),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                    leading: Icon(
                      option.id == 'current'
                          ? Icons.my_location_outlined
                          : Icons.place_outlined,
                    ),
                    title: Text(option.title),
                    subtitle: Text('${option.address}\n${option.detail}'),
                    isThreeLine: true,
                    trailing: selected
                        ? const Icon(Icons.check_circle, color: AppBrand.ink)
                        : const Icon(Icons.chevron_right),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CircleImagePickerSheet extends StatefulWidget {
  const _CircleImagePickerSheet({
    required this.initialImages,
  });

  final List<_CircleImageAsset> initialImages;

  @override
  State<_CircleImagePickerSheet> createState() =>
      _CircleImagePickerSheetState();
}

class _CircleImagePickerSheetState extends State<_CircleImagePickerSheet> {
  late final Set<String> _selectedIds;
  String _selectedSource = '相册';

  @override
  void initState() {
    super.initState();
    _selectedIds = widget.initialImages.map((image) => image.id).toSet();
    final fromCamera = widget.initialImages.any(
      (image) => image.sourceLabel == '拍照',
    );
    if (fromCamera) {
      _selectedSource = '拍照';
    }
  }

  @override
  Widget build(BuildContext context) {
    final options = _CirclePublishCatalog.imageOptions.where((image) {
      return image.sourceLabel == _selectedSource;
    }).toList(growable: false);

    return FractionallySizedBox(
      heightFactor: 0.82,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              '图片组件',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            const Text('支持拍照和相册两种来源，当前先用结构化素材模拟选择与排序。'),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: const <String>['相册', '拍照'].map((source) {
                return ChoiceChip(
                  label: Text(source),
                  selected: _selectedSource == source,
                  onSelected: (_) {
                    setState(() {
                      _selectedSource = source;
                    });
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.separated(
                itemCount: options.length,
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (context, index) {
                  final image = options[index];
                  final selected = _selectedIds.contains(image.id);
                  return ListTile(
                    key: ValueKey<String>('circle-image-option-${image.id}'),
                    onTap: () {
                      setState(() {
                        if (selected) {
                          _selectedIds.remove(image.id);
                        } else if (_selectedIds.length < 9) {
                          _selectedIds.add(image.id);
                        }
                      });
                    },
                    tileColor: selected
                        ? const Color(0xFFF5E8DE)
                        : const Color(0xFFF8FAFC),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                    leading: CircleAvatar(
                      backgroundColor: const Color(0xFFFFF7ED),
                      foregroundColor: AppBrand.ink,
                      child: Icon(image.icon),
                    ),
                    title: Text(image.title),
                    subtitle: Text('${image.summary} · ${image.sourceLabel}'),
                    trailing: selected
                        ? const Icon(Icons.check_circle, color: AppBrand.ink)
                        : const Icon(Icons.add_circle_outline),
                  );
                },
              ),
            ),
            const SizedBox(height: 12),
            FilledButton(
              key: const ValueKey<String>('circle-image-confirm'),
              onPressed: () {
                final images = _CirclePublishCatalog.imageOptions
                    .where((image) => _selectedIds.contains(image.id))
                    .toList(growable: false);
                Navigator.of(context).pop(images);
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 14),
                child: Text('加入发布（${_selectedIds.length}/9）'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CircleVoiceRecorderSheet extends StatefulWidget {
  const _CircleVoiceRecorderSheet({
    required this.selectedVoice,
  });

  final _CircleVoiceDraft? selectedVoice;

  @override
  State<_CircleVoiceRecorderSheet> createState() =>
      _CircleVoiceRecorderSheetState();
}

class _CircleVoiceRecorderSheetState extends State<_CircleVoiceRecorderSheet> {
  _CircleVoiceDraft? _selectedVoice;

  @override
  void initState() {
    super.initState();
    _selectedVoice = widget.selectedVoice;
  }

  @override
  Widget build(BuildContext context) {
    return FractionallySizedBox(
      heightFactor: 0.76,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              '语音组件',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            const Text('这里对应长按录音、试听和重录流程；当前版本先用录音模板模拟录制结果。'),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.separated(
                itemCount: _CirclePublishCatalog.voiceTemplates.length,
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (context, index) {
                  final voice = _CirclePublishCatalog.voiceTemplates[index];
                  final selected = voice.id == _selectedVoice?.id;
                  return ListTile(
                    key: ValueKey<String>('circle-voice-option-${voice.id}'),
                    onTap: () {
                      setState(() {
                        _selectedVoice = voice;
                      });
                    },
                    tileColor: selected
                        ? const Color(0xFFF5E8DE)
                        : const Color(0xFFF8FAFC),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                    leading: const CircleAvatar(
                      backgroundColor: Color(0xFFFFF7ED),
                      foregroundColor: AppBrand.ink,
                      child: Icon(Icons.mic_none_outlined),
                    ),
                    title: Text(voice.title),
                    subtitle: Text('${voice.durationLabel} · ${voice.summary}'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        TextButton(
                          onPressed: () {
                            ScaffoldMessenger.of(context)
                              ..hideCurrentSnackBar()
                              ..showSnackBar(
                                SnackBar(content: Text('正在试听：${voice.title}')),
                              );
                          },
                          child: const Text('试听'),
                        ),
                        if (selected)
                          const Icon(Icons.check_circle, color: AppBrand.ink),
                      ],
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: <Widget>[
                Expanded(
                  child: OutlinedButton(
                    onPressed: _selectedVoice == null
                        ? null
                        : () {
                            setState(() {
                              _selectedVoice = null;
                            });
                          },
                    child: const Padding(
                      padding: EdgeInsets.symmetric(vertical: 14),
                      child: Text('重录'),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton(
                    key: const ValueKey<String>('circle-voice-confirm'),
                    onPressed: _selectedVoice == null
                        ? null
                        : () => Navigator.of(context).pop(_selectedVoice),
                    child: const Padding(
                      padding: EdgeInsets.symmetric(vertical: 14),
                      child: Text('带入发布'),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _CircleWorkPickerSheet extends StatefulWidget {
  const _CircleWorkPickerSheet({
    required this.availableWorks,
    required this.selectedWorks,
  });

  final List<ProfileMediaWork> availableWorks;
  final List<ProfileMediaWork> selectedWorks;

  @override
  State<_CircleWorkPickerSheet> createState() => _CircleWorkPickerSheetState();
}

class _CircleWorkPickerSheetState extends State<_CircleWorkPickerSheet> {
  late final Set<String> _selectedIds;

  @override
  void initState() {
    super.initState();
    _selectedIds = widget.selectedWorks.map((work) => work.id).toSet();
  }

  @override
  Widget build(BuildContext context) {
    return FractionallySizedBox(
      heightFactor: 0.82,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              '作品组件',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            const Text('从“我的作品”里挑选要带进动态的内容，发布后会以作品标签展示。'),
            const SizedBox(height: 16),
            if (widget.availableWorks.isEmpty)
              Expanded(
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(22),
                  ),
                  child: const Text('当前还没有可用作品，先去“我的作品”添加语音、视频或图片作品吧。'),
                ),
              )
            else
              Expanded(
                child: ListView.separated(
                  itemCount: widget.availableWorks.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    final work = widget.availableWorks[index];
                    final selected = _selectedIds.contains(work.id);
                    return ListTile(
                      key: ValueKey<String>('circle-work-option-${work.id}'),
                      onTap: () {
                        setState(() {
                          if (selected) {
                            _selectedIds.remove(work.id);
                          } else {
                            _selectedIds.add(work.id);
                          }
                        });
                      },
                      tileColor: selected
                          ? const Color(0xFFF5E8DE)
                          : const Color(0xFFF8FAFC),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                      leading: CircleAvatar(
                        backgroundColor: const Color(0xFFFFF7ED),
                        foregroundColor: AppBrand.ink,
                        child:
                            Text(work.type.label.characters.take(1).toString()),
                      ),
                      title: Text(work.title),
                      subtitle: Text('${work.type.label} · ${work.summary}'),
                      trailing: selected
                          ? const Icon(Icons.check_circle, color: AppBrand.ink)
                          : const Icon(Icons.add_circle_outline),
                    );
                  },
                ),
              ),
            const SizedBox(height: 12),
            FilledButton(
              key: const ValueKey<String>('circle-work-confirm'),
              onPressed: () {
                final works = widget.availableWorks
                    .where((work) => _selectedIds.contains(work.id))
                    .toList(growable: false);
                Navigator.of(context).pop(works);
              },
              child: const Padding(
                padding: EdgeInsets.symmetric(vertical: 14),
                child: Text('加入发布'),
              ),
            ),
          ],
        ),
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

class _CircleComposerResult {
  const _CircleComposerResult._({
    this.savedDraft,
    this.publishedDraft,
  });

  const _CircleComposerResult.saved(_CirclePostDraft draft)
      : this._(savedDraft: draft);

  const _CircleComposerResult.published(_CirclePostDraft draft)
      : this._(publishedDraft: draft);

  final _CirclePostDraft? savedDraft;
  final _CirclePostDraft? publishedDraft;
}

class _CirclePostDraft {
  const _CirclePostDraft({
    this.content = '',
    this.location,
    this.images = const <_CircleImageAsset>[],
    this.voiceNote,
    this.selectedWorks = const <ProfileMediaWork>[],
  });

  final String content;
  final _CircleLocationOption? location;
  final List<_CircleImageAsset> images;
  final _CircleVoiceDraft? voiceNote;
  final List<ProfileMediaWork> selectedWorks;

  _CircleLocationOption get locationOption {
    return location ?? _CirclePublishCatalog.locationOptions.first;
  }

  bool get hasAnyContent {
    return content.trim().isNotEmpty ||
        images.isNotEmpty ||
        voiceNote != null ||
        selectedWorks.isNotEmpty;
  }

  String get displayContent {
    final text = content.trim();
    if (text.isNotEmpty) {
      return text;
    }
    if (selectedWorks.isNotEmpty) {
      return '分享了 ${selectedWorks.length} 个作品，欢迎来看看最想聊哪一个。';
    }
    if (voiceNote != null) {
      return '分享了一段刚录好的语音动态，欢迎来圈子里互动。';
    }
    if (images.isNotEmpty) {
      return '分享了 ${images.length} 张刚拍好的内容，欢迎来看看。';
    }
    return '分享了一条新的圈子动态。';
  }

  List<String> get attachmentLabels {
    final labels = <String>[];
    if (images.isNotEmpty) {
      labels.add('图片 ${images.length}张');
    }
    if (voiceNote != null) {
      labels.add('语音 ${voiceNote!.durationLabel}');
    }
    if (selectedWorks.isNotEmpty) {
      labels.add(
        selectedWorks.length == 1
            ? '作品 ${selectedWorks.first.title}'
            : '作品 ${selectedWorks.length}个',
      );
    }
    return labels;
  }
}

class _CircleLocationOption {
  const _CircleLocationOption({
    required this.id,
    required this.title,
    required this.address,
    required this.detail,
  });

  final String id;
  final String title;
  final String address;
  final String detail;
}

class _CircleImageAsset {
  const _CircleImageAsset({
    required this.id,
    required this.title,
    required this.summary,
    required this.sourceLabel,
    required this.icon,
  });

  final String id;
  final String title;
  final String summary;
  final String sourceLabel;
  final IconData icon;
}

class _CircleVoiceDraft {
  const _CircleVoiceDraft({
    required this.id,
    required this.title,
    required this.summary,
    required this.durationSeconds,
  });

  final String id;
  final String title;
  final String summary;
  final int durationSeconds;

  String get durationLabel => '$durationSeconds秒';
}

class _CirclePublishCatalog {
  static const List<_CircleLocationOption> locationOptions =
      <_CircleLocationOption>[
    _CircleLocationOption(
      id: 'current',
      title: '当前位置',
      address: '上海·徐汇·武康路',
      detail: '距你 120m · 自动获取',
    ),
    _CircleLocationOption(
      id: 'anfu',
      title: '安福路路口',
      address: '上海·徐汇·安福路',
      detail: '距你 420m · 附近热门',
    ),
    _CircleLocationOption(
      id: 'west-lake',
      title: '西湖音乐喷泉',
      address: '杭州·西湖',
      detail: '距你 2.4km · 手动选择',
    ),
    _CircleLocationOption(
      id: 'jinji-lake',
      title: '金鸡湖步道',
      address: '苏州·园区',
      detail: '距你 4.1km · 手动选择',
    ),
  ];

  static const List<_CircleImageAsset> imageOptions = <_CircleImageAsset>[
    _CircleImageAsset(
      id: 'night-street',
      title: '夜景街拍',
      summary: '适合展示附近氛围感',
      sourceLabel: '相册',
      icon: Icons.photo_library_outlined,
    ),
    _CircleImageAsset(
      id: 'coffee-table',
      title: '咖啡桌面',
      summary: '安静聊天向内容',
      sourceLabel: '相册',
      icon: Icons.image_outlined,
    ),
    _CircleImageAsset(
      id: 'cat-window',
      title: '窗边剪影',
      summary: '适合配文案和定位',
      sourceLabel: '相册',
      icon: Icons.collections_outlined,
    ),
    _CircleImageAsset(
      id: 'camera-selfie',
      title: '刚拍的自拍',
      summary: '模拟拍照组件返回结果',
      sourceLabel: '拍照',
      icon: Icons.camera_alt_outlined,
    ),
    _CircleImageAsset(
      id: 'camera-street',
      title: '随手拍街景',
      summary: '模拟拍照后直接带入发布',
      sourceLabel: '拍照',
      icon: Icons.add_a_photo_outlined,
    ),
  ];

  static const List<_CircleVoiceDraft> voiceTemplates = <_CircleVoiceDraft>[
    _CircleVoiceDraft(
      id: 'voice-good-night',
      title: '轻声晚安',
      summary: '适合睡前互动的一段语音',
      durationSeconds: 18,
    ),
    _CircleVoiceDraft(
      id: 'voice-city',
      title: '城市夜风',
      summary: '用语音描述此刻的街头氛围',
      durationSeconds: 26,
    ),
    _CircleVoiceDraft(
      id: 'voice-intro',
      title: '一句自我介绍',
      summary: '适合新朋友快速认识你',
      durationSeconds: 12,
    ),
  ];
}
