import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:water_drink_app/core/session/app_session.dart';
import 'package:water_drink_app/core/stats/system_stats_helper.dart';
import 'package:water_drink_app/core/session/local_profile_store.dart';
import 'package:water_drink_app/data/models/focus_system.dart';
import 'package:water_drink_app/data/models/routine_task.dart';
import 'package:water_drink_app/features/focus/controllers/systems_controller.dart';
import 'package:water_drink_app/data/repositories/user_repository.dart';
import 'package:water_drink_app/data/services/auth_service.dart';

class HomeController extends GetxController {
  final activeProgress = 0.0.obs;
  final currentSessionProgress = 0.0.obs;
  final streakDays = 0.obs;
  final focusHours = 0.0.obs;
  final morningStepsRemaining = 0.obs;
  final phaseLabel = 'Get started'.obs;

  final statsStreakDays = 0.obs;
  final statsCompletionRate = 0.0.obs;
  final statsFocusDepthSeconds = 0.obs;
  final statsFocusDepthDeltaPct = 0.obs;
  final statsMonthlyDone = 0.obs;
  final statsMonthlyTotal = 0.obs;
  final statsQuote = 'Start tracking to see insights here.'.obs;
  final statsReportScope = 'week'.obs;
  final weeklyHeights = List<double>.filled(7, 0.0).obs;
  final weeklyHighlightIndex = 0.obs;
  final efficiencyRows = <EfficiencyEntry>[].obs;

  final routineDurationMin = 0.obs;
  final routineFrequency = 'Daily'.obs;

  final userSystems = <FocusSystem>[].obs;
  final activeHomeSystemId = RxnString();

  StreamSubscription<DocumentSnapshot<Map<String, dynamic>>>? _userSub;
  StreamSubscription<List<FocusSystem>>? _systemsSub;
  StreamSubscription<User?>? _authSub;

  String get activeProgressText => '${(activeProgress.value * 100).round()}%';
  String get sessionRemainingText =>
      '${((1 - currentSessionProgress.value) * 60).round()}m left';

  double get monthlyGoalProgress {
    final t = statsMonthlyTotal.value;
    if (t <= 0) return 0;
    return (statsMonthlyDone.value / t).clamp(0.0, 1.0);
  }

  String get focusDepthFormatted {
    final s = statsFocusDepthSeconds.value;
    final m = s ~/ 60;
    final sec = s % 60;
    return '${m}m ${sec.toString().padLeft(2, '0')}s';
  }

  FocusSystem? get activeHomeSystem {
    final id = activeHomeSystemId.value;
    if (id != null) {
      for (final system in userSystems) {
        if (system.id == id) return system;
      }
    }
    return _firstSystemOfKind('routine') ?? (userSystems.isEmpty ? null : userSystems.first);
  }

  Future<void> setActiveHomeSystem(String systemId) async {
    if (!userSystems.any((system) => system.id == systemId)) return;

    activeHomeSystemId.value = systemId;
    if (Get.isRegistered<LocalProfileStore>()) {
      Get.find<LocalProfileStore>().setActiveHomeSystem(systemId);
    }
    if (Get.isRegistered<SystemsController>()) {
      Get.find<SystemsController>().selectSystem(systemId);
    }
    refreshDerivedStats();

    if (!AppSession.canSync) return;
    try {
      await Get.find<UserRepository>().updateActiveHomeSystem(
        AppSession.uid!,
        systemId,
      );
    } catch (_) {
      Get.snackbar('Hydra', 'Active system saved on this device only');
    }
  }

  void refreshDerivedStats() {
    scheduleMicrotask(_applyDerivedStatsNow);
  }

  void _applyDerivedStatsNow() {
    if (!Get.isRegistered<SystemsController>()) return;
    final systemsCtrl = Get.find<SystemsController>();
    final systems = userSystems.isNotEmpty
        ? userSystems
        : systemsCtrl.availableSystems;
    final snap = SystemStatsHelper.compute(
      systems: systems,
      tasks: systemsCtrl.tasks,
      activeSystemId: activeHomeSystemId.value,
    );
    statsCompletionRate.value = snap.completionRate;
    statsMonthlyDone.value = snap.monthlyDone;
    statsMonthlyTotal.value = snap.monthlyTotal;
    efficiencyRows.assignAll(snap.efficiency);
    activeProgress.value = snap.activeProgress;
    morningStepsRemaining.value = snap.activeRemaining;
  }

  Future<void> setReportScope(String scope) async {
    statsReportScope.value = scope;
    if (!AppSession.canSync) return;
    await Get.find<UserRepository>().updateReportScope(AppSession.uid!, scope);
  }

  void resetForSignOut() {
    activeProgress.value = 0;
    currentSessionProgress.value = 0;
    streakDays.value = 0;
    focusHours.value = 0;
    morningStepsRemaining.value = 0;
    phaseLabel.value = 'Get started';
    statsStreakDays.value = 0;
    statsCompletionRate.value = 0;
    statsFocusDepthSeconds.value = 0;
    statsFocusDepthDeltaPct.value = 0;
    statsMonthlyDone.value = 0;
    statsMonthlyTotal.value = 30;
    statsQuote.value = 'Start tracking to see insights here.';
    statsReportScope.value = 'week';
    weeklyHeights.assignAll(List<double>.filled(7, 0));
    weeklyHighlightIndex.value = 0;
    efficiencyRows.clear();
    routineDurationMin.value = 45;
    routineFrequency.value = 'Daily';
    userSystems.clear();
    activeHomeSystemId.value = null;
  }

  Future<void> applyFocusPrompt({required bool completed}) async {
    if (AppSession.canSync) {
      await Get.find<UserRepository>().recordFocusPrompt(
        AppSession.uid!,
        completed: completed,
      );
      return;
    }

    if (!completed) return;
    activeProgress.value = (activeProgress.value + 0.02).clamp(0.0, 1.0);
    focusHours.value = double.parse((focusHours.value + 0.05).toStringAsFixed(2));
    statsFocusDepthSeconds.value += 90;
    statsMonthlyDone.value += 1;
    statsFocusDepthDeltaPct.value =
        (statsFocusDepthDeltaPct.value + 1).clamp(0, 99);
    final idx = DateTime.now().weekday - 1;
    weeklyHighlightIndex.value = idx;
    final heights = List<double>.from(weeklyHeights);
    if (heights.length == 7) {
      heights[idx] = (heights[idx] + 0.1).clamp(0.0, 1.0);
      weeklyHeights.assignAll(heights);
    }
  }

  @override
  void onInit() {
    super.onInit();
    _bindUserStream();
    if (!AppSession.hasCloud) {
      _applyLocalSystems();
    }
  }

  void _bindUserStream() {
    if (!AppSession.hasCloud) {
      _applyLocalSystems();
      return;
    }
    final auth = Get.find<AuthService>();
    _authSub?.cancel();
    _authSub = auth.authStateChanges().listen((user) async {
      final uid = user?.uid;
      if (uid == null) {
        _userSub?.cancel();
        _systemsSub?.cancel();
        resetForSignOut();
        _applyLocalSystems();
        return;
      }
      final seeded = await AppSession.ensureUserSeed();
      if (!seeded) {
        _applyLocalSystems();
        return;
      }
      _listenUser(uid);
      _listenFocusSystems(uid);
    });
  }

  void _applyLocalSystems() {
    if (!Get.isRegistered<LocalProfileStore>()) return;
    final local = Get.find<LocalProfileStore>();
    userSystems.assignAll(local.systems);
    activeHomeSystemId.value = local.activeHomeSystemId.value;
    _syncActiveHomeSystem();
    refreshDerivedStats();
  }

  FocusSystem? _firstSystemOfKind(String kind) {
    for (final system in userSystems) {
      if (system.kind == kind) return system;
    }
    return null;
  }

  void _syncActiveHomeSystem() {
    final id = activeHomeSystemId.value;
    if (id == null) return;
    if (userSystems.any((system) => system.id == id)) return;
    activeHomeSystemId.value = null;
    if (Get.isRegistered<LocalProfileStore>()) {
      Get.find<LocalProfileStore>().setActiveHomeSystem(null);
    }
  }

  void _listenFocusSystems(String uid) {
    _systemsSub?.cancel();
    if (!Get.isRegistered<UserRepository>()) return;
    _systemsSub = Get.find<UserRepository>().watchFocusSystems(uid).listen(
      (list) {
        userSystems.assignAll(list);
        _syncActiveHomeSystem();
        refreshDerivedStats();
      },
      onError: (_) => _applyLocalSystems(),
    );
  }

  void _listenUser(String uid) {
    _userSub?.cancel();
    if (!Get.isRegistered<UserRepository>()) return;
    final repo = Get.find<UserRepository>();
    _userSub = repo.watchUser(uid).listen(
      (snap) {
        if (!snap.exists || snap.data() == null) return;
        _applyUser(snap.data()!);
      },
      onError: (_) => _applyLocalSystems(),
    );
  }

  void _applyUser(Map<String, dynamic> data) {
    activeProgress.value =
        (data['activeProgress'] as num?)?.toDouble() ?? activeProgress.value;
    currentSessionProgress.value =
        (data['studySessionProgress'] as num?)?.toDouble() ??
        currentSessionProgress.value;
    streakDays.value =
        (data['streakDays'] as num?)?.toInt() ?? streakDays.value;
    focusHours.value =
        (data['focusHours'] as num?)?.toDouble() ?? focusHours.value;
    morningStepsRemaining.value =
        (data['morningStepsRemaining'] as num?)?.toInt() ??
        morningStepsRemaining.value;
    phaseLabel.value = data['phaseLabel'] as String? ?? phaseLabel.value;

    statsStreakDays.value =
        (data['statsStreakDays'] as num?)?.toInt() ?? statsStreakDays.value;
    statsCompletionRate.value =
        (data['statsCompletionRate'] as num?)?.toDouble() ??
        statsCompletionRate.value;
    statsFocusDepthSeconds.value =
        (data['statsFocusDepthSeconds'] as num?)?.toInt() ??
        statsFocusDepthSeconds.value;
    statsFocusDepthDeltaPct.value =
        (data['statsFocusDepthDeltaPct'] as num?)?.toInt() ??
        statsFocusDepthDeltaPct.value;
    statsMonthlyDone.value =
        (data['statsMonthlyDone'] as num?)?.toInt() ?? statsMonthlyDone.value;
    statsMonthlyTotal.value =
        (data['statsMonthlyTotal'] as num?)?.toInt() ?? statsMonthlyTotal.value;
    statsQuote.value = data['statsQuote'] as String? ?? statsQuote.value;
    statsReportScope.value =
        data['statsReportScope'] as String? ?? statsReportScope.value;

    final wh = data['weeklyHeights'] as List?;
    if (wh != null && wh.length == 7) {
      weeklyHeights.assignAll(wh.map((e) => (e as num).toDouble()).toList());
    }
    weeklyHighlightIndex.value =
        (data['weeklyHighlightIndex'] as num?)?.toInt() ??
        weeklyHighlightIndex.value;

    final eff = data['efficiency'] as List?;
    if (eff != null) {
      if (eff.isEmpty) {
        efficiencyRows.clear();
      } else {
        efficiencyRows.assignAll(
          eff
              .map(
                (e) => EfficiencyEntry.fromMap(
                  Map<String, dynamic>.from(e as Map),
                ),
              )
              .toList(),
        );
      }
    }

    routineDurationMin.value =
        (data['routineDurationMin'] as num?)?.toInt() ??
        routineDurationMin.value;
    routineFrequency.value =
        data['routineFrequency'] as String? ?? routineFrequency.value;

    final activeId = data['activeHomeSystemId'] as String?;
    activeHomeSystemId.value = activeId;
    if (Get.isRegistered<LocalProfileStore>()) {
      Get.find<LocalProfileStore>().setActiveHomeSystem(activeId);
    }
    _syncActiveHomeSystem();
    refreshDerivedStats();
  }

  @override
  void onClose() {
    _authSub?.cancel();
    _userSub?.cancel();
    _systemsSub?.cancel();
    super.onClose();
  }
}
