import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:water_drink_app/core/firebase/app_firebase.dart';
import 'package:water_drink_app/data/models/focus_system.dart';
import 'package:water_drink_app/data/models/routine_task.dart';
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
  final weeklyHeights = List<double>.filled(7, 0.0).obs;
  final weeklyHighlightIndex = 0.obs;
  final efficiencyRows = <EfficiencyEntry>[].obs;

  final routineDurationMin = 0.obs;
  final routineFrequency = 'Daily'.obs;

  final userSystems = <FocusSystem>[].obs;

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

  @override
  void onInit() {
    super.onInit();
    _bindUserStream();
  }

  void _bindUserStream() {
    if (!AppFirebase.isReady || !Get.isRegistered<AuthService>()) return;
    final auth = Get.find<AuthService>();
    _authSub?.cancel();
    _authSub = auth.authStateChanges().listen((user) async {
      final uid = user?.uid;
      if (uid == null) {
        _userSub?.cancel();
        _systemsSub?.cancel();
        userSystems.clear();
        return;
      }
      if (Get.isRegistered<UserRepository>()) {
        await Get.find<UserRepository>().ensureSeed(uid);
      }
      _listenUser(uid);
      _listenFocusSystems(uid);
    });
  }

  void _listenFocusSystems(String uid) {
    _systemsSub?.cancel();
    if (!Get.isRegistered<UserRepository>()) return;
    _systemsSub = Get.find<UserRepository>().watchFocusSystems(uid).listen((
      list,
    ) {
      userSystems.assignAll(list);
    });
  }

  void _listenUser(String uid) {
    _userSub?.cancel();
    if (!Get.isRegistered<UserRepository>()) return;
    final repo = Get.find<UserRepository>();
    _userSub = repo.watchUser(uid).listen((snap) {
      if (!snap.exists || snap.data() == null) return;
      _applyUser(snap.data()!);
    });
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
  }

  @override
  void onClose() {
    _authSub?.cancel();
    _userSub?.cancel();
    _systemsSub?.cancel();
    super.onClose();
  }
}
