import 'package:cloud_firestore/cloud_firestore.dart';

class RoutineTask {
  const RoutineTask({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.done,
    required this.order,
    this.systemId,
  });

  final String id;
  final String title;
  final String subtitle;
  final bool done;
  final int order;
  final String? systemId;

  Map<String, dynamic> toMap() => {
    'title': title,
    'subtitle': subtitle,
    'done': done,
    'order': order,
    if (systemId != null) 'systemId': systemId,
  };

  factory RoutineTask.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final d = doc.data() ?? {};
    return RoutineTask(
      id: doc.id,
      title: d['title'] as String? ?? '',
      subtitle: d['subtitle'] as String? ?? '',
      done: d['done'] as bool? ?? false,
      order: (d['order'] as num?)?.toInt() ?? 0,
      systemId: d['systemId'] as String?,
    );
  }

  RoutineTask copyWith({
    String? id,
    String? title,
    String? subtitle,
    bool? done,
    int? order,
    String? systemId,
  }) {
    return RoutineTask(
      id: id ?? this.id,
      title: title ?? this.title,
      subtitle: subtitle ?? this.subtitle,
      done: done ?? this.done,
      order: order ?? this.order,
      systemId: systemId ?? this.systemId,
    );
  }
}

class EfficiencyEntry {
  const EfficiencyEntry({
    required this.title,
    required this.subtitle,
    required this.score,
    required this.status,
  });

  final String title;
  final String subtitle;
  final String score;
  final String status;

  Map<String, dynamic> toMap() => {
    'title': title,
    'subtitle': subtitle,
    'score': score,
    'status': status,
  };

  factory EfficiencyEntry.fromMap(Map<String, dynamic> m) {
    return EfficiencyEntry(
      title: m['title'] as String? ?? '',
      subtitle: m['subtitle'] as String? ?? '',
      score: m['score'] as String? ?? '',
      status: m['status'] as String? ?? '',
    );
  }
}
