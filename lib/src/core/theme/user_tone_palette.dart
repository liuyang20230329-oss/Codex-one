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
        primary: Color(0xFF0F766E),
        secondary: Color(0xFF2563EB),
        surface: Color(0xFFE6FFFB),
        badge: Color(0xFFF97316),
        foreground: Colors.white,
      );
    case UserGender.female:
      return const UserTonePalette(
        primary: Color(0xFFE11D48),
        secondary: Color(0xFFF97393),
        surface: Color(0xFFFFF1F2),
        badge: Color(0xFFFB7185),
        foreground: Colors.white,
      );
    case UserGender.nonBinary:
      return const UserTonePalette(
        primary: Color(0xFF7C3AED),
        secondary: Color(0xFF0EA5E9),
        surface: Color(0xFFF5F3FF),
        badge: Color(0xFFF59E0B),
        foreground: Colors.white,
      );
    case UserGender.undisclosed:
      return const UserTonePalette(
        primary: Color(0xFF334155),
        secondary: Color(0xFF0F766E),
        surface: Color(0xFFF8FAFC),
        badge: Color(0xFFF97316),
        foreground: Colors.white,
      );
  }
}
