import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:water_drink_app/core/session/app_session.dart';
import 'package:water_drink_app/core/session/local_profile_store.dart';
import 'package:water_drink_app/data/models/routine_task.dart';
import 'package:water_drink_app/data/repositories/user_repository.dart';
import 'package:water_drink_app/data/services/auth_service.dart';
import 'package:water_drink_app/features/focus/controllers/home_controller.dart';
import 'package:water_drink_app/features/focus/presentation/screens/add_edit_task_screen.dart';

class SystemsController extends GetxController {
  final tasks = <RoutineTask>[].obs;
  StreamSubscription<List<RoutineTask>>? _tasksSub;
  StreamSubscription<User?>? _authSub;
  double? _lastPushedMorningProgress;
  int? _lastPushedRemaining;

  LocalProfileStore get _local => Get.find<LocalProfileStore>();

  int get doneCount => tasks.where((t) => t.done).length;
  int get remainingCount => tasks.where((t) => !t.done).length;
  double get morningProgress => tasks.isEmpty ? 0.0 : doneCount / tasks.length;

  String get morningPercentText => '${(morningProgress * 100).round()}%';

  String get streakLabel {
    if (!Get.isRegistered<HomeController>()) return '0 Days';
    return '${Get.find<HomeController>().streakDays.value} Days';
  }

  @override
  void onInit() {
    super.onInit();
    _bind();
  }

  void applyLocalDefaults() {
    tasks.assignAll(_local.tasks);
  }

  void _bind() {
    if (!AppSession.hasCloud) {
      applyLocalDefaults();
      return;
    }

    final auth = Get.find<AuthService>();
    _authSub?.cancel();
    _authSub = auth.authStateChanges().listen((user) async {
      final uid = user?.uid;
      if (uid == null) {
        _tasksSub?.cancel();
        applyLocalDefaults();
        _lastPushedMorningProgress = null;
        _lastPushedRemaining = null;
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
    _lastPushedMorningProgress = null;
    _lastPushedRemaining = null;
    _tasksSub = Get.find<UserRepository>().watchTasks(uid).listen(
      (list) {
        tasks.assignAll(list);
        if (AppSession.canSync) {
          _pushMorningToUser(uid);
        }
      },
      onError: (_) => applyLocalDefaults(),
    );
  }

  Future<void> _pushMorningToUser(String uid) async {
    if (!Get.isRegistered<UserRepository>()) return;
    final p = morningProgress;
    final r = remainingCount;
    if (_lastPushedMorningProgress == p && _lastPushedRemaining == r) return;
    _lastPushedMorningProgress = p;
    _lastPushedRemaining = r;
    try {
      await Get.find<UserRepository>().syncMorningProgress(uid, p, r);
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
    Get.to(() => const AddEditTaskScreen());
  }

  void openEditTask(RoutineTask task) {
    Get.to(() => AddEditTaskScreen(existing: task));
  }

  @override
  void onClose() {
    _authSub?.cancel();
    _tasksSub?.cancel();
    super.onClose();
  }
}
