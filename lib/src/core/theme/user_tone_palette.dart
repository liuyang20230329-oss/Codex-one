import 'package:flutter/material.dart';

import '../../features/auth/domain/user_gender.dart';

/// Keeps the shell colors for each gender theme in one place so the home,
/// chat, and account modules stay visually aligned.
class UserTonePalette {
  const UserTonePalette({
    required this.primary,
    required this.secondary,
    required this.surface,
    required this.badge,
    required this.foreground,
    required this.canvas,
    required this.cardBackground,
    required this.outline,
    required this.mutedForeground,
    required this.highlight,
  });

  final Color primary;
  final Color secondary;
  final Color surface;
  final Color badge;
  final Color foreground;
  final Color canvas;
  final Color cardBackground;
  final Color outline;
  final Color mutedForeground;
  final Color highlight;

  LinearGradient get heroGradient {
    return LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: <Color>[
        primary,
        Color.lerp(primary, secondary, 0.58)!,
        secondary,
      ],
    );
  }

  LinearGradient get shellGradient {
    return LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomCenter,
      colors: <Color>[
        primary,
        Color.lerp(primary, secondary, 0.42)!,
        canvas,
      ],
      stops: const <double>[0.0, 0.42, 1.0],
    );
  }
}

/// Maps the selected gender to a full visual system instead of only one accent
/// color, making the male and female themes feel clearly different.
UserTonePalette tonePaletteFor(UserGender gender) {
  switch (gender) {
    case UserGender.male:
      return const UserTonePalette(
        primary: Color(0xFF0D1016),
        secondary: Color(0xFF4F77FF),
        surface: Color(0xFFE7EDF9),
        badge: Color(0xFF2F6BFF),
        foreground: Colors.white,
        canvas: Color(0xFFF1F4FA),
        cardBackground: Color(0xFFFCFDFF),
        outline: Color(0xFFD8E0EC),
        mutedForeground: Color(0xFF7D8797),
        highlight: Color(0xFFD8E4FF),
      );
    case UserGender.female:
      return const UserTonePalette(
        primary: Color(0xFF2A1820),
        secondary: Color(0xFFE07198),
        surface: Color(0xFFFBEAF2),
        badge: Color(0xFFE85A8E),
        foreground: Colors.white,
        canvas: Color(0xFFFFF5F7),
        cardBackground: Color(0xFFFFFCFD),
        outline: Color(0xFFF0D5DF),
        mutedForeground: Color(0xFF97727D),
        highlight: Color(0xFFFFE2EB),
      );
    case UserGender.nonBinary:
      return const UserTonePalette(
        primary: Color(0xFF1E1930),
        secondary: Color(0xFF6E5CF6),
        surface: Color(0xFFF1EEFF),
        badge: Color(0xFFF59E0B),
        foreground: Colors.white,
        canvas: Color(0xFFF7F5FF),
        cardBackground: Color(0xFFFFFEFF),
        outline: Color(0xFFE1DBFF),
        mutedForeground: Color(0xFF7A7296),
        highlight: Color(0xFFE8E3FF),
      );
    case UserGender.undisclosed:
      return const UserTonePalette(
        primary: Color(0xFF191B20),
        secondary: Color(0xFF585E6C),
        surface: Color(0xFFF1F2F4),
        badge: Color(0xFFB7791F),
        foreground: Colors.white,
        canvas: Color(0xFFF6F7F8),
        cardBackground: Color(0xFFFFFFFF),
        outline: Color(0xFFE4E7EB),
        mutedForeground: Color(0xFF7B808C),
        highlight: Color(0xFFE9EDF2),
      );
  }
}
