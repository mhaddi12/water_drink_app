import 'package:get/get.dart';
import 'package:water_drink_app/core/firebase/app_firebase.dart';
import 'package:water_drink_app/core/network/connectivity_controller.dart';
import 'package:water_drink_app/data/repositories/user_repository.dart';
import 'package:water_drink_app/data/services/auth_service.dart';

abstract final class AppSession {
  static bool get hasCloud =>
      AppFirebase.isReady &&
      Get.isRegistered<AuthService>() &&
      Get.isRegistered<UserRepository>();

  static bool get isOnline {
    if (!Get.isRegistered<ConnectivityController>()) return true;
    return Get.find<ConnectivityController>().isOnline.value;
  }

  static String? get uid =>
      hasCloud ? Get.find<AuthService>().currentUid : null;

  static bool get canSync => hasCloud && uid != null && isOnline;

  static Future<bool> ensureUserSeed() async {
    if (!canSync) return false;
    final userId = uid;
    if (userId == null) return false;
    try {
      await Get.find<UserRepository>().ensureSeed(userId);
      return true;
    } catch (_) {
      return false;
    }
  }
}
