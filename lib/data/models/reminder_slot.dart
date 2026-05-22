class ReminderSlot {
  const ReminderSlot({
    required this.id,
    required this.time,
    required this.enabled,
    required this.order,
  });

  final String id;
  final String time;
  final bool enabled;
  final int order;

  Map<String, dynamic> toMap() => {
    'id': id,
    'time': time,
    'enabled': enabled,
    'order': order,
  };

  factory ReminderSlot.fromMap(Map<String, dynamic> map) {
    final order = (map['order'] as num?)?.toInt() ?? 0;
    final time = map['time'] as String? ?? '';
    return ReminderSlot(
      id: map['id'] as String? ?? 'slot_${order}_$time',
      time: time,
      enabled: map['enabled'] as bool? ?? false,
      order: order,
    );
  }

  ReminderSlot copyWith({
    String? id,
    String? time,
    bool? enabled,
    int? order,
  }) {
    return ReminderSlot(
      id: id ?? this.id,
      time: time ?? this.time,
      enabled: enabled ?? this.enabled,
      order: order ?? this.order,
    );
  }
}
