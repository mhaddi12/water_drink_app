import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:water_drink_app/core/firebase/app_firebase.dart';
import 'package:water_drink_app/core/reminders/reminder_timezone.dart';
import 'package:water_drink_app/data/repositories/user_repository.dart';
import 'package:water_drink_app/data/services/auth_service.dart';

/// Persists the device IANA timezone to Firestore for server-side push scheduling.
class UserTimezoneFirestoreSync with WidgetsBindingObserver {
  UserTimezoneFirestoreSync._();

  static final UserTimezoneFirestoreSync instance =
      UserTimezoneFirestoreSync._();

  UserRepository? _repository;
  AuthService? _auth;
  StreamSubscription<User?>? _authSub;
  String? _uid;
  String? _lastPersistedTimezone;
  bool _lifecycleObserverRegistered = false;
  bool _syncInFlight = false;

  void bind({
    required AuthService auth,
    required UserRepository repository,
  }) {
    if (!AppFirebase.isReady) return;

    _repository = repository;
    _auth = auth;
    _registerLifecycleObserver();

    _authSub?.cancel();
    _authSub = auth.authStateChanges().listen(_onAuthUser);
    unawaited(ensureSynced());
  }

  /// Syncs timezone for the current session — app start, login, or resume.
  Future<void> ensureSynced({bool force = false}) async {
    if (!AppFirebase.isReady) return;
    if (_syncInFlight) return;

    final user = _auth?.currentUser;
    if (user == null) return;

    _uid = user.uid;
    _syncInFlight = true;
    try {
      await _persistCurrent(force: force);
    } finally {
      _syncInFlight = false;
    }
  }

  void _registerLifecycleObserver() {
    if (_lifecycleObserverRegistered) return;
    WidgetsBinding.instance.addObserver(this);
    _lifecycleObserverRegistered = true;
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      unawaited(ensureSynced());
    }
  }

  void _onAuthUser(User? user) {
    if (user == null) {
      _uid = null;
      _lastPersistedTimezone = null;
      return;
    }
    _uid = user.uid;
    unawaited(ensureSynced(force: true));
  }

  Future<void> _persistCurrent({bool force = false}) async {
    final uid = _uid;
    final repo = _repository;
    if (uid == null || repo == null || !AppFirebase.isReady) return;

    final timezoneId = await ReminderTimezone.readDeviceTimezoneId();
    if (!force && _lastPersistedTimezone == timezoneId) return;

    try {
      await repo.upsertTimezone(uid: uid, timezoneId: timezoneId);
      _lastPersistedTimezone = timezoneId;
      if (kDebugMode) {
        debugPrint('Hydra: saved timezone $timezoneId for $uid');
      }
    } catch (e, stack) {
      if (kDebugMode) {
        debugPrint('Hydra: timezone save failed: $e\n$stack');
      }
    }
  }

  void dispose() {
    _authSub?.cancel();
    _authSub = null;
    if (_lifecycleObserverRegistered) {
      WidgetsBinding.instance.removeObserver(this);
      _lifecycleObserverRegistered = false;
    }
    _repository = null;
    _auth = null;
    _uid = null;
    _lastPersistedTimezone = null;
  }
}
