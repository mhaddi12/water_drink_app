import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:water_drink_app/core/session/app_session.dart';
import 'package:water_drink_app/core/session/local_profile_store.dart';
import 'package:water_drink_app/core/reminders/reminder_schedule_helper.dart';
import 'package:water_drink_app/data/models/hydration_intake.dart';
import 'package:water_drink_app/data/models/reminder_slot.dart';
import 'package:water_drink_app/data/repositories/user_repository.dart';
import 'package:water_drink_app/data/services/auth_service.dart';

class HydrationController extends GetxController {
  final goalMl = 3000.obs;
  final displayName = 'Hydra user'.obs;
  final todayIntakes = <HydrationIntake>[].obs;
  final nextReminderText = 'No reminders enabled'.obs;

  StreamSubscription<List<HydrationIntake>>? _intakesSub;
  StreamSubscription<User?>? _authSub;
  StreamSubscription? _userSub;

  LocalProfileStore get _local => Get.find<LocalProfileStore>();

  int get currentMl => todayIntakes.fold(0, (sum, intake) => sum + intake.amountMl);

  @override
  void onInit() {
    super.onInit();
    _bind();
  }

  void applyLocalDefaults() {
    goalMl.value = _local.hydrationGoalMl.value;
    displayName.value = _local.displayName.value;
    nextReminderText.value = _local.nextReminderLabel();
    todayIntakes.assignAll(_local.todayIntakes);
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
        _intakesSub?.cancel();
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
      _listenTodayIntakes(uid);
    });
  }

  void _listenUser(String uid) {
    if (!Get.isRegistered<UserRepository>()) return;
    _userSub?.cancel();
    _userSub = Get.find<UserRepository>().watchUser(uid).listen(
      (snap) {
        final data = snap.data();
        if (data == null) return;
        goalMl.value = (data['hydrationGoalMl'] as num?)?.toInt() ?? goalMl.value;
        displayName.value = data['displayName'] as String? ?? displayName.value;
        nextReminderText.value = _nextReminderLabel(data['reminderSlots'] as List?);
        _syncLocalReminderSlots(data['reminderSlots'] as List?);
      },
      onError: (_) => applyLocalDefaults(),
    );
  }

  void _listenTodayIntakes(String uid) {
    if (!Get.isRegistered<UserRepository>()) return;
    _intakesSub?.cancel();
    final now = DateTime.now();
    final start = DateTime(now.year, now.month, now.day);
    _intakesSub = Get.find<UserRepository>()
        .watchHydrationIntakes(uid, since: start)
        .listen(
          todayIntakes.assignAll,
          onError: (_) => applyLocalDefaults(),
        );
  }

  Future<void> addWater(int amountMl) async {
    if (amountMl <= 0) return;

    if (!AppSession.canSync) {
      _local.addIntake(amountMl);
      applyLocalDefaults();
      return;
    }

    try {
      await Get.find<UserRepository>().addHydrationIntake(
        AppSession.uid!,
        amountMl,
      );
    } catch (_) {
      _local.addIntake(amountMl);
      applyLocalDefaults();
      Get.snackbar('Hydra', 'Saved on this device only');
    }
  }

  String greeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning';
    if (hour < 17) return 'Good afternoon';
    return 'Good evening';
  }

  void refreshReminderLabel(List<ReminderSlot> slots) {
    nextReminderText.value = ReminderScheduleHelper.nextLabel(slots);
  }

  void _syncLocalReminderSlots(List<dynamic>? raw) {
    final parsed = raw == null || raw.isEmpty
        ? null
        : raw
            .map((entry) => ReminderSlot.fromMap(Map<String, dynamic>.from(entry)))
            .toList();
    _local.reminderSlots.assignAll(ReminderScheduleHelper.normalizeSlots(parsed));
  }

  static String _nextReminderLabel(List<dynamic>? raw) {
    final parsed = raw == null || raw.isEmpty
        ? null
        : raw
            .map((entry) => ReminderSlot.fromMap(Map<String, dynamic>.from(entry)))
            .toList();
    return ReminderScheduleHelper.nextLabel(
      ReminderScheduleHelper.normalizeSlots(parsed),
    );
  }

  @override
  void onClose() {
    _authSub?.cancel();
    _intakesSub?.cancel();
    _userSub?.cancel();
    super.onClose();
  }
}
