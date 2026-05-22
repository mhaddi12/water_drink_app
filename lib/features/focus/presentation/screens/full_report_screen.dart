import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:water_drink_app/core/firebase/app_firebase.dart';
import 'package:water_drink_app/data/repositories/user_repository.dart';
import 'package:water_drink_app/data/services/auth_service.dart';
import 'package:water_drink_app/features/focus/controllers/home_controller.dart';
import 'package:water_drink_app/features/focus/presentation/widgets/focus_app_bar.dart';
import 'package:water_drink_app/features/focus/presentation/widgets/focus_ui.dart';
import 'package:water_drink_app/features/focus/presentation/widgets/stats_visuals.dart';

class FullReportScreen extends StatelessWidget {
  const FullReportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<HomeController>();
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            FocusAppBar(
              title: 'Full report',
              leading: Icons.arrow_back_rounded,
              onLeadingTap: Get.back,
            ),
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
                  controller.focusHours.value;
                  controller.streakDays.value;
                  controller.statsReportScope.value;
                  final scope = controller.statsReportScope.value;
                  final showWeekly = scope == 'week';
                  final showMonthly = scope == 'week' || scope == 'month';
                  final showEfficiency = scope == 'all' || scope == 'week';

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const FocusPageHeader(
                        title: 'Performance report',
                        subtitle:
                            'A complete look at your consistency, focus depth, and system efficiency.',
                      ),
                      const SizedBox(height: 16),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          _ReportChip(
                            label: 'This week',
                            scope: 'week',
                            controller: controller,
                          ),
                          _ReportChip(
                            label: 'This month',
                            scope: 'month',
                            controller: controller,
                          ),
                          _ReportChip(
                            label: 'All systems',
                            scope: 'all',
                            controller: controller,
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      MomentumSummaryCard(
                        streakDays: controller.statsStreakDays.value,
                        completionRate: controller.statsCompletionRate.value,
                        showAction: false,
                      ),
                      const SizedBox(height: 12),
                      if (showWeekly) ...[
                        Row(
                          children: [
                            Expanded(
                              child: FocusMetricChip(
                                label: 'Focus hours',
                                value: '${controller.focusHours.value}h',
                                icon: Icons.bolt_rounded,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: FocusMetricChip(
                                label: 'Active streak',
                                value: '${controller.streakDays.value}d',
                                icon: Icons.local_fire_department_outlined,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        WeeklyCompletionCard(
                          heights: controller.weeklyHeights,
                          highlightIndex: controller.weeklyHighlightIndex.value,
                        ),
                        const SizedBox(height: 12),
                        FocusDepthCard(
                          durationLabel: controller.focusDepthFormatted,
                          deltaPct: controller.statsFocusDepthDeltaPct.value,
                        ),
                        const SizedBox(height: 12),
                      ],
                      if (showMonthly) ...[
                        MonthlyGoalCard(
                          done: controller.statsMonthlyDone.value,
                          total: controller.statsMonthlyTotal.value,
                          progress: controller.monthlyGoalProgress,
                          quote: controller.statsQuote.value,
                        ),
                        const SizedBox(height: 12),
                      ],
                      if (showEfficiency)
                        EfficiencyListCard(
                          rows: controller.efficiencyRows,
                          title: 'Detailed efficiency',
                        ),
                      if (showEfficiency) const SizedBox(height: 12),
                      FocusSurface(
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: const Color(0xFFE8F6EF),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(
                                Icons.auto_awesome_rounded,
                                color: FocusUi.accent,
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Coach note',
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleSmall
                                        ?.copyWith(
                                          fontWeight: FontWeight.w700,
                                          color: FocusUi.inkSoft(context),
                                        ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    controller.statsQuote.value,
                                    style: TextStyle(
                                      color: FocusUi.muted(context),
                                      height: 1.4,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                }),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ReportChip extends StatelessWidget {
  const _ReportChip({
    required this.label,
    required this.scope,
    required this.controller,
  });

  final String label;
  final String scope;
  final HomeController controller;

  @override
  Widget build(BuildContext context) {
    final selected = controller.statsReportScope.value == scope;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return InkWell(
      onTap: () => controller.setReportScope(scope),
      borderRadius: BorderRadius.circular(999),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: selected
              ? (isDark
                  ? const Color(0xFF1A2744)
                  : const Color(0xFFE8F0FF))
              : FocusUi.surface(context),
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: selected
                ? const Color(0xFF4F74FF)
                : FocusUi.line(context),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: selected
                ? (isDark
                    ? const Color(0xFF9DB4FF)
                    : const Color(0xFF2E4CB2))
                : FocusUi.muted(context),
          ),
        ),
      ),
    );
  }
}

Future<void> openFullReport() async {
  if (AppFirebase.isReady &&
      Get.isRegistered<AuthService>() &&
      Get.isRegistered<UserRepository>()) {
    final uid = Get.find<AuthService>().currentUid;
    if (uid != null) {
      await Get.find<UserRepository>().recordStatsReportOpened(uid);
    }
  }
  await Get.to(() => const FullReportScreen());
}
