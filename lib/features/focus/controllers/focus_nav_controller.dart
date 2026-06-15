import 'package:get/get.dart';

class FocusNavController extends GetxController {
  static const int homeTab = 0;
  static const int systemsTab = 1;
  static const int waterTab = 2;
  static const int settingsTab = 3;

  final selectedIndex = 0.obs;

  void setTab(int index) {
    if (index < 0 || index > settingsTab) return;
    selectedIndex.value = index;
  }

  void goHome() => setTab(homeTab);
  void goSystems() => setTab(systemsTab);
  void goWater() => setTab(waterTab);
  void goSettings() => setTab(settingsTab);
}
