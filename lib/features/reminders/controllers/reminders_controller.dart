import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:water_drink_app/core/session/app_session.dart';
import 'package:water_drink_app/core/session/local_profile_store.dart';
import 'package:water_drink_app/data/models/reminder_slot.dart';
import 'package:water_drink_app/data/repositories/user_repository.dart';
import 'package:water_drink_app/data/services/auth_service.dart';

class RemindersController extends GetxController {
  final slots = <ReminderSlot>[].obs;
  final reminderFrequencyHours = 2.obs;

  StreamSubscription<User?>? _authSub;
  StreamSubscription? _userSub;

  LocalProfileStore get _local => Get.find<LocalProfileStore>();

  @override
  void onInit() {
    super.onInit();
    _bind();
  }

  void applyLocalDefaults() {
    slots.assignAll(_local.reminderSlots);
    reminderFrequencyHours.value = _local.reminderFrequencyHours.value;
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
        reminderFrequencyHours.value =
            (data['reminderFrequencyHours'] as num?)?.toInt() ??
            reminderFrequencyHours.value;
        final raw = data['reminderSlots'] as List?;
        if (raw == null || raw.isEmpty) {
          slots.assignAll(
            UserRepository.defaultReminderSlots()
                .map(ReminderSlot.fromMap)
                .toList(),
          );
          return;
        }
        slots.assignAll(
          raw
              .map(
                (entry) => ReminderSlot.fromMap(Map<String, dynamic>.from(entry)),
              )
              .toList()
            ..sort((a, b) => a.order.compareTo(b.order)),
        );
      },
      onError: (_) => applyLocalDefaults(),
    );
  }

  Future<void> toggleSlot(String time, bool enabled) async {
    final index = slots.indexWhere((slot) => slot.time == time);
    if (index < 0) return;
    slots[index] = slots[index].copyWith(enabled: enabled);
    slots.refresh();
    _local.setReminderEnabled(time, enabled);

    if (!AppSession.canSync) {
      return;
    }

    try {
      await Get.find<UserRepository>().setReminderEnabled(
        AppSession.uid!,
        time: time,
        enabled: enabled,
      );
    } catch (_) {
      Get.snackbar('Hydra', 'Saved on this device only');
    }
  }

  String get scheduleSummary {
    final hours = reminderFrequencyHours.value;
    return 'Reminder schedule active every $hours hours between 8 AM and 10 PM';
  }

  @override
  void onClose() {
    _authSub?.cancel();
    _userSub?.cancel();
    super.onClose();
  }
}
