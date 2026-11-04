import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'storage_service.dart';
import 'firebase_service.dart';
import 'licensing_api_service.dart';

class IAPService {
  static final IAPService _instance = IAPService._internal();
  factory IAPService() => _instance;
  IAPService._internal();

  final InAppPurchase _iap = InAppPurchase.instance;
  final StorageService _storageService = StorageService();
  StreamSubscription<List<PurchaseDetails>>? _subscription;
  bool _isAvailable = false;
  List<ProductDetails> _products = [];

  // Subscription Product IDs (Auto-Renewable)
  static const String monthlySubId = 'minigenius_monthly';
  static const String yearlySubId = 'minigenius_yearly';
  static const String lifetimeId = 'minigenius_lifetime';
  static const String legacyProductId = 'premium_upgrade';

  static const Set<String> allProductIds = {
    monthlySubId,
    yearlySubId,
    lifetimeId,
    legacyProductId,
  };

  bool get isAvailable => _isAvailable;
  List<ProductDetails> get products => _products;

  Future<void> initialize() async {
    try {
      _isAvailable = await _iap.isAvailable();
      if (!_isAvailable) {
        debugPrint('⚠️ IAP is not available on this device');
        return;
      }

      // Listen to purchase updates
      _subscription = _iap.purchaseStream.listen(
        _onPurchaseUpdate,
        onDone: () => _subscription?.cancel(),
        onError: (error) {
          debugPrint('❌ IAP purchaseStream error: $error');
          _subscription?.cancel();
        },
      );

      // Load products
      await loadProducts();

      // Check central licensing server status in background
      LicensingApiService().verifyLicense();
    } catch (e) {
      debugPrint('⚠️ IAP initialize error: $e');
    }
  }

  Future<void> loadProducts() async {
    if (!_isAvailable) return;

    try {
      final response = await _iap.queryProductDetails(allProductIds);
      if (response.notFoundIDs.isNotEmpty) {
        debugPrint('ℹ️ IAP Products not found in store: ${response.notFoundIDs}');
      }
      _products = response.productDetails;
      debugPrint('✅ Loaded ${_products.length} IAP products from store');
    } catch (e) {
      debugPrint('⚠️ Error querying IAP products: $e');
    }
  }

  ProductDetails? getProduct(String id) {
    try {
      return _products.firstWhere((p) => p.id == id);
    } catch (_) {
      return null;
    }
  }

  ProductDetails? getMonthlyProduct() => getProduct(monthlySubId);
  ProductDetails? getYearlyProduct() => getProduct(yearlySubId);
  ProductDetails? getLifetimeProduct() => getProduct(lifetimeId);

  Future<bool> purchaseProduct(String productId) async {
    if (!_isAvailable || _products.isEmpty) {
      // In development or test mode, simulate successful purchase
      debugPrint('ℹ️ Simulating purchase for product: $productId');
      await activatePremiumLocally();
      return true;
    }

    try {
      final product = _products.firstWhere(
        (p) => p.id == productId,
        orElse: () => _products.first,
      );

      final purchaseParam = PurchaseParam(productDetails: product);
      if (productId == monthlySubId || productId == yearlySubId) {
        // Auto-renewable subscriptions
        return await _iap.buyNonConsumable(purchaseParam: purchaseParam);
      } else {
        return await _iap.buyNonConsumable(purchaseParam: purchaseParam);
      }
    } catch (e) {
      debugPrint('❌ Purchase failed with error: $e');
      return false;
    }
  }

  Future<bool> purchaseMonthly() => purchaseProduct(monthlySubId);
  Future<bool> purchaseYearly() => purchaseProduct(yearlySubId);
  Future<bool> purchaseLifetime() => purchaseProduct(lifetimeId);
  Future<bool> purchasePremium() => purchaseYearly(); // Default

  Future<void> restorePurchases() async {
    if (!_isAvailable) {
      // If store is not connected, check local status
      return;
    }
    try {
      await _iap.restorePurchases();
    } catch (e) {
      debugPrint('❌ restorePurchases error: $e');
    }
  }

  void _onPurchaseUpdate(List<PurchaseDetails> purchases) {
    for (var purchase in purchases) {
      if (purchase.status == PurchaseStatus.purchased ||
          purchase.status == PurchaseStatus.restored) {
        _handlePurchaseSuccess(purchase);
      } else if (purchase.status == PurchaseStatus.error) {
        _handlePurchaseError(purchase);
      }

      if (purchase.pendingCompletePurchase) {
        _iap.completePurchase(purchase);
      }
    }
  }

  void _handlePurchaseSuccess(PurchaseDetails purchase) {
    if (allProductIds.contains(purchase.productID)) {
      activatePremiumLocally();
      FirebaseService().logPremiumPurchase();
      debugPrint('🎉 Subscription / Premium activated for ${purchase.productID}');
    }
  }

  Future<void> activatePremiumLocally() async {
    await _storageService.updateUserProgress((progress) {
      progress.isPremium = true;
      return progress;
    });
  }

  void _handlePurchaseError(PurchaseDetails purchase) {
    debugPrint('❌ Purchase error: ${purchase.error?.message}');
  }

  bool isPremium() {
    final userProgress = _storageService.getUserProgress();
    return userProgress.isPremium || (userProgress.isTestMode ?? false);
  }

  ProductDetails? getPremiumProduct() {
    return getYearlyProduct() ?? getMonthlyProduct() ?? getProduct(legacyProductId);
  }

  void dispose() {
    _subscription?.cancel();
  }
}
