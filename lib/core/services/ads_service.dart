import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../models/user_progress.dart';
import 'storage_service.dart';

class AdsService {
  static final AdsService _instance = AdsService._internal();
  factory AdsService() => _instance;
  AdsService._internal();

  BannerAd? _bannerAd;
  bool _isInitialized = false;
  final StorageService _storageService = StorageService();

  // AdMob Ad Unit IDs
  static const String _bannerAdUnitId = 'ca-app-pub-2410231577080071/1286377452'; // minigenius_banner

  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      await MobileAds.instance.initialize();
      
      // Global configuration for child-directed treatment (COPPA/GDPR compliance)
      final RequestConfiguration requestConfiguration = RequestConfiguration(
        tagForChildDirectedTreatment: TagForChildDirectedTreatment.yes,
        maxAdContentRating: MaxAdContentRating.g,
      );
      await MobileAds.instance.updateRequestConfiguration(requestConfiguration);
      
      _isInitialized = true;
    } catch (e) {
      debugPrint('Error initializing MobileAds: $e');
    }
  }

  bool shouldShowAds() {
    try {
      final userProgress = _storageService.getUserProgress();
      return !userProgress.isPremium;
    } catch (e) {
      debugPrint('Error checking shouldShowAds: $e');
      return false; // Don't show ads if there's an error
    }
  }

  BannerAd? createBannerAd({
    required AdSize adSize,
    required BannerAdListener listener,
    String? adUnitId,
  }) {
    if (!shouldShowAds()) return null;

    final ad = BannerAd(
      adUnitId: adUnitId ?? _bannerAdUnitId,
      size: adSize,
      request: const AdRequest(),
      listener: listener,
    );

    ad.load();
    return ad;
  }

  void disposeBannerAd(BannerAd? ad) {
    ad?.dispose();
  }

  // Preload banner ad
  Future<BannerAd?> preloadBannerAd({
    AdSize adSize = AdSize.banner,
    String? adUnitId,
  }) async {
    if (!shouldShowAds()) return null;

    final completer = Completer<BannerAd?>();
    
    final ad = BannerAd(
      adUnitId: adUnitId ?? _bannerAdUnitId,
      size: adSize,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          completer.complete(ad as BannerAd);
        },
        onAdFailedToLoad: (ad, error) {
          ad.dispose();
          completer.complete(null);
        },
      ),
    );

    ad.load();
    return completer.future;
  }
}

// Helper widget for banner ads
class BannerAdWidget extends StatefulWidget {
  final AdSize adSize;
  final String? adUnitId;

  const BannerAdWidget({
    super.key,
    this.adSize = AdSize.banner,
    this.adUnitId,
  });

  @override
  State<BannerAdWidget> createState() => _BannerAdWidgetState();
}

class _BannerAdWidgetState extends State<BannerAdWidget> {
  BannerAd? _bannerAd;
  bool _isAdLoaded = false;

  @override
  void initState() {
    super.initState();
    // Delay ad loading to avoid blocking app startup
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        _loadBannerAd();
      }
    });
  }

  void _loadBannerAd() {
    try {
      if (!AdsService().shouldShowAds()) return;

      _bannerAd = AdsService().createBannerAd(
        adSize: widget.adSize,
        adUnitId: widget.adUnitId,
        listener: BannerAdListener(
          onAdLoaded: (_) {
            if (mounted) {
              setState(() {
                _isAdLoaded = true;
              });
            }
          },
          onAdFailedToLoad: (ad, error) {
            debugPrint('Ad failed to load: $error');
            ad.dispose();
            if (mounted) {
              setState(() {
                _isAdLoaded = false;
              });
            }
          },
        ),
      );
    } catch (e) {
      debugPrint('Error loading banner ad: $e');
      // Silently fail - ads are not critical
    }
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    try {
      if (!AdsService().shouldShowAds() || !_isAdLoaded || _bannerAd == null) {
        return const SizedBox.shrink();
      }

      return Container(
        alignment: Alignment.center,
        width: _bannerAd!.size.width.toDouble(),
        height: _bannerAd!.size.height.toDouble(),
        child: AdWidget(ad: _bannerAd!),
      );
    } catch (e) {
      debugPrint('Error building banner ad widget: $e');
      return const SizedBox.shrink();
    }
  }
}

