import 'package:flutter/material.dart';
import '../models/world.dart';
import '../models/game_progress.dart';
import 'storage_service.dart';
import 'iap_service.dart';

class WorldService {
  static final WorldService _instance = WorldService._internal();
  factory WorldService() => _instance;
  WorldService._internal();

  final StorageService _storageService = StorageService();

  // Define worlds
  static final List<World> allWorlds = [
    World.fromColor(
      id: 'space',
      name: 'Space World',
      nameAr: 'عالم الفضاء',
      description: 'Explore the universe and stars',
      descriptionAr: 'استكشف الكون والنجوم',
      icon: '🚀',
      color: const Color(0xFF6C5CE7), // Purple
      requiredStars: 0, // First world is unlocked
      totalLevels: 12,
      gameIds: ['memory_cards', 'find_difference', 'shape_matcher'],
    ),
    World.fromColor(
      id: 'ocean',
      name: 'Ocean World',
      nameAr: 'عالم البحر',
      description: 'Dive into the deep blue sea',
      descriptionAr: 'اغوص في أعماق البحر',
      icon: '🌊',
      color: const Color(0xFF00B894), // Teal
      requiredStars: 30, // Need 30 stars to unlock
      totalLevels: 12,
      gameIds: ['pattern_logic', 'quick_math', 'color_memory'],
    ),
    World.fromColor(
      id: 'forest',
      name: 'Forest World',
      nameAr: 'عالم الغابة',
      description: 'Discover nature and wildlife',
      descriptionAr: 'اكتشف الطبيعة والحياة البرية',
      icon: '🌳',
      color: const Color(0xFF00B894), // Green
      requiredStars: 60, // Need 60 stars to unlock
      totalLevels: 15,
      gameIds: ['memory_cards', 'pattern_logic', 'quick_math', 'color_memory'],
    ),
  ];

  Future<void> init() async {
    await _storageService.init();
  }

  List<World> getAvailableWorlds(int totalStars) {
    // If user is premium, return all worlds
    if (IAPService().isPremium()) {
      return allWorlds;
    }

    // In normal mode, return worlds that either:
    // 1. Meet star requirement, OR
    // 2. Were previously unlocked (e.g., in test mode)
    return allWorlds.where((world) {
      // Check if world meets star requirement
      if (world.isUnlocked(totalStars)) {
        return true;
      }

      // Check if world was previously unlocked
      final progress = _storageService.getWorldProgress(world.id);
      if (progress != null && progress.isUnlocked) {
        return true; // Keep unlocked even if stars don't meet requirement
      }

      return false;
    }).toList();
  }

  World? getWorld(String worldId) {
    try {
      return allWorlds.firstWhere((world) => world.id == worldId);
    } catch (e) {
      return null;
    }
  }

  WorldProgress getOrCreateWorldProgress(String worldId) {
    final progress = _storageService.getWorldProgress(worldId);
    if (progress != null) {
      return progress;
    }

    final newProgress = WorldProgress(worldId: worldId);
    // Save synchronously - this is safe because Hive boxes are in-memory
    // The actual disk write happens asynchronously
    _storageService.saveWorldProgress(newProgress);
    return newProgress;
  }

  Future<void> unlockWorld(String worldId, int totalStars) async {
    final world = getWorld(worldId);
    if (world == null) return;

    if (world.isUnlocked(totalStars)) {
      final progress = getOrCreateWorldProgress(worldId);
      if (!progress.isUnlocked) {
        final updated = progress.copyWith(
          isUnlocked: true,
          unlockedAt: DateTime.now(),
        );
        await _storageService.saveWorldProgress(updated);
      }
    }
  }

  Future<void> updateWorldLevel(
    String worldId,
    int levelNumber,
    LevelProgress levelProgress,
  ) async {
    final progress = getOrCreateWorldProgress(worldId);
    progress.updateLevel(levelNumber, levelProgress);
    await _storageService.saveWorldProgress(progress);
  }

  int getTotalStarsForWorld(String worldId) {
    final progress = _storageService.getWorldProgress(worldId);
    return progress?.totalStars ?? 0;
  }

  bool isWorldUnlocked(String worldId, int totalStars) {
    final world = getWorld(worldId);
    if (world == null) return false;

    // Check if user is premium - unlock all worlds
    if (IAPService().isPremium()) {
      // Make sure world progress is marked as unlocked
      final progress = getOrCreateWorldProgress(worldId);
      if (!progress.isUnlocked) {
        final updated = progress.copyWith(
          isUnlocked: true,
          unlockedAt: DateTime.now(),
        );
        _storageService.saveWorldProgress(updated);
      }
      return true;
    }

    // Normal mode: check if world progress is already unlocked
    // If a world was unlocked in test mode, it stays unlocked even after disabling test mode
    final progress = _storageService.getWorldProgress(worldId);
    if (progress != null && progress.isUnlocked) {
      // World was previously unlocked (either in test mode or normally)
      // Check if it still meets star requirement, if not, keep it unlocked anyway
      // (once unlocked, stays unlocked)
      return true;
    }

    // Check if world meets star requirement
    if (!world.isUnlocked(totalStars)) {
      return false;
    }

    // World meets requirement - unlock it
    if (progress == null) {
      // Create and unlock if meets star requirement
      final newProgress = WorldProgress(
        worldId: worldId,
        isUnlocked: true,
        unlockedAt: DateTime.now(),
      );
      _storageService.saveWorldProgress(newProgress);
      return true;
    }

    // If progress exists but not unlocked, unlock it if meets requirement
    if (!progress.isUnlocked) {
      final updated = progress.copyWith(
        isUnlocked: true,
        unlockedAt: DateTime.now(),
      );
      _storageService.saveWorldProgress(updated);
      return true;
    }

    return progress.isUnlocked;
  }
}
