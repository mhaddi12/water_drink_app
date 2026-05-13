import 'package:flutter/foundation.dart';

abstract final class AdUnits {
  static const String androidBanner = String.fromEnvironment(
    'HYDRA_ANDROID_BANNER_AD_UNIT',
    defaultValue: 'ca-app-pub-8385354422515933/3640635798',
  );

  static const String iosBanner = String.fromEnvironment(
    'HYDRA_IOS_BANNER_AD_UNIT',
    defaultValue: 'ca-app-pub-8385354422515933/3640635798',
  );

  static const String androidAppOpen = String.fromEnvironment(
    'HYDRA_ANDROID_APP_OPEN_AD_UNIT',
    defaultValue: 'ca-app-pub-8385354422515933/2947719810',
  );

  static const String iosAppOpen = String.fromEnvironment(
    'HYDRA_IOS_APP_OPEN_AD_UNIT',
    defaultValue: 'ca-app-pub-8385354422515933/2947719810',
  );

  static const String _androidBannerTest =
      'ca-app-pub-3940256099942544/6300978111';
  static const String _iosBannerTest =
      'ca-app-pub-3940256099942544/2934735716';
  static const String _androidAppOpenTest =
      'ca-app-pub-3940256099942544/9257395921';
  static const String _iosAppOpenTest =
      'ca-app-pub-3940256099942544/5662855259';

  static bool get adsEnabled => !kIsWeb;

  static String bannerForCurrentPlatform() {
    if (!adsEnabled) return '';
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return kDebugMode ? _androidBannerTest : androidBanner;
      case TargetPlatform.iOS:
        return kDebugMode ? _iosBannerTest : iosBanner;
      default:
        return '';
    }
  }

  static String appOpenForCurrentPlatform() {
    if (!adsEnabled) return '';
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return kDebugMode ? _androidAppOpenTest : androidAppOpen;
      case TargetPlatform.iOS:
        return kDebugMode ? _iosAppOpenTest : iosAppOpen;
      default:
        return '';
    }
  }
}
