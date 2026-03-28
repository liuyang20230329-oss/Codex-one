import 'package:flutter/material.dart';

class AppBrand {
  const AppBrand._();

  static const String brandName = '三十七度';
  static const String appName = '37°';
  static const String englishName = 'Thirty-Seven Degrees';
  static const String slogan = '温度与信任';
  static const String introLine = '以温度连接真诚，以严肃守护信任。';
  static const String aboutTitle = '关于37°';

  static const Color ink = Color(0xFF101114);
  static const Color inkSoft = Color(0xFF1A1C22);
  static const Color line = Color(0xFF2A2D35);
  static const Color paper = Color(0xFFF3EFE8);
  static const Color paperStrong = Color(0xFFE8E1D7);
}

class AppBrandLockup extends StatelessWidget {
  const AppBrandLockup({
    super.key,
    this.alignment = CrossAxisAlignment.start,
    this.symbolSize = 72,
    this.showSlogan = true,
    this.onDark = true,
  });

  final CrossAxisAlignment alignment;
  final double symbolSize;
  final bool showSlogan;
  final bool onDark;

  @override
  Widget build(BuildContext context) {
    final titleColor = onDark ? Colors.white : AppBrand.ink;
    final subtitleColor = onDark
        ? Colors.white.withValues(alpha: 0.68)
        : AppBrand.ink.withValues(alpha: 0.66);

    return Column(
      crossAxisAlignment: alignment,
      children: <Widget>[
        Container(
          height: symbolSize,
          width: symbolSize,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: onDark ? Colors.white.withValues(alpha: 0.06) : AppBrand.ink,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: onDark
                  ? Colors.white.withValues(alpha: 0.14)
                  : AppBrand.ink.withValues(alpha: 0.08),
            ),
          ),
          child: Text(
            AppBrand.appName,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -1.4,
                ),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          AppBrand.appName,
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                color: titleColor,
                fontWeight: FontWeight.w800,
                letterSpacing: -1.2,
              ),
        ),
        if (showSlogan) ...<Widget>[
          const SizedBox(height: 8),
          Text(
            AppBrand.introLine,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: subtitleColor,
                ),
          ),
        ],
      ],
    );
  }
}
