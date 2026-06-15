import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:water_drink_app/core/firebase/app_firebase.dart';
import 'package:water_drink_app/core/push/onesignal_service.dart';
import 'package:water_drink_app/data/repositories/user_repository.dart';
import 'package:water_drink_app/data/services/auth_service.dart';

/// Persists the device push token (FCM on Android, APNs on iOS) to Firestore.
class PushTokenFirestoreSync with WidgetsBindingObserver {
  PushTokenFirestoreSync._();

  static final PushTokenFirestoreSync instance = PushTokenFirestoreSync._();

  static const _retryDelaysMs = [0, 400, 1200, 2500, 5000, 8000];

  UserRepository? _repository;
  AuthService? _auth;
  StreamSubscription<User?>? _authSub;
  String? _uid;
  String? _deviceKey;
  String? _lastPersistedToken;
  bool _observerRegistered = false;
  bool _lifecycleObserverRegistered = false;
  bool _syncInFlight = false;

  void bind({
    required AuthService auth,
    required UserRepository repository,
  }) {
    if (!AppFirebase.isReady || !OneSignalService.isSupported) return;

    _repository = repository;
    _auth = auth;
    _registerSubscriptionObserver();
    _registerLifecycleObserver();

    _authSub?.cancel();
    _authSub = auth.authStateChanges().listen(_onAuthUser);
    unawaited(ensureSynced());
  }

  /// Syncs token for the current session — call on app start, resume, or login.
  Future<void> ensureSynced() async {
    if (!AppFirebase.isReady || !OneSignalService.isSupported) return;
    if (_syncInFlight) return;

    final user = _auth?.currentUser;
    if (user == null) return;

    _uid = user.uid;
    _registerSubscriptionObserver();

    if (!OneSignalService.instance.isReady) {
      unawaited(_retryWhenOneSignalReady());
      return;
    }

    _syncInFlight = true;
    try {
      for (var i = 0; i < _retryDelaysMs.length; i++) {
        if (i > 0) {
          await Future<void>.delayed(
            Duration(milliseconds: _retryDelaysMs[i]),
          );
        }
        if (_uid == null) return;

        await _persistCurrent(force: i == _retryDelaysMs.length - 1);
        if (_hasPersistableToken()) return;
      }
    } finally {
      _syncInFlight = false;
    }
  }

  Future<void> _retryWhenOneSignalReady() async {
    for (var i = 0; i < 20; i++) {
      await Future<void>.delayed(const Duration(milliseconds: 250));
      if (OneSignalService.instance.isReady) {
        await ensureSynced();
        return;
      }
    }
  }

  /// Re-reads the current push token and writes it to Firestore if signed in.
  Future<void> syncNow() => ensureSynced();

  bool _hasPersistableToken() {
    final token = OneSignal.User.pushSubscription.token?.trim();
    return token != null && token.isNotEmpty;
  }

  void _registerLifecycleObserver() {
    if (_lifecycleObserverRegistered) return;
    WidgetsBinding.instance.addObserver(this);
    _lifecycleObserverRegistered = true;
  }

  void _registerSubscriptionObserver() {
    if (_observerRegistered || !OneSignalService.instance.isReady) return;
    OneSignal.User.pushSubscription.addObserver(_onPushSubscriptionChange);
    _observerRegistered = true;
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      unawaited(ensureSynced());
    }
  }

  void _onPushSubscriptionChange(OSPushSubscriptionChangedState state) {
    unawaited(_handleSubscriptionChange(state));
  }

  Future<void> _handleSubscriptionChange(
    OSPushSubscriptionChangedState state,
  ) async {
    final uid = _uid;
    final repo = _repository;
    if (uid == null || repo == null || !AppFirebase.isReady) return;

    final previous = state.previous;
    final current = state.current;

    final previousId = previous.id?.trim();
    final currentId = current.id?.trim();
    final previousToken = previous.token?.trim();
    final currentToken = current.token?.trim();

    if (previousId != null &&
        previousId.isNotEmpty &&
        previousId != currentId) {
      try {
        await repo.removeFcmToken(uid: uid, deviceKey: previousId);
      } catch (e, stack) {
        if (kDebugMode) {
          debugPrint('Hydra: stale FCM remove failed: $e\n$stack');
        }
      }
      if (_deviceKey == previousId) {
        _deviceKey = null;
        _lastPersistedToken = null;
      }
    }

    if (currentToken == null || currentToken.isEmpty) {
      final keyToRemove = currentId ?? previousId;
      if (keyToRemove != null && keyToRemove.isNotEmpty) {
        try {
          await repo.removeFcmToken(uid: uid, deviceKey: keyToRemove);
        } catch (_) {}
      }
      if (_deviceKey == keyToRemove || _deviceKey == currentId) {
        _deviceKey = null;
        _lastPersistedToken = null;
      }
      return;
    }

    if (previousToken != null &&
        previousToken != currentToken &&
        previousId == currentId &&
        kDebugMode) {
      debugPrint('Hydra: push token rotated for $currentId');
    }

    await _persist(current, source: 'onesignal_subscription');
  }

  void _onAuthUser(User? user) {
    if (user == null) {
      unawaited(_removeCurrentDevice());
      _uid = null;
      _lastPersistedToken = null;
      return;
    }
    _uid = user.uid;
    unawaited(ensureSynced());
  }

  Future<void> _persistCurrent({bool force = false}) async {
    if (!OneSignalService.instance.isReady) return;
    final subscription = OneSignal.User.pushSubscription;
    await _persist(
      OSPushSubscriptionState({
        'id': subscription.id,
        'token': subscription.token,
        'optedIn': subscription.optedIn ?? false,
      }),
      source: 'sync',
      force: force,
    );
  }

  Future<void> _persist(
    OSPushSubscriptionState state, {
    required String source,
    bool force = false,
  }) async {
    final uid = _uid;
    final repo = _repository;
    if (uid == null || repo == null || !AppFirebase.isReady) return;

    final token = state.token?.trim();
    var deviceKey = state.id?.trim();
    if (token == null || token.isEmpty) return;

    deviceKey ??= 'fcm_$_platformName';

    if (!force &&
        _lastPersistedToken == token &&
        _deviceKey == deviceKey) {
      return;
    }

    _deviceKey = deviceKey;
    try {
      await repo.upsertFcmToken(
        uid: uid,
        deviceKey: deviceKey,
        token: token,
        platform: _platformName,
        optedIn: state.optedIn,
      );
      _lastPersistedToken = token;
      if (kDebugMode) {
        debugPrint(
          'Hydra: saved FCM token for $uid (device $deviceKey, $source)',
        );
      }
    } catch (e, stack) {
      if (kDebugMode) {
        debugPrint('Hydra: FCM token save failed: $e\n$stack');
      }
    }
  }

  Future<void> clearCurrentDevice() => _removeCurrentDevice();

  Future<void> _removeCurrentDevice() async {
    final uid = _uid;
    final deviceKey = _deviceKey;
    final repo = _repository;
    if (uid == null ||
        deviceKey == null ||
        repo == null ||
        !AppFirebase.isReady) {
      _deviceKey = null;
      _lastPersistedToken = null;
      return;
    }

    try {
      await repo.removeFcmToken(uid: uid, deviceKey: deviceKey);
    } catch (e, stack) {
      if (kDebugMode) {
        debugPrint('Hydra: FCM token remove failed: $e\n$stack');
      }
    } finally {
      _deviceKey = null;
      _lastPersistedToken = null;
    }
  }

  void dispose() {
    _authSub?.cancel();
    _authSub = null;
    if (_observerRegistered) {
      OneSignal.User.pushSubscription.removeObserver(_onPushSubscriptionChange);
      _observerRegistered = false;
    }
    if (_lifecycleObserverRegistered) {
      WidgetsBinding.instance.removeObserver(this);
      _lifecycleObserverRegistered = false;
    }
    _repository = null;
    _auth = null;
    _uid = null;
    _deviceKey = null;
    _lastPersistedToken = null;
  }

  static String get _platformName {
    return switch (defaultTargetPlatform) {
      TargetPlatform.android => 'android',
      TargetPlatform.iOS => 'ios',
      _ => defaultTargetPlatform.name,
    };
  }
}
