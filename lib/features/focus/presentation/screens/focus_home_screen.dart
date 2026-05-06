import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:water_drink_app/features/focus/controllers/home_controller.dart';
import 'package:water_drink_app/features/focus/presentation/widgets/focus_app_bar.dart';

class FocusHomeScreen extends StatelessWidget {
  const FocusHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(HomeController(), permanent: true);
    return SafeArea(
      child: Column(
        children: [
          const FocusAppBar(),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 4),
                  Text(
                    'Build your system.',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF143064),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Manage your focus with intentionality',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: const Color(0xFF7A8299),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Obx(
                    () => _SystemCard(
                      title: 'Morning Routine',
                      tag: 'ACTIVE SYSTEM',
                      subtitle: 'Daily Progress',
                      valueText: controller.activeProgressText,
                      progress: controller.activeProgress.value,
                      footerLeft: '2',
                      footerText: '3 steps remaining',
                      accentColor: const Color(0xFF2B7E5F),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Obx(
                    () => _SystemCard(
                      title: 'Study System',
                      tag: 'DEEP WORK',
                      subtitle: 'Current Session',
                      valueText: controller.sessionRemainingText,
                      progress: controller.currentSessionProgress.value,
                      footerLeft: 'Phase: Research & Analysis',
                      footerText: 'Resume',
                      accentColor: const Color(0xFF234EB8),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Obx(
                    () => Row(
                      children: [
                        Expanded(
                          child: _StatCard(
                            icon: Icons.bolt_rounded,
                            value: '${controller.streakDays.value}d',
                            label: 'STREAK',
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _StatCard(
                            icon: Icons.timelapse_rounded,
                            value: '${controller.focusHours.value}h',
                            label: 'FOCUS',
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 22),
                  Center(
                    child: FilledButton(
                      onPressed: () {},
                      style: FilledButton.styleFrom(
                        backgroundColor: const Color(0xFF0A2C88),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 18,
                          vertical: 12,
                        ),
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        visualDensity: VisualDensity.compact,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        textStyle: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                      child: const Text('+ Create New System'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SystemCard extends StatelessWidget {
  const _SystemCard({
    required this.title,
    required this.tag,
    required this.subtitle,
    required this.valueText,
    required this.progress,
    required this.footerLeft,
    required this.footerText,
    required this.accentColor,
  });

  final String title;
  final String tag;
  final String subtitle;
  final String valueText;
  final double progress;
  final String footerLeft;
  final String footerText;
  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            tag,
            style: TextStyle(
              color: accentColor,
              fontSize: 10,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.6,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            title,
            style: const TextStyle(
              fontSize: 24 / 1.6,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Text(
                subtitle,
                style: const TextStyle(fontSize: 11, color: Color(0xFF687187)),
              ),
              const Spacer(),
              Text(
                valueText,
                style: const TextStyle(fontSize: 11, color: Color(0xFF4B5570)),
              ),
            ],
          ),
          const SizedBox(height: 4),
          LinearProgressIndicator(
            value: progress,
            minHeight: 4,
            borderRadius: BorderRadius.circular(99),
            backgroundColor: const Color(0xFFE4E8F2),
            valueColor: AlwaysStoppedAnimation<Color>(accentColor),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Text(
                footerLeft,
                style: const TextStyle(fontSize: 10, color: Color(0xFF8A92A8)),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  footerText,
                  style: TextStyle(
                    fontSize: 10,
                    color: footerText == 'Resume'
                        ? const Color(0xFF0F398F)
                        : const Color(0xFF8A92A8),
                    fontWeight: footerText == 'Resume'
                        ? FontWeight.w700
                        : FontWeight.w500,
                  ),
                  textAlign: footerText == 'Resume'
                      ? TextAlign.right
                      : TextAlign.left,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.icon,
    required this.value,
    required this.label,
  });

  final IconData icon;
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 76,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.75),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: const Color(0xFF0F398F), size: 16),
          const SizedBox(height: 2),
          Text(
            value,
            style: const TextStyle(
              fontSize: 18 / 1.3,
              fontWeight: FontWeight.w700,
            ),
          ),
          Text(
            label,
            style: const TextStyle(
              fontSize: 9,
              color: Color(0xFF8A92A8),
              letterSpacing: 0.7,
            ),
          ),
        ],
      ),
    );
  }
}
