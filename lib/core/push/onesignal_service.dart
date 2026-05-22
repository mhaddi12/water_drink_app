import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:water_drink_app/core/notifications/notification_coordinator.dart';
import 'package:water_drink_app/data/services/auth_service.dart';

/// OneSignal App ID — Settings → Keys & IDs in the OneSignal dashboard.
const String kOneSignalAppId = 'bf972d12-cf11-4055-9f52-450a94584f45';

class OneSignalService {
  OneSignalService._();

  static final OneSignalService instance = OneSignalService._();

  bool _initialized = false;
  StreamSubscription<User?>? _authSub;

  static bool get isSupported =>
      !kIsWeb &&
      (defaultTargetPlatform == TargetPlatform.android ||
          defaultTargetPlatform == TargetPlatform.iOS);

  bool get isReady => _initialized;

  bool get isPushOptedIn => OneSignal.User.pushSubscription.optedIn ?? false;

  String? get subscriptionId => OneSignal.User.pushSubscription.id;

  Future<void> initialize() async {
    if (!isSupported || _initialized) return;

    try {
      if (kDebugMode) {
        OneSignal.Debug.setLogLevel(OSLogLevel.verbose);
        OneSignal.Debug.setAlertLevel(OSLogLevel.none);
      }

      OneSignal.initialize(kOneSignalAppId);

      OneSignal.Notifications.addClickListener((_) {
        NotificationCoordinator.handleNotificationOpen();
      });

      await requestPushPermission();
      _initialized = true;

      if (kDebugMode) {
        debugPrint('OneSignal push subscription id: $subscriptionId');
        debugPrint('OneSignal opted in: $isPushOptedIn');
      }
    } catch (e, stack) {
      if (kDebugMode) {
        debugPrint('OneSignal init failed: $e\n$stack');
      }
    }
  }

  Future<void> requestPushPermission() async {
    if (!isSupported) return;
    try {
      await OneSignal.Notifications.requestPermission(true);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('OneSignal permission request failed: $e');
      }
    }
  }

  Future<void> syncReminderPreferences({
    required int reminderCount,
    required int enabledCount,
  }) async {
    if (!_initialized) return;
    try {
      await OneSignal.User.addTags({
        'reminders_total_count': '$reminderCount',
        'reminders_enabled_count': '$enabledCount',
        'hydration_reminders_on': enabledCount > 0 ? 'true' : 'false',
      });
    } catch (e) {
      if (kDebugMode) {
        debugPrint('OneSignal tag sync failed: $e');
      }
    }
  }

  void bindAuth(AuthService auth) {
    if (!isSupported || !_initialized) return;

    _authSub?.cancel();
    _authSub = auth.authStateChanges().listen(_onAuthUser);
    _onAuthUser(auth.currentUser);
  }

  void _onAuthUser(User? user) {
    if (!_initialized) return;
    try {
      if (user == null) {
        OneSignal.logout();
        return;
      }
      OneSignal.login(user.uid);
      if (kDebugMode) {
        debugPrint('OneSignal login external id: ${user.uid}');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('OneSignal auth sync failed: $e');
      }
    }
  }

  void dispose() {
    _authSub?.cancel();
    _authSub = null;
  }
}
