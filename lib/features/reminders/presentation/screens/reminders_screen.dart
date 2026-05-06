import 'package:flutter/material.dart';

class RemindersScreen extends StatelessWidget {
  const RemindersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return SafeArea(
      child: Padding(
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
                children: const [
                  Icon(Icons.notifications_active_outlined),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Reminder schedule active every 2 hours between 8 AM and 10 PM',
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            Expanded(
              child: ListView(
                children: const [
                  _ReminderTile(time: '8:00 AM', enabled: true),
                  _ReminderTile(time: '10:00 AM', enabled: true),
                  _ReminderTile(time: '12:00 PM', enabled: true),
                  _ReminderTile(time: '2:00 PM', enabled: false),
                  _ReminderTile(time: '4:00 PM', enabled: true),
                  _ReminderTile(time: '6:00 PM', enabled: true),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ReminderTile extends StatelessWidget {
  const _ReminderTile({required this.time, required this.enabled});

  final String time;
  final bool enabled;

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
          Switch(value: enabled, onChanged: (_) {}),
        ],
      ),
    );
  }
}
