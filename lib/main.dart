import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:get/get.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:water_drink_app/app/app.dart';
import 'package:water_drink_app/core/firebase/app_firebase.dart';
import 'package:water_drink_app/core/network/connectivity_controller.dart';
import 'package:water_drink_app/core/session/local_profile_store.dart';
import 'package:water_drink_app/data/repositories/user_repository.dart';
import 'package:water_drink_app/data/services/auth_service.dart';
import 'package:water_drink_app/features/focus/controllers/home_controller.dart';
import 'package:water_drink_app/features/focus/controllers/systems_controller.dart';
import 'package:water_drink_app/features/history/controllers/history_controller.dart';
import 'package:water_drink_app/features/hydration/controllers/hydration_controller.dart';
import 'package:water_drink_app/features/reminders/controllers/reminders_controller.dart';
import 'package:water_drink_app/features/settings/controllers/settings_controller.dart';

Future<void> main() async {
  final widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);
  await AppFirebase.initialize();
  if (!kIsWeb) {
    MobileAds.instance.initialize();
  }
  if (AppFirebase.isReady) {
    Get.put(AuthService(), permanent: true);
    Get.put(UserRepository(), permanent: true);
  }
  Get.put(LocalProfileStore(), permanent: true);
  Get.put(ConnectivityController(), permanent: true);
  Get.put(HomeController(), permanent: true);
  Get.put(SystemsController(), permanent: true);
  Get.put(HydrationController(), permanent: true);
  Get.put(HistoryController(), permanent: true);
  Get.put(RemindersController(), permanent: true);
  Get.put(SettingsController(), permanent: true);
  FlutterNativeSplash.remove();
  runApp(const WaterDrinkApp());
}
