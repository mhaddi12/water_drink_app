import 'package:get/get.dart';
import 'package:water_drink_app/data/models/focus_system.dart';
import 'package:water_drink_app/data/models/hydration_intake.dart';
import 'package:water_drink_app/data/models/reminder_slot.dart';
import 'package:water_drink_app/data/models/routine_task.dart';
import 'package:water_drink_app/data/repositories/user_repository.dart';

class LocalProfileStore extends GetxService {
  final tasks = <RoutineTask>[].obs;
  final intakes = <HydrationIntake>[].obs;
  final systems = <FocusSystem>[].obs;
  final reminderSlots = <ReminderSlot>[].obs;

  final displayName = 'Hydra user'.obs;
  final hydrationGoalMl = 3000.obs;
  final reminderFrequencyHours = 2.obs;
  final theme = 'light'.obs;
  final activeHomeSystemId = RxnString();

  @override
  void onInit() {
    super.onInit();
    seedDefaults();
  }

  void seedDefaults() {
    if (tasks.isEmpty) {
      tasks.assignAll(UserRepository.defaultTasks());
    }
    if (reminderSlots.isEmpty) {
      reminderSlots.assignAll(
        UserRepository.defaultReminderSlots().map(ReminderSlot.fromMap).toList(),
      );
    }
    if (systems.isEmpty) {
      systems.assignAll(_defaultSystems());
    }
  }

  void reset() {
    tasks.clear();
    intakes.clear();
    systems.clear();
    reminderSlots.clear();
    displayName.value = 'Hydra user';
    hydrationGoalMl.value = 3000;
    reminderFrequencyHours.value = 2;
    theme.value = 'light';
    activeHomeSystemId.value = null;
    seedDefaults();
  }

  List<HydrationIntake> intakesSince(DateTime since) {
    return intakes
        .where((intake) => !intake.createdAt.isBefore(since))
        .toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  List<HydrationIntake> get todayIntakes {
    final now = DateTime.now();
    final start = DateTime(now.year, now.month, now.day);
    return intakesSince(start);
  }

  int get currentHydrationMl =>
      todayIntakes.fold(0, (sum, intake) => sum + intake.amountMl);

  void addIntake(int amountMl) {
    if (amountMl <= 0) return;
    intakes.insert(
      0,
      HydrationIntake(
        id: 'local_${DateTime.now().millisecondsSinceEpoch}',
        amountMl: amountMl,
        createdAt: DateTime.now(),
      ),
    );
  }

  void toggleTask(String taskId) {
    final index = tasks.indexWhere((task) => task.id == taskId);
    if (index < 0) return;
    tasks[index] = tasks[index].copyWith(done: !tasks[index].done);
    tasks.refresh();
  }

  void upsertTask(RoutineTask task) {
    final index = tasks.indexWhere((entry) => entry.id == task.id);
    if (index >= 0) {
      tasks[index] = task;
    } else {
      tasks.add(task);
    }
    tasks.refresh();
  }

  void removeTask(String taskId) {
    tasks.removeWhere((task) => task.id == taskId);
    tasks.refresh();
  }

  void setReminderEnabled(String time, bool enabled) {
    final index = reminderSlots.indexWhere((slot) => slot.time == time);
    if (index < 0) return;
    reminderSlots[index] = reminderSlots[index].copyWith(enabled: enabled);
    reminderSlots.refresh();
  }

  void addSystem(FocusSystem system) {
    systems.insert(0, system);
  }

  void setActiveHomeSystem(String? systemId) {
    activeHomeSystemId.value = systemId;
  }

  String nextReminderLabel() {
    final enabled = reminderSlots
        .where((slot) => slot.enabled)
        .map((slot) => slot.time)
        .where((time) => time.isNotEmpty)
        .toList();
    if (enabled.isEmpty) return 'No reminders enabled';
    return 'Next reminder ${enabled.first}';
  }

  static List<FocusSystem> _defaultSystems() {
    return const [
      FocusSystem(
        id: 'local_routine',
        name: 'Morning Routine',
        kind: 'routine',
        tag: 'ROUTINE',
        focusLine: 'Daily progress',
        frequency: 'Daily',
        targetMinutes: 45,
      ),
      FocusSystem(
        id: 'local_deep_work',
        name: 'Study System',
        kind: 'deep_work',
        tag: 'DEEP WORK',
        focusLine: 'Current session',
        frequency: 'Weekdays',
        targetMinutes: 60,
      ),
      FocusSystem(
        id: 'local_hydration',
        name: 'Hydration Rhythm',
        kind: 'habit',
        tag: 'CUSTOM SYSTEM',
        focusLine: 'Stay on pace',
        frequency: 'Daily',
      ),
      FocusSystem(
        id: 'local_review',
        name: 'Weekly Review',
        kind: 'habit',
        tag: 'CUSTOM SYSTEM',
        focusLine: 'Reflect and reset',
        frequency: 'Weekly',
        targetMinutes: 20,
      ),
    ];
  }
}
