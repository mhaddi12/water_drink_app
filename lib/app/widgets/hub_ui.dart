import 'package:flutter/material.dart';
import 'package:water_drink_app/app/widgets/hydra_app_drawer.dart';

/// Shared layout and cards for Water hub screens (History, Reminders, Settings).
abstract final class HubUi {
  static const Color primary = Color(0xFF4F74FF);
  static const Color primaryLight = Color(0xFF62A5FF);

  static Color mutedText(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return scheme.onSurfaceVariant;
  }

  static Color border(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? const Color(0xFF2E2E2E)
        : const Color(0xFFE3EBFF);
  }

  static Color scaffold(BuildContext context) {
    return Theme.of(context).scaffoldBackgroundColor;
  }

  static Color cardSurface(BuildContext context) {
    return Theme.of(context).cardColor;
  }
}

class HubPageHeader extends StatelessWidget {
  const HubPageHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.trailing,
  });

  final String title;
  final String? subtitle;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final canPop = Navigator.of(context).canPop();
    final hasDrawer = Scaffold.maybeOf(context)?.hasDrawer == true;

    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 4, 8, 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (hasDrawer && canPop)
            IconButton(
              onPressed: () => Navigator.of(context).maybePop(),
              icon: const Icon(Icons.arrow_back_rounded),
              tooltip: 'Back',
            )
          else if (hasDrawer)
            IconButton(
              onPressed: () => openHydraDrawer(context),
              icon: const Icon(Icons.menu_rounded),
              tooltip: 'Menu',
            )
          else if (canPop)
            IconButton(
              onPressed: () => Navigator.of(context).maybePop(),
              icon: const Icon(Icons.arrow_back_rounded),
              tooltip: 'Back',
            )
          else
            const SizedBox(width: 4),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    subtitle!,
                    style: textTheme.bodyMedium?.copyWith(
                      color: HubUi.mutedText(context),
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (trailing != null)
            trailing!
          else if (hasDrawer && canPop)
            IconButton(
              onPressed: () => openHydraDrawer(context),
              icon: const Icon(Icons.menu_rounded),
              tooltip: 'Menu',
            ),
        ],
      ),
    );
  }
}

class HubSectionLabel extends StatelessWidget {
  const HubSectionLabel(this.label, {super.key});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10, top: 4),
      child: Text(
        label.toUpperCase(),
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.8,
          color: HubUi.mutedText(context),
        ),
      ),
    );
  }
}

class HubCard extends StatelessWidget {
  const HubCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.gradient,
  });

  final Widget child;
  final EdgeInsets padding;
  final Gradient? gradient;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        gradient: gradient,
        color: gradient == null ? HubUi.cardSurface(context) : null,
        border: gradient == null
            ? Border.all(color: HubUi.border(context))
            : null,
        boxShadow: gradient != null
            ? const [
                BoxShadow(
                  color: Color(0x334F74FF),
                  blurRadius: 16,
                  offset: Offset(0, 8),
                ),
              ]
            : null,
      ),
      child: child,
    );
  }
}

class HubStatCard extends StatelessWidget {
  const HubStatCard({
    super.key,
    required this.title,
    required this.value,
    required this.subtitle,
    required this.icon,
  });

  final String title;
  final String value;
  final String subtitle;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return HubCard(
      child: Row(
        children: [
          CircleAvatar(
            radius: 22,
            backgroundColor: HubUi.primary.withValues(alpha: 0.12),
            child: Icon(icon, color: HubUi.primary, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: HubUi.mutedText(context),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 12,
                    color: HubUi.mutedText(context),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class HubListTile extends StatelessWidget {
  const HubListTile({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.trailing,
    this.onTap,
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: HubUi.cardSurface(context),
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: HubUi.border(context)),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: Row(
              children: [
                Icon(icon, color: HubUi.primary),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      if (subtitle != null) ...[
                        const SizedBox(height: 2),
                        Text(
                          subtitle!,
                          style: TextStyle(
                            fontSize: 13,
                            color: HubUi.mutedText(context),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                if (trailing != null) trailing!,
                if (onTap != null && trailing == null)
                  Icon(
                    Icons.chevron_right_rounded,
                    color: HubUi.mutedText(context),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class HubEmptyState extends StatelessWidget {
  const HubEmptyState({
    super.key,
    required this.icon,
    required this.message,
  });

  final IconData icon;
  final String message;

  @override
  Widget build(BuildContext context) {
    return HubCard(
      child: Column(
        children: [
          Icon(icon, size: 40, color: HubUi.mutedText(context)),
          const SizedBox(height: 12),
          Text(
            message,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: HubUi.mutedText(context),
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}
