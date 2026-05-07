import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:water_drink_app/app/app.dart';
import 'package:water_drink_app/core/firebase/app_firebase.dart';
import 'package:water_drink_app/data/repositories/user_repository.dart';
import 'package:water_drink_app/data/services/auth_service.dart';
import 'package:water_drink_app/features/focus/controllers/home_controller.dart';
import 'package:water_drink_app/features/focus/controllers/systems_controller.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AppFirebase.initialize();
  if (!kIsWeb) {
    MobileAds.instance.initialize();
  }
  if (AppFirebase.isReady) {
    Get.put(AuthService(), permanent: true);
    Get.put(UserRepository(), permanent: true);
  }
  Get.put(HomeController(), permanent: true);
  Get.put(SystemsController(), permanent: true);
  runApp(const WaterDrinkApp());
}
