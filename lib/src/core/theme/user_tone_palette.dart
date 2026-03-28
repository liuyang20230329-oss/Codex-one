import 'package:flutter/material.dart';

import '../../features/auth/domain/user_gender.dart';

class UserTonePalette {
  const UserTonePalette({
    required this.primary,
    required this.secondary,
    required this.surface,
    required this.badge,
    required this.foreground,
  });

  final Color primary;
  final Color secondary;
  final Color surface;
  final Color badge;
  final Color foreground;
}

UserTonePalette tonePaletteFor(UserGender gender) {
  switch (gender) {
    case UserGender.male:
      return const UserTonePalette(
        primary: Color(0xFF12161F),
        secondary: Color(0xFF2F6BFF),
        surface: Color(0xFFE9EEF8),
        badge: Color(0xFF2563EB),
        foreground: Colors.white,
      );
    case UserGender.female:
      return const UserTonePalette(
        primary: Color(0xFF21151A),
        secondary: Color(0xFFD85A85),
        surface: Color(0xFFF7E9F0),
        badge: Color(0xFFE25586),
        foreground: Colors.white,
      );
    case UserGender.nonBinary:
      return const UserTonePalette(
        primary: Color(0xFF1E1930),
        secondary: Color(0xFF6E5CF6),
        surface: Color(0xFFF1EEFF),
        badge: Color(0xFFF59E0B),
        foreground: Colors.white,
      );
    case UserGender.undisclosed:
      return const UserTonePalette(
        primary: Color(0xFF191B20),
        secondary: Color(0xFF585E6C),
        surface: Color(0xFFF1F2F4),
        badge: Color(0xFFB7791F),
        foreground: Colors.white,
      );
  }
}
