import 'package:get/get.dart';

class FocusNavController extends GetxController {
  final selectedIndex = 0.obs;

  void setTab(int index) {
    selectedIndex.value = index;
  }
}
