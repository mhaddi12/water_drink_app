import 'package:get/get.dart';
import 'package:water_drink_app/core/session/local_profile_store.dart';
import 'package:water_drink_app/features/focus/controllers/home_controller.dart';
import 'package:water_drink_app/features/focus/controllers/systems_controller.dart';
import 'package:water_drink_app/features/history/controllers/history_controller.dart';
import 'package:water_drink_app/features/hydration/controllers/hydration_controller.dart';
import 'package:water_drink_app/features/reminders/controllers/reminders_controller.dart';
import 'package:water_drink_app/features/settings/controllers/settings_controller.dart';

abstract final class SessionReset {
  static void afterSignOut() {
    if (Get.isRegistered<LocalProfileStore>()) {
      Get.find<LocalProfileStore>().reset();
    }
    if (Get.isRegistered<HomeController>()) {
      Get.find<HomeController>().resetForSignOut();
    }
    if (Get.isRegistered<SystemsController>()) {
      Get.find<SystemsController>().applyLocalDefaults();
    }
    if (Get.isRegistered<HydrationController>()) {
      Get.find<HydrationController>().applyLocalDefaults();
    }
    if (Get.isRegistered<HistoryController>()) {
      Get.find<HistoryController>().applyLocalDefaults();
    }
    if (Get.isRegistered<RemindersController>()) {
      Get.find<RemindersController>().applyLocalDefaults();
    }
    if (Get.isRegistered<SettingsController>()) {
      Get.find<SettingsController>().applyLocalDefaults();
    }
  }
}
