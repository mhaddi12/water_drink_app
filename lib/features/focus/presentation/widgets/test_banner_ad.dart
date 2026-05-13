import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:water_drink_app/core/ads/ad_units.dart';

class TestBannerAd extends StatefulWidget {
  const TestBannerAd({super.key});

  @override
  State<TestBannerAd> createState() => _TestBannerAdState();
}

class _TestBannerAdState extends State<TestBannerAd> {
  BannerAd? _bannerAd;
  bool _loaded = false;

  String get _adUnitId => AdUnits.bannerForCurrentPlatform();

  @override
  void initState() {
    super.initState();
    if (kIsWeb) return;
    final unit = _adUnitId;
    if (unit.isEmpty) return;

    final ad = BannerAd(
      size: AdSize.banner,
      adUnitId: unit,
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          if (!mounted) return;
          setState(() {
            _loaded = true;
          });
        },
        onAdFailedToLoad: (ad, error) {
          ad.dispose();
        },
      ),
      request: const AdRequest(),
    );
    ad.load();
    _bannerAd = ad;
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_loaded || _bannerAd == null) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      alignment: Alignment.center,
      child: SizedBox(
        width: _bannerAd!.size.width.toDouble(),
        height: _bannerAd!.size.height.toDouble(),
        child: AdWidget(ad: _bannerAd!),
      ),
    );
  }
}
