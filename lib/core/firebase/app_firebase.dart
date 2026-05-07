import 'package:firebase_core/firebase_core.dart';
import 'package:water_drink_app/firebase_options.dart';

/// Central flag so UI/controllers can skip Firebase when unavailable (e.g. Linux, tests).
class AppFirebase {
  AppFirebase._();

  static bool isReady = false;

  static Future<void> initialize() async {
    try {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
      isReady = true;
    } catch (_) {
      isReady = false;
    }
  }
}
