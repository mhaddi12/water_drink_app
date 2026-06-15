import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:water_drink_app/core/session/local_profile_store.dart';
import 'package:water_drink_app/core/push/onesignal_service.dart';
import 'package:water_drink_app/core/push/push_token_firestore_sync.dart';
import 'package:water_drink_app/core/reminders/reminder_notification_service.dart';
import 'package:water_drink_app/core/reminders/reminder_schedule_helper.dart';
import 'package:water_drink_app/data/models/reminder_slot.dart';
import 'package:water_drink_app/features/focus/controllers/focus_nav_controller.dart';

/// Push notifications (OneSignal + your backend). No local 3h/3min schedules.
class NotificationCoordinator extends GetxService with WidgetsBindingObserver {
  final permissionGranted = false.obs;
  final pushOptedIn = false.obs;
  final pushSubscriptionId = RxnString();
  final pushRemindersEnabled = false.obs;
  final statusSummary = 'Checking notifications…'.obs;
  final nextAlarmLabel = 'Reminders off'.obs;

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
    scheduleMicrotask(refreshStatus);
  }

  @override
  void onClose() {
    WidgetsBinding.instance.removeObserver(this);
    super.onClose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      unawaited(refreshStatus());
    }
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

    if (Get.isRegistered<LocalProfileStore>()) {
      final enabled = Get.find<LocalProfileStore>()
          .reminderSlots
          .any((slot) => slot.enabled);
      pushRemindersEnabled.value = enabled;
      updateNextAlarmLabel(Get.find<LocalProfileStore>().reminderSlots.toList());
    }

    _updateSummary();
  }

  void updateNextAlarmLabel(List<ReminderSlot> slots) {
    nextAlarmLabel.value = ReminderScheduleHelper.nextLabel(slots);
  }

  void _updateSummary() {
    if (!permissionGranted.value) {
      statusSummary.value = 'Allow notifications to receive hydration alerts';
      return;
    }
    if (!pushRemindersEnabled.value) {
      statusSummary.value = 'Reminders off · turn on to register for push';
      return;
    }
    final push = pushOptedIn.value ? 'Device registered' : 'Enable push in settings';
    statusSummary.value = 'Push reminders on · $push';
  }

  Future<void> applySchedule(List<ReminderSlot> slots) async {
    final sorted = ReminderScheduleHelper.sortByTime(slots);
    final enabled = sorted.any((slot) => slot.enabled);
    pushRemindersEnabled.value = enabled;
    updateNextAlarmLabel(sorted);

    await ReminderNotificationService.instance.reschedule(sorted);

    await OneSignalService.instance.syncReminderPreferences(
      reminderCount: 1,
      enabledCount: enabled ? 1 : 0,
    );

    if (enabled) {
      await PushTokenFirestoreSync.instance.ensureSynced();
    }

    await refreshStatus();
  }

  Future<bool> requestPermissions() async {
    await ReminderNotificationService.instance.initialize();
    var granted = await ReminderNotificationService.instance.requestPermission();

    if (OneSignalService.isSupported) {
      await OneSignalService.instance.requestPushPermission();
      await PushTokenFirestoreSync.instance.ensureSynced();
      await refreshStatus();
      granted = granted || permissionGranted.value;
    } else {
      await refreshStatus();
    }

    return granted;
  }

  Future<void> showTestReminder() async {
    final shown = await ReminderNotificationService.instance.showTestNotification();
    if (!shown) {
      Get.snackbar('Hydra', 'Could not show test notification');
      return;
    }
    Get.snackbar('Hydra', 'Test notification sent');
  }

  static void handleNotificationOpen() {
    if (Get.isRegistered<FocusNavController>()) {
      Get.find<FocusNavController>().goWater();
    }
  }
}
