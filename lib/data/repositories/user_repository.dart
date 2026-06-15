import 'dart:math' as math;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:water_drink_app/core/firebase/app_firebase.dart';
import 'package:water_drink_app/core/reminders/reminder_schedule_helper.dart';
import 'package:water_drink_app/core/stats/system_stats_helper.dart';
import 'package:water_drink_app/data/models/focus_system.dart';
import 'package:water_drink_app/data/models/hydration_intake.dart';
import 'package:water_drink_app/data/models/reminder_slot.dart';
import 'package:water_drink_app/data/models/routine_task.dart';

class UserRepository extends GetxService {
  final _db = FirebaseFirestore.instance;

  DocumentReference<Map<String, dynamic>> userRef(String uid) =>
      _db.collection('users').doc(uid);

  CollectionReference<Map<String, dynamic>> tasksRef(String uid) =>
      userRef(uid).collection('routine_tasks');

  CollectionReference<Map<String, dynamic>> focusSystemsRef(String uid) =>
      userRef(uid).collection('focus_systems');

  CollectionReference<Map<String, dynamic>> hydrationIntakesRef(String uid) =>
      userRef(uid).collection('hydration_intakes');

  Stream<List<HydrationIntake>> watchHydrationIntakes(
    String uid, {
    required DateTime since,
  }) {
    return hydrationIntakesRef(uid)
        .where('createdAt', isGreaterThanOrEqualTo: Timestamp.fromDate(since))
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map(HydrationIntake.fromDoc).toList());
  }

  Stream<DocumentSnapshot<Map<String, dynamic>>> watchUser(String uid) {
    return userRef(uid).snapshots();
  }

  Stream<List<RoutineTask>> watchTasks(String uid) {
    return tasksRef(uid)
        .orderBy('order')
        .snapshots()
        .map((s) => s.docs.map(RoutineTask.fromDoc).toList());
  }

  Stream<List<FocusSystem>> watchFocusSystems(String uid) {
    return focusSystemsRef(uid).snapshots().map((s) {
      final list = s.docs.map(FocusSystem.fromDoc).toList();
      list.sort((a, b) {
        final ad = a.createdAt;
        final bd = b.createdAt;
        if (ad == null && bd == null) return 0;
        if (ad == null) return 1;
        if (bd == null) return -1;
        return bd.compareTo(ad);
      });
      return list;
    });
  }

  /// Fresh account defaults — all metrics start at zero / empty.
  static Map<String, dynamic> defaultUserPayload() => {
    'activeProgress': 0.0,
    'studySessionProgress': 0.0,
    'streakDays': 0,
    'focusHours': 0.0,
    'morningStepsRemaining': 3,
    'statsStreakDays': 0,
    'statsCompletionRate': 0.0,
    'statsFocusDepthSeconds': 0,
    'statsFocusDepthDeltaPct': 0,
    'statsMonthlyDone': 0,
    'statsMonthlyTotal': 30,
    'statsQuote': 'Start tracking to see insights here.',
    'weeklyHeights': List<double>.filled(7, 0.0),
    'weeklyHighlightIndex': 0,
    'phaseLabel': 'Study System',
    'systemsCreated': 0,
    'statsReportViews': 0,
    'statsReportScope': 'week',
    'routineDurationMin': 45,
    'routineFrequency': 'Daily',
    'displayName': 'Hydra user',
    'hydrationGoalMl': 3000,
    'reminderFrequencyHours': 0,
    'theme': 'light',
    'activeHomeSystemId': null,
    'hydrationWeeklyAverageMl': 0,
    'hydrationWeeklyDeltaPct': 0,
    'hydrationBestDayMl': 0,
    'hydrationBestDayLabel': '—',
    'reminderSlots': defaultReminderSlots(),
    'timezone': 'UTC',
    'efficiency': defaultEfficiencyRows(),
    'updatedAt': FieldValue.serverTimestamp(),
  };

  /// Starter routine tasks for new accounts.
  static List<RoutineTask> defaultTasks() => const [
    RoutineTask(
      id: 'starter_hydrate',
      title: 'Drink water',
      subtitle: '250 ml',
      done: false,
      order: 0,
    ),
    RoutineTask(
      id: 'starter_plan',
      title: 'Plan the day',
      subtitle: '5 min',
      done: false,
      order: 1,
    ),
    RoutineTask(
      id: 'starter_move',
      title: 'Short movement',
      subtitle: 'Stretch or walk',
      done: false,
      order: 2,
    ),
  ];

  static List<Map<String, dynamic>> defaultEfficiencyRows() => const [
    {
      'title': 'Morning Routine',
      'subtitle': 'Consistency score',
      'score': '0%',
      'status': 'Starter',
    },
    {
      'title': 'Study System',
      'subtitle': 'Deep work quality',
      'score': '0%',
      'status': 'Starter',
    },
    {
      'title': 'Hydration Rhythm',
      'subtitle': 'Daily pacing',
      'score': '0%',
      'status': 'Starter',
    },
    {
      'title': 'Weekly Review',
      'subtitle': 'Reflection cadence',
      'score': '0%',
      'status': 'Starter',
    },
  ];

  static List<Map<String, dynamic>> defaultReminderSlots() =>
      ReminderScheduleHelper.defaultStarterSlots()
          .map((slot) => slot.toMap())
          .toList();

  Future<void> ensureSeed(String uid) async {
    if (!AppFirebase.isReady) return;
    try {
      final ref = userRef(uid);
      final snap = await ref.get();
      if (!snap.exists) {
        await ref.set(defaultUserPayload());
      }
      await _ensureTasksSeed(uid);
      await _ensureSystemsSeed(uid);
    } catch (_) {
      rethrow;
    }
  }

  Future<void> _ensureTasksSeed(String uid) async {
    final q = await tasksRef(uid).limit(1).get();
    if (q.docs.isNotEmpty) return;
    final seed = defaultTasks();
    if (seed.isEmpty) return;
    final batch = _db.batch();
    for (final t in seed) {
      batch.set(tasksRef(uid).doc(t.id), t.toMap());
    }
    await batch.commit();
  }

  Future<void> _ensureSystemsSeed(String uid) async {
    final existing = await focusSystemsRef(uid).limit(1).get();
    if (existing.docs.isNotEmpty) return;

    final batch = _db.batch();
    final now = FieldValue.serverTimestamp();
    final starters = <Map<String, dynamic>>[
      {
        'name': 'Morning Routine',
        'kind': 'routine',
        'tag': 'ROUTINE',
        'focusLine': 'Daily progress',
        'frequency': 'Daily',
        'targetMinutes': 45,
      },
      {
        'name': 'Study System',
        'kind': 'deep_work',
        'tag': 'DEEP WORK',
        'focusLine': 'Current session',
        'frequency': 'Weekdays',
        'targetMinutes': 60,
      },
      {
        'name': 'Hydration Rhythm',
        'kind': 'habit',
        'tag': 'CUSTOM SYSTEM',
        'focusLine': 'Stay on pace',
        'frequency': 'Daily',
      },
      {
        'name': 'Weekly Review',
        'kind': 'habit',
        'tag': 'CUSTOM SYSTEM',
        'focusLine': 'Reflect and reset',
        'frequency': 'Weekly',
        'targetMinutes': 20,
      },
    ];

    for (final starter in starters) {
      final doc = focusSystemsRef(uid).doc();
      batch.set(doc, {
        ...starter,
        'createdAt': now,
      });
    }

    batch.set(
      userRef(uid),
      {
        'systemsCreated': starters.length,
        'phaseLabel': 'Study System',
        'routineFrequency': 'Daily',
        'routineDurationMin': 45,
        'studySessionProgress': 0.12,
        'efficiency': defaultEfficiencyRows(),
        'updatedAt': now,
      },
      SetOptions(merge: true),
    );

    await batch.commit();
  }

  Future<void> mergeUser(String uid, Map<String, dynamic> data) async {
    if (!AppFirebase.isReady) return;
    data['updatedAt'] = FieldValue.serverTimestamp();
    await userRef(uid).set(data, SetOptions(merge: true));
  }

  Future<void> setTaskDone(String uid, String taskId, bool done) async {
    if (!AppFirebase.isReady) return;
    await tasksRef(
      uid,
    ).doc(taskId).set({'done': done}, SetOptions(merge: true));
  }

  Future<void> addTask(String uid, RoutineTask task) async {
    if (!AppFirebase.isReady) return;
    await tasksRef(uid).doc(task.id).set(task.toMap());
  }

  Future<void> updateTask(String uid, RoutineTask task) async {
    if (!AppFirebase.isReady) return;
    await tasksRef(uid).doc(task.id).set(task.toMap(), SetOptions(merge: true));
  }

  Future<void> deleteTask(String uid, String taskId) async {
    if (!AppFirebase.isReady) return;
    await tasksRef(uid).doc(taskId).delete();
  }

  Future<void> syncDerivedStats(String uid, SystemStatsSnapshot snap) async {
    if (!AppFirebase.isReady) return;
    final doc = await userRef(uid).get();
    final data = doc.data() ?? {};
    final raw = data['weeklyHeights'] as List?;
    final heights = <double>[];
    if (raw != null && raw.length == 7) {
      heights.addAll(raw.map((e) => (e as num).toDouble()));
    } else {
      heights.addAll(List<double>.filled(7, 0.0));
    }
    final idx = DateTime.now().weekday - 1;
    final progress = snap.activeProgress.clamp(0.0, 1.0);
    heights[idx] = math.max(heights[idx], progress);
    await mergeUser(uid, {
      'activeProgress': progress,
      'morningStepsRemaining': snap.activeRemaining,
      'statsCompletionRate': snap.completionRate,
      'statsMonthlyDone': snap.monthlyDone,
      'statsMonthlyTotal': snap.monthlyTotal,
      'efficiency': snap.efficiency.map((row) => row.toMap()).toList(),
      'weeklyHeights': heights,
      'weeklyHighlightIndex': idx,
    });
  }

  Future<void> recordFocusPrompt(String uid, {required bool completed}) async {
    if (!AppFirebase.isReady) return;
    await userRef(uid).collection('focus_events').add({
      'completed': completed,
      'createdAt': FieldValue.serverTimestamp(),
    });
    if (!completed) return;
    final snap = await userRef(uid).get();
    final data = snap.data() ?? {};
    final curP = (data['activeProgress'] as num?)?.toDouble() ?? 0.0;
    final curH = (data['focusHours'] as num?)?.toDouble() ?? 0.0;
    final depths = (data['statsFocusDepthSeconds'] as num?)?.toInt() ?? 0;
    final monthlyDone = (data['statsMonthlyDone'] as num?)?.toInt() ?? 0;
    final deltaPct = (data['statsFocusDepthDeltaPct'] as num?)?.toInt() ?? 0;
    final rawH = data['weeklyHeights'] as List?;
    final heights = <double>[];
    if (rawH != null && rawH.length == 7) {
      heights.addAll(rawH.map((e) => (e as num).toDouble()));
    } else {
      heights.addAll(List<double>.filled(7, 0.0));
    }
    final idx = DateTime.now().weekday - 1;
    heights[idx] = math.min(1.0, heights[idx] + 0.1);
    await mergeUser(uid, {
      'activeProgress': (curP + 0.02).clamp(0.0, 1.0),
      'focusHours': double.parse((curH + 0.05).toStringAsFixed(2)),
      'statsFocusDepthSeconds': depths + 90,
      'statsMonthlyDone': monthlyDone + 1,
      'statsFocusDepthDeltaPct': math.min(99, deltaPct + 1),
      'weeklyHeights': heights,
      'weeklyHighlightIndex': idx,
    });
  }

  Future<void> recordStatsReportOpened(String uid) async {
    if (!AppFirebase.isReady) return;
    await userRef(uid).set({
      'statsReportViews': FieldValue.increment(1),
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Future<void> updateReportScope(String uid, String scope) async {
    if (!AppFirebase.isReady) return;
    await mergeUser(uid, {'statsReportScope': scope});
  }

  Future<void> updateActiveHomeSystem(String uid, String? systemId) async {
    if (!AppFirebase.isReady) return;
    await mergeUser(uid, {'activeHomeSystemId': systemId});
  }

  Future<void> addHydrationIntake(String uid, int amountMl) async {
    if (!AppFirebase.isReady || amountMl <= 0) return;
    await hydrationIntakesRef(uid).add({
      'amountMl': amountMl,
      'createdAt': FieldValue.serverTimestamp(),
    });
    await _refreshHydrationInsights(uid);
  }

  Future<void> updateReminderSlots(
    String uid,
    List<ReminderSlot> slots,
  ) async {
    if (!AppFirebase.isReady) return;
    final sorted = ReminderScheduleHelper.sortByTime(slots);
    await mergeUser(uid, {
      'reminderSlots': sorted.map((slot) => slot.toMap()).toList(),
    });
  }

  Future<void> updateProfileSettings(
    String uid, {
    String? displayName,
    int? hydrationGoalMl,
    int? reminderFrequencyHours,
    String? theme,
  }) async {
    if (!AppFirebase.isReady) return;
    final updates = <String, dynamic>{};
    if (displayName != null) {
      updates['displayName'] = displayName.trim();
    }
    if (hydrationGoalMl != null) {
      updates['hydrationGoalMl'] = hydrationGoalMl.clamp(250, 10000);
    }
    if (reminderFrequencyHours != null) {
      updates['reminderFrequencyHours'] =
          reminderFrequencyHours.clamp(1, 12);
    }
    if (theme != null) {
      updates['theme'] = theme;
    }
    if (updates.isEmpty) return;
    await mergeUser(uid, updates);
  }

  Future<void> _refreshHydrationInsights(String uid) async {
    final now = DateTime.now();
    final start = DateTime(now.year, now.month, now.day).subtract(
      const Duration(days: 13),
    );
    final snapshot = await hydrationIntakesRef(uid)
        .where('createdAt', isGreaterThanOrEqualTo: Timestamp.fromDate(start))
        .get();
    final totals = <DateTime, int>{};
    for (final doc in snapshot.docs) {
      final intake = HydrationIntake.fromDoc(doc);
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

    final weeklyAverage = thisWeek.isEmpty
        ? 0
        : (thisWeek.reduce((a, b) => a + b) / thisWeek.length).round();
    final previousAverage = lastWeek.isEmpty
        ? 0
        : (lastWeek.reduce((a, b) => a + b) / lastWeek.length).round();
    final deltaPct = previousAverage <= 0
        ? 0
        : (((weeklyAverage - previousAverage) / previousAverage) * 100)
              .round();

    var bestDayMl = 0;
    var bestDayLabel = '—';
    for (final entry in totals.entries) {
      if (entry.value > bestDayMl) {
        bestDayMl = entry.value;
        bestDayLabel = _dayLabel(entry.key, now);
      }
    }

    await mergeUser(uid, {
      'hydrationWeeklyAverageMl': weeklyAverage,
      'hydrationWeeklyDeltaPct': deltaPct,
      'hydrationBestDayMl': bestDayMl,
      'hydrationBestDayLabel': bestDayLabel,
    });
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

  /// Persists a new focus system and updates the user profile when relevant.
  Future<String> createFocusSystem(
    String uid, {
    required String name,
    required String kind,
    required String frequency,
    required String focusLine,
    int? targetMinutes,
  }) async {
    if (!AppFirebase.isReady) return '';
    final doc = focusSystemsRef(uid).doc();
    final tag = switch (kind) {
      'deep_work' => 'DEEP WORK',
      'routine' => 'ROUTINE',
      _ => 'CUSTOM SYSTEM',
    };
    await doc.set({
      'name': name.trim(),
      'kind': kind,
      'tag': tag,
      'focusLine': focusLine.trim().isEmpty
          ? _defaultFocusLine(kind)
          : focusLine.trim(),
      'frequency': frequency,
      'targetMinutes': targetMinutes,
      'createdAt': FieldValue.serverTimestamp(),
    });

    final snap = await userRef(uid).get();
    final data = snap.data() ?? {};
    final curStudy = (data['studySessionProgress'] as num?)?.toDouble() ?? 0.0;

    final updates = <String, dynamic>{
      'systemsCreated': FieldValue.increment(1),
    };

    switch (kind) {
      case 'deep_work':
        updates['phaseLabel'] = name.trim();
        updates['studySessionProgress'] = (curStudy + 0.08).clamp(0.0, 1.0);
        break;
      case 'routine':
        updates['routineFrequency'] = frequency;
        if (targetMinutes != null && targetMinutes > 0) {
          updates['routineDurationMin'] = targetMinutes;
        }
        break;
      default:
        updates['studySessionProgress'] = (curStudy + 0.05).clamp(0.0, 1.0);
    }

    await mergeUser(uid, updates);
    return doc.id;
  }

  static String _defaultFocusLine(String kind) {
    return switch (kind) {
      'deep_work' => 'Current session',
      'routine' => 'Daily progress',
      _ => 'Track consistently',
    };
  }

  String nextTaskId(String uid) => tasksRef(uid).doc().id;

  /// Stores the device push token (FCM on Android) keyed by OneSignal subscription id.
  Future<void> upsertFcmToken({
    required String uid,
    required String deviceKey,
    required String token,
    required String platform,
    required bool optedIn,
  }) async {
    if (!AppFirebase.isReady) return;
    await userRef(uid).set({
      'fcmTokens': {
        deviceKey: {
          'token': token,
          'platform': platform,
          'optedIn': optedIn,
          'updatedAt': FieldValue.serverTimestamp(),
        },
      },
    }, SetOptions(merge: true));
  }

  Future<void> removeFcmToken({
    required String uid,
    required String deviceKey,
  }) async {
    if (!AppFirebase.isReady) return;
    await userRef(uid).update({
      'fcmTokens.$deviceKey': FieldValue.delete(),
    });
  }

  /// IANA timezone id from the device, e.g. `Asia/Karachi` — used by the push backend.
  Future<void> upsertTimezone({
    required String uid,
    required String timezoneId,
  }) async {
    if (!AppFirebase.isReady) return;
    final trimmed = timezoneId.trim();
    if (trimmed.isEmpty) return;
    await mergeUser(uid, {
      'timezone': trimmed,
      'timezoneUpdatedAt': FieldValue.serverTimestamp(),
    });
  }
}
