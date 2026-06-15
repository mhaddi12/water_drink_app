import 'package:flutter/material.dart';
import 'package:water_drink_app/app/theme/app_theme.dart';

/// Primary app navigation — large tap targets, labels always visible.
class HydraBottomNav extends StatelessWidget {
  const HydraBottomNav({
    super.key,
    required this.selectedIndex,
    required this.onSelected,
  });

  final int selectedIndex;
  final ValueChanged<int> onSelected;

  static const destinations = [
    _NavItem(
      icon: Icons.home_outlined,
      selectedIcon: Icons.home_rounded,
      label: 'Home',
    ),
    _NavItem(
      icon: Icons.grid_view_rounded,
      selectedIcon: Icons.grid_view_rounded,
      label: 'Systems',
    ),
    _NavItem(
      icon: Icons.water_drop_outlined,
      selectedIcon: Icons.water_drop_rounded,
      label: 'Water',
    ),
    _NavItem(
      icon: Icons.settings_outlined,
      selectedIcon: Icons.settings_rounded,
      label: 'Settings',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: theme.navigationBarTheme.backgroundColor ??
            (isDark ? const Color(0xFF121212) : Colors.white),
        border: Border(
          top: BorderSide(
            color: isDark ? const Color(0xFF2A2A2A) : const Color(0xFFE3EBFF),
          ),
        ),
      ),
      child: SafeArea(
        top: false,
        child: NavigationBar(
          selectedIndex: selectedIndex,
          onDestinationSelected: onSelected,
          height: 68,
          elevation: 0,
          backgroundColor: Colors.transparent,
          surfaceTintColor: Colors.transparent,
          indicatorColor: AppTheme.primary.withValues(alpha: 0.14),
          labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
          destinations: [
            for (final item in destinations)
              NavigationDestination(
                icon: Icon(item.icon, size: 24),
                selectedIcon: Icon(item.selectedIcon, size: 24),
                label: item.label,
              ),
          ],
        ),
      ),
    );
  }
}

class _NavItem {
  const _NavItem({
    required this.icon,
    required this.selectedIcon,
    required this.label,
  });

  final IconData icon;
  final IconData selectedIcon;
  final String label;
}
