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

    return Scaffold(
      appBar: AppBar(
        title: const Text('Sticker Album'),
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
                    label: Text(_getCategoryName(category)),
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
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 1.0,
                ),
                itemCount: stickers.length,
                itemBuilder: (context, index) {
                  final sticker = stickers[index];
                  final isUnlocked = unlockedStickers.contains(sticker.id);

                  return Container(
                    decoration: BoxDecoration(
                      color: isUnlocked ? AppTheme.white : AppTheme.grey.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isUnlocked ? AppTheme.primaryBlue : AppTheme.grey,
                        width: 2,
                      ),
                    ),
                    child: isUnlocked
                        ? Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              // Placeholder for sticker image
                              Icon(
                                Icons.star,
                                size: 48,
                                color: AppTheme.primaryBlue,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                sticker.name,
                                style: Theme.of(context).textTheme.bodyMedium,
                                textAlign: TextAlign.center,
                              ),
                            ],
                          )
                        : Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.lock,
                                size: 48,
                                color: AppTheme.grey,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Locked',
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: AppTheme.grey,
                                    ),
                              ),
                            ],
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

  String _getCategoryName(StickerCategory category) {
    switch (category) {
      case StickerCategory.brainCharacters:
        return 'Brains';
      case StickerCategory.achievements:
        return 'Achievements';
      case StickerCategory.rewards:
        return 'Rewards';
    }
  }
}

