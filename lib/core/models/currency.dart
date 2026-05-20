import 'package:hive/hive.dart';

part 'currency.g.dart';

@HiveType(typeId: 8)
class Currency extends HiveObject {
  @HiveField(0)
  int coins; // Virtual currency

  @HiveField(1)
  int gems; // Premium currency

  Currency({
    this.coins = 0,
    this.gems = 0,
  });

  void addCoins(int amount) {
    coins += amount;
  }

  void addGems(int amount) {
    gems += amount;
  }

  bool spendCoins(int amount) {
    if (coins >= amount) {
      coins -= amount;
      return true;
    }
    return false;
  }

  bool spendGems(int amount) {
    if (gems >= amount) {
      gems -= amount;
      return true;
    }
    return false;
  }

  Currency copyWith({
    int? coins,
    int? gems,
  }) {
    return Currency(
      coins: coins ?? this.coins,
      gems: gems ?? this.gems,
    );
  }
}

@HiveType(typeId: 9)
class ShopItem extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final String nameAr; // Arabic name

  @HiveField(3)
  final String description;

  @HiveField(4)
  final String descriptionAr; // Arabic description

  @HiveField(5)
  final ShopItemType type;

  @HiveField(6)
  final int price; // Price in coins or gems

  @HiveField(7)
  final bool isPremium; // If true, price is in gems, else coins

  @HiveField(8)
  final String itemData; // JSON or identifier for the item (sticker ID, background ID, etc.)

  @HiveField(9)
  final String? imagePath; // Optional image path

  ShopItem({
    required this.id,
    required this.name,
    required this.nameAr,
    required this.description,
    required this.descriptionAr,
    required this.type,
    required this.price,
    this.isPremium = false,
    required this.itemData,
    this.imagePath,
  });
}

enum ShopItemType {
  sticker,
  background,
  avatar,
  powerUp,
  theme,
}

@HiveType(typeId: 10)
class PurchasedItem extends HiveObject {
  @HiveField(0)
  final String itemId;

  @HiveField(1)
  final ShopItemType type;

  @HiveField(2)
  final DateTime purchasedAt;

  PurchasedItem({
    required this.itemId,
    required this.type,
    required this.purchasedAt,
  });

  bool isOwned(String itemId) {
    return this.itemId == itemId;
  }
}

