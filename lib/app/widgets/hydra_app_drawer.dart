import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:water_drink_app/app/theme/app_theme.dart';
import 'package:water_drink_app/app/theme/hydra_theme_colors.dart';
import 'package:water_drink_app/app/widgets/hub_ui.dart';
import 'package:water_drink_app/core/firebase/app_firebase.dart';
import 'package:water_drink_app/core/session/sign_out_helper.dart';
import 'package:water_drink_app/data/services/auth_service.dart';
import 'package:water_drink_app/features/auth/presentation/screens/auth_screen.dart';
import 'package:water_drink_app/features/focus/controllers/focus_nav_controller.dart';
import 'package:water_drink_app/features/focus/presentation/screens/create_system_screen.dart';
import 'package:water_drink_app/features/focus/presentation/screens/full_report_screen.dart';
import 'package:water_drink_app/features/history/presentation/screens/history_screen.dart';
import 'package:water_drink_app/features/reminders/presentation/screens/reminders_screen.dart';
import 'package:water_drink_app/features/settings/controllers/settings_controller.dart';
import 'package:water_drink_app/features/settings/presentation/screens/settings_screen.dart';
import 'package:water_drink_app/features/settings/presentation/widgets/account_sheet.dart';

/// Opens the root [Scaffold] drawer when one is available.
void openHydraDrawer(BuildContext context) {
  final scaffold = Scaffold.maybeOf(context);
  if (scaffold?.hasDrawer == true) {
    scaffold!.openDrawer();
  }
}

class HydraAppDrawer extends StatelessWidget {
  const HydraAppDrawer({super.key});

  static const _tabDestinations = [
    _DrawerItem(tabIndex: 0, icon: Icons.home_rounded, label: 'Home'),
    _DrawerItem(tabIndex: 1, icon: Icons.grid_view_rounded, label: 'Systems'),
    _DrawerItem(tabIndex: 2, icon: Icons.timer_outlined, label: 'Focus'),
    _DrawerItem(tabIndex: 3, icon: Icons.bar_chart_rounded, label: 'Stats'),
    _DrawerItem(tabIndex: 4, icon: Icons.water_drop_rounded, label: 'Water'),
  ];

  static final _moreDestinations = [
    _DrawerItem(
      route: () => const HistoryScreen(),
      icon: Icons.history_rounded,
      label: 'History',
    ),
    _DrawerItem(
      route: () => const RemindersScreen(),
      icon: Icons.notifications_outlined,
      label: 'Reminders',
    ),
    _DrawerItem(
      route: () => const SettingsScreen(),
      icon: Icons.settings_outlined,
      label: 'Settings',
    ),
    _DrawerItem(
      route: () => const CreateSystemScreen(),
      icon: Icons.add_circle_outline_rounded,
      label: 'New system',
    ),
    _DrawerItem(
      route: () => const FullReportScreen(),
      icon: Icons.insights_outlined,
      label: 'Full report',
    ),
  ];

  void _closeDrawer(BuildContext context) => Navigator.pop(context);

  void _selectTab(BuildContext context, int index) {
    _closeDrawer(context);
    Get.find<FocusNavController>().setTab(index);
    if (Get.currentRoute != '/') {
      Get.until((route) => route.isFirst);
    }
  }

  void _openScreen(BuildContext context, Widget Function() builder) {
    _closeDrawer(context);
    Get.to(builder);
  }

  @override
  Widget build(BuildContext context) {
    final colors = HydraThemeColors.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final nav = Get.find<FocusNavController>();
    final displayName = Get.isRegistered<SettingsController>()
        ? Get.find<SettingsController>().displayName.value
        : 'Hydra user';

    return Drawer(
      width: 288,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      elevation: isDark ? 8 : 1,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.horizontal(right: Radius.circular(20)),
      ),
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(14),
                      gradient: const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [AppTheme.primary, AppTheme.primaryLight],
                      ),
                    ),
                    child: const Icon(
                      Icons.water_drop_rounded,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Hydra',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w800,
                            color: colors.ink,
                            height: 1.1,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          displayName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: colors.muted,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => _closeDrawer(context),
                    icon: Icon(Icons.close_rounded, color: colors.muted, size: 22),
                    tooltip: 'Close',
                    visualDensity: VisualDensity.compact,
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Divider(height: 1, color: HubUi.border(context)),
            ),
            Expanded(
              child: Obx(() {
                final selectedTab = nav.selectedIndex.value;
                return ListView(
                  padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
                  children: [
                    _DrawerSection(
                      title: 'Navigate',
                      children: [
                        for (final item in _tabDestinations)
                          _DrawerNavTile(
                            icon: item.icon,
                            label: item.label,
                            selected: selectedTab == item.tabIndex,
                            onTap: () => _selectTab(context, item.tabIndex!),
                          ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _DrawerSection(
                      title: 'More',
                      children: [
                        for (final item in _moreDestinations)
                          _DrawerNavTile(
                            icon: item.icon,
                            label: item.label,
                            onTap: () {
                              final builder = item.route;
                              if (builder != null) {
                                _openScreen(context, builder);
                              }
                            },
                          ),
                      ],
                    ),
                  ],
                );
              }),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: HubUi.cardSurface(context),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: HubUi.border(context)),
                ),
                child: Column(
                  children: [
                    _DrawerNavTile(
                      icon: Icons.person_outline_rounded,
                      label: 'Account',
                      compact: true,
                      onTap: () {
                        _closeDrawer(context);
                        if (AppFirebase.isReady &&
                            Get.isRegistered<AuthService>() &&
                            Get.find<AuthService>().currentUser != null) {
                          showHydraAccountSheet(context);
                        } else if (AppFirebase.isReady) {
                          Get.to(() => const AuthScreen());
                        } else {
                          Get.snackbar('Hydra', 'Cloud sync unavailable');
                        }
                      },
                    ),
                    if (AppFirebase.isReady &&
                        Get.isRegistered<AuthService>() &&
                        Get.find<AuthService>().currentUser != null) ...[
                      Divider(
                        height: 1,
                        indent: 56,
                        endIndent: 12,
                        color: HubUi.border(context),
                      ),
                      _DrawerNavTile(
                        icon: Icons.logout_rounded,
                        label: 'Sign out',
                        compact: true,
                        destructive: true,
                        onTap: () {
                          _closeDrawer(context);
                          SignOutHelper.confirmAndSignOut(context);
                        },
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DrawerSection extends StatelessWidget {
  const _DrawerSection({
    required this.title,
    required this.children,
  });

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final colors = HydraThemeColors.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 8, bottom: 6),
          child: Text(
            title,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.2,
              color: colors.muted,
            ),
          ),
        ),
        ...children,
      ],
    );
  }
}

class _DrawerNavTile extends StatelessWidget {
  const _DrawerNavTile({
    required this.icon,
    required this.label,
    required this.onTap,
    this.selected = false,
    this.compact = false,
    this.destructive = false,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool selected;
  final bool compact;
  final bool destructive;

  @override
  Widget build(BuildContext context) {
    final colors = HydraThemeColors.of(context);
    final accent = destructive ? const Color(0xFFC62828) : AppTheme.primary;
    final fg = destructive
        ? const Color(0xFFC62828)
        : selected
            ? AppTheme.primary
            : colors.ink;
    final iconBg = selected
        ? accent.withValues(alpha: 0.14)
        : colors.chipFill;

    return Padding(
      padding: EdgeInsets.only(bottom: compact ? 0 : 4),
      child: Material(
        color: selected
            ? accent.withValues(alpha: 0.08)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(14),
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: 10,
              vertical: compact ? 10 : 8,
            ),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: iconBg,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    icon,
                    size: 20,
                    color: destructive
                        ? const Color(0xFFC62828)
                        : selected
                            ? AppTheme.primary
                            : colors.muted,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    label,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: selected ? FontWeight.w700 : FontWeight.w600,
                      color: fg,
                    ),
                  ),
                ),
                if (selected)
                  Icon(
                    Icons.chevron_right_rounded,
                    size: 20,
                    color: AppTheme.primary.withValues(alpha: 0.7),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _DrawerItem {
  const _DrawerItem({
    required this.icon,
    required this.label,
    this.tabIndex,
    this.route,
  });

  final IconData icon;
  final String label;
  final int? tabIndex;
  final Widget Function()? route;
}
