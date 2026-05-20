class Badge {
  final String id;
  final String name;
  final String description;
  final String iconAsset;
  final BadgeType type;
  final int? requiredValue;

  Badge({
    required this.id,
    required this.name,
    required this.description,
    required this.iconAsset,
    required this.type,
    this.requiredValue,
  });
}

enum BadgeType {
  totalStars,
  totalPoints,
  levelsCompleted,
  consecutiveDays,
  gameSpecific,
}

class BadgeDefinitions {
  static List<Badge> getAllBadges() {
    return [
      Badge(
        id: 'first_star',
        name: 'First Star',
        description: 'Earn your first star',
        iconAsset: 'assets/badges/first_star.png',
        type: BadgeType.totalStars,
        requiredValue: 1,
      ),
      Badge(
        id: 'star_collector',
        name: 'Star Collector',
        description: 'Collect 50 stars',
        iconAsset: 'assets/badges/star_collector.png',
        type: BadgeType.totalStars,
        requiredValue: 50,
      ),
      Badge(
        id: 'star_master',
        name: 'Star Master',
        description: 'Collect 200 stars',
        iconAsset: 'assets/badges/star_master.png',
        type: BadgeType.totalStars,
        requiredValue: 200,
      ),
      Badge(
        id: 'first_level',
        name: 'Getting Started',
        description: 'Complete your first level',
        iconAsset: 'assets/badges/first_level.png',
        type: BadgeType.levelsCompleted,
        requiredValue: 1,
      ),
      Badge(
        id: 'level_expert',
        name: 'Level Expert',
        description: 'Complete 50 levels',
        iconAsset: 'assets/badges/level_expert.png',
        type: BadgeType.levelsCompleted,
        requiredValue: 50,
      ),
      Badge(
        id: 'daily_player',
        name: 'Daily Player',
        description: 'Play for 7 consecutive days',
        iconAsset: 'assets/badges/daily_player.png',
        type: BadgeType.consecutiveDays,
        requiredValue: 7,
      ),
      Badge(
        id: 'dedicated',
        name: 'Dedicated',
        description: 'Play for 30 consecutive days',
        iconAsset: 'assets/badges/dedicated.png',
        type: BadgeType.consecutiveDays,
        requiredValue: 30,
      ),
    ];
  }
}

