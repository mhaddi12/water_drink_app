import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:water_drink_app/features/focus/controllers/focus_nav_controller.dart';
import 'package:water_drink_app/features/focus/presentation/screens/focus_home_screen.dart';
import 'package:water_drink_app/features/focus/presentation/screens/focus_sessions_screen.dart';
import 'package:water_drink_app/features/focus/presentation/screens/stats_screen.dart';
import 'package:water_drink_app/features/focus/presentation/screens/systems_screen.dart';
import 'package:water_drink_app/features/focus/presentation/widgets/test_banner_ad.dart';
import 'package:water_drink_app/features/hydration/presentation/screens/hydration_home_screen.dart';

class FocusRootScreen extends GetView<FocusNavController> {
  const FocusRootScreen({super.key});

  static const _pages = [
    FocusHomeScreen(),
    SystemsScreen(),
    FocusSessionsScreen(),
    StatsScreen(),
    HydrationHomeScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Scaffold(
        backgroundColor: const Color(0xFFF1F2F7),
        body: _pages[controller.selectedIndex.value],
        bottomNavigationBar: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const TestBannerAd(),
            NavigationBar(
              selectedIndex: controller.selectedIndex.value,
              onDestinationSelected: controller.setTab,
              destinations: const [
                NavigationDestination(
                  icon: Icon(Icons.home_filled),
                  label: 'HOME',
                ),
                NavigationDestination(
                  icon: Icon(Icons.grid_view_rounded),
                  label: 'SYSTEMS',
                ),
                NavigationDestination(
                  icon: Icon(Icons.timer_outlined),
                  label: 'FOCUS',
                ),
                NavigationDestination(
                  icon: Icon(Icons.assessment_outlined),
                  label: 'STATS',
                ),
                NavigationDestination(
                  icon: Icon(Icons.water_drop_outlined),
                  selectedIcon: Icon(Icons.water_drop),
                  label: 'WATER',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
