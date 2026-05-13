import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:water_drink_app/core/session/app_session.dart';
import 'package:water_drink_app/core/session/local_profile_store.dart';
import 'package:water_drink_app/data/models/hydration_intake.dart';
import 'package:water_drink_app/data/repositories/user_repository.dart';
import 'package:water_drink_app/data/services/auth_service.dart';

class HistoryController extends GetxController {
  final weeklyAverageMl = 0.obs;
  final weeklyDeltaPct = 0.obs;
  final bestDayMl = 0.obs;
  final bestDayLabel = '—'.obs;
  final goalMl = 3000.obs;
  final daySummaries = <HydrationDaySummary>[].obs;

  StreamSubscription<List<HydrationIntake>>? _intakesSub;
  StreamSubscription<User?>? _authSub;
  StreamSubscription? _userSub;

  LocalProfileStore get _local => Get.find<LocalProfileStore>();

  @override
  void onInit() {
    super.onInit();
    _bind();
  }

  void applyLocalDefaults() {
    goalMl.value = _local.hydrationGoalMl.value;
    _rebuildSummaries(_local.intakes);
    _rebuildSummaryCards(_local.intakes);
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
        _intakesSub?.cancel();
        _userSub?.cancel();
        applyLocalDefaults();
        return;
      }
      final seeded = await AppSession.ensureUserSeed();
      if (!seeded) {
        applyLocalDefaults();
        return;
      }
      _listenUser(uid);
      _listenRecentIntakes(uid);
    });
  }

  void _listenUser(String uid) {
    if (!Get.isRegistered<UserRepository>()) return;
    _userSub?.cancel();
    _userSub = Get.find<UserRepository>().watchUser(uid).listen(
      (snap) {
        final data = snap.data();
        if (data == null) return;
        weeklyAverageMl.value =
            (data['hydrationWeeklyAverageMl'] as num?)?.toInt() ??
            weeklyAverageMl.value;
        weeklyDeltaPct.value =
            (data['hydrationWeeklyDeltaPct'] as num?)?.toInt() ??
            weeklyDeltaPct.value;
        bestDayMl.value =
            (data['hydrationBestDayMl'] as num?)?.toInt() ?? bestDayMl.value;
        bestDayLabel.value =
            data['hydrationBestDayLabel'] as String? ?? bestDayLabel.value;
        goalMl.value = (data['hydrationGoalMl'] as num?)?.toInt() ?? goalMl.value;
      },
      onError: (_) => applyLocalDefaults(),
    );
  }

  void _listenRecentIntakes(String uid) {
    if (!Get.isRegistered<UserRepository>()) return;
    _intakesSub?.cancel();
    final now = DateTime.now();
    final start = DateTime(now.year, now.month, now.day).subtract(
      const Duration(days: 13),
    );
    _intakesSub = Get.find<UserRepository>()
        .watchHydrationIntakes(uid, since: start)
        .listen(
          (intakes) {
            _rebuildSummaries(intakes);
            _rebuildSummaryCards(intakes);
          },
          onError: (_) => applyLocalDefaults(),
        );
  }

  void _rebuildSummaries(List<HydrationIntake> intakes) {
    final now = DateTime.now();
    final totals = <DateTime, int>{};
    for (final intake in intakes) {
      final day = DateTime(
        intake.createdAt.year,
        intake.createdAt.month,
        intake.createdAt.day,
      );
      totals[day] = (totals[day] ?? 0) + intake.amountMl;
    }

    final summaries = <HydrationDaySummary>[];
    for (var offset = 0; offset < 14; offset++) {
      final day = DateTime(
        now.year,
        now.month,
        now.day,
      ).subtract(Duration(days: offset));
      summaries.add(
        HydrationDaySummary(
          label: _dayLabel(day, now),
          intakeMl: totals[day] ?? 0,
          goalMl: goalMl.value,
          day: day,
        ),
      );
    }
    daySummaries.assignAll(summaries);
  }

  void _rebuildSummaryCards(List<HydrationIntake> intakes) {
    final now = DateTime.now();
    final totals = <DateTime, int>{};
    for (final intake in intakes) {
      final day = DateTime(
        intake.createdAt.year,
        intake.createdAt.month,
        intake.createdAt.day,
      );
      totals[day] = (totals[day] ?? 0) + intake.amountMl;
    }

    final thisWeek = List.generate(7, (index) {
      final day = DateTime(
        now.year,
        now.month,
        now.day,
      ).subtract(Duration(days: 6 - index));
      return totals[day] ?? 0;
    });
    final lastWeek = List.generate(7, (index) {
      final day = DateTime(
        now.year,
        now.month,
        now.day,
      ).subtract(Duration(days: 13 - index));
      return totals[day] ?? 0;
    });

    weeklyAverageMl.value = thisWeek.isEmpty
        ? 0
        : (thisWeek.reduce((a, b) => a + b) / thisWeek.length).round();
    final previousAverage = lastWeek.isEmpty
        ? 0
        : (lastWeek.reduce((a, b) => a + b) / lastWeek.length).round();
    weeklyDeltaPct.value = previousAverage <= 0
        ? 0
        : (((weeklyAverageMl.value - previousAverage) / previousAverage) * 100)
              .round();

    var bestMl = 0;
    var bestLabel = '—';
    for (final entry in totals.entries) {
      if (entry.value > bestMl) {
        bestMl = entry.value;
        bestLabel = _dayLabel(entry.key, now);
      }
    }
    bestDayMl.value = bestMl;
    bestDayLabel.value = bestLabel;
  }

  static String _dayLabel(DateTime day, DateTime now) {
    final today = DateTime(now.year, now.month, now.day);
    final target = DateTime(day.year, day.month, day.day);
    if (target == today) return 'Today';
    if (target == today.subtract(const Duration(days: 1))) return 'Yesterday';
    const labels = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday',
    ];
    return labels[target.weekday - 1];
  }

  String get weeklyAverageLabel {
    final value = weeklyAverageMl.value;
    return '${_formatMl(value)} ml';
  }

  String get weeklyDeltaLabel {
    final delta = weeklyDeltaPct.value;
    final sign = delta >= 0 ? '+' : '';
    return '$sign$delta% vs last week';
  }

  String get bestDayValueLabel => '${_formatMl(bestDayMl.value)} ml';

  static String _formatMl(int value) {
    final text = value.toString();
    return text.replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (match) => '${match[1]},',
    );
  }

  @override
  void onClose() {
    _authSub?.cancel();
    _intakesSub?.cancel();
    _userSub?.cancel();
    super.onClose();
  }
}
