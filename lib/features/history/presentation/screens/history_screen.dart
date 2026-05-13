import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:water_drink_app/features/history/controllers/history_controller.dart';

class HistoryScreen extends GetView<HistoryController> {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return SafeArea(
      child: Obx(() {
        controller.weeklyAverageMl.value;
        controller.weeklyDeltaPct.value;
        controller.bestDayMl.value;
        controller.bestDayLabel.value;
        controller.daySummaries;

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'History',
                style: textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Track your hydration consistency',
                style: textTheme.bodyMedium?.copyWith(
                  color: const Color(0xFF667185),
                ),
              ),
              const SizedBox(height: 20),
              _SummaryCard(
                title: 'Weekly Average',
                value: controller.weeklyAverageLabel,
                subtitle: controller.weeklyDeltaLabel,
                icon: Icons.trending_up_rounded,
              ),
              const SizedBox(height: 12),
              _SummaryCard(
                title: 'Best Day',
                value: controller.bestDayValueLabel,
                subtitle: controller.bestDayLabel.value,
                icon: Icons.emoji_events_outlined,
              ),
              const SizedBox(height: 18),
              Expanded(
                child: controller.daySummaries.isEmpty
                    ? const Center(
                        child: Text(
                          'Your hydration history will appear here after you log water.',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Color(0xFF667185)),
                        ),
                      )
                    : ListView(
                        children: controller.daySummaries
                            .map(
                              (summary) => _DayHistoryTile(
                                day: summary.label,
                                intakeMl: summary.intakeMl,
                                goalMl: summary.goalMl,
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

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
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
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE3EBFF)),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: const Color(0xFFE8F0FF),
            child: Icon(icon, color: const Color(0xFF4F74FF)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF667185),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                Text(subtitle, style: const TextStyle(fontSize: 12)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DayHistoryTile extends StatelessWidget {
  const _DayHistoryTile({
    required this.day,
    required this.intakeMl,
    required this.goalMl,
  });

  final String day;
  final int intakeMl;
  final int goalMl;

  @override
  Widget build(BuildContext context) {
    final progress = goalMl <= 0
        ? 0.0
        : (intakeMl / goalMl).clamp(0, 1).toDouble();
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(day, style: const TextStyle(fontWeight: FontWeight.w700)),
              const Spacer(),
              Text('$intakeMl / $goalMl ml'),
            ],
          ),
          const SizedBox(height: 10),
          LinearProgressIndicator(
            value: progress,
            minHeight: 8,
            borderRadius: BorderRadius.circular(99),
          ),
        ],
      ),
    );
  }
}
