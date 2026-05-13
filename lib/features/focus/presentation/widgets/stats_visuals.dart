import 'package:flutter/material.dart';
import 'package:water_drink_app/data/models/routine_task.dart';
import 'package:water_drink_app/features/focus/controllers/home_controller.dart';
import 'package:water_drink_app/features/focus/presentation/widgets/focus_ui.dart';

const _weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

class WeeklyCompletionCard extends StatelessWidget {
  const WeeklyCompletionCard({
    super.key,
    required this.heights,
    required this.highlightIndex,
    this.compact = false,
  });

  final List<double> heights;
  final int highlightIndex;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final hi = highlightIndex.clamp(0, 6);
    final maxHeight = compact ? 52.0 : 72.0;
    final minHeight = compact ? 14.0 : 18.0;

    return FocusSurface(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const FocusSectionLabel(label: 'Activity insight'),
          const SizedBox(height: 6),
          Text(
            'Weekly completion',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
              color: FocusUi.inkSoft,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: maxHeight,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: List.generate(7, (index) {
                final raw = index < heights.length ? heights[index] : 0.2;
                final barHeight = minHeight + raw * (maxHeight - minHeight);
                return _WeeklyBar(
                  height: barHeight,
                  highlighted: index == hi,
                  day: _weekdays[index],
                  showDayLabel: !compact,
                );
              }),
            ),
          ),
          if (compact) ...[
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: _weekdays
                  .map(
                    (day) => Text(
                      day,
                      style: const TextStyle(
                        fontSize: 10,
                        color: FocusUi.muted,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  )
                  .toList(),
            ),
          ],
        ],
      ),
    );
  }
}

class MomentumSummaryCard extends StatelessWidget {
  const MomentumSummaryCard({
    super.key,
    required this.streakDays,
    required this.completionRate,
    this.onViewFullReport,
    this.showAction = true,
  });

  final int streakDays;
  final double completionRate;
  final VoidCallback? onViewFullReport;
  final bool showAction;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(FocusUi.radius),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF0A2C88), Color(0xFF082F86)],
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x1A082F86),
            blurRadius: 20,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const FocusSectionLabel(
            label: 'Momentum',
            color: Color(0xFF8EA3E1),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _MomentumMetric(
                  value: '$streakDays day',
                  label: 'Current streak',
                ),
              ),
              Container(width: 1, height: 42, color: const Color(0x33FFFFFF)),
              Expanded(
                child: _MomentumMetric(
                  value: '${(completionRate * 100).round()}%',
                  label: 'Completion rate',
                ),
              ),
            ],
          ),
          if (showAction) ...[
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: onViewFullReport,
                style: FilledButton.styleFrom(
                  backgroundColor: FocusUi.accentMint,
                  foregroundColor: const Color(0xFF0D4D3B),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('View full report'),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class FocusDepthCard extends StatelessWidget {
  const FocusDepthCard({
    super.key,
    required this.durationLabel,
    required this.deltaPct,
  });

  final String durationLabel;
  final int deltaPct;

  @override
  Widget build(BuildContext context) {
    return FocusSurface(
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: const Color(0xFFE7EBF6),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.timelapse_rounded,
              size: 20,
              color: FocusUi.inkSoft,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Average focus depth',
                  style: TextStyle(fontSize: 12, color: FocusUi.muted),
                ),
                const SizedBox(height: 4),
                Text(
                  durationLabel,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 18,
                    color: FocusUi.inkSoft,
                  ),
                ),
                Text(
                  '+ $deltaPct% from last week',
                  style: const TextStyle(
                    fontSize: 11,
                    color: FocusUi.accent,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class MonthlyGoalCard extends StatelessWidget {
  const MonthlyGoalCard({
    super.key,
    required this.done,
    required this.total,
    required this.progress,
    required this.quote,
  });

  final int done;
  final int total;
  final double progress;
  final String quote;

  @override
  Widget build(BuildContext context) {
    return FocusSurface(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text(
                'Monthly goal',
                style: TextStyle(fontSize: 12, color: FocusUi.muted),
              ),
              const Spacer(),
              Text(
                '$done / $total tasks',
                style: const TextStyle(
                  fontSize: 12,
                  color: FocusUi.inkSoft,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(30),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 6,
              backgroundColor: const Color(0xFFE2E6EF),
              valueColor: const AlwaysStoppedAnimation<Color>(
                FocusUi.accentMint,
              ),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            '"$quote"',
            style: const TextStyle(fontSize: 12, color: FocusUi.muted),
          ),
        ],
      ),
    );
  }
}

class EfficiencyListCard extends StatelessWidget {
  const EfficiencyListCard({
    super.key,
    required this.rows,
    this.title = 'System efficiency',
  });

  final List<EfficiencyEntry> rows;
  final String title;

  @override
  Widget build(BuildContext context) {
    return FocusSurface(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: FocusUi.inkSoft,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (rows.isEmpty)
            const Text(
              'Complete a few systems to unlock efficiency insights.',
              style: TextStyle(fontSize: 12, color: FocusUi.muted),
            )
          else
            ...rows.map(
              (entry) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: EfficiencyRow(entry: entry),
              ),
            ),
        ],
      ),
    );
  }
}

class EfficiencyRow extends StatelessWidget {
  const EfficiencyRow({super.key, required this.entry});

  final EfficiencyEntry entry;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: const Color(0xFFE7EBF6),
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Icon(
            Icons.grid_view_rounded,
            size: 16,
            color: FocusUi.inkSoft,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                entry.title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF3D4760),
                ),
              ),
              Text(
                entry.subtitle,
                style: const TextStyle(fontSize: 11, color: FocusUi.muted),
              ),
            ],
          ),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              entry.score,
              style: const TextStyle(
                color: FocusUi.inkSoft,
                fontWeight: FontWeight.w700,
              ),
            ),
            Text(
              entry.status,
              style: const TextStyle(
                fontSize: 11,
                color: FocusUi.accent,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class StatsSnapshot extends StatelessWidget {
  const StatsSnapshot({super.key, required this.controller});

  final HomeController controller;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        WeeklyCompletionCard(
          heights: controller.weeklyHeights,
          highlightIndex: controller.weeklyHighlightIndex.value,
          compact: true,
        ),
        const SizedBox(height: 12),
        MomentumSummaryCard(
          streakDays: controller.statsStreakDays.value,
          completionRate: controller.statsCompletionRate.value,
          onViewFullReport: null,
          showAction: false,
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
  }
}

class _WeeklyBar extends StatelessWidget {
  const _WeeklyBar({
    required this.height,
    required this.highlighted,
    required this.day,
    required this.showDayLabel,
  });

  final double height;
  final bool highlighted;
  final String day;
  final bool showDayLabel;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Expanded(
            child: Align(
              alignment: Alignment.bottomCenter,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                margin: const EdgeInsets.symmetric(horizontal: 3),
                width: double.infinity,
                height: height,
                decoration: BoxDecoration(
                  color: highlighted ? FocusUi.navy : FocusUi.accentMint,
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          if (showDayLabel) ...[
            const SizedBox(height: 8),
            Text(
              day,
              style: TextStyle(
                fontSize: 10,
                color: highlighted ? FocusUi.inkSoft : FocusUi.muted,
                fontWeight: highlighted ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _MomentumMetric extends StatelessWidget {
  const _MomentumMetric({required this.value, required this.label});

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Column(
        children: [
          Text(
            value,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w700,
              fontSize: 22,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Color(0xFFB9C5EA), fontSize: 11),
          ),
        ],
      ),
    );
  }
}
