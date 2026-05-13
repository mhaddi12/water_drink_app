class ReminderSlot {
  const ReminderSlot({
    required this.time,
    required this.enabled,
    required this.order,
  });

  final String time;
  final bool enabled;
  final int order;

  Map<String, dynamic> toMap() => {
    'time': time,
    'enabled': enabled,
    'order': order,
  };

  factory ReminderSlot.fromMap(Map<String, dynamic> map) {
    return ReminderSlot(
      time: map['time'] as String? ?? '',
      enabled: map['enabled'] as bool? ?? false,
      order: (map['order'] as num?)?.toInt() ?? 0,
    );
  }

  ReminderSlot copyWith({bool? enabled}) {
    return ReminderSlot(
      time: time,
      enabled: enabled ?? this.enabled,
      order: order,
    );
  }
}
