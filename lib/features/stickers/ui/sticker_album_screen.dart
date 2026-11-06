import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/models/sticker.dart';
import '../../../core/models/user_progress.dart';
import '../../../core/services/storage_service.dart';

class StickerAlbumScreen extends StatefulWidget {
  const StickerAlbumScreen({super.key});

  @override
  State<StickerAlbumScreen> createState() => _StickerAlbumScreenState();
}

class _StickerAlbumScreenState extends State<StickerAlbumScreen> {
  late final StorageService _storageService;
  UserProgress? _userProgress;
  StickerCategory _selectedCategory = StickerCategory.brainCharacters;

  @override
  void initState() {
    super.initState();
    _storageService = StorageService();
    _loadProgress();
  }

  Future<void> _loadProgress() async {
    await _storageService.init();
    if (mounted) {
      setState(() {
        _userProgress = _storageService.getUserProgress();
      });
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Reload progress when screen becomes visible again
    _loadProgress();
  }

  @override
  Widget build(BuildContext context) {
    if (_userProgress == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    
    final stickers = StickerDefinitions.getStickersByCategory(_selectedCategory);
    final unlockedStickers = _userProgress!.unlockedStickers;
    final isAr = Directionality.of(context) == TextDirection.rtl;

    return Scaffold(
      appBar: AppBar(
        title: Text(isAr ? 'ألبوم الملصقات' : 'Sticker Album'),
      ),
      body: Column(
        children: [
          // Category selector
          Container(
            height: 60,
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: StickerCategory.values.map((category) {
                final isSelected = _selectedCategory == category;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text(_getCategoryName(category, isAr)),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() {
                        _selectedCategory = category;
                      });
                    },
                    selectedColor: AppTheme.primaryBlue,
                    checkmarkColor: AppTheme.white,
                  ),
                );
              }).toList(),
            ),
          ),

          // Stickers grid
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 0.82,
                ),
                itemCount: stickers.length,
                itemBuilder: (context, index) {
                  final sticker = stickers[index];
                  final isUnlocked = unlockedStickers.contains(sticker.id);

                  return Container(
                    decoration: BoxDecoration(
                      color: isUnlocked ? AppTheme.white : AppTheme.grey.withOpacity(0.18),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isUnlocked ? AppTheme.primaryBlue : AppTheme.grey.withOpacity(0.5),
                        width: 1.5,
                      ),
                    ),
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 6.0, vertical: 8.0),
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: isUnlocked
                              ? Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(
                                      Icons.stars_rounded,
                                      size: 38,
                                      color: Colors.amber,
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      sticker.name,
                                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 12,
                                          ),
                                      textAlign: TextAlign.center,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                )
                              : Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.lock_rounded,
                                      size: 34,
                                      color: AppTheme.grey.withOpacity(0.6),
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      isAr ? 'مقفل 🔒' : 'Locked 🔒',
                                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                            color: AppTheme.grey,
                                            fontSize: 11,
                                            fontWeight: FontWeight.w600,
                                          ),
                                    ),
                                  ],
                                ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getCategoryName(StickerCategory category, bool isAr) {
    switch (category) {
      case StickerCategory.brainCharacters:
        return isAr ? 'الشخصيات' : 'Brains';
      case StickerCategory.achievements:
        return isAr ? 'الإنجازات' : 'Achievements';
      case StickerCategory.rewards:
        return isAr ? 'المكافآت' : 'Rewards';
    }
  }
}

