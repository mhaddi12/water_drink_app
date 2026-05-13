import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:water_drink_app/features/focus/controllers/home_controller.dart';
import 'package:water_drink_app/features/focus/presentation/screens/full_report_screen.dart';
import 'package:water_drink_app/features/focus/presentation/widgets/focus_app_bar.dart';
import 'package:water_drink_app/features/focus/presentation/widgets/focus_ui.dart';
import 'package:water_drink_app/features/focus/presentation/widgets/stats_visuals.dart';

class StatsScreen extends StatelessWidget {
  const StatsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<HomeController>();
    return SafeArea(
      child: Column(
        children: [
          const FocusAppBar(),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
              child: Obx(() {
                controller.weeklyHeights;
                controller.weeklyHighlightIndex.value;
                controller.statsStreakDays.value;
                controller.statsCompletionRate.value;
                controller.statsFocusDepthSeconds.value;
                controller.statsFocusDepthDeltaPct.value;
                controller.statsMonthlyDone.value;
                controller.statsMonthlyTotal.value;
                controller.statsQuote.value;
                controller.efficiencyRows;

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const FocusPageHeader(
                      title: 'Your progress',
                      subtitle:
                          'Review your consistency and refine your mental clarity.',
                    ),
                    const SizedBox(height: 16),
                    WeeklyCompletionCard(
                      heights: controller.weeklyHeights,
                      highlightIndex: controller.weeklyHighlightIndex.value,
                      compact: true,
                    ),
                    const SizedBox(height: 12),
                    MomentumSummaryCard(
                      streakDays: controller.statsStreakDays.value,
                      completionRate: controller.statsCompletionRate.value,
                      onViewFullReport: openFullReport,
                    ),
                    const SizedBox(height: 12),
                    FocusDepthCard(
                      durationLabel: controller.focusDepthFormatted,
                      deltaPct: controller.statsFocusDepthDeltaPct.value,
                    ),
                    const SizedBox(height: 12),
                    MonthlyGoalCard(
                      done: controller.statsMonthlyDone.value,
                      total: controller.statsMonthlyTotal.value,
                      progress: controller.monthlyGoalProgress,
                      quote: controller.statsQuote.value,
                    ),
                    const SizedBox(height: 12),
                    EfficiencyListCard(rows: controller.efficiencyRows),
                  ],
                );
              }),
            ),
          ),
        ],
      ),
    );
  }
}
