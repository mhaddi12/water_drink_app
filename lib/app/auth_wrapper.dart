import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:water_drink_app/core/firebase/app_firebase.dart';
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
          return const FocusRootScreen();
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

class _AuthBootstrapScaffold extends StatelessWidget {
  const _AuthBootstrapScaffold();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Color(0xFFF1F2F7),
      body: Center(
        child: SizedBox(
          width: 28,
          height: 28,
          child: CircularProgressIndicator(
            strokeWidth: 2.5,
            color: Color(0xFF0A2C88),
          ),
        ),
      ),
    );
  }
}
