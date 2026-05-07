import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:water_drink_app/core/firebase/app_firebase.dart';
import 'package:water_drink_app/data/repositories/user_repository.dart';
import 'package:water_drink_app/data/services/auth_service.dart';
import 'package:water_drink_app/features/focus/controllers/home_controller.dart';
import 'package:water_drink_app/features/focus/presentation/widgets/focus_app_bar.dart';

class StatsScreen extends StatelessWidget {
  const StatsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final h = Get.find<HomeController>();
    return SafeArea(
      child: Column(
        children: [
          const FocusAppBar(),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(14, 12, 14, 18),
              child: Obx(() {
                h.weeklyHeights;
                h.weeklyHighlightIndex.value;
                h.statsStreakDays.value;
                h.statsCompletionRate.value;
                h.statsFocusDepthSeconds.value;
                h.statsFocusDepthDeltaPct.value;
                h.statsMonthlyDone.value;
                h.statsMonthlyTotal.value;
                h.statsQuote.value;
                h.efficiencyRows;
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Your Progress',
                      style: TextStyle(
                        color: Color(0xFF163E90),
                        fontWeight: FontWeight.w700,
                        fontSize: 34 / 1.8,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Review your consistency and refine your\nmental clarity.',
                      style: TextStyle(color: Color(0xFF7E869D), fontSize: 12),
                    ),
                    const SizedBox(height: 14),
                    _WeeklyCompletionCard(h: h),
                    const SizedBox(height: 10),
                    _MomentumCard(h: h),
                    const SizedBox(height: 10),
                    _SmallInsightCard(h: h),
                    const SizedBox(height: 10),
                    _GoalCard(h: h),
                    const SizedBox(height: 10),
                    _EfficiencyCard(h: h),
                    const SizedBox(height: 12),
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

class _WeeklyCompletionCard extends StatelessWidget {
  const _WeeklyCompletionCard({required this.h});

  final HomeController h;

  @override
  Widget build(BuildContext context) {
    final heights = h.weeklyHeights;
    final hi = h.weeklyHighlightIndex.value.clamp(0, 6);
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE8EAF2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'ACTIVITY INSIGHT',
            style: TextStyle(
              color: Color(0xFF4A987E),
              fontWeight: FontWeight.w700,
              fontSize: 9,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Weekly Completion',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 23 / 1.4,
              color: Color(0xFF163E90),
            ),
          ),
          const SizedBox(height: 10),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: List.generate(7, (i) {
              final raw = i < heights.length ? heights[i] : 0.2;
              final px = 12.0 + raw * 40;
              return _Bar(height: px, highlighted: i == hi);
            }),
          ),
          const SizedBox(height: 6),
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Mon', style: _dayStyle),
              Text('Tue', style: _dayStyle),
              Text('Wed', style: _dayStyle),
              Text('Thu', style: _dayStyle),
              Text('Fri', style: _dayStyle),
              Text('Sat', style: _dayStyle),
              Text('Sun', style: _dayStyle),
            ],
          ),
        ],
      ),
    );
  }
}

class _MomentumCard extends StatelessWidget {
  const _MomentumCard({required this.h});

  final HomeController h;

  @override
  Widget build(BuildContext context) {
    final streak = h.statsStreakDays.value;
    final rate = h.statsCompletionRate.value;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF082F86),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'MOMENTUM',
            style: TextStyle(
              color: Color(0xFF8EA3E1),
              fontWeight: FontWeight.w700,
              fontSize: 9,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '$streak Day',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w700,
              fontSize: 36 / 1.6,
            ),
          ),
          const Text(
            'Current Streak',
            style: TextStyle(color: Color(0xFFB9C5EA), fontSize: 11),
          ),
          const SizedBox(height: 10),
          Text(
            '${(rate * 100).round()}%',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w700,
              fontSize: 36 / 1.6,
            ),
          ),
          const Text(
            'Completion Rate',
            style: TextStyle(color: Color(0xFFB9C5EA), fontSize: 11),
          ),
          const SizedBox(height: 12),
          Center(
            child: FilledButton(
              onPressed: _onViewFullReport,
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFF93E6C4),
                foregroundColor: const Color(0xFF0D4D3B),
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 10,
                ),
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                visualDensity: VisualDensity.compact,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
              child: const Text('View Full Report'),
            ),
          ),
        ],
      ),
    );
  }
}

class _SmallInsightCard extends StatelessWidget {
  const _SmallInsightCard({required this.h});

  final HomeController h;

  @override
  Widget build(BuildContext context) {
    final delta = h.statsFocusDepthDeltaPct.value;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE8EAF2)),
      ),
      child: Row(
        children: [
          const CircleAvatar(
            radius: 15,
            backgroundColor: Color(0xFFE7EBF6),
            child: Icon(
              Icons.timelapse_rounded,
              size: 15,
              color: Color(0xFF0E3A8F),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Average Focus Depth',
                  style: TextStyle(fontSize: 10, color: Color(0xFF8990A5)),
                ),
                const SizedBox(height: 1),
                Text(
                  h.focusDepthFormatted,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF163E90),
                  ),
                ),
                Text(
                  '+ $delta% from last week',
                  style: const TextStyle(
                    fontSize: 9.5,
                    color: Color(0xFF5D9F87),
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

class _GoalCard extends StatelessWidget {
  const _GoalCard({required this.h});

  final HomeController h;

  @override
  Widget build(BuildContext context) {
    final done = h.statsMonthlyDone.value;
    final total = h.statsMonthlyTotal.value;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE8EAF2)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              const Text(
                'Monthly Goal',
                style: TextStyle(fontSize: 10, color: Color(0xFF8D95AA)),
              ),
              const Spacer(),
              Text(
                '$done / $total Tasks',
                style: const TextStyle(
                  fontSize: 10,
                  color: Color(0xFF1D3D8F),
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(30),
            child: LinearProgressIndicator(
              value: h.monthlyGoalProgress,
              minHeight: 4,
              backgroundColor: const Color(0xFFE2E6EF),
              valueColor: const AlwaysStoppedAnimation<Color>(
                Color(0xFF98E7C9),
              ),
            ),
          ),
          const SizedBox(height: 6),
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              '"${h.statsQuote.value}"',
              style: const TextStyle(fontSize: 9.5, color: Color(0xFF8A92A8)),
            ),
          ),
        ],
      ),
    );
  }
}

class _EfficiencyCard extends StatelessWidget {
  const _EfficiencyCard({required this.h});

  final HomeController h;

  @override
  Widget build(BuildContext context) {
    final rows = h.efficiencyRows;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE8EAF2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Text(
                'System Efficiency',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF163E90),
                ),
              ),
              Spacer(),
              Icon(Icons.more_horiz, size: 16, color: Color(0xFF8A92A8)),
            ],
          ),
          const SizedBox(height: 8),
          ...rows.map(
            (e) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: _EfficiencyRow(
                title: e.title,
                subtitle: e.subtitle,
                score: e.score,
                status: e.status,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _EfficiencyRow extends StatelessWidget {
  const _EfficiencyRow({
    required this.title,
    required this.subtitle,
    required this.score,
    required this.status,
  });

  final String title;
  final String subtitle;
  final String score;
  final String status;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 18,
          height: 18,
          decoration: BoxDecoration(
            color: const Color(0xFFE7EBF6),
            borderRadius: BorderRadius.circular(4),
          ),
          child: const Icon(
            Icons.grid_view_rounded,
            size: 10,
            color: Color(0xFF174092),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(fontSize: 12, color: Color(0xFF3D4760)),
              ),
              Text(
                subtitle,
                style: const TextStyle(fontSize: 9.5, color: Color(0xFF8B92A7)),
              ),
            ],
          ),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              score,
              style: const TextStyle(
                color: Color(0xFF163E90),
                fontWeight: FontWeight.w700,
              ),
            ),
            Text(
              status,
              style: const TextStyle(
                fontSize: 9.5,
                color: Color(0xFF7CA190),
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _Bar extends StatelessWidget {
  const _Bar({required this.height, this.highlighted = false});

  final double height;
  final bool highlighted;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Align(
        alignment: Alignment.bottomCenter,
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 1.5),
          height: height,
          decoration: BoxDecoration(
            color: highlighted
                ? const Color(0xFF0B3289)
                : const Color(0xFF95E6C7),
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }
}

const _dayStyle = TextStyle(fontSize: 9, color: Color(0xFF9AA1B5));

Future<void> _onViewFullReport() async {
  if (!AppFirebase.isReady ||
      !Get.isRegistered<AuthService>() ||
      !Get.isRegistered<UserRepository>()) {
    Get.snackbar('Hydra', 'Connect Firebase to sync report views');
    return;
  }
  final uid = Get.find<AuthService>().currentUid;
  if (uid == null) {
    Get.snackbar('Hydra', 'Signing in… try again in a moment');
    return;
  }
  await Get.find<UserRepository>().recordStatsReportOpened(uid);
  Get.snackbar('Hydra', 'Report view saved to your profile');
}
