class Sticker {
  final String id;
  final String name;
  final String assetPath;
  final StickerCategory category;

  Sticker({
    required this.id,
    required this.name,
    required this.assetPath,
    required this.category,
  });
}

enum StickerCategory {
  brainCharacters,
  achievements,
  rewards,
}

class StickerDefinitions {
  static List<Sticker> getAllStickers() {
    return [
      // Brain Characters
      Sticker(
        id: 'happy_brain',
        name: 'Happy Brain',
        assetPath: 'assets/stickers/happy_brain.png',
        category: StickerCategory.brainCharacters,
      ),
      Sticker(
        id: 'thinking_brain',
        name: 'Thinking Brain',
        assetPath: 'assets/stickers/thinking_brain.png',
        category: StickerCategory.brainCharacters,
      ),
      Sticker(
        id: 'winner_brain',
        name: 'Winner Brain',
        assetPath: 'assets/stickers/winner_brain.png',
        category: StickerCategory.brainCharacters,
      ),
      // Achievement Stickers
      Sticker(
        id: 'level_up',
        name: 'Level Up!',
        assetPath: 'assets/stickers/level_up.png',
        category: StickerCategory.achievements,
      ),
      Sticker(
        id: 'super_smart',
        name: 'Super Smart!',
        assetPath: 'assets/stickers/super_smart.png',
        category: StickerCategory.achievements,
      ),
      Sticker(
        id: 'mini_genius',
        name: 'Mini Genius!',
        assetPath: 'assets/stickers/mini_genius.png',
        category: StickerCategory.achievements,
      ),
      // Reward Items
      Sticker(
        id: 'star_badge',
        name: 'Star Badge',
        assetPath: 'assets/stickers/star_badge.png',
        category: StickerCategory.rewards,
      ),
      Sticker(
        id: 'trophy',
        name: 'Trophy',
        assetPath: 'assets/stickers/trophy.png',
        category: StickerCategory.rewards,
      ),
      Sticker(
        id: 'colorful_badge',
        name: 'Colorful Badge',
        assetPath: 'assets/stickers/colorful_badge.png',
        category: StickerCategory.rewards,
      ),
    ];
  }

  static List<Sticker> getStickersByCategory(StickerCategory category) {
    return getAllStickers().where((s) => s.category == category).toList();
  }
}

