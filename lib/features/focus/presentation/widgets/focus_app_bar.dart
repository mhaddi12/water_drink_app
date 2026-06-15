import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:water_drink_app/app/theme/app_theme.dart';
import 'package:water_drink_app/app/theme/hydra_theme_colors.dart';
import 'package:water_drink_app/core/firebase/app_firebase.dart';
import 'package:water_drink_app/data/services/auth_service.dart';
import 'package:water_drink_app/app/widgets/hydra_app_drawer.dart';
import 'package:water_drink_app/features/auth/presentation/screens/auth_screen.dart';
import 'package:water_drink_app/features/settings/presentation/widgets/account_sheet.dart';

class FocusAppBar extends StatelessWidget {
  const FocusAppBar({
    super.key,
    this.title = 'Serene Focus',
    this.leading,
    this.onLeadingTap,
    this.showDrawerMenu = true,
  });

  final String title;
  final IconData? leading;
  final VoidCallback? onLeadingTap;
  final bool showDrawerMenu;

  @override
  Widget build(BuildContext context) {
    final colors = HydraThemeColors.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      height: 48,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: isDark ? Colors.black : colors.surface,
        border: Border(bottom: BorderSide(color: colors.line)),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 40,
            height: 40,
            child: leading == null
                ? (showDrawerMenu
                    ? IconButton(
                        onPressed: () => openHydraDrawer(context),
                        icon: const Icon(Icons.menu_rounded, size: 22),
                        color: isDark
                            ? AppTheme.primaryLight
                            : const Color(0xFF143D90),
                        splashRadius: 20,
                        tooltip: 'Menu',
                      )
                    : Icon(
                        Icons.self_improvement,
                        size: 14,
                        color: isDark
                            ? AppTheme.primaryLight
                            : const Color(0xFF143D90),
                      ))
                : IconButton(
                    onPressed: onLeadingTap ?? () => Get.back(),
                    icon: Icon(leading, size: 18),
                    color: isDark ? AppTheme.primaryLight : const Color(0xFF143D90),
                    splashRadius: 20,
                    tooltip: 'Back',
                  ),
          ),
          Expanded(
            child: Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: colors.inkSoft,
                fontWeight: FontWeight.w700,
                fontSize: 13,
              ),
            ),
          ),
          _FocusProfileAvatar(showMenu: leading == null),
          const SizedBox(width: 8),
        ],
      ),
    );
  }
}

class _FocusProfileAvatar extends StatelessWidget {
  const _FocusProfileAvatar({required this.showMenu});

  final bool showMenu;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final avatar = CircleAvatar(
      radius: 10,
      backgroundColor: isDark ? const Color(0xFF3A3A3A) : const Color(0xFFB3B7C8),
      child: const Icon(Icons.person, size: 11, color: Colors.white),
    );

    final canUseAuth =
        AppFirebase.isReady &&
        showMenu &&
        Get.isRegistered<AuthService>() &&
        Get.find<AuthService>().currentUser != null;

    if (!canUseAuth) {
      return Material(
        color: Colors.transparent,
        shape: const CircleBorder(),
        child: InkWell(
          onTap: () {
            if (AppFirebase.isReady && Get.isRegistered<AuthService>()) {
              Get.to(() => const AuthScreen());
              return;
            }
            Get.snackbar('Hydra', 'Sign in to sync your profile');
          },
          customBorder: const CircleBorder(),
          child: avatar,
        ),
      );
    }

    return Material(
      color: Colors.transparent,
      shape: const CircleBorder(),
      child: InkWell(
        onTap: () => showHydraAccountSheet(context),
        customBorder: const CircleBorder(),
        child: avatar,
      ),
    );
  }
}
