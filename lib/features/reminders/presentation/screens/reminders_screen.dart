import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:water_drink_app/app/widgets/hub_ui.dart';
import 'package:water_drink_app/app/widgets/hydra_app_drawer.dart';
import 'package:water_drink_app/core/notifications/notification_coordinator.dart';
import 'package:water_drink_app/core/reminders/reminder_schedule_helper.dart';
import 'package:water_drink_app/features/reminders/controllers/reminders_controller.dart';

class RemindersScreen extends GetView<RemindersController> {
  const RemindersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final interval = ReminderScheduleHelper.intervalLabel;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      drawer: const HydraAppDrawer(),
      body: SafeArea(
        child: Obx(() {
          controller.slots;
          controller.remindersEnabled;
          final coordinator = NotificationCoordinator.instance;
          coordinator.permissionGranted.value;
          coordinator.pushOptedIn.value;
          coordinator.statusSummary.value;
          coordinator.nextAlarmLabel.value;

          final permission = coordinator.permissionGranted.value;
          final notifications = coordinator.statusSummary.value;
          final nextLabel = coordinator.nextAlarmLabel.value;
          final enabled = controller.remindersEnabled;

          return CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: HubPageHeader(
                  title: 'Hydration reminders',
                  subtitle: 'Notifications every $interval',
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    if (!permission)
                      HubCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.notifications_off_outlined,
                                  color: Colors.orange.shade800,
                                ),
                                const SizedBox(width: 10),
                                const Expanded(
                                  child: Text(
                                    'Notifications are off',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w800,
                                      fontSize: 16,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Enable alerts to get a reminder every $interval.',
                              style: TextStyle(
                                color: HubUi.mutedText(context),
                                height: 1.4,
                              ),
                            ),
                            const SizedBox(height: 14),
                            FilledButton.icon(
                              onPressed: controller.requestPermissions,
                              icon: const Icon(Icons.notifications_active),
                              label: const Text('Enable notifications'),
                              style: FilledButton.styleFrom(
                                backgroundColor: HubUi.primary,
                                minimumSize: const Size.fromHeight(48),
                              ),
                            ),
                          ],
                        ),
                      )
                    else
                      HubCard(
                        gradient: const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [HubUi.primary, HubUi.primaryLight],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(
                                  Icons.alarm_on_rounded,
                                  color: Colors.white,
                                  size: 28,
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    enabled ? 'Reminders on' : 'Reminders off',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w800,
                                      fontSize: 18,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Text(
                              nextLabel,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                                height: 1.35,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              notifications,
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                    const SizedBox(height: 16),
                    HubCard(
                      child: SwitchListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text(
                          interval,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        subtitle: Text(
                          enabled
                              ? (ReminderScheduleHelper.useFastReminders
                                  ? 'Debug build · fires every 3 minutes'
                                  : '${ReminderScheduleHelper.slotsPerDay} reminders per day')
                              : 'Turn on to remind you throughout the day',
                          style: TextStyle(color: HubUi.mutedText(context)),
                        ),
                        value: enabled && permission,
                        activeTrackColor: HubUi.primary.withValues(alpha: 0.5),
                        activeThumbColor: HubUi.primary,
                        onChanged: permission
                            ? controller.setRemindersEnabled
                            : null,
                      ),
                    ),
                    if (kDebugMode) ...[
                      const SizedBox(height: 10),
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton.icon(
                          onPressed: controller.sendTestNotification,
                          icon: const Icon(Icons.science_outlined, size: 18),
                          label: const Text('Test notification (debug)'),
                        ),
                      ),
                    ],
                  ]),
                ),
              ),
            ],
          );
        }),
      ),
    );
  }
}
