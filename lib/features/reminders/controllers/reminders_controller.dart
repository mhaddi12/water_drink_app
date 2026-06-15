import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:water_drink_app/core/notifications/notification_coordinator.dart';
import 'package:water_drink_app/core/reminders/reminder_schedule_helper.dart';
import 'package:water_drink_app/core/session/app_session.dart';
import 'package:water_drink_app/core/session/local_profile_store.dart';
import 'package:water_drink_app/data/models/reminder_slot.dart';
import 'package:water_drink_app/data/repositories/user_repository.dart';
import 'package:water_drink_app/data/services/auth_service.dart';
import 'package:water_drink_app/features/hydration/controllers/hydration_controller.dart';

class RemindersController extends GetxController {
  final slots = <ReminderSlot>[].obs;

  StreamSubscription<User?>? _authSub;
  StreamSubscription? _userSub;

  NotificationCoordinator get _notifications => NotificationCoordinator.instance;

  LocalProfileStore get _local => Get.find<LocalProfileStore>();

  bool get permissionGranted => _notifications.permissionGranted.value;
  bool get pushOptedIn => _notifications.pushOptedIn.value;
  String get statusSummary => _notifications.statusSummary.value;
  String get nextAlarmLabel => _notifications.nextAlarmLabel.value;
  bool get remindersEnabled => slots.any((slot) => slot.enabled);

  @override
  void onInit() {
    super.onInit();
    _bind();
    scheduleMicrotask(_notifications.refreshStatus);
  }

  void applyLocalDefaults() {
    final local = _local.reminderSlots;
    slots.assignAll(
      ReminderScheduleHelper.normalizeSlots(
        local.isEmpty ? null : local.toList(),
      ),
    );
    scheduleMicrotask(_applySchedule);
  }

  void _bind() {
    if (!AppSession.hasCloud) {
      applyLocalDefaults();
      return;
    }

    final auth = Get.find<AuthService>();
    _authSub?.cancel();
    _authSub = auth.authStateChanges().listen((user) async {
      final uid = user?.uid;
      if (uid == null) {
        _userSub?.cancel();
        applyLocalDefaults();
        return;
      }
      final seeded = await AppSession.ensureUserSeed();
      if (!seeded) {
        applyLocalDefaults();
        return;
      }
      _listenUser(uid);
    });
  }

  void _listenUser(String uid) {
    if (!Get.isRegistered<UserRepository>()) return;
    _userSub?.cancel();
    _userSub = Get.find<UserRepository>().watchUser(uid).listen(
      (snap) {
        final data = snap.data();
        if (data == null) return;

        final raw = data['reminderSlots'] as List?;
        final parsed = raw == null || raw.isEmpty
            ? null
            : raw
                .map(
                  (entry) => ReminderSlot.fromMap(
                    Map<String, dynamic>.from(entry),
                  ),
                )
                .toList();
        slots.assignAll(ReminderScheduleHelper.normalizeSlots(parsed));
        _local.reminderSlots.assignAll(slots);
        _syncHydrationReminderLabel();
        unawaited(_applySchedule());
      },
      onError: (_) => applyLocalDefaults(),
    );
  }

  Future<void> setRemindersEnabled(bool enabled) async {
    if (enabled && !permissionGranted) {
      final granted = await _notifications.requestPermissions();
      if (!granted) {
        Get.snackbar('Hydra', 'Enable notifications to turn reminders on');
        return;
      }
    }

    slots.assignAll(ReminderScheduleHelper.pushPreference(enabled: enabled));
    await persistSlots();
    Get.snackbar(
      'Hydra',
      enabled
          ? 'Push reminders on · your server controls timing'
          : 'Push reminders turned off',
    );
  }

  Future<void> persistSlots() async {
    slots.assignAll(ReminderScheduleHelper.normalizeSlots(slots.toList()));
    _local.reminderSlots.assignAll(slots);
    _syncHydrationReminderLabel();
    await _applySchedule();

    if (!AppSession.canSync) return;
    try {
      await Get.find<UserRepository>().updateReminderSlots(
        AppSession.uid!,
        slots,
      );
    } catch (_) {
      Get.snackbar('Hydra', 'Saved on this device only');
    }
  }

  Future<void> requestPermissions() async {
    final granted = await _notifications.requestPermissions();
    if (granted) {
      if (!remindersEnabled) {
        await setRemindersEnabled(true);
      } else {
        await _applySchedule();
      }
      Get.snackbar('Hydra', 'Ready for push reminders from your server');
    } else {
      Get.snackbar(
        'Hydra',
        'Allow notifications in system settings',
      );
    }
  }

  Future<void> sendTestNotification() async {
    await _notifications.showTestReminder();
  }

  Future<void> refreshNotificationStatus() => _notifications.refreshStatus();

  Future<void> _applySchedule() async {
    await _notifications.applySchedule(slots);
  }

  void _syncHydrationReminderLabel() {
    if (!Get.isRegistered<HydrationController>()) return;
    Get.find<HydrationController>().refreshReminderLabel(slots);
  }

  @override
  void onClose() {
    _authSub?.cancel();
    _userSub?.cancel();
    super.onClose();
  }
}
