import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:water_drink_app/app/widgets/internet_connection_banner.dart';
import 'package:water_drink_app/app/auth_wrapper.dart';
import 'package:water_drink_app/app/theme/app_theme.dart';
import 'package:water_drink_app/features/focus/controllers/focus_nav_controller.dart';
import 'package:water_drink_app/features/settings/controllers/settings_controller.dart';

class WaterDrinkApp extends StatelessWidget {
  const WaterDrinkApp({super.key});

  @override
  Widget build(BuildContext context) {
    if (!Get.isRegistered<FocusNavController>()) {
      Get.put(FocusNavController(), permanent: true);
    }

    return Obx(() {
      final themeMode = Get.isRegistered<SettingsController>() &&
              Get.find<SettingsController>().theme.value == 'dark'
          ? ThemeMode.dark
          : ThemeMode.light;

      return GetMaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Hydra',
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: themeMode,
        home: const AuthWrapper(),
        builder: (context, child) {
          return Column(
            children: [
              const InternetConnectionBanner(),
              Expanded(child: child ?? const SizedBox.shrink()),
            ],
          );
        },
      );
    });
  }
}
