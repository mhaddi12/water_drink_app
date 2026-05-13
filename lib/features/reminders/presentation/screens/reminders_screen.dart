import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:water_drink_app/features/reminders/controllers/reminders_controller.dart';

class RemindersScreen extends GetView<RemindersController> {
  const RemindersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return SafeArea(
      child: Obx(() {
        controller.slots;
        controller.reminderFrequencyHours.value;

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Reminders',
                style: textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Stay on track with smart alerts',
                style: textTheme.bodyMedium?.copyWith(
                  color: const Color(0xFF667185),
                ),
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: const Color(0xFFE3EBFF)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.notifications_active_outlined),
                    const SizedBox(width: 12),
                    Expanded(child: Text(controller.scheduleSummary)),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              Expanded(
                child: controller.slots.isEmpty
                    ? const Center(
                        child: Text(
                          'Reminder slots will sync from your Firebase profile.',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Color(0xFF667185)),
                        ),
                      )
                    : ListView(
                        children: controller.slots
                            .map(
                              (slot) => _ReminderTile(
                                time: slot.time,
                                enabled: slot.enabled,
                                onChanged: (enabled) =>
                                    controller.toggleSlot(slot.time, enabled),
                              ),
                            )
                            .toList(),
                      ),
              ),
            ],
          ),
        );
      }),
    );
  }
}

class _ReminderTile extends StatelessWidget {
  const _ReminderTile({
    required this.time,
    required this.enabled,
    required this.onChanged,
  });

  final String time;
  final bool enabled;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          const Icon(Icons.alarm_rounded, color: Color(0xFF4F74FF)),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              time,
              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
            ),
          ),
          Switch(value: enabled, onChanged: onChanged),
        ],
      ),
    );
  }
}
