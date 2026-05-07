import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:water_drink_app/core/firebase/app_firebase.dart';
import 'package:water_drink_app/data/services/auth_service.dart';

class FocusAppBar extends StatelessWidget {
  const FocusAppBar({
    super.key,
    this.title = 'Serene Focus',
    this.leading,
    this.onLeadingTap,
  });

  final String title;
  final IconData? leading;
  final VoidCallback? onLeadingTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(
            color: const Color(0xFFE8EAF2).withValues(alpha: 0.9),
          ),
        ),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 40,
            height: 40,
            child: leading == null
                ? const Icon(
                    Icons.self_improvement,
                    size: 14,
                    color: Color(0xFF143D90),
                  )
                : IconButton(
                    onPressed: onLeadingTap ?? () {},
                    icon: Icon(leading, size: 18),
                    color: const Color(0xFF143D90),
                    splashRadius: 20,
                    tooltip: 'Back',
                  ),
          ),
          Expanded(
            child: Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Color(0xFF143D90),
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
    const avatar = CircleAvatar(
      radius: 10,
      backgroundColor: Color(0xFFB3B7C8),
      child: Icon(Icons.person, size: 11, color: Colors.white),
    );

    final canUseAuth =
        AppFirebase.isReady &&
        showMenu &&
        Get.isRegistered<AuthService>() &&
        Get.find<AuthService>().currentUser != null;

    if (!canUseAuth) {
      return avatar;
    }

    return InkWell(
      onTap: () => _showAccountSheet(context),
      borderRadius: BorderRadius.circular(20),
      child: avatar,
    );
  }

  Future<void> _showAccountSheet(BuildContext context) async {
    final auth = Get.find<AuthService>();
    final u = auth.currentUser!;
    final label = u.isAnonymous ? 'Guest' : (u.email ?? 'Signed in');

    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(14)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                  color: Color(0xFF143064),
                ),
              ),
              if (!u.isAnonymous && u.email != null) ...[
                const SizedBox(height: 4),
                Text(
                  u.email!,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF7A8299),
                  ),
                ),
              ],
              if (u.isAnonymous) ...[
                const SizedBox(height: 8),
                const Text(
                  'You are on a guest (anonymous) account. Data syncs to this profile on Firebase.',
                  style: TextStyle(fontSize: 12, color: Color(0xFF7A8299)),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Moving to email: signing up or signing in with email creates a '
                  'separate account unless the app adds account linking (e.g. '
                  'Firebase linkWithCredential). Your guest progress would not transfer automatically.',
                  style: TextStyle(
                    fontSize: 12,
                    color: Color(0xFF7A8299),
                    height: 1.35,
                  ),
                ),
              ],
              const SizedBox(height: 16),
              FilledButton.icon(
                onPressed: () async {
                  final ok = await showDialog<bool>(
                    context: ctx,
                    builder: (d) => AlertDialog(
                      title: const Text('Sign out?'),
                      content: const Text(
                        'You can sign in again anytime. Unsynced guest data stays on this device until you sign back in.',
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(d, false),
                          child: const Text('Cancel'),
                        ),
                        FilledButton(
                          onPressed: () => Navigator.pop(d, true),
                          child: const Text('Sign out'),
                        ),
                      ],
                    ),
                  );
                  if (ok == true && ctx.mounted) {
                    Navigator.pop(ctx);
                    await auth.signOut();
                  }
                },
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFF0A2C88),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                icon: const Icon(Icons.logout_rounded, size: 18),
                label: const Text('Sign out'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
