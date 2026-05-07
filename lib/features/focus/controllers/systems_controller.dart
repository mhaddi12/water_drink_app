import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:water_drink_app/core/firebase/app_firebase.dart';
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

  void _bind() {
    if (!AppFirebase.isReady || !Get.isRegistered<AuthService>()) {
      tasks.assignAll(UserRepository.defaultTasks());
      return;
    }
    final auth = Get.find<AuthService>();
    _authSub?.cancel();
    _authSub = auth.authStateChanges().listen((user) async {
      final uid = user?.uid;
      if (uid == null) {
        _tasksSub?.cancel();
        tasks.clear();
        _lastPushedMorningProgress = null;
        _lastPushedRemaining = null;
        return;
      }
      if (Get.isRegistered<UserRepository>()) {
        await Get.find<UserRepository>().ensureSeed(uid);
      }
      _listenTasks(uid);
    });
  }

  void _listenTasks(String uid) {
    if (!Get.isRegistered<UserRepository>()) return;
    _tasksSub?.cancel();
    _lastPushedMorningProgress = null;
    _lastPushedRemaining = null;
    _tasksSub = Get.find<UserRepository>().watchTasks(uid).listen((list) {
      tasks.assignAll(list);
      if (AppFirebase.isReady) _pushMorningToUser(uid);
    });
  }

  Future<void> _pushMorningToUser(String uid) async {
    if (!Get.isRegistered<UserRepository>()) return;
    final p = morningProgress;
    final r = remainingCount;
    if (_lastPushedMorningProgress == p && _lastPushedRemaining == r) return;
    _lastPushedMorningProgress = p;
    _lastPushedRemaining = r;
    await Get.find<UserRepository>().syncMorningProgress(uid, p, r);
  }

  Future<void> toggleTask(String taskId) async {
    RoutineTask? t;
    for (final e in tasks) {
      if (e.id == taskId) t = e;
    }
    if (t == null) return;
    if (!AppFirebase.isReady || !Get.isRegistered<AuthService>()) {
      final i = tasks.indexWhere((e) => e.id == taskId);
      tasks[i] = tasks[i].copyWith(done: !tasks[i].done);
      tasks.refresh();
      return;
    }
    final uid = Get.find<AuthService>().currentUid;
    if (uid == null) return;
    await Get.find<UserRepository>().setTaskDone(uid, taskId, !t.done);
  }

  void openAddTask() {
    Get.to(() => const AddEditTaskScreen());
  }

  void openEditTask(RoutineTask task) {
    Get.to(() => AddEditTaskScreen(existing: task));
  }

  /// Offline / demo: update in-memory tasks when cloud is unavailable.
  Future<void> saveTaskOfflineFirst({
    required String title,
    required String subtitle,
    RoutineTask? existing,
  }) async {
    if (existing != null) {
      final i = tasks.indexWhere((e) => e.id == existing.id);
      if (i >= 0) {
        tasks[i] = tasks[i].copyWith(title: title, subtitle: subtitle);
        tasks.refresh();
      }
    } else {
      final order = tasks.isEmpty
          ? 0
          : tasks.map((e) => e.order).reduce((a, b) => a > b ? a : b) + 1;
      final id = 'local_${DateTime.now().millisecondsSinceEpoch}';
      tasks.add(
        RoutineTask(
          id: id,
          title: title,
          subtitle: subtitle,
          done: false,
          order: order,
        ),
      );
      tasks.refresh();
    }
    Get.snackbar('Hydra', 'Saved on device only (offline)');
  }

  void deleteTaskLocal(String taskId) {
    tasks.removeWhere((e) => e.id == taskId);
    tasks.refresh();
  }

  @override
  void onClose() {
    _authSub?.cancel();
    _tasksSub?.cancel();
    super.onClose();
  }
}
