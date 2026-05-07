import 'dart:math' as math;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:water_drink_app/core/firebase/app_firebase.dart';
import 'package:water_drink_app/data/models/focus_system.dart';
import 'package:water_drink_app/data/models/routine_task.dart';

class UserRepository extends GetxService {
  final _db = FirebaseFirestore.instance;

  DocumentReference<Map<String, dynamic>> userRef(String uid) =>
      _db.collection('users').doc(uid);

  CollectionReference<Map<String, dynamic>> tasksRef(String uid) =>
      userRef(uid).collection('routine_tasks');

  CollectionReference<Map<String, dynamic>> focusSystemsRef(String uid) =>
      userRef(uid).collection('focus_systems');

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
    'morningStepsRemaining': 0,
    'statsStreakDays': 0,
    'statsCompletionRate': 0.0,
    'statsFocusDepthSeconds': 0,
    'statsFocusDepthDeltaPct': 0,
    'statsMonthlyDone': 0,
    'statsMonthlyTotal': 0,
    'statsQuote': 'Start tracking to see insights here.',
    'weeklyHeights': List<double>.filled(7, 0.0),
    'weeklyHighlightIndex': 0,
    'phaseLabel': 'Get started',
    'systemsCreated': 0,
    'statsReportViews': 0,
    'routineDurationMin': 0,
    'routineFrequency': 'Daily',
    'efficiency': <Map<String, dynamic>>[],
    'updatedAt': FieldValue.serverTimestamp(),
  };

  /// No sample tasks — new users add their own under Systems.
  static List<RoutineTask> defaultTasks() => const [];

  Future<void> ensureSeed(String uid) async {
    if (!AppFirebase.isReady) return;
    final ref = userRef(uid);
    final snap = await ref.get();
    if (!snap.exists) {
      await ref.set(defaultUserPayload());
    }
    await _ensureTasksSeed(uid);
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

  Future<void> syncMorningProgress(
    String uid,
    double progress,
    int remaining,
  ) async {
    if (!AppFirebase.isReady) return;
    final snap = await userRef(uid).get();
    final data = snap.data() ?? {};
    final raw = data['weeklyHeights'] as List?;
    final heights = <double>[];
    if (raw != null && raw.length == 7) {
      heights.addAll(raw.map((e) => (e as num).toDouble()));
    } else {
      heights.addAll(List<double>.filled(7, 0.0));
    }
    final idx = DateTime.now().weekday - 1;
    final p = progress.clamp(0.0, 1.0);
    heights[idx] = math.max(heights[idx], p);
    await mergeUser(uid, {
      'activeProgress': p,
      'morningStepsRemaining': remaining,
      'statsCompletionRate': p,
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

  /// Persists a new focus system and updates the user profile when relevant.
  Future<void> createFocusSystem(
    String uid, {
    required String name,
    required String kind,
    required String frequency,
    required String focusLine,
    int? targetMinutes,
  }) async {
    if (!AppFirebase.isReady) return;
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
  }

  static String _defaultFocusLine(String kind) {
    return switch (kind) {
      'deep_work' => 'Current session',
      'routine' => 'Daily progress',
      _ => 'Track consistently',
    };
  }

  String nextTaskId(String uid) => tasksRef(uid).doc().id;
}
