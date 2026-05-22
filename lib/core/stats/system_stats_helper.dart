import 'package:water_drink_app/data/models/focus_system.dart';
import 'package:water_drink_app/data/models/routine_task.dart' show EfficiencyEntry, RoutineTask;

class SystemStatsSnapshot {
  const SystemStatsSnapshot({
    required this.completionRate,
    required this.monthlyDone,
    required this.monthlyTotal,
    required this.efficiency,
    required this.activeProgress,
    required this.activeRemaining,
  });

  final double completionRate;
  final int monthlyDone;
  final int monthlyTotal;
  final List<EfficiencyEntry> efficiency;
  final double activeProgress;
  final int activeRemaining;
}

abstract final class SystemStatsHelper {
  static SystemStatsSnapshot compute({
    required List<FocusSystem> systems,
    required List<RoutineTask> tasks,
    String? activeSystemId,
  }) {
    final efficiency = <EfficiencyEntry>[];
    var systemsWithTasks = 0;
    var progressSum = 0.0;

    for (final system in systems) {
      final scoped = _tasksForSystem(tasks, system.id, systems);
      final progress = _progressFor(scoped);
      if (scoped.isNotEmpty) {
        systemsWithTasks++;
        progressSum += progress;
      }
      efficiency.add(
        EfficiencyEntry(
          title: system.name,
          subtitle: system.focusLine.isNotEmpty
              ? system.focusLine
              : system.frequency,
          score: '${(progress * 100).round()}%',
          status: _statusFor(progress, scoped.isEmpty),
        ),
      );
    }

    final done = tasks.where((task) => task.done).length;
    final total = tasks.length;
    final completionRate = total == 0
        ? 0.0
        : done / total;
    final aggregateFromSystems = systemsWithTasks == 0
        ? completionRate
        : progressSum / systemsWithTasks;

    final activeId = _resolveActiveId(systems, activeSystemId);
    final activeScoped = _tasksForSystem(tasks, activeId, systems);

    return SystemStatsSnapshot(
      completionRate: aggregateFromSystems,
      monthlyDone: done,
      monthlyTotal: total == 0 ? 30 : total,
      efficiency: efficiency,
      activeProgress: _progressFor(activeScoped),
      activeRemaining: activeScoped.where((task) => !task.done).length,
    );
  }

  static String? _resolveActiveId(
    List<FocusSystem> systems,
    String? activeSystemId,
  ) {
    if (activeSystemId != null &&
        systems.any((system) => system.id == activeSystemId)) {
      return activeSystemId;
    }
    for (final system in systems) {
      if (system.kind == 'routine') return system.id;
    }
    return systems.isEmpty ? null : systems.first.id;
  }

  static List<RoutineTask> _tasksForSystem(
    List<RoutineTask> tasks,
    String? systemId,
    List<FocusSystem> systems,
  ) {
    if (systemId == null) return const [];
    return tasks.where((task) {
      if (task.systemId != null) return task.systemId == systemId;
      final routine = _resolveActiveId(systems, null);
      return routine == systemId;
    }).toList()
      ..sort((a, b) => a.order.compareTo(b.order));
  }

  static double _progressFor(List<RoutineTask> scoped) {
    if (scoped.isEmpty) return 0.0;
    final done = scoped.where((task) => task.done).length;
    return done / scoped.length;
  }

  static String _statusFor(double progress, bool noTasks) {
    if (noTasks) return 'Add tasks';
    if (progress >= 1.0) return 'Complete';
    if (progress >= 0.5) return 'On track';
    if (progress > 0) return 'In progress';
    return 'Not started';
  }
}
