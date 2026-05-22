import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:water_drink_app/core/session/local_profile_store.dart';
import 'package:water_drink_app/core/push/onesignal_service.dart';
import 'package:water_drink_app/core/reminders/reminder_notification_service.dart';
import 'package:water_drink_app/core/reminders/reminder_schedule_helper.dart';
import 'package:water_drink_app/data/models/reminder_slot.dart';
import 'package:water_drink_app/features/focus/controllers/focus_nav_controller.dart';

/// Coordinates local scheduled reminders and OneSignal push subscription state.
class NotificationCoordinator extends GetxService with WidgetsBindingObserver {
  final permissionGranted = false.obs;
  final pushOptedIn = false.obs;
  final pushSubscriptionId = RxnString();
  final localRemindersActive = 0.obs;
  final statusSummary = 'Checking notifications…'.obs;
  final nextAlarmLabel = 'No reminders set'.obs;

  static NotificationCoordinator get instance {
    if (!Get.isRegistered<NotificationCoordinator>()) {
      Get.put(NotificationCoordinator(), permanent: true);
    }
    return Get.find<NotificationCoordinator>();
  }

  @override
  void onInit() {
    super.onInit();
    WidgetsBinding.instance.addObserver(this);
    scheduleMicrotask(() async {
      await refreshStatus();
      await topUpScheduleFromLocal();
    });
  }

  @override
  void onClose() {
    WidgetsBinding.instance.removeObserver(this);
    super.onClose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      unawaited(topUpScheduleFromLocal());
    }
  }

  /// Re-applies the local reminder schedule (needed for 3‑minute test alarms).
  Future<void> topUpScheduleFromLocal() async {
    if (!Get.isRegistered<LocalProfileStore>()) return;
    final slots = Get.find<LocalProfileStore>().reminderSlots.toList();
    if (!slots.any((slot) => slot.enabled)) return;
    await applySchedule(slots);
  }

  Future<void> refreshStatus() async {
    if (!ReminderNotificationService.isSupported) {
      statusSummary.value = 'Notifications not supported on this platform';
      return;
    }

    await ReminderNotificationService.instance.initialize();
    permissionGranted.value =
        await ReminderNotificationService.instance.hasPermission();

    if (OneSignalService.isSupported && OneSignalService.instance.isReady) {
      pushOptedIn.value = OneSignalService.instance.isPushOptedIn;
      pushSubscriptionId.value = OneSignalService.instance.subscriptionId;
    } else {
      pushOptedIn.value = false;
      pushSubscriptionId.value = null;
    }

    _updateSummary();
  }

  void updateNextAlarmLabel(List<ReminderSlot> slots) {
    nextAlarmLabel.value = ReminderScheduleHelper.nextLabel(slots);
  }

  void _updateSummary() {
    final local = localRemindersActive.value;
    if (!permissionGranted.value) {
      statusSummary.value = 'Tap Enable below to turn on hydration alarms';
      return;
    }
    if (local == 0) {
      statusSummary.value =
          'Reminders off · turn on for ${ReminderScheduleHelper.intervalLabel}';
      return;
    }
    final push = pushOptedIn.value ? 'Push on' : 'Push optional';
    final interval = ReminderScheduleHelper.intervalLabel;
    statusSummary.value = 'Every $interval · $push';
  }

  Future<void> applySchedule(List<ReminderSlot> slots) async {
    final sorted = ReminderScheduleHelper.sortByTime(slots);
    final enabled = sorted.any((slot) => slot.enabled);
    localRemindersActive.value = enabled
        ? (ReminderScheduleHelper.useFastReminders
            ? ReminderScheduleHelper.debugPendingNotifications
            : sorted.where((slot) => slot.enabled).length)
        : 0;
    updateNextAlarmLabel(sorted);
    final scheduled = await ReminderNotificationService.instance.reschedule(sorted);
    if (kDebugMode && enabled && scheduled == 0) {
      debugPrint('Hydra: no notifications were scheduled — check permissions');
    }
    await OneSignalService.instance.syncReminderPreferences(
      reminderCount: sorted.length,
      enabledCount: localRemindersActive.value,
    );
    await refreshStatus();
  }

  Future<bool> requestPermissions() async {
    await ReminderNotificationService.instance.initialize();
    var granted = await ReminderNotificationService.instance.requestPermission(
      requestExactAlarms: true,
    );

    if (OneSignalService.isSupported) {
      await OneSignalService.instance.requestPushPermission();
      await refreshStatus();
      granted = granted || permissionGranted.value;
    } else {
      await refreshStatus();
    }

    return granted;
  }

  Future<void> showTestReminder() async {
    if (!ReminderScheduleHelper.useFastReminders) return;
    final shown = await ReminderNotificationService.instance.showTestNotification();
    if (!shown) {
      Get.snackbar('Hydra', 'Could not show test notification');
      return;
    }
    Get.snackbar('Hydra', 'Test alarm sent');
  }

  static void handleNotificationOpen() {
    if (Get.isRegistered<FocusNavController>()) {
      Get.find<FocusNavController>().setTab(4);
    }
  }
}
