import 'dart:async';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'storage_service.dart';
import '../models/user_progress.dart';
import 'firebase_service.dart';

class IAPService {
  static final IAPService _instance = IAPService._internal();
  factory IAPService() => _instance;
  IAPService._internal();

  final InAppPurchase _iap = InAppPurchase.instance;
  final StorageService _storageService = StorageService();
  StreamSubscription<List<PurchaseDetails>>? _subscription;
  bool _isAvailable = false;
  List<ProductDetails> _products = [];

  // Product IDs - Replace with your actual product IDs from Google Play / App Store
  static const String premiumProductId = 'premium_upgrade';

  Future<void> initialize() async {
    _isAvailable = await _iap.isAvailable();
    
    if (!_isAvailable) {
      return;
    }

    // Listen to purchase updates
    _subscription = _iap.purchaseStream.listen(
      _onPurchaseUpdate,
      onDone: () => _subscription?.cancel(),
      onError: (error) => _subscription?.cancel(),
    );

    // Load products
    await loadProducts();
  }

  Future<void> loadProducts() async {
    if (!_isAvailable) return;

    final productIds = {premiumProductId};
    final response = await _iap.queryProductDetails(productIds);

    if (response.notFoundIDs.isNotEmpty) {
      // Handle not found products
    }

    _products = response.productDetails;
  }

  Future<bool> purchasePremium() async {
    if (!_isAvailable || _products.isEmpty) {
      return false;
    }

    final product = _products.firstWhere(
      (p) => p.id == premiumProductId,
      orElse: () => _products.first,
    );

    final purchaseParam = PurchaseParam(productDetails: product);
    return await _iap.buyNonConsumable(purchaseParam: purchaseParam);
  }

  Future<void> restorePurchases() async {
    if (!_isAvailable) return;
    await _iap.restorePurchases();
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
    if (purchase.productID == premiumProductId) {
      _storageService.updateUserProgress((progress) {
        progress.isPremium = true;
        return progress;
      });

      // Log analytics
      FirebaseService().logPremiumPurchase();
    }
  }

  void _handlePurchaseError(PurchaseDetails purchase) {
    // Handle purchase error
  }

  bool isPremium() {
    final userProgress = _storageService.getUserProgress();
    return userProgress.isPremium;
  }

  ProductDetails? getPremiumProduct() {
    try {
      return _products.firstWhere((p) => p.id == premiumProductId);
    } catch (e) {
      return null;
    }
  }

  void dispose() {
    _subscription?.cancel();
  }
}

