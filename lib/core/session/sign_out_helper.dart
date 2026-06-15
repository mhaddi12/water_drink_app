import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:water_drink_app/core/firebase/app_firebase.dart';
import 'package:water_drink_app/core/push/onesignal_service.dart';
import 'package:water_drink_app/core/push/push_token_firestore_sync.dart';
import 'package:water_drink_app/core/session/session_reset.dart';
import 'package:water_drink_app/data/services/auth_service.dart';

abstract final class SignOutHelper {
  static Future<bool> confirmAndSignOut(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Sign out?'),
        content: const Text(
          'Your data stays in the cloud. Sign in again anytime to sync on this device.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFFC62828),
              foregroundColor: Colors.white,
            ),
            child: const Text('Sign out'),
          ),
        ],
      ),
    );

    if (confirmed != true) return false;
    if (!context.mounted) return false;

    final navigator = Navigator.of(context);
    if (navigator.canPop()) {
      navigator.popUntil((route) => route.isFirst);
    }

    await perform();
    return true;
  }

  static Future<void> perform() async {
    final navigator = Get.key.currentState;
    if (navigator != null) {
      while (navigator.canPop()) {
        navigator.pop();
      }
    }

    try {
      await PushTokenFirestoreSync.instance.clearCurrentDevice();
    } catch (_) {}

    try {
      if (AppFirebase.isReady && Get.isRegistered<AuthService>()) {
        await Get.find<AuthService>().signOut();
      }
    } catch (_) {}

    if (OneSignalService.isSupported) {
      try {
        OneSignal.logout();
      } catch (_) {}
    }

    SessionReset.afterSignOut();
    Get.closeAllSnackbars();
    Get.snackbar('Hydra', 'Signed out');
  }
}
