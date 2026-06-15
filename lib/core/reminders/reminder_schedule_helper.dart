import 'package:flutter/material.dart';
import 'package:water_drink_app/data/models/reminder_slot.dart';

/// Push reminder preference only — timing is handled by your backend / OneSignal.
abstract final class ReminderScheduleHelper {
  static const String pushSlotId = 'push_reminders';

  static List<ReminderSlot> pushPreference({bool enabled = false}) => [
    ReminderSlot(
      id: pushSlotId,
      time: '',
      enabled: enabled,
      order: 0,
    ),
  ];

  static List<ReminderSlot> defaultStarterSlots() =>
      pushPreference(enabled: false);

  /// Maps any saved slots to a single on/off push preference.
  static List<ReminderSlot> normalizeSlots(List<ReminderSlot>? existing) {
    final enabled = existing != null && existing.any((slot) => slot.enabled);
    return pushPreference(enabled: enabled);
  }

  static List<ReminderSlot> sortByTime(List<ReminderSlot> slots) =>
      normalizeSlots(slots);

  static bool hasDuplicateTime(
    List<ReminderSlot> slots,
    String time, {
    String? exceptId,
  }) =>
      false;

  static String formatTimeOfDay(TimeOfDay time) => '';

  static TimeOfDay? timeOfDayFromLabel(String label) => null;

  static String get statusLabel => 'Push notifications';

  static String nextLabel(List<ReminderSlot> slots) {
    if (!slots.any((slot) => slot.enabled)) {
      return 'Reminders off';
    }
    return 'Push reminders on · schedule from your server';
  }

  static int? parseMinutes(String label) => null;

  static int notificationIdFor(ReminderSlot slot) => 1;
}
