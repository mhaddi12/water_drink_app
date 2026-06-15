import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:water_drink_app/core/firebase/app_firebase.dart';
import 'package:water_drink_app/core/push/push_token_firestore_sync.dart';
import 'package:water_drink_app/core/session/user_timezone_firestore_sync.dart';
import 'package:water_drink_app/data/services/auth_service.dart';
import 'package:water_drink_app/features/auth/presentation/screens/auth_screen.dart';
import 'package:water_drink_app/features/focus/presentation/screens/focus_root_screen.dart';

/// Shows [AuthScreen] until Firebase Auth has a user; otherwise the main shell.
class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  bool _authTimedOut = false;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer(const Duration(seconds: 12), () {
      if (!mounted) return;
      setState(() => _authTimedOut = true);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!AppFirebase.isReady || !Get.isRegistered<AuthService>()) {
      return const _OfflineShell();
    }

    final auth = Get.find<AuthService>();
    return StreamBuilder(
      stream: auth.authStateChanges(),
      builder: (context, snapshot) {
        if (!_authTimedOut &&
            snapshot.connectionState == ConnectionState.waiting &&
            auth.currentUser == null) {
          return const _AuthBootstrapScaffold();
        }
        final user = snapshot.data ?? auth.currentUser;
        if (user != null) {
          return const _AuthenticatedHome();
        }
        return const AuthScreen();
      },
    );
  }
}

class _OfflineShell extends StatelessWidget {
  const _OfflineShell();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        MaterialBanner(
          content: const Text(
            'Cloud sync is unavailable on this device. You can still use Hydra locally.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                ScaffoldMessenger.of(context).hideCurrentMaterialBanner();
              },
              child: const Text('Dismiss'),
            ),
          ],
        ),
        const Expanded(child: FocusRootScreen()),
      ],
    );
  }
}

/// Runs push-token sync once when the user is already signed in (app reopen).
class _AuthenticatedHome extends StatefulWidget {
  const _AuthenticatedHome();

  @override
  State<_AuthenticatedHome> createState() => _AuthenticatedHomeState();
}

class _AuthenticatedHomeState extends State<_AuthenticatedHome> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      unawaited(PushTokenFirestoreSync.instance.ensureSynced());
      unawaited(UserTimezoneFirestoreSync.instance.ensureSynced());
    });
  }

  @override
  Widget build(BuildContext context) => const FocusRootScreen();
}

class _AuthBootstrapScaffold extends StatelessWidget {
  const _AuthBootstrapScaffold();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Center(
        child: CircularProgressIndicator(
          strokeWidth: 2.5,
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }
}
