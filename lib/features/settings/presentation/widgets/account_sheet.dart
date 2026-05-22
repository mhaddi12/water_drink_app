import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:water_drink_app/app/theme/app_theme.dart';
import 'package:water_drink_app/app/theme/hydra_theme_colors.dart';
import 'package:water_drink_app/core/firebase/app_firebase.dart';
import 'package:water_drink_app/core/session/sign_out_helper.dart';
import 'package:water_drink_app/data/services/auth_service.dart';
import 'package:water_drink_app/features/auth/presentation/screens/auth_screen.dart';
import 'package:water_drink_app/features/settings/presentation/screens/settings_screen.dart';

Future<void> showHydraAccountSheet(BuildContext context) async {
  final colors = HydraThemeColors.of(context);
  final auth = Get.isRegistered<AuthService>() ? Get.find<AuthService>() : null;
  final user = auth?.currentUser;
  final canSignOut = user != null;
  final label = user == null
      ? 'Not signed in'
      : user.isAnonymous
          ? 'Guest account'
          : (user.email ?? 'Signed in');

  await showModalBottomSheet<void>(
    context: context,
    backgroundColor: Theme.of(context).cardColor,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
    builder: (sheetContext) {
      return SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: colors.line,
                    borderRadius: BorderRadius.circular(99),
                  ),
                ),
              ),
              Text(
                'Account',
                style: Theme.of(sheetContext).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: colors.ink,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  color: colors.muted,
                ),
              ),
              const SizedBox(height: 16),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Icon(Icons.settings_outlined, color: AppTheme.primary),
                title: const Text('Settings'),
                subtitle: const Text('Profile, theme, and alarms'),
                trailing: const Icon(Icons.chevron_right_rounded),
                onTap: () {
                  Navigator.pop(sheetContext);
                  Get.to(() => const SettingsScreen());
                },
              ),
              if (!canSignOut && AppFirebase.isReady) ...[
                const SizedBox(height: 8),
                FilledButton.icon(
                  onPressed: () {
                    Navigator.pop(sheetContext);
                    Get.to(() => const AuthScreen());
                  },
                  icon: const Icon(Icons.login_rounded),
                  label: const Text('Sign in'),
                  style: FilledButton.styleFrom(
                    backgroundColor: AppTheme.primary,
                    minimumSize: const Size.fromHeight(48),
                  ),
                ),
              ],
              if (canSignOut) ...[
                const SizedBox(height: 12),
                OutlinedButton.icon(
                  onPressed: () {
                    Navigator.pop(sheetContext);
                    SignOutHelper.confirmAndSignOut(context);
                  },
                  icon: const Icon(Icons.logout_rounded),
                  label: const Text('Sign out'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFFC62828),
                    side: const BorderSide(color: Color(0xFFC62828)),
                    minimumSize: const Size.fromHeight(48),
                  ),
                ),
              ],
            ],
          ),
        ),
      );
    },
  );
}
