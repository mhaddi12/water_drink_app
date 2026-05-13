import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:water_drink_app/data/models/focus_system.dart';
import 'package:water_drink_app/features/focus/controllers/focus_nav_controller.dart';
import 'package:water_drink_app/features/focus/controllers/home_controller.dart';
import 'package:water_drink_app/features/focus/controllers/systems_controller.dart';
import 'package:water_drink_app/features/focus/presentation/screens/create_system_screen.dart';
import 'package:water_drink_app/features/focus/presentation/widgets/focus_app_bar.dart';
import 'package:water_drink_app/features/focus/presentation/widgets/focus_ui.dart';

class FocusHomeScreen extends StatelessWidget {
  const FocusHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<HomeController>();
    final systems = Get.find<SystemsController>();
    return SafeArea(
      child: Column(
        children: [
          const FocusAppBar(),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const FocusPageHeader(
                    title: 'Build your system',
                    subtitle: 'Manage your focus with intentionality.',
                  ),
                  const SizedBox(height: 16),
                  Obx(() {
                    controller.userSystems;
                    systems.tasks;
                    final routine = _systemOfKind(controller, 'routine');
                    return _SystemCard(
                      title: routine?.name ?? 'Morning Routine',
                      tag: routine?.tag ?? 'ACTIVE SYSTEM',
                      subtitle: routine?.focusLine ?? 'Daily progress',
                      valueText: systems.morningPercentText,
                      progress: systems.morningProgress,
                      footerLeft: '${systems.remainingCount}',
                      footerText: '${systems.remainingCount} steps remaining',
                      accentColor: const Color(0xFF2B7E5F),
                    );
                  }),
                  const SizedBox(height: 12),
                  Obx(
                    () {
                      final deepWork = _systemOfKind(controller, 'deep_work');
                      return _SystemCard(
                        title: deepWork?.name ?? 'Study System',
                        tag: deepWork?.tag ?? 'DEEP WORK',
                        subtitle: deepWork?.focusLine ?? 'Current session',
                        valueText: controller.sessionRemainingText,
                        progress: controller.currentSessionProgress.value,
                        footerLeft: controller.phaseLabel.value,
                        footerText: 'Open focus',
                        accentColor: const Color(0xFF234EB8),
                        onResume: Get.isRegistered<FocusNavController>()
                            ? () => Get.find<FocusNavController>().setTab(2)
                            : null,
                      );
                    },
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
                  Obx(() {
                    if (controller.userSystems.isEmpty) {
                      return const SizedBox.shrink();
                    }
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 14),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Your systems',
                            style: Theme.of(context).textTheme.titleSmall
                                ?.copyWith(
                                  fontWeight: FontWeight.w700,
                                  color: FocusUi.ink,
                                ),
                          ),
                          const SizedBox(height: 8),
                          ...controller.userSystems
                              .take(6)
                              .map(
                                (s) => Padding(
                                  padding: const EdgeInsets.only(bottom: 8),
                                  child: FocusSurface(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 14,
                                      vertical: 12,
                                    ),
                                    child: Row(
                                      children: [
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                s.tag,
                                                style: const TextStyle(
                                                  fontSize: 9,
                                                  fontWeight: FontWeight.w700,
                                                  color: Color(0xFF4A987E),
                                                  letterSpacing: 0.4,
                                                ),
                                              ),
                                              Text(
                                                s.name,
                                                style: const TextStyle(
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w600,
                                                  color: Color(0xFF2C3550),
                                                ),
                                              ),
                                              Text(
                                                '${s.focusLine} · ${s.frequency}',
                                                style: const TextStyle(
                                                  fontSize: 10,
                                                  color: Color(0xFF8A92A8),
                                                ),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                        ],
                      ),
                    );
                  }),
                  Center(
                    child: FilledButton(
                      onPressed: () => Get.to(() => const CreateSystemScreen()),
                      style: FilledButton.styleFrom(
                        backgroundColor: FocusUi.navy,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 12,
                        ),
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        visualDensity: VisualDensity.compact,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
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

FocusSystem? _systemOfKind(HomeController controller, String kind) {
  for (final system in controller.userSystems) {
    if (system.kind == kind) return system;
  }
  return null;
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
    this.onResume,
  });

  final String title;
  final String tag;
  final String subtitle;
  final String valueText;
  final double progress;
  final String footerLeft;
  final String footerText;
  final Color accentColor;
  final VoidCallback? onResume;

  @override
  Widget build(BuildContext context) {
    return FocusSurface(
      padding: const EdgeInsets.all(16),
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
                child: onResume != null && footerText == 'Open focus'
                    ? Align(
                        alignment: Alignment.centerRight,
                        child: InkWell(
                          onTap: onResume,
                          borderRadius: BorderRadius.circular(4),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 4,
                              vertical: 2,
                            ),
                            child: Text(
                              footerText,
                              style: const TextStyle(
                                fontSize: 10,
                                color: Color(0xFF0F398F),
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),
                      )
                    : Text(
                        footerText,
                        style: TextStyle(
                          fontSize: 10,
                          color: footerText == 'Open focus'
                              ? const Color(0xFF0F398F)
                              : const Color(0xFF8A92A8),
                          fontWeight: footerText == 'Open focus'
                              ? FontWeight.w700
                              : FontWeight.w500,
                        ),
                        textAlign: footerText == 'Open focus'
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
    return FocusSurface(
      padding: const EdgeInsets.symmetric(vertical: 14),
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
