import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:water_drink_app/core/ads/ad_units.dart';
import 'package:water_drink_app/core/network/connectivity_controller.dart';
import 'package:water_drink_app/data/services/auth_service.dart';

class AppOpenAdController extends GetxService with WidgetsBindingObserver {
  static const Duration _backgroundThreshold = Duration(minutes: 30);
  static const Duration _showCooldown = Duration(hours: 4);
  static const Duration _startupGrace = Duration(seconds: 45);

  AppOpenAd? _appOpenAd;
  bool _isShowingAd = false;
  bool _isLoadingAd = false;
  DateTime? _backgroundStartedAt;
  DateTime? _lastShownAt;
  final DateTime _startedAt = DateTime.now();

  @override
  void onInit() {
    super.onInit();
    if (!AdUnits.adsEnabled) return;
    WidgetsBinding.instance.addObserver(this);
    unawaited(_loadAd());
  }

  @override
  void onClose() {
    WidgetsBinding.instance.removeObserver(this);
    _appOpenAd?.dispose();
    _appOpenAd = null;
    super.onClose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (!AdUnits.adsEnabled) return;

    switch (state) {
      case AppLifecycleState.paused:
      case AppLifecycleState.inactive:
        _backgroundStartedAt ??= DateTime.now();
      case AppLifecycleState.resumed:
        unawaited(_showAdIfAvailable());
      case AppLifecycleState.detached:
      case AppLifecycleState.hidden:
        break;
    }
  }

  bool _canShowAds() {
    if (!AdUnits.adsEnabled) return false;
    if (DateTime.now().difference(_startedAt) < _startupGrace) return false;
    if (Get.isRegistered<ConnectivityController>() &&
        !Get.find<ConnectivityController>().isOnline.value) {
      return false;
    }
    if (Get.isRegistered<AuthService>() &&
        Get.find<AuthService>().currentUser == null) {
      return false;
    }
    return true;
  }

  Future<void> _loadAd() async {
    if (_isLoadingAd || _appOpenAd != null) return;

    final adUnitId = AdUnits.appOpenForCurrentPlatform();
    if (adUnitId.isEmpty) return;

    _isLoadingAd = true;
    await AppOpenAd.load(
      adUnitId: adUnitId,
      request: const AdRequest(),
      adLoadCallback: AppOpenAdLoadCallback(
        onAdLoaded: (ad) {
          _isLoadingAd = false;
          _appOpenAd?.dispose();
          _appOpenAd = ad;
        },
        onAdFailedToLoad: (error) {
          _isLoadingAd = false;
          _appOpenAd = null;
        },
      ),
    );
  }

  Future<void> _showAdIfAvailable() async {
    if (!_canShowAds() || _isShowingAd) return;

    final backgroundStartedAt = _backgroundStartedAt;
    _backgroundStartedAt = null;
    if (backgroundStartedAt == null) return;

    final backgroundDuration = DateTime.now().difference(backgroundStartedAt);
    if (backgroundDuration < _backgroundThreshold) return;

    final lastShownAt = _lastShownAt;
    if (lastShownAt != null &&
        DateTime.now().difference(lastShownAt) < _showCooldown) {
      return;
    }

    final ad = _appOpenAd;
    if (ad == null) {
      unawaited(_loadAd());
      return;
    }

    _isShowingAd = true;
    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdShowedFullScreenContent: (ad) {
        _lastShownAt = DateTime.now();
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        _isShowingAd = false;
        ad.dispose();
        _appOpenAd = null;
        unawaited(_loadAd());
      },
      onAdDismissedFullScreenContent: (ad) {
        _isShowingAd = false;
        ad.dispose();
        _appOpenAd = null;
        unawaited(_loadAd());
      },
    );

    try {
      await ad.show();
    } catch (_) {
      _isShowingAd = false;
      ad.dispose();
      _appOpenAd = null;
      unawaited(_loadAd());
    }
  }
}
