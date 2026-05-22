import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:water_drink_app/app/widgets/hydra_app_drawer.dart';
import 'package:water_drink_app/features/focus/controllers/focus_nav_controller.dart';
import 'package:water_drink_app/features/focus/presentation/screens/focus_home_screen.dart';
import 'package:water_drink_app/features/focus/presentation/screens/focus_sessions_screen.dart';
import 'package:water_drink_app/features/focus/presentation/screens/stats_screen.dart';
import 'package:water_drink_app/features/focus/presentation/screens/systems_screen.dart';
import 'package:water_drink_app/features/focus/presentation/widgets/hydra_banner_ad.dart';
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

  static const _bannerTabIndexes = {0, 4};

  @override
  Widget build(BuildContext context) {
    return Obx(
      () {
        final selectedIndex = controller.selectedIndex.value;
        final showBanner = _bannerTabIndexes.contains(selectedIndex);

        return Scaffold(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          drawer: const HydraAppDrawer(),
          body: Column(
            children: [
              Expanded(child: _pages[selectedIndex]),
              SafeArea(
                top: false,
                child: HydraBannerAd(visible: showBanner),
              ),
            ],
          ),
        );
      },
    );
  }
}
