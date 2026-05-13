import 'package:flutter/material.dart';

abstract final class FocusUi {
  static const Color ink = Color(0xFF143064);
  static const Color inkSoft = Color(0xFF163E90);
  static const Color muted = Color(0xFF7A8299);
  static const Color line = Color(0xFFE8EAF2);
  static const Color accent = Color(0xFF4A987E);
  static const Color accentMint = Color(0xFF93E6C4);
  static const Color navy = Color(0xFF082F86);
  static const double radius = 16;

  static BoxDecoration surfaceDecoration({Color? color, Color? borderColor}) {
    return BoxDecoration(
      color: color ?? Colors.white,
      borderRadius: BorderRadius.circular(radius),
      border: Border.all(color: borderColor ?? line),
      boxShadow: const [
        BoxShadow(
          color: Color(0x0A152238),
          blurRadius: 18,
          offset: Offset(0, 8),
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
            color: FocusUi.ink,
            height: 1.15,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          subtitle,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: FocusUi.muted,
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
    this.color = FocusUi.accent,
  });

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Text(
      label.toUpperCase(),
      style: TextStyle(
        color: color,
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
    this.valueColor = FocusUi.inkSoft,
  });

  final String label;
  final String value;
  final IconData? icon;
  final Color valueColor;

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
                Icon(icon, size: 14, color: FocusUi.muted),
                const SizedBox(width: 6),
              ],
              Expanded(
                child: Text(
                  label.toUpperCase(),
                  style: const TextStyle(
                    fontSize: 9,
                    color: FocusUi.muted,
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
              color: valueColor,
            ),
          ),
        ],
      ),
    );
  }
}
