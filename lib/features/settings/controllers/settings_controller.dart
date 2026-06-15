import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:water_drink_app/core/firebase/app_firebase.dart';
import 'package:water_drink_app/core/session/app_session.dart';
import 'package:water_drink_app/core/session/local_profile_store.dart';
import 'package:water_drink_app/core/session/sign_out_helper.dart';
import 'package:water_drink_app/data/repositories/user_repository.dart';
import 'package:water_drink_app/data/services/auth_service.dart';
import 'package:water_drink_app/features/auth/presentation/screens/auth_screen.dart';
import 'package:water_drink_app/features/hydration/controllers/hydration_controller.dart';

class SettingsController extends GetxController {
  final displayName = 'Hydra user'.obs;
  final hydrationGoalMl = 3000.obs;
  final reminderFrequencyHours = 0.obs;
  final theme = 'light'.obs;
  final appVersionLabel = '1.0.0'.obs;
  final accountHint = 'Not signed in'.obs;
  final isSignedIn = false.obs;

  StreamSubscription<User?>? _authSub;
  StreamSubscription? _userSub;

  LocalProfileStore get _local => Get.find<LocalProfileStore>();

  @override
  void onInit() {
    super.onInit();
    _loadAppVersion();
    applyLocalDefaults();
    _bind();
  }

  Future<void> _loadAppVersion() async {
    final info = await PackageInfo.fromPlatform();
    appVersionLabel.value = '${info.version}+${info.buildNumber}';
  }

  void applyLocalDefaults() {
    displayName.value = _local.displayName.value;
    hydrationGoalMl.value = _local.hydrationGoalMl.value;
    reminderFrequencyHours.value = _local.reminderFrequencyHours.value;
    theme.value = _local.theme.value;
    _refreshAccountHint();
  }

  void _refreshAccountHint() {
    if (!AppFirebase.isReady) {
      accountHint.value = 'Offline mode on this device';
      isSignedIn.value = false;
      return;
    }
    if (!Get.isRegistered<AuthService>()) {
      accountHint.value = 'Cloud sync unavailable';
      isSignedIn.value = false;
      return;
    }
    final user = Get.find<AuthService>().currentUser;
    isSignedIn.value = user != null;
    if (user == null) {
      accountHint.value = 'Not signed in';
      return;
    }
    if (user.isAnonymous) {
      accountHint.value = 'Guest · sign in to sync with email';
      return;
    }
    accountHint.value = user.email ?? 'Signed in';
  }

  void _bind() {
    if (!AppSession.hasCloud) return;

    final auth = Get.find<AuthService>();
    _authSub?.cancel();
    _authSub = auth.authStateChanges().listen((user) async {
      _refreshAccountHint();
      final uid = user?.uid;
      if (uid == null) {
        _userSub?.cancel();
        applyLocalDefaults();
        return;
      }
      final seeded = await AppSession.ensureUserSeed();
      if (!seeded) {
        applyLocalDefaults();
        return;
      }
      _listenUser(uid);
    });
  }

  void _listenUser(String uid) {
    if (!Get.isRegistered<UserRepository>()) return;
    _userSub?.cancel();
    _userSub = Get.find<UserRepository>().watchUser(uid).listen(
      (snap) {
        final data = snap.data();
        if (data == null) return;
        displayName.value = data['displayName'] as String? ?? displayName.value;
        hydrationGoalMl.value =
            (data['hydrationGoalMl'] as num?)?.toInt() ?? hydrationGoalMl.value;
        theme.value = data['theme'] as String? ?? theme.value;
        _syncLocalFromState();
      },
      onError: (_) => applyLocalDefaults(),
    );
  }

  void _syncLocalFromState() {
    _local.displayName.value = displayName.value;
    _local.hydrationGoalMl.value = hydrationGoalMl.value;
    _local.theme.value = theme.value;
  }

  String get goalLabel => '${_formatMl(hydrationGoalMl.value)} ml/day';

  String get themeLabel => theme.value == 'dark' ? 'Dark' : 'Light';

  Future<void> signOut() async {
    final context = Get.context;
    if (context == null) return;
    await SignOutHelper.confirmAndSignOut(context);
  }

  void openSignIn() {
    Get.to(() => const AuthScreen());
  }

  Future<void> editDailyGoal() async {
    final context = Get.context;
    if (context == null) return;
    final controller = TextEditingController(
      text: hydrationGoalMl.value.toString(),
    );
    final result = await showDialog<int>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Daily goal'),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: 'Goal (ml)',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              final value = int.tryParse(controller.text.trim());
              Navigator.pop(dialogContext, value);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
    if (result == null || result < 250 || result > 10000) {
      if (result != null) {
        Get.snackbar('Hydra', 'Enter a goal between 250 and 10,000 ml');
      }
      return;
    }
    await _saveSettings(hydrationGoalMl: result);
  }

  Future<void> toggleTheme() async {
    final next = theme.value == 'light' ? 'dark' : 'light';
    await _saveSettings(theme: next);
  }

  Future<void> editDisplayName() async {
    final context = Get.context;
    if (context == null) return;
    final controller = TextEditingController(text: displayName.value);
    final result = await showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Display name'),
        content: TextField(
          controller: controller,
          textCapitalization: TextCapitalization.words,
          decoration: const InputDecoration(
            labelText: 'Name',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, controller.text.trim()),
            child: const Text('Save'),
          ),
        ],
      ),
    );
    if (result == null || result.isEmpty) return;
    await _saveSettings(displayName: result);
  }

  Future<void> _saveSettings({
    String? displayName,
    int? hydrationGoalMl,
    String? theme,
  }) async {
    if (displayName != null) {
      this.displayName.value = displayName;
      _local.displayName.value = displayName;
    }
    if (hydrationGoalMl != null) {
      this.hydrationGoalMl.value = hydrationGoalMl;
      _local.hydrationGoalMl.value = hydrationGoalMl;
      if (Get.isRegistered<HydrationController>()) {
        Get.find<HydrationController>().goalMl.value = hydrationGoalMl;
      }
    }
    if (theme != null) {
      this.theme.value = theme;
      _local.theme.value = theme;
    }

    if (!AppSession.canSync) {
      Get.snackbar('Hydra', 'Saved on this device');
      return;
    }

    try {
      await Get.find<UserRepository>().updateProfileSettings(
        AppSession.uid!,
        displayName: displayName,
        hydrationGoalMl: hydrationGoalMl,
        theme: theme,
      );
      Get.snackbar('Hydra', 'Settings saved to your profile');
    } catch (_) {
      Get.snackbar('Hydra', 'Saved on this device only');
    }
  }

  static String _formatMl(int value) {
    final text = value.toString();
    return text.replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (match) => '${match[1]},',
    );
  }

  @override
  void onClose() {
    _authSub?.cancel();
    _userSub?.cancel();
    super.onClose();
  }
}
