import 'package:flutter/material.dart';

import '../../features/auth/domain/app_user.dart';
import '../../features/auth/domain/verification_status.dart';

class AvatarOptionData {
  const AvatarOptionData({
    required this.key,
    required this.label,
    required this.background,
    required this.foreground,
  });

  final String key;
  final String label;
  final Color background;
  final Color foreground;
}

const List<AvatarOptionData> avatarOptions = <AvatarOptionData>[
  AvatarOptionData(
    key: 'aurora',
    label: 'Aurora',
    background: Color(0xFF0F766E),
    foreground: Colors.white,
  ),
  AvatarOptionData(
    key: 'sunset',
    label: 'Sunset',
    background: Color(0xFFF97316),
    foreground: Colors.white,
  ),
  AvatarOptionData(
    key: 'lagoon',
    label: 'Lagoon',
    background: Color(0xFF0369A1),
    foreground: Colors.white,
  ),
  AvatarOptionData(
    key: 'ember',
    label: 'Ember',
    background: Color(0xFFBE123C),
    foreground: Colors.white,
  ),
  AvatarOptionData(
    key: 'graphite',
    label: 'Graphite',
    background: Color(0xFF334155),
    foreground: Colors.white,
  ),
];

AvatarOptionData avatarOptionFor(String key) {
  return avatarOptions.firstWhere(
    (option) => option.key == key,
    orElse: () => avatarOptions.first,
  );
}

class AppProfileAvatar extends StatelessWidget {
  const AppProfileAvatar({
    super.key,
    required this.user,
    this.radius = 28,
    this.showVerificationBadge = true,
  });

  final AppUser user;
  final double radius;
  final bool showVerificationBadge;

  @override
  Widget build(BuildContext context) {
    final option = avatarOptionFor(user.avatarKey);
    final initials = _initialsForName(user.name);
    final size = radius * 2;
    final badgeVisible = showVerificationBadge &&
        user.verification.faceStatus == VerificationStatus.verified;

    return SizedBox(
      width: size + 8,
      height: size + 8,
      child: Stack(
        clipBehavior: Clip.none,
        children: <Widget>[
          Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              color: option.background,
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Text(
              initials,
              style: TextStyle(
                color: option.foreground,
                fontSize: radius * 0.7,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          if (badgeVisible)
            Positioned(
              right: -2,
              bottom: -2,
              child: Container(
                padding: const EdgeInsets.all(3),
                decoration: BoxDecoration(
                  color: const Color(0xFFDCFCE7),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                ),
                child: const Icon(
                  Icons.verified_rounded,
                  size: 16,
                  color: Color(0xFF15803D),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

String _initialsForName(String name) {
  final parts = name
      .trim()
      .split(RegExp(r'\s+'))
      .where((part) => part.isNotEmpty)
      .toList();
  if (parts.isEmpty) {
    return 'U';
  }
  if (parts.length == 1) {
    return parts.first.characters.take(1).toString().toUpperCase();
  }
  return '${parts.first.characters.take(1)}${parts.last.characters.take(1)}'
      .toUpperCase();
}
