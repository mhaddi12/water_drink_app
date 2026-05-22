import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:water_drink_app/app/widgets/hydra_app_drawer.dart';
import 'package:water_drink_app/features/history/presentation/screens/history_screen.dart';
import 'package:water_drink_app/features/hydration/controllers/hydration_controller.dart';
import 'package:water_drink_app/features/hydration/presentation/widgets/hydration_progress_card.dart';
import 'package:water_drink_app/features/hydration/presentation/widgets/intake_timeline_tile.dart';
import 'package:water_drink_app/features/hydration/presentation/widgets/quick_add_row.dart';
import 'package:water_drink_app/features/reminders/presentation/screens/reminders_screen.dart';
import 'package:water_drink_app/features/settings/presentation/screens/settings_screen.dart';

class HydrationHomeScreen extends GetView<HydrationController> {
  const HydrationHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return SafeArea(
      bottom: false,
      child: Obx(() {
        controller.todayIntakes;
        controller.goalMl.value;
        controller.displayName.value;
        controller.nextReminderText.value;
        final currentMl = controller.currentMl;
        final goalMl = controller.goalMl.value;

        return SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  IconButton(
                    onPressed: () => openHydraDrawer(context),
                    icon: const Icon(Icons.menu_rounded),
                    tooltip: 'Menu',
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          controller.greeting(),
                          style: textTheme.titleMedium?.copyWith(
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Stay hydrated, ${controller.displayName.value}',
                          style: textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Get.to(() => const HistoryScreen()),
                    icon: const Icon(Icons.history_rounded),
                    tooltip: 'History',
                  ),
                  IconButton(
                    onPressed: () => Get.to(() => const RemindersScreen()),
                    icon: const Icon(Icons.notifications_none_rounded),
                    tooltip: 'Reminders',
                  ),
                  IconButton(
                    onPressed: () => Get.to(() => const SettingsScreen()),
                    icon: const Icon(Icons.settings_outlined),
                    tooltip: 'Settings',
                  ),
                ],
              ),
              const SizedBox(height: 22),
              HydrationProgressCard(
                currentMl: currentMl,
                goalMl: goalMl,
                reminderText: controller.nextReminderText.value,
              ),
              const SizedBox(height: 20),
              Text(
                'Quick Add',
                style: textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 10),
              QuickAddRow(onAdd: controller.addWater),
              const SizedBox(height: 18),
              Center(
                child: FilledButton.icon(
                  onPressed: () => controller.addWater(250),
                  icon: const Icon(Icons.local_drink_rounded),
                  label: const Text('Add 250 ml'),
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    visualDensity: VisualDensity.compact,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    textStyle: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 22),
              Text(
                'Today',
                style: textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 10),
              if (controller.todayIntakes.isEmpty)
                Text(
                  'No intake logged yet. Add water to sync today\'s timeline.',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                )
              else
                ...controller.todayIntakes.map(
                  (intake) => IntakeTimelineTile(
                    time: _formatTime(intake.createdAt),
                    amountMl: intake.amountMl,
                  ),
                ),
            ],
          ),
        );
      }),
    );
  }

  static String _formatTime(DateTime time) {
    final hour = time.hour % 12 == 0 ? 12 : time.hour % 12;
    final minute = time.minute.toString().padLeft(2, '0');
    final suffix = time.hour >= 12 ? 'PM' : 'AM';
    return '$hour:$minute $suffix';
  }
}
