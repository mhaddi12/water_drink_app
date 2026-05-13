import 'package:cloud_firestore/cloud_firestore.dart';

class HydrationIntake {
  const HydrationIntake({
    required this.id,
    required this.amountMl,
    required this.createdAt,
  });

  final String id;
  final int amountMl;
  final DateTime createdAt;

  factory HydrationIntake.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
    final createdAt = data['createdAt'];
    return HydrationIntake(
      id: doc.id,
      amountMl: (data['amountMl'] as num?)?.toInt() ?? 0,
      createdAt: createdAt is Timestamp
          ? createdAt.toDate()
          : DateTime.fromMillisecondsSinceEpoch(0),
    );
  }

  Map<String, dynamic> toMap() => {
    'amountMl': amountMl,
    'createdAt': FieldValue.serverTimestamp(),
  };
}

class HydrationDaySummary {
  const HydrationDaySummary({
    required this.label,
    required this.intakeMl,
    required this.goalMl,
    required this.day,
  });

  final String label;
  final int intakeMl;
  final int goalMl;
  final DateTime day;
}
