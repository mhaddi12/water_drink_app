import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:water_drink_app/core/firebase/app_firebase.dart';

class AuthService extends GetxService {
  final _auth = FirebaseAuth.instance;

  User? get currentUser => AppFirebase.isReady ? _auth.currentUser : null;

  String? get currentUid => currentUser?.uid;

  bool get isAnonymous => currentUser?.isAnonymous ?? false;

  /// Human-readable errors for snackbars and dialogs.
  static String messageFor(FirebaseAuthException e) {
    switch (e.code) {
      case 'invalid-email':
        return 'That email address is not valid.';
      case 'user-disabled':
        return 'This account has been disabled.';
      case 'user-not-found':
        return 'No account found for that email.';
      case 'wrong-password':
        return 'Incorrect password.';
      case 'invalid-credential':
        return 'Incorrect email or password.';
      case 'email-already-in-use':
        return 'That email is already registered. Try signing in.';
      case 'weak-password':
        return 'Pick a stronger password (at least 6 characters).';
      case 'operation-not-allowed':
        return 'This sign-in method is not enabled in Firebase.';
      case 'network-request-failed':
        return 'Network error. Check your connection.';
      case 'too-many-requests':
        return 'Too many attempts. Try again later.';
      default:
        return e.message?.isNotEmpty == true
            ? e.message!
            : 'Something went wrong.';
    }
  }

  Future<void> signInWithEmail(String email, String password) async {
    if (!AppFirebase.isReady) return;
    await _auth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
  }

  Future<void> registerWithEmail(String email, String password) async {
    if (!AppFirebase.isReady) return;
    await _auth.createUserWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
  }

  Future<void> sendPasswordResetEmail(String email) async {
    if (!AppFirebase.isReady) return;
    await _auth.sendPasswordResetEmail(email: email.trim());
  }

  Future<void> signInAnonymously() async {
    if (!AppFirebase.isReady) return;
    await _auth.signInAnonymously();
  }

  Future<void> signOut() async {
    if (!AppFirebase.isReady) return;
    await _auth.signOut();
  }

  Stream<User?> authStateChanges() =>
      AppFirebase.isReady ? _auth.authStateChanges() : const Stream.empty();

  /// For scripts/tests that need any uid without showing UI (optional).
  Future<String?> ensureSignedInAnonymously() async {
    if (!AppFirebase.isReady) return null;
    if (_auth.currentUser != null) return _auth.currentUser!.uid;
    final cred = await _auth.signInAnonymously();
    return cred.user?.uid;
  }
}
