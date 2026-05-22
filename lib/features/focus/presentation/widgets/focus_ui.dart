import 'package:flutter/material.dart';
import 'package:water_drink_app/app/theme/hydra_theme_colors.dart';

abstract final class FocusUi {
  static const Color accent = Color(0xFF4A987E);
  static const Color accentMint = Color(0xFF93E6C4);
  static const Color navy = Color(0xFF082F86);
  static const double radius = 16;

  static HydraThemeColors _c(BuildContext context) => HydraThemeColors.of(context);

  static Color ink(BuildContext context) => _c(context).ink;
  static Color inkSoft(BuildContext context) => _c(context).inkSoft;
  static Color muted(BuildContext context) => _c(context).muted;
  static Color line(BuildContext context) => _c(context).line;
  static Color surface(BuildContext context) => _c(context).surface;

  static BoxDecoration surfaceDecoration(
    BuildContext context, {
    Color? color,
    Color? borderColor,
  }) {
    final colors = _c(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return BoxDecoration(
      color: color ?? colors.surface,
      borderRadius: BorderRadius.circular(radius),
      border: Border.all(color: borderColor ?? colors.line),
      boxShadow: isDark
          ? null
          : [
              BoxShadow(
                color: colors.shadow,
                blurRadius: 18,
                offset: const Offset(0, 8),
              ),
            ],
    );
  }
}

class FocusPageHeader extends StatelessWidget {
  const FocusPageHeader({
    super.key,
    required this.title,
    required this.subtitle,
  });

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w700,
            color: FocusUi.ink(context),
            height: 1.15,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          subtitle,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: FocusUi.muted(context),
            height: 1.35,
          ),
        ),
      ],
    );
  }
}

class FocusSectionLabel extends StatelessWidget {
  const FocusSectionLabel({
    super.key,
    required this.label,
    this.color,
  });

  final String label;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Text(
      label.toUpperCase(),
      style: TextStyle(
        color: color ?? FocusUi.accent,
        fontWeight: FontWeight.w700,
        fontSize: 10,
        letterSpacing: 0.7,
      ),
    );
  }
}

class FocusSurface extends StatelessWidget {
  const FocusSurface({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.color,
    this.borderColor,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final Color? color;
  final Color? borderColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: padding,
      decoration: FocusUi.surfaceDecoration(
        context,
        color: color,
        borderColor: borderColor,
      ),
      child: child,
    );
  }
}

class FocusMetricChip extends StatelessWidget {
  const FocusMetricChip({
    super.key,
    required this.label,
    required this.value,
    this.icon,
    this.valueColor,
  });

  final String label;
  final String value;
  final IconData? icon;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    return FocusSurface(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (icon != null) ...[
                Icon(icon, size: 14, color: FocusUi.muted(context)),
                const SizedBox(width: 6),
              ],
              Expanded(
                child: Text(
                  label.toUpperCase(),
                  style: TextStyle(
                    fontSize: 9,
                    color: FocusUi.muted(context),
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: valueColor ?? FocusUi.inkSoft(context),
            ),
          ),
        ],
      ),
    );
  }
}
