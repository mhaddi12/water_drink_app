import 'package:flutter/material.dart';
import 'package:water_drink_app/app/widgets/hub_ui.dart';

/// Opens the Material dial (watch-style) time picker.
Future<TimeOfDay?> pickReminderTime(
  BuildContext context, {
  TimeOfDay? initial,
}) {
  return showTimePicker(
    context: context,
    initialTime: initial ?? TimeOfDay.now(),
    initialEntryMode: TimePickerEntryMode.dial,
    helpText: 'Pick reminder time',
    cancelText: 'Cancel',
    confirmText: 'Set',
    builder: (context, child) {
      return Theme(
        data: Theme.of(context).copyWith(
          colorScheme: Theme.of(context).colorScheme.copyWith(
            primary: HubUi.primary,
          ),
          timePickerTheme: TimePickerThemeData(
            dialHandColor: HubUi.primary,
            hourMinuteColor: HubUi.primary.withValues(alpha: 0.12),
            dayPeriodColor: HubUi.primary.withValues(alpha: 0.12),
          ),
        ),
        child: child!,
      );
    },
  );
}
