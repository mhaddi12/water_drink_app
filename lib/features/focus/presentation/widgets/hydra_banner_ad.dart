import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:water_drink_app/core/ads/ad_units.dart';

class HydraBannerAd extends StatefulWidget {
  const HydraBannerAd({super.key, required this.visible});

  final bool visible;

  @override
  State<HydraBannerAd> createState() => _HydraBannerAdState();
}

class _HydraBannerAdState extends State<HydraBannerAd> {
  BannerAd? _bannerAd;
  bool _loaded = false;

  @override
  void initState() {
    super.initState();
    if (widget.visible) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _loadAd();
        }
      });
    }
  }

  @override
  void didUpdateWidget(covariant HydraBannerAd oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.visible == oldWidget.visible) return;
    if (widget.visible) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _loadAd();
        }
      });
    } else {
      _disposeAd();
    }
  }

  Future<void> _loadAd() async {
    if (!AdUnits.adsEnabled || _bannerAd != null) return;

    final adUnitId = AdUnits.bannerForCurrentPlatform();
    if (adUnitId.isEmpty) return;

    final width = MediaQuery.sizeOf(context).width.truncate();
    final size =
        await AdSize.getCurrentOrientationAnchoredAdaptiveBannerAdSize(width);
    if (!mounted || !widget.visible) return;
    if (size == null) return;

    final ad = BannerAd(
      size: size,
      adUnitId: adUnitId,
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          if (!mounted || !widget.visible) {
            ad.dispose();
            return;
          }
          setState(() {
            _loaded = true;
          });
        },
        onAdFailedToLoad: (ad, error) {
          ad.dispose();
          if (!mounted) return;
          setState(() {
            _bannerAd = null;
            _loaded = false;
          });
        },
      ),
      request: const AdRequest(),
    );
    ad.load();
    _bannerAd = ad;
  }

  void _disposeAd() {
    _bannerAd?.dispose();
    _bannerAd = null;
    _loaded = false;
  }

  @override
  void dispose() {
    _disposeAd();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.visible || !_loaded || _bannerAd == null) {
      return const SizedBox.shrink();
    }

    final theme = Theme.of(context);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border(
          top: BorderSide(
            color: theme.dividerColor.withValues(alpha: 0.35),
          ),
        ),
      ),
      child: SizedBox(
        width: double.infinity,
        height: _bannerAd!.size.height.toDouble(),
        child: AdWidget(ad: _bannerAd!),
      ),
    );
  }
}
