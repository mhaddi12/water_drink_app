import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:water_drink_app/core/firebase/app_firebase.dart';
import 'package:water_drink_app/core/session/app_session.dart';
import 'package:water_drink_app/data/services/auth_service.dart';
import 'package:water_drink_app/app/theme/hydra_theme_colors.dart';
import 'package:water_drink_app/features/focus/presentation/widgets/focus_input_decoration.dart';

/// Email / password sign-in and registration, with optional guest access.
class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabs;
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _busy = false;
  bool _obscure = true;

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabs.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  Future<void> _submitSignIn() async {
    if (!_formKey.currentState!.validate()) return;
    if (!Get.isRegistered<AuthService>()) return;
    if (!AppSession.isOnline) {
      Get.snackbar('Hydra', 'Check your internet connection and try again.');
      return;
    }
    setState(() => _busy = true);
    try {
      await Get.find<AuthService>().signInWithEmail(
        _emailCtrl.text.trim(),
        _passwordCtrl.text,
      );
    } on FirebaseAuthException catch (e) {
      Get.snackbar('Hydra', AuthService.messageFor(e));
    } catch (_) {
      Get.snackbar('Hydra', 'Sign-in failed. Try again.');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _submitRegister() async {
    if (!_formKey.currentState!.validate()) return;
    if (!Get.isRegistered<AuthService>()) return;
    if (!AppSession.isOnline) {
      Get.snackbar('Hydra', 'Check your internet connection and try again.');
      return;
    }
    setState(() => _busy = true);
    try {
      await Get.find<AuthService>().registerWithEmail(
        _emailCtrl.text.trim(),
        _passwordCtrl.text,
      );
      Get.snackbar('Hydra', 'Welcome — your account is ready');
    } on FirebaseAuthException catch (e) {
      Get.snackbar('Hydra', AuthService.messageFor(e));
    } catch (_) {
      Get.snackbar('Hydra', 'Could not create account. Try again.');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _forgotPassword() async {
    final email = _emailCtrl.text.trim();
    if (email.isEmpty || !email.contains('@')) {
      Get.snackbar('Hydra', 'Enter your email above first');
      return;
    }
    if (!AppSession.isOnline) {
      Get.snackbar('Hydra', 'Check your internet connection and try again.');
      return;
    }
    setState(() => _busy = true);
    try {
      await Get.find<AuthService>().sendPasswordResetEmail(email);
      Get.snackbar('Hydra', 'Password reset email sent');
    } on FirebaseAuthException catch (e) {
      Get.snackbar('Hydra', AuthService.messageFor(e));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _continueAsGuest() async {
    if (!Get.isRegistered<AuthService>()) return;
    if (!AppSession.isOnline) {
      Get.snackbar('Hydra', 'Check your internet connection and try again.');
      return;
    }
    setState(() => _busy = true);
    try {
      await Get.find<AuthService>().signInAnonymously();
      Get.snackbar(
        'Hydra',
        'Signed in as guest. Email sign-in uses a separate account unless we add linking later.',
      );
    } on FirebaseAuthException catch (e) {
      Get.snackbar('Hydra', AuthService.messageFor(e));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!AppFirebase.isReady) {
      return const Scaffold(
        body: Center(
          child: Text('Firebase is not available on this platform.'),
        ),
      );
    }

    final colors = HydraThemeColors.of(context);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(22, 28, 22, 32),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Icon(
                  Icons.water_drop_rounded,
                  size: 48,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(height: 12),
                Text(
                  'Hydra',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: colors.ink,
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Sign in to sync routines, systems, and focus across devices.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13,
                    color: colors.muted,
                    height: 1.35,
                  ),
                ),
                const SizedBox(height: 28),
                Material(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(12),
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      children: [
                        TabBar(
                          controller: _tabs,
                          onTap: (_) {
                            FocusScope.of(context).unfocus();
                            setState(() {});
                          },
                          labelStyle: const TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 13,
                          ),
                          labelColor: const Color(0xFF082F86),
                          unselectedLabelColor: const Color(0xFF8A92A8),
                          indicatorColor: const Color(0xFF082F86),
                          tabs: const [
                            Tab(text: 'Sign in'),
                            Tab(text: 'Create account'),
                          ],
                        ),
                        const SizedBox(height: 18),
                        TextFormField(
                          controller: _emailCtrl,
                          keyboardType: TextInputType.emailAddress,
                          autofillHints: const [
                            AutofillHints.username,
                            AutofillHints.email,
                          ],
                          textInputAction: TextInputAction.next,
                          decoration: focusInputDecoration(context,'Email'),
                          validator: (v) {
                            final t = v?.trim() ?? '';
                            if (t.isEmpty) return 'Enter your email';
                            if (!t.contains('@')) return 'Enter a valid email';
                            return null;
                          },
                        ),
                        const SizedBox(height: 14),
                        TextFormField(
                          controller: _passwordCtrl,
                          obscureText: _obscure,
                          autofillHints: const [AutofillHints.password],
                          textInputAction: TextInputAction.done,
                          onFieldSubmitted: (_) {
                            if (_tabs.index == 0) {
                              _submitSignIn();
                            } else {
                              _submitRegister();
                            }
                          },
                          decoration: focusInputDecoration(context,'Password').copyWith(
                            suffixIcon: IconButton(
                              tooltip: _obscure ? 'Show' : 'Hide',
                              onPressed: () =>
                                  setState(() => _obscure = !_obscure),
                              icon: Icon(
                                _obscure
                                    ? Icons.visibility_outlined
                                    : Icons.visibility_off_outlined,
                              ),
                            ),
                          ),
                          validator: (v) {
                            final t = v ?? '';
                            if (t.isEmpty) return 'Enter a password';
                            if (t.length < 6) {
                              return 'Use at least 6 characters';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 18),
                        SizedBox(
                          width: double.infinity,
                          child: AnimatedBuilder(
                            animation: _tabs,
                            builder: (context, _) {
                              return FilledButton(
                                onPressed: _busy
                                    ? null
                                    : (_tabs.index == 0
                                        ? _submitSignIn
                                        : _submitRegister),
                                style: FilledButton.styleFrom(
                                  backgroundColor: const Color(0xFF0A2C88),
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 14,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                child: _busy
                                    ? const SizedBox(
                                        height: 20,
                                        width: 20,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: Colors.white,
                                        ),
                                      )
                                    : Text(
                                        _tabs.index == 0
                                            ? 'Sign in'
                                            : 'Create account',
                                      ),
                              );
                            },
                          ),
                        ),
                        if (_tabs.index == 0) ...[
                          const SizedBox(height: 8),
                          TextButton(
                            onPressed: _busy ? null : _forgotPassword,
                            child: const Text(
                              'Forgot password?',
                              style: TextStyle(
                                color: Color(0xFF234EB8),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                TextButton(
                  onPressed: _busy ? null : _continueAsGuest,
                  child: const Text(
                    'Continue as guest',
                    style: TextStyle(
                      color: Color(0xFF4B5570),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Guest mode uses an anonymous Firebase account on this device. '
                  'Your routines and systems sync to that guest profile.\n\n'
                  'Important: If you later create or sign in with email, that is a '
                  'new account by default—your guest data does not move over automatically. '
                  'Merging guest data into an email account would require account linking '
                  '(for example Firebase linkWithCredential), which this app does not do yet.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 11,
                    color: Color(0xFF9AA1B5),
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
