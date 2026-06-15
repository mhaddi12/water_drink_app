import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:water_drink_app/app/theme/app_theme.dart';
import 'package:water_drink_app/app/theme/hydra_theme_colors.dart';
import 'package:water_drink_app/core/firebase/app_firebase.dart';
import 'package:water_drink_app/data/services/auth_service.dart';
import 'package:water_drink_app/features/auth/presentation/screens/auth_screen.dart';
import 'package:water_drink_app/features/focus/presentation/screens/create_system_screen.dart';
import 'package:water_drink_app/features/focus/presentation/screens/full_report_screen.dart';
import 'package:water_drink_app/features/history/presentation/screens/history_screen.dart';
import 'package:water_drink_app/features/reminders/presentation/screens/reminders_screen.dart';
import 'package:water_drink_app/features/focus/presentation/screens/stats_screen.dart';
import 'package:water_drink_app/features/settings/controllers/settings_controller.dart';
import 'package:water_drink_app/features/settings/presentation/widgets/account_sheet.dart';

void openHydraDrawer(BuildContext context) {
  final scaffold = Scaffold.maybeOf(context);
  if (scaffold?.hasDrawer == true) {
    scaffold!.openDrawer();
  }
}

/// Secondary destinations only — main tabs live in the bottom bar.
class HydraAppDrawer extends StatelessWidget {
  const HydraAppDrawer({super.key});

  static final _items = [
    _DrawerLink(
      icon: Icons.bar_chart_rounded,
      label: 'Stats',
      builder: () => const StatsScreen(),
    ),
    _DrawerLink(
      icon: Icons.history_rounded,
      label: 'History',
      builder: () => const HistoryScreen(),
    ),
    _DrawerLink(
      icon: Icons.notifications_outlined,
      label: 'Reminders',
      builder: () => const RemindersScreen(),
    ),
    _DrawerLink(
      icon: Icons.add_circle_outline_rounded,
      label: 'New system',
      builder: () => const CreateSystemScreen(),
    ),
    _DrawerLink(
      icon: Icons.insights_outlined,
      label: 'Full report',
      builder: () => const FullReportScreen(),
    ),
  ];

  bool get _isSignedIn =>
      AppFirebase.isReady &&
      Get.isRegistered<AuthService>() &&
      Get.find<AuthService>().currentUser != null;

  @override
  Widget build(BuildContext context) {
    final colors = HydraThemeColors.of(context);
    final displayName = Get.isRegistered<SettingsController>()
        ? Get.find<SettingsController>().displayName.value
        : 'Hydra user';

    return Drawer(
      width: 280,
      backgroundColor: colors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.horizontal(right: Radius.circular(20)),
      ),
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 12, 8),
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [AppTheme.primary, AppTheme.primaryLight],
                      ),
                      borderRadius: BorderRadius.circular(14),
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
                          displayName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w800,
                            color: colors.ink,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'More options',
                          style: TextStyle(
                            fontSize: 13,
                            color: colors.muted,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: Icon(Icons.close_rounded, color: colors.muted),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                'Use the bar at the bottom for Home, Systems, Water, and Settings.',
                style: TextStyle(
                  fontSize: 12,
                  height: 1.35,
                  color: colors.muted,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                itemCount: _items.length,
                separatorBuilder: (_, __) => const SizedBox(height: 4),
                itemBuilder: (context, index) {
                  final item = _items[index];
                  return _DrawerTile(
                    icon: item.icon,
                    label: item.label,
                    onTap: () {
                      Navigator.pop(context);
                      Get.to(item.builder);
                    },
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              child: FilledButton.tonalIcon(
                onPressed: () {
                  Navigator.pop(context);
                  if (_isSignedIn) {
                    showHydraAccountSheet(context);
                  } else if (AppFirebase.isReady) {
                    Get.to(() => const AuthScreen());
                  } else {
                    Get.snackbar('Hydra', 'Cloud sync unavailable');
                  }
                },
                icon: Icon(_isSignedIn ? Icons.person_outline : Icons.login_rounded),
                label: Text(_isSignedIn ? 'Account' : 'Sign in'),
                style: FilledButton.styleFrom(
                  minimumSize: const Size.fromHeight(52),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DrawerTile extends StatelessWidget {
  const _DrawerTile({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = HydraThemeColors.of(context);

    return Material(
      color: colors.chipFill,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Icon(icon, size: 22, color: AppTheme.primary),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: colors.ink,
                  ),
                ),
              ),
              Icon(Icons.chevron_right_rounded, color: colors.muted, size: 22),
            ],
          ),
        ),
      ),
    );
  }
}

class _DrawerLink {
  const _DrawerLink({
    required this.icon,
    required this.label,
    required this.builder,
  });

  final IconData icon;
  final String label;
  final Widget Function() builder;
}
