class ChildProfile {
  final String id;
  String name;
  String avatar;
  int age;
  bool isScreenTimeEnabled;
  int dailyLimitMinutes; // 0 = unlimited / disabled, 15, 30, 45, 60, 90, 120
  int secondsUsedToday;
  String lastActiveDate; // Format: YYYY-MM-DD
  bool isTemporarilyUnlocked; // Unlocked by parent for rest of today

  ChildProfile({
    required this.id,
    required this.name,
    this.avatar = 'boy',
    this.age = 6,
    this.isScreenTimeEnabled = false,
    this.dailyLimitMinutes = 30,
    this.secondsUsedToday = 0,
    String? lastActiveDate,
    this.isTemporarilyUnlocked = false,
  }) : lastActiveDate = lastActiveDate ?? _getTodayDateString();

  static String _getTodayDateString() {
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
  }

  void checkAndResetDaily() {
    final today = _getTodayDateString();
    if (lastActiveDate != today) {
      secondsUsedToday = 0;
      lastActiveDate = today;
      isTemporarilyUnlocked = false;
    }
  }

  int get remainingSeconds {
    checkAndResetDaily();
    if (!isScreenTimeEnabled || dailyLimitMinutes <= 0 || isTemporarilyUnlocked) {
      return 999999;
    }
    final totalLimitSeconds = dailyLimitMinutes * 60;
    final diff = totalLimitSeconds - secondsUsedToday;
    return diff > 0 ? diff : 0;
  }

  int get remainingMinutes {
    final remSec = remainingSeconds;
    if (remSec >= 999999) return -1; // Unlimited
    return (remSec / 60).ceil();
  }

  bool get isLimitReached {
    checkAndResetDaily();
    if (!isScreenTimeEnabled || dailyLimitMinutes <= 0 || isTemporarilyUnlocked) {
      return false;
    }
    return secondsUsedToday >= (dailyLimitMinutes * 60);
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'avatar': avatar,
      'age': age,
      'isScreenTimeEnabled': isScreenTimeEnabled,
      'dailyLimitMinutes': dailyLimitMinutes,
      'secondsUsedToday': secondsUsedToday,
      'lastActiveDate': lastActiveDate,
      'isTemporarilyUnlocked': isTemporarilyUnlocked,
    };
  }

  factory ChildProfile.fromJson(Map<String, dynamic> json) {
    return ChildProfile(
      id: json['id'] as String? ?? 'default_child',
      name: json['name'] as String? ?? 'بطلنا الصغير',
      avatar: json['avatar'] as String? ?? 'boy',
      age: (json['age'] as num?)?.toInt() ?? 6,
      isScreenTimeEnabled: json['isScreenTimeEnabled'] as bool? ?? false,
      dailyLimitMinutes: (json['dailyLimitMinutes'] as num?)?.toInt() ?? 30,
      secondsUsedToday: (json['secondsUsedToday'] as num?)?.toInt() ?? 0,
      lastActiveDate: json['lastActiveDate'] as String?,
      isTemporarilyUnlocked: json['isTemporarilyUnlocked'] as bool? ?? false,
    );
  }

  ChildProfile copyWith({
    String? id,
    String? name,
    String? avatar,
    int? age,
    bool? isScreenTimeEnabled,
    int? dailyLimitMinutes,
    int? secondsUsedToday,
    String? lastActiveDate,
    bool? isTemporarilyUnlocked,
  }) {
    return ChildProfile(
      id: id ?? this.id,
      name: name ?? this.name,
      avatar: avatar ?? this.avatar,
      age: age ?? this.age,
      isScreenTimeEnabled: isScreenTimeEnabled ?? this.isScreenTimeEnabled,
      dailyLimitMinutes: dailyLimitMinutes ?? this.dailyLimitMinutes,
      secondsUsedToday: secondsUsedToday ?? this.secondsUsedToday,
      lastActiveDate: lastActiveDate ?? this.lastActiveDate,
      isTemporarilyUnlocked:
          isTemporarilyUnlocked ?? this.isTemporarilyUnlocked,
    );
  }
}
