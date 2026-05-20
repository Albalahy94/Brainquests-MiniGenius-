import '../models/currency.dart';
import 'storage_service.dart';

class ShopService {
  static final ShopService _instance = ShopService._internal();
  factory ShopService() => _instance;
  ShopService._internal();

  final StorageService _storageService = StorageService();

  // Define shop items
  static final List<ShopItem> allShopItems = [
    // Stickers
    ShopItem(
      id: 'sticker_7',
      name: 'Special Sticker 7',
      nameAr: 'ملصق خاص 7',
      description: 'A special collectible sticker',
      descriptionAr: 'ملصق خاص للجمع',
      type: ShopItemType.sticker,
      price: 50,
      isPremium: false,
      itemData: 'sticker_7',
    ),
    ShopItem(
      id: 'sticker_8',
      name: 'Special Sticker 8',
      nameAr: 'ملصق خاص 8',
      description: 'A special collectible sticker',
      descriptionAr: 'ملصق خاص للجمع',
      type: ShopItemType.sticker,
      price: 50,
      isPremium: false,
      itemData: 'sticker_8',
    ),
    // Backgrounds
    ShopItem(
      id: 'bg_space',
      name: 'Space Background',
      nameAr: 'خلفية الفضاء',
      description: 'Beautiful space theme background',
      descriptionAr: 'خلفية جميلة بموضوع الفضاء',
      type: ShopItemType.background,
      price: 100,
      isPremium: false,
      itemData: 'bg_space',
    ),
    ShopItem(
      id: 'bg_ocean',
      name: 'Ocean Background',
      nameAr: 'خلفية المحيط',
      description: 'Beautiful ocean theme background',
      descriptionAr: 'خلفية جميلة بموضوع المحيط',
      type: ShopItemType.background,
      price: 100,
      isPremium: false,
      itemData: 'bg_ocean',
    ),
    // Avatars
    ShopItem(
      id: 'avatar_1',
      name: 'Cool Avatar',
      nameAr: 'أفاتار رائع',
      description: 'A cool character avatar',
      descriptionAr: 'أفاتار شخصية رائعة',
      type: ShopItemType.avatar,
      price: 5,
      isPremium: true, // Gems
      itemData: 'avatar_1',
    ),
    // Power-ups
    ShopItem(
      id: 'powerup_hint',
      name: 'Hint Power-up',
      nameAr: 'تلميح',
      description: 'Get a hint in any game',
      descriptionAr: 'احصل على تلميح في أي لعبة',
      type: ShopItemType.powerUp,
      price: 30,
      isPremium: false,
      itemData: 'hint',
    ),
    ShopItem(
      id: 'powerup_extra_time',
      name: 'Extra Time',
      nameAr: 'وقت إضافي',
      description: 'Get 30 seconds extra time',
      descriptionAr: 'احصل على 30 ثانية إضافية',
      type: ShopItemType.powerUp,
      price: 40,
      isPremium: false,
      itemData: 'extra_time',
    ),
  ];

  List<ShopItem> getAvailableItems() {
    final purchasedItems = _storageService.getAllPurchasedItems();
    final purchasedIds = purchasedItems.map((item) => item.itemId).toSet();
    
    return allShopItems.where((item) => !purchasedIds.contains(item.id)).toList();
  }

  List<ShopItem> getPurchasedItems() {
    final purchasedItems = _storageService.getAllPurchasedItems();
    final purchasedIds = purchasedItems.map((item) => item.itemId).toSet();
    
    return allShopItems.where((item) => purchasedIds.contains(item.id)).toList();
  }

  Future<bool> purchaseItem(String itemId) async {
    final item = allShopItems.firstWhere(
      (item) => item.id == itemId,
      orElse: () => throw Exception('Item not found'),
    );

    // Check if already purchased
    if (_storageService.isItemPurchased(itemId)) {
      return false;
    }

    final userProgress = _storageService.getUserProgress();
    bool canPurchase = false;

    if (item.isPremium) {
      canPurchase = userProgress.spendGems(item.price);
    } else {
      canPurchase = userProgress.spendCoins(item.price);
    }

    if (!canPurchase) {
      return false; // Not enough currency
    }

    // Save purchase
    final purchasedItem = PurchasedItem(
      itemId: itemId,
      type: item.type,
      purchasedAt: DateTime.now(),
    );
    await _storageService.savePurchasedItem(purchasedItem);
    await _storageService.saveUserProgress(userProgress);

    // If it's a sticker, add to unlocked stickers
    if (item.type == ShopItemType.sticker) {
      userProgress.addSticker(item.itemData);
      await _storageService.saveUserProgress(userProgress);
    }

    return true;
  }

  bool isItemPurchased(String itemId) {
    return _storageService.isItemPurchased(itemId);
  }

  ShopItem? getItem(String itemId) {
    try {
      return allShopItems.firstWhere((item) => item.id == itemId);
    } catch (e) {
      return null;
    }
  }
}

