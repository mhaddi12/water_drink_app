import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:water_drink_app/data/models/reminder_slot.dart';

abstract final class ReminderScheduleHelper {
  /// Production: hydration alarms every 3 hours.
  static const int reminderIntervalHours = 3;

  /// Debug only: fire every 3 minutes (release builds ignore this).
  static const int debugIntervalMinutes = 3;

  /// How many one-shot debug alarms to queue ahead.
  static const int debugPendingNotifications = 30;

  /// First alarm of the day (production schedule).
  static const int dayStartHour = 6;

  /// Debug/profile: every 3 minutes. Release: every 3 hours.
  /// Force fast mode in any build: `--dart-define=HYDRA_FAST_REMINDERS=true`
  static bool get useFastReminders {
    const fromEnv = bool.fromEnvironment(
      'HYDRA_FAST_REMINDERS',
      defaultValue: false,
    );
    return kDebugMode || fromEnv;
  }

  static Duration get scheduleInterval => useFastReminders
      ? const Duration(minutes: debugIntervalMinutes)
      : Duration(hours: reminderIntervalHours);

  /// Shown in UI copy (e.g. "3 hours" or "3 minutes (debug)").
  static String get intervalLabel => useFastReminders
      ? '$debugIntervalMinutes minutes (debug)'
      : '$reminderIntervalHours hours';

  static int get slotsPerDay => useFastReminders
      ? debugPendingNotifications
      : 24 ~/ reminderIntervalHours;

  static List<ReminderSlot> slotsEveryThreeHours({bool enabled = true}) {
    if (useFastReminders) {
      return [
        ReminderSlot(
          id: 'debug_every_${debugIntervalMinutes}m',
          time: '',
          enabled: enabled,
          order: 0,
        ),
      ];
    }

    return List.generate(24 ~/ reminderIntervalHours, (index) {
      final hour = (dayStartHour + index * reminderIntervalHours) % 24;
      final label = formatTimeOfDay(TimeOfDay(hour: hour, minute: 0));
      return ReminderSlot(
        id: 'every_${reminderIntervalHours}h_$hour',
        time: label,
        enabled: enabled,
        order: index,
      );
    });
  }

  /// Replaces any saved custom times with the fixed interval schedule.
  static List<ReminderSlot> normalizeSlots(List<ReminderSlot>? existing) {
    final enabled = existing == null || existing.isEmpty
        ? true
        : existing.any((slot) => slot.enabled);
    return slotsEveryThreeHours(enabled: enabled);
  }

  static List<ReminderSlot> defaultStarterSlots() =>
      slotsEveryThreeHours(enabled: true);

  static String formatTimeOfDay(TimeOfDay time) {
    final hour = time.hour;
    final minute = time.minute;
    final period = hour >= 12 ? 'PM' : 'AM';
    var displayHour = hour % 12;
    if (displayHour == 0) displayHour = 12;
    final min = minute.toString().padLeft(2, '0');
    return '$displayHour:$min $period';
  }

  static TimeOfDay? timeOfDayFromLabel(String label) {
    final minutes = parseMinutes(label);
    if (minutes == null) return null;
    return TimeOfDay(hour: minutes ~/ 60, minute: minutes % 60);
  }

  static List<ReminderSlot> sortByTime(List<ReminderSlot> slots) {
    return normalizeSlots(slots);
  }

  static bool hasDuplicateTime(
    List<ReminderSlot> slots,
    String time, {
    String? exceptId,
  }) {
    return slots.any(
      (slot) =>
          slot.time.toLowerCase() == time.toLowerCase() &&
          (exceptId == null || slot.id != exceptId),
    );
  }

  static String nextLabel(List<ReminderSlot> slots) {
    final normalized = normalizeSlots(slots);
    if (!normalized.any((slot) => slot.enabled)) {
      return 'Reminders off · every $intervalLabel when on';
    }

    if (useFastReminders) {
      return 'Every $debugIntervalMinutes min · debug build only';
    }

    final now = DateTime.now();
    final nowMinutes = now.hour * 60 + now.minute;
    var nextDelta = 24 * 60;

    for (final slot in normalized) {
      if (!slot.enabled || slot.time.isEmpty) continue;
      final parsed = parseMinutes(slot.time);
      if (parsed == null) continue;
      var delta = parsed - nowMinutes;
      if (delta <= 0) delta += 24 * 60;
      if (delta < nextDelta) {
        nextDelta = delta;
      }
    }

    if (nextDelta >= 24 * 60) {
      return 'Every $reminderIntervalHours hours';
    }
    final hours = nextDelta ~/ 60;
    final mins = nextDelta % 60;
    if (hours > 0) {
      return 'Next reminder in ${hours}h ${mins}m';
    }
    return 'Next reminder in ${mins}m';
  }

  static int? parseMinutes(String label) {
    final match = RegExp(
      r'^(\d{1,2}):(\d{2})\s*(AM|PM)$',
      caseSensitive: false,
    ).firstMatch(label.trim());
    if (match == null) return null;

    var hour = int.parse(match.group(1)!);
    final minute = int.parse(match.group(2)!);
    final period = match.group(3)!.toUpperCase();
    if (period == 'PM' && hour < 12) hour += 12;
    if (period == 'AM' && hour == 12) hour = 0;
    return hour * 60 + minute;
  }

  static int notificationIdFor(ReminderSlot slot) {
    return slot.id.hashCode.abs() % 100000 + 1;
  }

  static int debugNotificationId(int index) => 20000 + index;
}
