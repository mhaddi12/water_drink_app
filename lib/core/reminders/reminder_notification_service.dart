import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:water_drink_app/core/notifications/notification_coordinator.dart';
import 'package:water_drink_app/core/reminders/reminder_schedule_helper.dart';
import 'package:water_drink_app/core/reminders/reminder_timezone.dart';
import 'package:water_drink_app/data/models/reminder_slot.dart';

class ReminderNotificationService {
  ReminderNotificationService._();

  static final ReminderNotificationService instance =
      ReminderNotificationService._();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  bool _initialized = false;
  bool _available = true;

  static const _alarmChannelId = 'hydra_hydration_alarms';

  static bool get isSupported =>
      !kIsWeb &&
      (defaultTargetPlatform == TargetPlatform.android ||
          defaultTargetPlatform == TargetPlatform.iOS);

  NotificationDetails _alarmDetails() => NotificationDetails(
    android: AndroidNotificationDetails(
      _alarmChannelId,
      'Hydration alarms',
      channelDescription: ReminderScheduleHelper.useFastReminders
          ? 'Hydration reminders every 3 minutes (test mode)'
          : 'Hydration reminders every 3 hours throughout the day',
      importance: Importance.max,
      priority: Priority.high,
      playSound: true,
      enableVibration: true,
      category: AndroidNotificationCategory.alarm,
      visibility: NotificationVisibility.public,
    ),
    iOS: const DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
      interruptionLevel: InterruptionLevel.timeSensitive,
    ),
  );

  Future<void> initialize() async {
    if (!isSupported || _initialized || !_available) return;

    try {
      await ReminderTimezone.ensureConfigured();

      const android = AndroidInitializationSettings('@mipmap/ic_launcher');
      const ios = DarwinInitializationSettings();
      await _plugin.initialize(
        const InitializationSettings(android: android, iOS: ios),
        onDidReceiveNotificationResponse: _onNotificationResponse,
      );

      _initialized = true;
    } catch (e, stack) {
      _available = false;
      if (kDebugMode) {
        debugPrint('Hydra reminders unavailable: $e\n$stack');
      }
    }
  }

  void _onNotificationResponse(NotificationResponse response) {
    NotificationCoordinator.handleNotificationOpen();
    NotificationCoordinator.instance.topUpScheduleFromLocal();
  }

  Future<bool> hasPermission() async {
    if (!isSupported) return false;
    await initialize();
    if (!_initialized) return false;

    if (defaultTargetPlatform == TargetPlatform.android) {
      final android = _androidPlugin;
      return await android?.areNotificationsEnabled() ?? false;
    }

    final ios = _iosPlugin;
    if (ios != null) {
      final settings = await ios.checkPermissions();
      return settings?.isEnabled ?? false;
    }
    return true;
  }

  Future<bool> requestPermission({bool requestExactAlarms = true}) async {
    if (!isSupported) return false;
    await initialize();
    if (!_initialized) return false;

    var granted = false;

    if (defaultTargetPlatform == TargetPlatform.android) {
      final android = _androidPlugin;
      granted = await android?.requestNotificationsPermission() ?? false;
      if (requestExactAlarms && granted) {
        await android?.requestExactAlarmsPermission();
      }
    } else {
      final ios = _iosPlugin;
      if (ios != null) {
        granted =
            await ios.requestPermissions(
              alert: true,
              badge: true,
              sound: true,
            ) ??
            false;
      }
    }

    return granted;
  }

  Future<bool> showTestNotification() async {
    if (!ReminderScheduleHelper.useFastReminders || !isSupported || !_available) {
      return false;
    }
    await initialize();
    if (!_initialized) return false;

    final allowed = await hasPermission();
    if (!allowed) {
      final granted = await requestPermission();
      if (!granted) return false;
    }

    await _plugin.show(
      9999,
      'Hydra',
      'Time to drink water — test alarm',
      _alarmDetails(),
    );
    return true;
  }

  Future<int> reschedule(List<ReminderSlot> slots) async {
    if (!isSupported || !_available) return 0;
    await initialize();
    if (!_initialized) return 0;

    final allowed = await hasPermission();
    if (!allowed) {
      if (kDebugMode) {
        debugPrint('Hydra: reschedule skipped — no notification permission');
      }
      return 0;
    }

    await _plugin.cancelAll();

    final scheduleMode = await _resolveAndroidScheduleMode();
    final enabled = slots.any((slot) => slot.enabled);
    if (!enabled) return 0;

    if (ReminderScheduleHelper.useFastReminders) {
      return _scheduleFastIntervalReminders(scheduleMode);
    }

    var scheduled = 0;
    for (final slot in slots) {
      if (!slot.enabled || slot.time.isEmpty) continue;
      final minutes = ReminderScheduleHelper.parseMinutes(slot.time);
      if (minutes == null) continue;

      final ok = await _scheduleDailyReminder(
        id: ReminderScheduleHelper.notificationIdFor(slot),
        hour: minutes ~/ 60,
        minute: minutes % 60,
        scheduleMode: scheduleMode,
      );
      if (ok) scheduled++;
    }
    return scheduled;
  }

  AndroidFlutterLocalNotificationsPlugin? get _androidPlugin => _plugin
      .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin
      >();

  IOSFlutterLocalNotificationsPlugin? get _iosPlugin => _plugin
      .resolvePlatformSpecificImplementation<
        IOSFlutterLocalNotificationsPlugin
      >();

  Future<AndroidScheduleMode> _resolveAndroidScheduleMode() async {
    if (defaultTargetPlatform != TargetPlatform.android) {
      return AndroidScheduleMode.exactAllowWhileIdle;
    }

    final canExact = await _androidPlugin?.canScheduleExactNotifications() ?? false;
    if (canExact) {
      return AndroidScheduleMode.alarmClock;
    }
    return AndroidScheduleMode.inexactAllowWhileIdle;
  }

  /// Fast test mode: first ping in 1 minute, then every 3 minutes.
  Future<int> _scheduleFastIntervalReminders(
    AndroidScheduleMode scheduleMode,
  ) async {
    final now = tz.TZDateTime.now(tz.local);
    final interval = ReminderScheduleHelper.debugIntervalMinutes;
    var scheduled = 0;

    for (var i = 0; i < ReminderScheduleHelper.debugPendingNotifications; i++) {
      final delayMinutes = i == 0 ? 1 : interval * i;
      final when = now.add(Duration(minutes: delayMinutes));
      final id = ReminderScheduleHelper.debugNotificationId(i + 1);

      final ok = await _zonedSchedule(
        id: id,
        when: when,
        scheduleMode: scheduleMode,
        repeatDaily: false,
        body: 'Stay hydrated · every $interval min',
      );
      if (ok) scheduled++;
    }

    if (kDebugMode || ReminderScheduleHelper.useFastReminders) {
      final pending = await _plugin.pendingNotificationRequests();
      debugPrint(
        'Hydra fast reminders: scheduled $scheduled, '
        'pending=${pending.length}, mode=$scheduleMode',
      );
    }
    return scheduled;
  }

  Future<bool> _scheduleDailyReminder({
    required int id,
    required int hour,
    required int minute,
    required AndroidScheduleMode scheduleMode,
  }) async {
    final when = _nextDailyInstance(hour, minute);
    return _zonedSchedule(
      id: id,
      when: when,
      scheduleMode: scheduleMode,
      repeatDaily: true,
      body: 'Stay hydrated. Tap to log water.',
    );
  }

  Future<bool> _zonedSchedule({
    required int id,
    required tz.TZDateTime when,
    required AndroidScheduleMode scheduleMode,
    required bool repeatDaily,
    required String body,
  }) async {
    try {
      await _plugin.zonedSchedule(
        id,
        'Hydra — drink water',
        body,
        when,
        _alarmDetails(),
        androidScheduleMode: scheduleMode,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents:
            repeatDaily ? DateTimeComponents.time : null,
      );
      return true;
    } on PlatformException catch (e) {
      if (e.code != 'exact_alarms_not_permitted') {
        if (kDebugMode) {
          debugPrint('Hydra schedule failed id=$id: ${e.code} ${e.message}');
        }
        return false;
      }
      try {
        await _plugin.zonedSchedule(
          id,
          'Hydra — drink water',
          body,
          when,
          _alarmDetails(),
          androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
          uiLocalNotificationDateInterpretation:
              UILocalNotificationDateInterpretation.absoluteTime,
          matchDateTimeComponents:
              repeatDaily ? DateTimeComponents.time : null,
        );
        return true;
      } catch (e2) {
        if (kDebugMode) {
          debugPrint('Hydra inexact schedule failed id=$id: $e2');
        }
        return false;
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Hydra schedule error id=$id: $e');
      }
      return false;
    }
  }

  tz.TZDateTime _nextDailyInstance(int hour, int minute) {
    final now = tz.TZDateTime.now(tz.local);
    var scheduled = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    );
    if (scheduled.isBefore(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }
    return scheduled;
  }
}
