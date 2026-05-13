import 'package:flutter/foundation.dart';

abstract final class AdUnits {
  static const String androidBanner = String.fromEnvironment(
    'HYDRA_ANDROID_BANNER_AD_UNIT',
    defaultValue: 'ca-app-pub-3940256099942544/6300978111',
  );

  static const String iosBanner = String.fromEnvironment(
    'HYDRA_IOS_BANNER_AD_UNIT',
    defaultValue: 'ca-app-pub-3940256099942544/2934735716',
  );

  static String bannerForCurrentPlatform() {
    if (kIsWeb) return '';
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return androidBanner;
      case TargetPlatform.iOS:
        return iosBanner;
      default:
        return '';
    }
  }
}
