import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:water_drink_app/app/widgets/hub_ui.dart';
import 'package:water_drink_app/core/firebase/app_firebase.dart';
import 'package:water_drink_app/core/notifications/notification_coordinator.dart';
import 'package:water_drink_app/features/reminders/controllers/reminders_controller.dart';
import 'package:water_drink_app/features/reminders/presentation/screens/reminders_screen.dart';
import 'package:water_drink_app/features/settings/controllers/settings_controller.dart';

class SettingsScreen extends GetView<SettingsController> {
  const SettingsScreen({super.key, this.embedded = false});

  /// True when shown as a bottom-nav tab (no drawer, no duplicate nav).
  final bool embedded;

  @override
  Widget build(BuildContext context) {
    final notifications = NotificationCoordinator.instance;
    final textTheme = Theme.of(context).textTheme;

    final body = Obx(() {
      controller.displayName.value;
      controller.hydrationGoalMl.value;
      controller.theme.value;
      controller.appVersionLabel.value;
      controller.accountHint.value;
      controller.isSignedIn.value;
      notifications.permissionGranted.value;
      notifications.pushOptedIn.value;
      notifications.statusSummary.value;
      if (Get.isRegistered<RemindersController>()) {
        Get.find<RemindersController>().slots.length;
      }

      final remindersOn = Get.isRegistered<RemindersController>() &&
          Get.find<RemindersController>().remindersEnabled;

      return CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: HubPageHeader(
              title: 'Settings',
              subtitle: 'Profile and app preferences',
              showMenu: !embedded,
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                HubCard(
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 28,
                        backgroundColor: HubUi.primary.withValues(alpha: 0.12),
                        child: const Icon(
                          Icons.person_outline_rounded,
                          color: HubUi.primary,
                          size: 30,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              controller.displayName.value,
                              style: textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              controller.accountHint.value,
                              style: textTheme.bodySmall?.copyWith(
                                color: HubUi.mutedText(context),
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: controller.editDisplayName,
                        icon: const Icon(Icons.edit_outlined),
                        tooltip: 'Edit name',
                        color: HubUi.primary,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                const HubSectionLabel('Notifications'),
                HubListTile(
                  icon: Icons.notifications_active_outlined,
                  title: 'Push status',
                  subtitle: notifications.statusSummary.value,
                  trailing: IconButton(
                    onPressed: notifications.refreshStatus,
                    icon: const Icon(Icons.refresh_rounded),
                    color: HubUi.primary,
                    tooltip: 'Refresh',
                  ),
                ),
                if (!notifications.permissionGranted.value)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: FilledButton.icon(
                      onPressed: () async {
                        if (Get.isRegistered<RemindersController>()) {
                          await Get.find<RemindersController>()
                              .requestPermissions();
                        } else {
                          await notifications.requestPermissions();
                        }
                      },
                      icon: const Icon(Icons.notifications_outlined),
                      label: const Text('Enable notifications'),
                      style: FilledButton.styleFrom(
                        backgroundColor: HubUi.primary,
                        minimumSize: const Size.fromHeight(52),
                      ),
                    ),
                  ),
                HubListTile(
                  icon: Icons.alarm_rounded,
                  title: 'Hydration reminders',
                  subtitle: !remindersOn
                      ? 'Off · push from your server when enabled'
                      : 'On · push from your server',
                  onTap: () => Get.to(() => const RemindersScreen()),
                ),
                const SizedBox(height: 20),
                const HubSectionLabel('Hydration'),
                HubListTile(
                  icon: Icons.flag_outlined,
                  title: 'Daily goal',
                  subtitle: controller.goalLabel,
                  onTap: controller.editDailyGoal,
                ),
                const SizedBox(height: 20),
                const HubSectionLabel('App'),
                HubListTile(
                  icon: Icons.palette_outlined,
                  title: 'Theme',
                  subtitle: controller.themeLabel,
                  onTap: controller.toggleTheme,
                ),
                HubListTile(
                  icon: Icons.info_outline,
                  title: 'About Hydra',
                  subtitle: 'Version ${controller.appVersionLabel.value}',
                ),
                const SizedBox(height: 28),
                if (AppFirebase.isReady && controller.isSignedIn.value)
                  OutlinedButton.icon(
                    onPressed: controller.signOut,
                    icon: const Icon(Icons.logout_rounded),
                    label: const Text('Sign out'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFFC62828),
                      side: const BorderSide(color: Color(0xFFC62828)),
                      minimumSize: const Size.fromHeight(52),
                    ),
                  )
                else if (AppFirebase.isReady && !controller.isSignedIn.value)
                  FilledButton.icon(
                    onPressed: controller.openSignIn,
                    icon: const Icon(Icons.login_rounded),
                    label: const Text('Sign in'),
                    style: FilledButton.styleFrom(
                      backgroundColor: HubUi.primary,
                      minimumSize: const Size.fromHeight(52),
                    ),
                  ),
                const SizedBox(height: 16),
              ]),
            ),
          ),
        ],
      );
    });

    if (embedded) {
      return SafeArea(bottom: false, child: body);
    }

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(child: body),
    );
  }
}
