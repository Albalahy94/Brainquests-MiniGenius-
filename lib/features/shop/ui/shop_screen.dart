import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/services/shop_service.dart';
import '../../../core/services/storage_service.dart';
import '../../../core/models/currency.dart';
import '../../../core/models/user_progress.dart';

class ShopScreen extends StatefulWidget {
  const ShopScreen({super.key});

  @override
  State<ShopScreen> createState() => _ShopScreenState();
}

class _ShopScreenState extends State<ShopScreen> {
  final ShopService _shopService = ShopService();
  final StorageService _storageService = StorageService();
  UserProgress? _userProgress;
  List<ShopItem> _availableItems = [];
  List<ShopItem> _purchasedItems = [];
  int _selectedTab = 0; // 0 = available, 1 = purchased

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    await _storageService.init();
    setState(() {
      _userProgress = _storageService.getUserProgress();
      _availableItems = _shopService.getAvailableItems();
      _purchasedItems = _shopService.getPurchasedItems();
    });
  }

  Future<void> _purchaseItem(ShopItem item) async {
    final success = await _shopService.purchaseItem(item.id);
    if (success) {
      _loadData(); // Refresh data
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('تم شراء ${item.nameAr} بنجاح!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('لا توجد عملات كافية!'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_userProgress == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppTheme.blueGradient,
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                    Expanded(
                      child: Text(
                        'المتجر',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                    ),
                    const SizedBox(width: 48),
                  ],
                ),
              ),

              // Currency Display
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _CurrencyDisplay(
                      icon: Icons.monetization_on,
                      amount: _userProgress!.coins,
                      label: 'عملات',
                      color: Colors.orange,
                    ),
                    _CurrencyDisplay(
                      icon: Icons.diamond,
                      amount: _userProgress!.gems,
                      label: 'جواهر',
                      color: Colors.blue,
                    ),
                  ],
                ),
              ),

              // Tabs
              Row(
                children: [
                  Expanded(
                    child: _TabButton(
                      label: 'متاح',
                      isSelected: _selectedTab == 0,
                      onTap: () => setState(() => _selectedTab = 0),
                    ),
                  ),
                  Expanded(
                    child: _TabButton(
                      label: 'مشترى',
                      isSelected: _selectedTab == 1,
                      onTap: () => setState(() => _selectedTab = 1),
                    ),
                  ),
                ],
              ),

              // Items List
              Expanded(
                child: _selectedTab == 0
                    ? _buildAvailableItems()
                    : _buildPurchasedItems(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAvailableItems() {
    if (_availableItems.isEmpty) {
      return const Center(
        child: Text(
          'لا توجد عناصر متاحة',
          style: TextStyle(color: Colors.white, fontSize: 18),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: _availableItems.length,
      itemBuilder: (context, index) {
        final item = _availableItems[index];
        final canAfford = item.isPremium
            ? _userProgress!.gems >= item.price
            : _userProgress!.coins >= item.price;

        return _ShopItemCard(
          item: item,
          canAfford: canAfford,
          onPurchase: () => _purchaseItem(item),
        );
      },
    );
  }

  Widget _buildPurchasedItems() {
    if (_purchasedItems.isEmpty) {
      return const Center(
        child: Text(
          'لم تشترِ أي عناصر بعد',
          style: TextStyle(color: Colors.white, fontSize: 18),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: _purchasedItems.length,
      itemBuilder: (context, index) {
        final item = _purchasedItems[index];
        return _PurchasedItemCard(item: item);
      },
    );
  }
}

class _CurrencyDisplay extends StatelessWidget {
  final IconData icon;
  final int amount;
  final String label;
  final Color color;

  const _CurrencyDisplay({
    required this.icon,
    required this.amount,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(width: 8),
        Text(
          '$amount',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
          ),
        ),
      ],
    );
  }
}

class _TabButton extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _TabButton({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? Colors.white.withOpacity(0.3)
              : Colors.transparent,
          border: Border(
            bottom: BorderSide(
              color: isSelected ? Colors.white : Colors.transparent,
              width: 2,
            ),
          ),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}

class _ShopItemCard extends StatelessWidget {
  final ShopItem item;
  final bool canAfford;
  final VoidCallback onPurchase;

  const _ShopItemCard({
    required this.item,
    required this.canAfford,
    required this.onPurchase,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Icon/Image placeholder
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: AppTheme.primaryBlue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              _getIconForType(item.type),
              color: AppTheme.primaryBlue,
              size: 32,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.nameAr,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  item.descriptionAr,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          Column(
            children: [
              Row(
                children: [
                  Icon(
                    item.isPremium ? Icons.diamond : Icons.monetization_on,
                    color: item.isPremium ? Colors.blue : Colors.orange,
                    size: 20,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${item.price}',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: canAfford ? Colors.black : Colors.red,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: canAfford ? onPurchase : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: canAfford ? AppTheme.primaryBlue : Colors.grey,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text('شراء'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  IconData _getIconForType(ShopItemType type) {
    switch (type) {
      case ShopItemType.sticker:
        return Icons.star;
      case ShopItemType.background:
        return Icons.image;
      case ShopItemType.avatar:
        return Icons.person;
      case ShopItemType.powerUp:
        return Icons.flash_on;
      case ShopItemType.theme:
        return Icons.palette;
    }
  }
}

class _PurchasedItemCard extends StatelessWidget {
  final ShopItem item;

  const _PurchasedItemCard({required this.item});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.green, width: 2),
      ),
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.check_circle,
              color: Colors.green,
              size: 32,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.nameAr,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  item.descriptionAr,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          const Icon(Icons.check, color: Colors.green, size: 32),
        ],
      ),
    );
  }
}

