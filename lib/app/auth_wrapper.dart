import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:water_drink_app/core/firebase/app_firebase.dart';
import 'package:water_drink_app/data/services/auth_service.dart';
import 'package:water_drink_app/features/auth/presentation/screens/auth_screen.dart';
import 'package:water_drink_app/features/focus/presentation/screens/focus_root_screen.dart';

/// Shows [AuthScreen] until Firebase Auth has a user; otherwise the main shell.
class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    if (!AppFirebase.isReady || !Get.isRegistered<AuthService>()) {
      return const FocusRootScreen();
    }
    final auth = Get.find<AuthService>();
    return StreamBuilder(
      stream: auth.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting &&
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
