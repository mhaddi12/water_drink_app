import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:water_drink_app/app/auth_wrapper.dart';
import 'package:water_drink_app/app/theme/app_theme.dart';
import 'package:water_drink_app/features/focus/controllers/focus_nav_controller.dart';

class WaterDrinkApp extends StatelessWidget {
  const WaterDrinkApp({super.key});

  @override
  Widget build(BuildContext context) {
    if (!Get.isRegistered<FocusNavController>()) {
      Get.put(FocusNavController(), permanent: true);
    }
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Hydra',
      theme: AppTheme.lightTheme,
      home: const AuthWrapper(),
    );
  }
}
