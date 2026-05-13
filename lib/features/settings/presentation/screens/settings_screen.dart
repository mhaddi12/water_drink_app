import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:water_drink_app/features/settings/controllers/settings_controller.dart';

class SettingsScreen extends GetView<SettingsController> {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return SafeArea(
      child: Obx(() {
        controller.displayName.value;
        controller.hydrationGoalMl.value;
        controller.reminderFrequencyHours.value;
        controller.theme.value;
        controller.appVersionLabel.value;

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Settings',
                style: textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    const CircleAvatar(
                      radius: 22,
                      backgroundColor: Color(0xFFDCE7FF),
                      child: Icon(Icons.person_outline_rounded),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            controller.displayName.value,
                            style: const TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 16,
                            ),
                          ),
                          Text('Goal: ${controller.goalLabel}'),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: controller.editDisplayName,
                      icon: const Icon(Icons.edit_outlined),
                      tooltip: 'Edit name',
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              _SettingTile(
                icon: Icons.flag_outlined,
                title: 'Daily Goal',
                subtitle: controller.goalLabel,
                onTap: controller.editDailyGoal,
              ),
              _SettingTile(
                icon: Icons.notifications_none_rounded,
                title: 'Reminder Frequency',
                subtitle: controller.reminderFrequencyLabel,
                onTap: controller.editReminderFrequency,
              ),
              _SettingTile(
                icon: Icons.palette_outlined,
                title: 'Theme',
                subtitle: controller.themeLabel,
                onTap: controller.toggleTheme,
              ),
              _SettingTile(
                icon: Icons.info_outline,
                title: 'About',
                subtitle: 'Hydra ${controller.appVersionLabel.value}',
              ),
            ],
          ),
        );
      }),
    );
  }
}

class _SettingTile extends StatelessWidget {
  const _SettingTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(14),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                Icon(icon, color: const Color(0xFF4F74FF)),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: const TextStyle(
                          fontSize: 13,
                          color: Color(0xFF667185),
                        ),
                      ),
                    ],
                  ),
                ),
                if (onTap != null)
                  const Icon(Icons.chevron_right_rounded),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
