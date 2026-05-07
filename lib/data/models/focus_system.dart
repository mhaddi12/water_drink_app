import 'package:cloud_firestore/cloud_firestore.dart';

/// User-defined focus system stored under `users/{uid}/focus_systems/{id}`.
class FocusSystem {
  const FocusSystem({
    required this.id,
    required this.name,
    required this.kind,
    required this.tag,
    required this.focusLine,
    required this.frequency,
    this.targetMinutes,
    this.createdAt,
  });

  final String id;
  final String name;

  /// `deep_work` | `routine` | `habit`
  final String kind;
  final String tag;
  final String focusLine;
  final String frequency;
  final int? targetMinutes;
  final DateTime? createdAt;

  factory FocusSystem.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final d = doc.data() ?? {};
    final ts = d['createdAt'];
    DateTime? created;
    if (ts is Timestamp) created = ts.toDate();
    return FocusSystem(
      id: doc.id,
      name: d['name'] as String? ?? '',
      kind: d['kind'] as String? ?? 'habit',
      tag: d['tag'] as String? ?? 'CUSTOM',
      focusLine: d['focusLine'] as String? ?? '',
      frequency: d['frequency'] as String? ?? 'Daily',
      targetMinutes: (d['targetMinutes'] as num?)?.toInt(),
      createdAt: created,
    );
  }
}
