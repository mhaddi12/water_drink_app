import 'package:flutter/material.dart';

/// Semantic colors for Hydra UI that adapt to light / dark theme.
@immutable
class HydraThemeColors extends ThemeExtension<HydraThemeColors> {
  const HydraThemeColors({
    required this.ink,
    required this.inkSoft,
    required this.muted,
    required this.line,
    required this.surface,
    required this.chipFill,
    required this.shadow,
  });

  final Color ink;
  final Color inkSoft;
  final Color muted;
  final Color line;
  final Color surface;
  final Color chipFill;
  final Color shadow;

  static const light = HydraThemeColors(
    ink: Color(0xFF143064),
    inkSoft: Color(0xFF163E90),
    muted: Color(0xFF7A8299),
    line: Color(0xFFE8EAF2),
    surface: Colors.white,
    chipFill: Color(0xFFE8F0FF),
    shadow: Color(0x0A152238),
  );

  static const dark = HydraThemeColors(
    ink: Color(0xFFF2F2F2),
    inkSoft: Color(0xFFD6D6D6),
    muted: Color(0xFF9E9E9E),
    line: Color(0xFF2E2E2E),
    surface: Color(0xFF121212),
    chipFill: Color(0xFF1A1A1A),
    shadow: Colors.transparent,
  );

  static HydraThemeColors of(BuildContext context) {
    return Theme.of(context).extension<HydraThemeColors>() ??
        (Theme.of(context).brightness == Brightness.dark ? dark : light);
  }

  @override
  HydraThemeColors copyWith({
    Color? ink,
    Color? inkSoft,
    Color? muted,
    Color? line,
    Color? surface,
    Color? chipFill,
    Color? shadow,
  }) {
    return HydraThemeColors(
      ink: ink ?? this.ink,
      inkSoft: inkSoft ?? this.inkSoft,
      muted: muted ?? this.muted,
      line: line ?? this.line,
      surface: surface ?? this.surface,
      chipFill: chipFill ?? this.chipFill,
      shadow: shadow ?? this.shadow,
    );
  }

  @override
  HydraThemeColors lerp(ThemeExtension<HydraThemeColors>? other, double t) {
    if (other is! HydraThemeColors) return this;
    return HydraThemeColors(
      ink: Color.lerp(ink, other.ink, t)!,
      inkSoft: Color.lerp(inkSoft, other.inkSoft, t)!,
      muted: Color.lerp(muted, other.muted, t)!,
      line: Color.lerp(line, other.line, t)!,
      surface: Color.lerp(surface, other.surface, t)!,
      chipFill: Color.lerp(chipFill, other.chipFill, t)!,
      shadow: Color.lerp(shadow, other.shadow, t)!,
    );
  }
}
