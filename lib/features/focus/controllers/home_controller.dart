import 'package:get/get.dart';

class HomeController extends GetxController {
  final activeProgress = 0.75.obs;
  final currentSessionProgress = 0.40.obs;
  final streakDays = 12.obs;
  final focusHours = 4.5.obs;

  String get activeProgressText => '${(activeProgress.value * 100).round()}%';
  String get sessionRemainingText =>
      '${((1 - currentSessionProgress.value) * 60).round()}m left';
}
