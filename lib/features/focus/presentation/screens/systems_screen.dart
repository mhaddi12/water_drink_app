import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:water_drink_app/data/models/focus_system.dart';
import 'package:water_drink_app/features/focus/controllers/home_controller.dart';
import 'package:water_drink_app/features/focus/controllers/systems_controller.dart';
import 'package:water_drink_app/features/focus/presentation/widgets/focus_app_bar.dart';
import 'package:water_drink_app/features/focus/presentation/widgets/focus_ui.dart';

class SystemsScreen extends GetView<SystemsController> {
  const SystemsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          const FocusAppBar(),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
              child: Obx(() {
                controller.tasks;
                final home = Get.find<HomeController>();
                home.routineDurationMin.value;
                home.routineFrequency.value;
                home.userSystems;
                final pct = controller.morningProgress;
                final routine = _routineSystem(home);
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    FocusPageHeader(
                      title: routine?.name ?? 'Morning routine',
                      subtitle:
                          'Track duration, frequency, and the steps that anchor your day.',
                    ),
                    const SizedBox(height: 14),
                    FocusSurface(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                'Today\'s progress',
                                style: Theme.of(context).textTheme.titleSmall
                                    ?.copyWith(
                                      fontWeight: FontWeight.w700,
                                      color: FocusUi.inkSoft,
                                    ),
                              ),
                              const Spacer(),
                              Text(
                                '${(pct * 100).round()}%',
                                style: const TextStyle(
                                  color: FocusUi.accent,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(30),
                            child: LinearProgressIndicator(
                              value: pct.clamp(0.0, 1.0),
                              minHeight: 6,
                              backgroundColor: const Color(0xFFE2DFEA),
                              valueColor: const AlwaysStoppedAnimation<Color>(
                                FocusUi.accentMint,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: _MetricTile(
                            title: 'DURATION',
                            value: '${home.routineDurationMin.value} min',
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _MetricTile(
                            title: 'FREQUENCY',
                            value: home.routineFrequency.value,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _MetricTile(
                            title: 'STREAK',
                            value: controller.streakLabel,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    ...controller.tasks.map(
                      (t) => Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: _TaskTile(
                          title: t.title,
                          subtitle: t.subtitle,
                          done: t.done,
                          onTap: () => controller.toggleTask(t.id),
                          onEdit: () => controller.openEditTask(t),
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),
                    Center(
                      child: FilledButton(
                        onPressed: controller.openAddTask,
                        style: FilledButton.styleFrom(
                          backgroundColor: FocusUi.navy,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 18,
                            vertical: 12,
                          ),
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          visualDensity: VisualDensity.compact,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          textStyle: const TextStyle(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        child: const Text('+ Add Task'),
                      ),
                    ),
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

FocusSystem? _routineSystem(HomeController home) {
  for (final system in home.userSystems) {
    if (system.kind == 'routine') return system;
  }
  return null;
}

class _MetricTile extends StatelessWidget {
  const _MetricTile({required this.title, required this.value});

  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    return FocusSurface(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 8.5,
              color: Color(0xFFB3B6C1),
              fontWeight: FontWeight.w700,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 16 / 1.2,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _TaskTile extends StatelessWidget {
  const _TaskTile({
    required this.title,
    required this.subtitle,
    required this.done,
    required this.onTap,
    required this.onEdit,
  });

  final String title;
  final String subtitle;
  final bool done;
  final VoidCallback onTap;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    return FocusSurface(
      padding: EdgeInsets.zero,
      child: Row(
          children: [
            Expanded(
              child: InkWell(
                onTap: onTap,
                borderRadius: BorderRadius.circular(10),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 18,
                        height: 18,
                        decoration: BoxDecoration(
                          color: done
                              ? const Color(0xFFA1E5CB)
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(5),
                          border: Border.all(
                            color: done
                                ? const Color(0xFF4FB78C)
                                : const Color(0xFFCAD0DD),
                          ),
                        ),
                        child: done
                            ? const Icon(
                                Icons.check,
                                size: 12,
                                color: Color(0xFF1B5E3C),
                              )
                            : null,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              title,
                              style: const TextStyle(
                                fontSize: 16 / 1.2,
                                color: Color(0xFF3F485F),
                              ),
                            ),
                            Text(
                              subtitle,
                              style: const TextStyle(
                                fontSize: 9,
                                color: Color(0xFFA3A8B8),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            IconButton(
              onPressed: onEdit,
              icon: const Icon(Icons.edit_outlined, size: 18),
              color: FocusUi.inkSoft,
              tooltip: 'Edit',
              splashRadius: 20,
            ),
          ],
        ),
    );
  }
}
