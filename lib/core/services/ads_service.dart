import 'package:flutter/material.dart';

// AdMob has been removed from Mini Genius to comply with Apple App Store
// Guideline 1.3 (Kids Category). The app no longer uses any third-party
// contextual advertising. Monetization is handled exclusively via In-App
// Purchase (Apple StoreKit / IAP).

class AdsService {
  static final AdsService _instance = AdsService._internal();
  factory AdsService() => _instance;
  AdsService._internal();

  Future<void> initialize() async {
    // No-op: AdMob removed for Kids Category compliance
  }

  bool shouldShowAds() => false;
}

/// A stub widget that renders nothing. Retained so that any existing
/// import of BannerAdWidget compiles without modification.
class BannerAdWidget extends StatelessWidget {
  final double? adSize;
  final String? adUnitId;

  const BannerAdWidget({super.key, this.adSize, this.adUnitId});

  @override
  Widget build(BuildContext context) => const SizedBox.shrink();
}
