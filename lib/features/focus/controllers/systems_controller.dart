import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:water_drink_app/core/session/app_session.dart';
import 'package:water_drink_app/core/stats/system_stats_helper.dart';
import 'package:water_drink_app/core/session/local_profile_store.dart';
import 'package:water_drink_app/data/models/focus_system.dart';
import 'package:water_drink_app/data/models/routine_task.dart';
import 'package:water_drink_app/data/repositories/user_repository.dart';
import 'package:water_drink_app/data/services/auth_service.dart';
import 'package:water_drink_app/features/focus/controllers/home_controller.dart';
import 'package:water_drink_app/features/focus/presentation/screens/add_edit_task_screen.dart';

class SystemsController extends GetxController {
  final tasks = <RoutineTask>[].obs;
  final selectedSystemId = RxnString();

  StreamSubscription<List<RoutineTask>>? _tasksSub;
  StreamSubscription<User?>? _authSub;
  String? _lastPushedStatsKey;

  LocalProfileStore get _local => Get.find<LocalProfileStore>();

  List<FocusSystem> get availableSystems {
    if (Get.isRegistered<HomeController>()) {
      final remote = Get.find<HomeController>().userSystems;
      if (remote.isNotEmpty) return remote;
    }
    return _local.systems;
  }

  FocusSystem? get selectedSystem {
    final id = selectedSystemId.value;
    if (id == null) return null;
    for (final system in availableSystems) {
      if (system.id == id) return system;
    }
    return null;
  }

  List<RoutineTask> tasksForSystem(String? systemId) {
    if (systemId == null) return const [];
    return tasks
        .where((task) => _taskMatchesSystem(task, systemId))
        .toList()
      ..sort((a, b) => a.order.compareTo(b.order));
  }

  List<RoutineTask> get selectedTasks => tasksForSystem(selectedSystemId.value);

  int doneCountFor(String? systemId) =>
      tasksForSystem(systemId).where((task) => task.done).length;

  int remainingCountFor(String? systemId) =>
      tasksForSystem(systemId).where((task) => !task.done).length;

  double progressForSystem(String? systemId) {
    final scoped = tasksForSystem(systemId);
    if (scoped.isEmpty) return 0.0;
    return doneCountFor(systemId) / scoped.length;
  }

  String progressTextFor(String? systemId) =>
      '${(progressForSystem(systemId) * 100).round()}%';

  int get doneCount => doneCountFor(selectedSystemId.value);
  int get remainingCount => remainingCountFor(selectedSystemId.value);
  double get morningProgress => progressForSystem(selectedSystemId.value);
  String get morningPercentText => progressTextFor(selectedSystemId.value);

  String get streakLabel {
    if (!Get.isRegistered<HomeController>()) return '0 Days';
    return '${Get.find<HomeController>().streakDays.value} Days';
  }

  @override
  void onInit() {
    super.onInit();
    _bind();
    if (Get.isRegistered<HomeController>()) {
      ever(Get.find<HomeController>().userSystems, (_) => _ensureSelectedSystem());
    }
    ever(_local.systems, (_) => _ensureSelectedSystem());
  }

  void applyLocalDefaults() {
    tasks.assignAll(_local.tasks);
    _ensureSelectedSystem();
  }

  void selectSystem(String systemId) {
    selectedSystemId.value = systemId;
  }

  void _ensureSelectedSystem() {
    final systems = availableSystems;
    if (systems.isEmpty) {
      selectedSystemId.value = null;
      return;
    }

    final current = selectedSystemId.value;
    if (current != null && systems.any((system) => system.id == current)) {
      return;
    }

    final routine = _firstRoutineSystem(systems);
    selectedSystemId.value = routine?.id ?? systems.first.id;
  }

  void _bind() {
    if (!AppSession.hasCloud) {
      applyLocalDefaults();
      scheduleMicrotask(() => _onTasksChanged(null));
      return;
    }

    final auth = Get.find<AuthService>();
    _authSub?.cancel();
    _authSub = auth.authStateChanges().listen((user) async {
      final uid = user?.uid;
      if (uid == null) {
        _tasksSub?.cancel();
        applyLocalDefaults();
        _lastPushedStatsKey = null;
        return;
      }
      final seeded = await AppSession.ensureUserSeed();
      if (!seeded) {
        applyLocalDefaults();
        return;
      }
      _listenTasks(uid);
    });
  }

  void _listenTasks(String uid) {
    if (!Get.isRegistered<UserRepository>()) return;
    _tasksSub?.cancel();
    _lastPushedStatsKey = null;
    _tasksSub = Get.find<UserRepository>().watchTasks(uid).listen(
      (list) {
        tasks.assignAll(list);
        _ensureSelectedSystem();
        _onTasksChanged(uid);
      },
      onError: (_) => applyLocalDefaults(),
    );
  }

  void _onTasksChanged(String? uid) {
    if (Get.isRegistered<HomeController>()) {
      Get.find<HomeController>().refreshDerivedStats();
    }
    if (uid != null && AppSession.canSync) {
      unawaited(_pushDerivedStatsToUser(uid));
    }
  }

  SystemStatsSnapshot _statsSnapshot() {
    final home = Get.isRegistered<HomeController>()
        ? Get.find<HomeController>()
        : null;
    final systems = home != null && home.userSystems.isNotEmpty
        ? home.userSystems
        : availableSystems;
    final activeId = home?.activeHomeSystemId.value ?? _local.activeHomeSystemId.value;
    return SystemStatsHelper.compute(
      systems: systems,
      tasks: tasks,
      activeSystemId: activeId,
    );
  }

  Future<void> _pushDerivedStatsToUser(String uid) async {
    if (!Get.isRegistered<UserRepository>()) return;
    final snap = _statsSnapshot();
    final key =
        '${snap.completionRate}_${snap.monthlyDone}_${snap.monthlyTotal}_${snap.activeProgress}_${snap.activeRemaining}_${snap.efficiency.map((row) => row.score).join('|')}';
    if (_lastPushedStatsKey == key) return;
    _lastPushedStatsKey = key;
    try {
      await Get.find<UserRepository>().syncDerivedStats(uid, snap);
    } catch (_) {}
  }

  Future<void> toggleTask(String taskId) async {
    RoutineTask? task;
    for (final entry in tasks) {
      if (entry.id == taskId) task = entry;
    }
    if (task == null) return;

    if (!AppSession.canSync) {
      _local.toggleTask(taskId);
      applyLocalDefaults();
      return;
    }

    try {
      await Get.find<UserRepository>().setTaskDone(
        AppSession.uid!,
        taskId,
        !task.done,
      );
    } catch (_) {
      _local.toggleTask(taskId);
      applyLocalDefaults();
      Get.snackbar('Hydra', 'Saved on this device only');
    }
  }

  void openAddTask() {
    _ensureSelectedSystem();
    final systemId = selectedSystemId.value;
    if (systemId == null) {
      Get.snackbar('Hydra', 'Create a system first.');
      return;
    }
    Get.to(() => AddEditTaskScreen(systemId: systemId));
  }

  void openEditTask(RoutineTask task) {
    final systemId = task.systemId ?? selectedSystemId.value;
    if (systemId == null) {
      Get.snackbar('Hydra', 'Choose a system first.');
      return;
    }
    Get.to(() => AddEditTaskScreen(systemId: systemId, existing: task));
  }

  bool _taskMatchesSystem(RoutineTask task, String systemId) {
    if (task.systemId != null) return task.systemId == systemId;

    final routine = _firstRoutineSystem(availableSystems);
    return routine?.id == systemId;
  }

  FocusSystem? _firstRoutineSystem(List<FocusSystem> systems) {
    for (final system in systems) {
      if (system.kind == 'routine') return system;
    }
    return null;
  }

  @override
  void onClose() {
    _authSub?.cancel();
    _tasksSub?.cancel();
    super.onClose();
  }
}
