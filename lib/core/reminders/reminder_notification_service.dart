import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:water_drink_app/core/notifications/notification_coordinator.dart';
import 'package:water_drink_app/data/models/reminder_slot.dart';

/// System notification permission and channels. Does not schedule 3h/3min alarms.
class ReminderNotificationService {
  ReminderNotificationService._();

  static final ReminderNotificationService instance =
      ReminderNotificationService._();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  bool _initialized = false;
  bool _available = true;

  static const _channelId = 'hydra_hydration_push';

  static bool get isSupported =>
      !kIsWeb &&
      (defaultTargetPlatform == TargetPlatform.android ||
          defaultTargetPlatform == TargetPlatform.iOS);

  NotificationDetails _details() => const NotificationDetails(
    android: AndroidNotificationDetails(
      _channelId,
      'Hydration reminders',
      channelDescription: 'Alerts sent from Hydra (push)',
      importance: Importance.high,
      priority: Priority.high,
      playSound: true,
      enableVibration: true,
    ),
    iOS: DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    ),
  );

  Future<void> initialize() async {
    if (!isSupported || _initialized || !_available) return;

    try {
      const android = AndroidInitializationSettings('@mipmap/ic_launcher');
      const ios = DarwinInitializationSettings();
      await _plugin.initialize(
        const InitializationSettings(android: android, iOS: ios),
        onDidReceiveNotificationResponse: (_) {
          NotificationCoordinator.handleNotificationOpen();
        },
      );
      _initialized = true;
    } catch (e, stack) {
      _available = false;
      if (kDebugMode) {
        debugPrint('Hydra notifications unavailable: $e\n$stack');
      }
    }
  }

  Future<bool> hasPermission() async {
    if (!isSupported) return false;
    await initialize();
    if (!_initialized) return false;

    if (defaultTargetPlatform == TargetPlatform.android) {
      final android = _plugin.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();
      return await android?.areNotificationsEnabled() ?? false;
    }

    final ios = _plugin.resolvePlatformSpecificImplementation<
        IOSFlutterLocalNotificationsPlugin>();
    if (ios != null) {
      final settings = await ios.checkPermissions();
      return settings?.isEnabled ?? false;
    }
    return true;
  }

  Future<bool> requestPermission({bool requestExactAlarms = false}) async {
    if (!isSupported) return false;
    await initialize();
    if (!_initialized) return false;

    if (defaultTargetPlatform == TargetPlatform.android) {
      final android = _plugin.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();
      return await android?.requestNotificationsPermission() ?? false;
    }

    final ios = _plugin.resolvePlatformSpecificImplementation<
        IOSFlutterLocalNotificationsPlugin>();
    if (ios != null) {
      return await ios.requestPermissions(
            alert: true,
            badge: true,
            sound: true,
          ) ??
          false;
    }
    return false;
  }

  /// Clears any legacy on-device schedules; push timing is server-side.
  Future<int> reschedule(List<ReminderSlot> slots) async {
    if (!isSupported || !_available) return 0;
    await initialize();
    if (!_initialized) return 0;

    await _plugin.cancelAll();
    if (kDebugMode) {
      debugPrint('Hydra: cleared local schedules (push-only mode)');
    }
    return 0;
  }

  Future<bool> showTestNotification() async {
    if (!kDebugMode || !isSupported || !_available) return false;
    await initialize();
    if (!_initialized) return false;

    if (!await hasPermission()) {
      final granted = await requestPermission();
      if (!granted) return false;
    }

    await _plugin.show(
      9999,
      'Hydra',
      'Notifications are working — timing comes from your server',
      _details(),
    );
    return true;
  }
}
