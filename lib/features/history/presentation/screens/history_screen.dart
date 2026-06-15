import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:water_drink_app/app/widgets/hub_ui.dart';
import 'package:water_drink_app/features/history/controllers/history_controller.dart';

class HistoryScreen extends GetView<HistoryController> {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('History'),
      ),
      body: SafeArea(
        child: Obx(() {
          controller.weeklyAverageMl.value;
          controller.weeklyDeltaPct.value;
          controller.bestDayMl.value;
          controller.bestDayLabel.value;
          controller.daySummaries;

          return CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
                  child: Text(
                    'Your hydration consistency over time',
                    style: TextStyle(
                      color: HubUi.mutedText(context),
                      height: 1.4,
                    ),
                  ),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    IntrinsicHeight(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Expanded(
                            child: HubStatCard(
                              title: 'Weekly avg',
                              value: controller.weeklyAverageLabel,
                              subtitle: controller.weeklyDeltaLabel,
                              icon: Icons.trending_up_rounded,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: HubStatCard(
                              title: 'Best day',
                              value: controller.bestDayValueLabel,
                              subtitle: controller.bestDayLabel.value,
                              icon: Icons.emoji_events_outlined,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 18),
                    const HubSectionLabel('Daily log'),
                    if (controller.daySummaries.isEmpty)
                      const HubEmptyState(
                        icon: Icons.water_drop_outlined,
                        message:
                            'Your hydration history will appear here after you log water on the Water tab.',
                      )
                    else
                      ...controller.daySummaries.map(
                        (summary) => _DayHistoryTile(
                          day: summary.label,
                          intakeMl: summary.intakeMl,
                          goalMl: summary.goalMl,
                        ),
                      ),
                    const SizedBox(height: 24),
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
    final hitGoal = progress >= 1.0;

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: HubCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    day,
                    style: const TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 16,
                    ),
                  ),
                ),
                if (hitGoal)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF22C55E).withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      'Goal met',
                      style: TextStyle(
                        color: Color(0xFF16A34A),
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                const SizedBox(width: 8),
                Text(
                  '$intakeMl ml',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    color: HubUi.mutedText(context),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              'Goal $goalMl ml · ${(progress * 100).round()}%',
              style: TextStyle(
                fontSize: 12,
                color: HubUi.mutedText(context),
              ),
            ),
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(99),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 8,
                backgroundColor: HubUi.primary.withValues(alpha: 0.12),
                color: HubUi.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
