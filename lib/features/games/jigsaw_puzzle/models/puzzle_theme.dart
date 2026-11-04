import 'package:flutter/material.dart';

class PuzzleScene {
  final int level;
  final String titleAr;
  final String titleEn;
  final IconData mainIcon;
  final List<Color> backgroundGradient;
  final List<PuzzleElement> elements;

  const PuzzleScene({
    required this.level,
    required this.titleAr,
    required this.titleEn,
    required this.mainIcon,
    required this.backgroundGradient,
    required this.elements,
  });
}

class PuzzleElement {
  final IconData icon;
  final Color color;
  final double x; // 0.0 to 1.0 (relative position)
  final double y; // 0.0 to 1.0
  final double size;

  const PuzzleElement({
    required this.icon,
    required this.color,
    required this.x,
    required this.y,
    this.size = 36,
  });
}

class PuzzleLibrary {
  static final List<PuzzleScene> scenes = [
    // Level 1: الحديقة اللطيفة
    const PuzzleScene(
      level: 1,
      titleAr: 'حديقة الحيوانات اللطيفة',
      titleEn: 'Sunny Park & Pets',
      mainIcon: Icons.pets_rounded,
      backgroundGradient: [Color(0xFF81D4FA), Color(0xFFA5D6A7)],
      elements: [
        PuzzleElement(icon: Icons.wb_sunny_rounded, color: Colors.amber, x: 0.8, y: 0.15, size: 48),
        PuzzleElement(icon: Icons.cloud_rounded, color: Colors.white, x: 0.25, y: 0.2, size: 40),
        PuzzleElement(icon: Icons.pets_rounded, color: Colors.brown, x: 0.5, y: 0.65, size: 44),
        PuzzleElement(icon: Icons.park_rounded, color: Colors.green, x: 0.15, y: 0.6, size: 50),
        PuzzleElement(icon: Icons.local_florist_rounded, color: Colors.pink, x: 0.8, y: 0.75, size: 32),
      ],
    ),
    // Level 2: الفضاء الخارق
    const PuzzleScene(
      level: 2,
      titleAr: 'سفينة الفضاء والكواكب',
      titleEn: 'Space Rocket & Orbit',
      mainIcon: Icons.rocket_launch_rounded,
      backgroundGradient: [Color(0xFF0D1B2A), Color(0xFF1B263B)],
      elements: [
        PuzzleElement(icon: Icons.rocket_launch_rounded, color: Colors.deepOrange, x: 0.5, y: 0.5, size: 52),
        PuzzleElement(icon: Icons.public_rounded, color: Colors.blueAccent, x: 0.2, y: 0.25, size: 46),
        PuzzleElement(icon: Icons.brightness_3_rounded, color: Colors.amberAccent, x: 0.8, y: 0.2, size: 38),
        PuzzleElement(icon: Icons.star_rounded, color: Colors.yellow, x: 0.35, y: 0.8, size: 28),
        PuzzleElement(icon: Icons.auto_awesome_rounded, color: Colors.cyanAccent, x: 0.75, y: 0.7, size: 30),
      ],
    ),
    // Level 3: أعماق البحار
    const PuzzleScene(
      level: 3,
      titleAr: 'أعماق البحار والدلافين',
      titleEn: 'Ocean & Dolphins',
      mainIcon: Icons.sailing_rounded,
      backgroundGradient: [Color(0xFF0077B6), Color(0xFF023E8A)],
      elements: [
        PuzzleElement(icon: Icons.phishing_rounded, color: Colors.orangeAccent, x: 0.45, y: 0.5, size: 48),
        PuzzleElement(icon: Icons.bubble_chart_rounded, color: Colors.white70, x: 0.2, y: 0.3, size: 32),
        PuzzleElement(icon: Icons.anchor_rounded, color: Colors.grey, x: 0.8, y: 0.75, size: 40),
        PuzzleElement(icon: Icons.water_rounded, color: Colors.cyanAccent, x: 0.2, y: 0.75, size: 36),
        PuzzleElement(icon: Icons.sailing_rounded, color: Colors.amber, x: 0.5, y: 0.15, size: 42),
      ],
    ),
    // Level 4: المزرعة السعيدة
    const PuzzleScene(
      level: 4,
      titleAr: 'المزرعة السعيدة',
      titleEn: 'Happy Barn & Farm',
      mainIcon: Icons.agriculture_rounded,
      backgroundGradient: [Color(0xFFE9EDC9), Color(0xFFCCD5AE)],
      elements: [
        PuzzleElement(icon: Icons.cottage_rounded, color: Colors.redAccent, x: 0.5, y: 0.45, size: 52),
        PuzzleElement(icon: Icons.agriculture_rounded, color: Colors.green, x: 0.2, y: 0.7, size: 40),
        PuzzleElement(icon: Icons.cruelty_free_rounded, color: Colors.white, x: 0.75, y: 0.7, size: 38),
        PuzzleElement(icon: Icons.wb_sunny_rounded, color: Colors.amber, x: 0.8, y: 0.15, size: 42),
      ],
    ),
    // Level 5: غابة السفاري
    const PuzzleScene(
      level: 5,
      titleAr: 'غابة السفاري والمغامرة',
      titleEn: 'Safari Adventure',
      mainIcon: Icons.forest_rounded,
      backgroundGradient: [Color(0xFFD4A373), Color(0xFF606C38)],
      elements: [
        PuzzleElement(icon: Icons.forest_rounded, color: Color(0xFF1B5E20), x: 0.2, y: 0.5, size: 54),
        PuzzleElement(icon: Icons.camera_alt_rounded, color: Colors.deepOrange, x: 0.75, y: 0.6, size: 40),
        PuzzleElement(icon: Icons.landscape_rounded, color: Colors.brown, x: 0.5, y: 0.3, size: 48),
        PuzzleElement(icon: Icons.explore_rounded, color: Colors.amber, x: 0.5, y: 0.8, size: 36),
      ],
    ),
    // Level 6: مدينة الألعاب والملاهي
    const PuzzleScene(
      level: 6,
      titleAr: 'مدينة الملاهي السحرية',
      titleEn: 'Fun Fair & Circus',
      mainIcon: Icons.attractions_rounded,
      backgroundGradient: [Color(0xFFFFB4D6), Color(0xFFC77DFF)],
      elements: [
        PuzzleElement(icon: Icons.attractions_rounded, color: Colors.purple, x: 0.5, y: 0.4, size: 56),
        PuzzleElement(icon: Icons.celebration_rounded, color: Colors.yellowAccent, x: 0.2, y: 0.2, size: 40),
        PuzzleElement(icon: Icons.icecream_rounded, color: Colors.pinkAccent, x: 0.2, y: 0.75, size: 38),
        PuzzleElement(icon: Icons.music_note_rounded, color: Colors.white, x: 0.8, y: 0.6, size: 36),
      ],
    ),
    // Level 7: قطار الألعاب السريع
    const PuzzleScene(
      level: 7,
      titleAr: 'قطار الألعاب السريع',
      titleEn: 'Toy Train Express',
      mainIcon: Icons.train_rounded,
      backgroundGradient: [Color(0xFFBDE0FE), Color(0xFFA2D2FF)],
      elements: [
        PuzzleElement(icon: Icons.train_rounded, color: Color(0xFFD32F2F), x: 0.5, y: 0.6, size: 56),
        PuzzleElement(icon: Icons.cloud_circle_rounded, color: Colors.white, x: 0.3, y: 0.3, size: 34),
        PuzzleElement(icon: Icons.add_road_rounded, color: Colors.black54, x: 0.5, y: 0.85, size: 46),
        PuzzleElement(icon: Icons.wb_twilight_rounded, color: Colors.orange, x: 0.8, y: 0.2, size: 40),
      ],
    ),
    // Level 8: قلعة الفرسان
    const PuzzleScene(
      level: 8,
      titleAr: 'قلعة الفرسان والملوك',
      titleEn: 'Knights & Castle',
      mainIcon: Icons.castle_rounded,
      backgroundGradient: [Color(0xFFE0E1DD), Color(0xFF778DA9)],
      elements: [
        PuzzleElement(icon: Icons.castle_rounded, color: Color(0xFF415A77), x: 0.5, y: 0.45, size: 60),
        PuzzleElement(icon: Icons.shield_rounded, color: Colors.amber, x: 0.2, y: 0.7, size: 38),
        PuzzleElement(icon: Icons.flag_rounded, color: Colors.redAccent, x: 0.5, y: 0.15, size: 36),
        PuzzleElement(icon: Icons.military_tech_rounded, color: Colors.yellow, x: 0.8, y: 0.7, size: 38),
      ],
    ),
    // Level 9: عالم الديناصورات
    const PuzzleScene(
      level: 9,
      titleAr: 'عالم الديناصورات والبراكين',
      titleEn: 'Dino Valley & Volcano',
      mainIcon: Icons.volcano_rounded,
      backgroundGradient: [Color(0xFFF39A59), Color(0xFFE76F51)],
      elements: [
        PuzzleElement(icon: Icons.volcano_rounded, color: Color(0xFFB71C1C), x: 0.3, y: 0.4, size: 56),
        PuzzleElement(icon: Icons.egg_rounded, color: Color(0xFFFFE082), x: 0.75, y: 0.7, size: 40),
        PuzzleElement(icon: Icons.whatshot_rounded, color: Colors.orangeAccent, x: 0.3, y: 0.15, size: 36),
        PuzzleElement(icon: Icons.nature_rounded, color: Color(0xFF2E7D32), x: 0.8, y: 0.4, size: 44),
      ],
    ),
    // Level 10: حفل عيد الميلاد
    const PuzzleScene(
      level: 10,
      titleAr: 'حفل عيد الميلاد والبالونات',
      titleEn: 'Birthday Celebration',
      mainIcon: Icons.cake_rounded,
      backgroundGradient: [Color(0xFFFFD166), Color(0xFFEF476F)],
      elements: [
        PuzzleElement(icon: Icons.cake_rounded, color: Colors.white, x: 0.5, y: 0.55, size: 56),
        PuzzleElement(icon: Icons.card_giftcard_rounded, color: Colors.cyanAccent, x: 0.2, y: 0.75, size: 40),
        PuzzleElement(icon: Icons.celebration_rounded, color: Colors.amberAccent, x: 0.8, y: 0.25, size: 44),
        PuzzleElement(icon: Icons.favorite_rounded, color: Colors.redAccent, x: 0.2, y: 0.25, size: 32),
      ],
    ),

    // 👑 VIP PRO LEVELS (11 - 20)
    // Level 11: رواد الفضاء على القمر
    const PuzzleScene(
      level: 11,
      titleAr: 'رواد الفضاء على سطح القمر',
      titleEn: 'Moonwalkers & Apollo',
      mainIcon: Icons.brightness_2_rounded,
      backgroundGradient: [Color(0xFF03071E), Color(0xFF370617)],
      elements: [
        PuzzleElement(icon: Icons.brightness_2_rounded, color: Colors.amberAccent, x: 0.5, y: 0.35, size: 60),
        PuzzleElement(icon: Icons.sports_score_rounded, color: Colors.blueAccent, x: 0.2, y: 0.65, size: 40),
        PuzzleElement(icon: Icons.flag_circle_rounded, color: Colors.red, x: 0.75, y: 0.65, size: 42),
        PuzzleElement(icon: Icons.star_border_purple500_rounded, color: Colors.yellow, x: 0.8, y: 0.15, size: 32),
      ],
    ),
    // Level 12: مدينة الروبوتات المستقبلية
    const PuzzleScene(
      level: 12,
      titleAr: 'مدينة الروبوتات المستقبلية',
      titleEn: 'Cyber Robot Metropolis',
      mainIcon: Icons.smart_toy_rounded,
      backgroundGradient: [Color(0xFF14213D), Color(0xFF000000)],
      elements: [
        PuzzleElement(icon: Icons.smart_toy_rounded, color: Colors.cyanAccent, x: 0.5, y: 0.5, size: 60),
        PuzzleElement(icon: Icons.memory_rounded, color: Colors.greenAccent, x: 0.2, y: 0.2, size: 40),
        PuzzleElement(icon: Icons.battery_charging_full_rounded, color: Colors.amber, x: 0.8, y: 0.25, size: 38),
        PuzzleElement(icon: Icons.electric_bolt_rounded, color: Colors.yellowAccent, x: 0.5, y: 0.85, size: 36),
      ],
    ),
    // Level 13: سفينة القراصنة والكنز
    const PuzzleScene(
      level: 13,
      titleAr: 'سفينة القراصنة وجزيرة الكنز',
      titleEn: 'Pirate Ship & Treasure',
      mainIcon: Icons.directions_boat_rounded,
      backgroundGradient: [Color(0xFF003049), Color(0xFF669BBC)],
      elements: [
        PuzzleElement(icon: Icons.directions_boat_rounded, color: Color(0xFF5D4037), x: 0.45, y: 0.45, size: 62),
        PuzzleElement(icon: Icons.diamond_rounded, color: Colors.amberAccent, x: 0.8, y: 0.75, size: 42),
        PuzzleElement(icon: Icons.map_rounded, color: Color(0xFFDDA15E), x: 0.2, y: 0.7, size: 38),
        PuzzleElement(icon: Icons.waves_rounded, color: Colors.white70, x: 0.5, y: 0.85, size: 44),
      ],
    ),
    // Level 14: قاع المحيط والمرجان
    const PuzzleScene(
      level: 14,
      titleAr: 'قاع المحيط والمرجان السحري',
      titleEn: 'Coral Kingdom & Pearl',
      mainIcon: Icons.water_drop_rounded,
      backgroundGradient: [Color(0xFF001219), Color(0xFF005F73)],
      elements: [
        PuzzleElement(icon: Icons.wb_twilight_rounded, color: Colors.pinkAccent, x: 0.5, y: 0.5, size: 58),
        PuzzleElement(icon: Icons.bubble_chart_rounded, color: Colors.cyanAccent, x: 0.2, y: 0.3, size: 40),
        PuzzleElement(icon: Icons.blur_on_rounded, color: Colors.yellowAccent, x: 0.8, y: 0.7, size: 42),
        PuzzleElement(icon: Icons.filter_vintage_rounded, color: Colors.tealAccent, x: 0.2, y: 0.8, size: 38),
      ],
    ),
    // Level 15: المناطيد وقوس قزح
    const PuzzleScene(
      level: 15,
      titleAr: 'منطاد الهواء وقوس قزح',
      titleEn: 'Hot Air Balloons & Rainbow',
      mainIcon: Icons.airplanemode_active_rounded,
      backgroundGradient: [Color(0xFF48CAE4), Color(0xFFADE8F4)],
      elements: [
        PuzzleElement(icon: Icons.cloud_sync_rounded, color: Colors.pink, x: 0.45, y: 0.35, size: 60),
        PuzzleElement(icon: Icons.wb_sunny_rounded, color: Colors.amber, x: 0.85, y: 0.15, size: 44),
        PuzzleElement(icon: Icons.filter_drama_rounded, color: Colors.white, x: 0.15, y: 0.6, size: 48),
        PuzzleElement(icon: Icons.all_inclusive_rounded, color: Colors.purpleAccent, x: 0.6, y: 0.75, size: 40),
      ],
    ),
    // Level 16: أرض الحلويات
    const PuzzleScene(
      level: 16,
      titleAr: 'أرض السكاكر والحلويات',
      titleEn: 'Candy Wonderland',
      mainIcon: Icons.cookie_rounded,
      backgroundGradient: [Color(0xFFFFB3C1), Color(0xFFFF4D6D)],
      elements: [
        PuzzleElement(icon: Icons.cookie_rounded, color: Color(0xFFFF8F00), x: 0.5, y: 0.45, size: 60),
        PuzzleElement(icon: Icons.icecream_rounded, color: Colors.white, x: 0.2, y: 0.65, size: 44),
        PuzzleElement(icon: Icons.local_pizza_rounded, color: Colors.yellow, x: 0.8, y: 0.65, size: 40),
        PuzzleElement(icon: Icons.auto_awesome_rounded, color: Colors.cyanAccent, x: 0.75, y: 0.2, size: 34),
      ],
    ),
    // Level 17: القطب الشمالي والبطاريق
    const PuzzleScene(
      level: 17,
      titleAr: 'القطب الشمالي والجليد',
      titleEn: 'Arctic Ice & Polar Bears',
      mainIcon: Icons.ac_unit_rounded,
      backgroundGradient: [Color(0xFFD8F3DC), Color(0xFF95D5B2)],
      elements: [
        PuzzleElement(icon: Icons.ac_unit_rounded, color: Colors.white, x: 0.5, y: 0.4, size: 64),
        PuzzleElement(icon: Icons.downhill_skiing_rounded, color: Color(0xFF0D47A1), x: 0.2, y: 0.7, size: 42),
        PuzzleElement(icon: Icons.snowboarding_rounded, color: Color(0xFF004D40), x: 0.8, y: 0.7, size: 40),
        PuzzleElement(icon: Icons.severe_cold_rounded, color: Colors.lightBlueAccent, x: 0.2, y: 0.2, size: 36),
      ],
    ),
    // Level 18: الغابة السحرية
    const PuzzleScene(
      level: 18,
      titleAr: 'الغابة السحرية والفراشات',
      titleEn: 'Enchanted Butterfly Woods',
      mainIcon: Icons.flare_rounded,
      backgroundGradient: [Color(0xFF2B2D42), Color(0xFF8D99AE)],
      elements: [
        PuzzleElement(icon: Icons.flutter_dash_rounded, color: Colors.pinkAccent, x: 0.5, y: 0.4, size: 60),
        PuzzleElement(icon: Icons.spa_rounded, color: Colors.greenAccent, x: 0.2, y: 0.65, size: 44),
        PuzzleElement(icon: Icons.flare_rounded, color: Colors.amberAccent, x: 0.8, y: 0.25, size: 40),
        PuzzleElement(icon: Icons.nights_stay_rounded, color: Colors.yellow, x: 0.2, y: 0.15, size: 36),
      ],
    ),
    // Level 19: الأبطال الخارقون
    const PuzzleScene(
      level: 19,
      titleAr: 'أبطال العدالة الخارقون',
      titleEn: 'Flying Superheroes',
      mainIcon: Icons.flash_on_rounded,
      backgroundGradient: [Color(0xFF7209B7), Color(0xFF3F37C9)],
      elements: [
        PuzzleElement(icon: Icons.flash_on_rounded, color: Colors.yellowAccent, x: 0.5, y: 0.45, size: 64),
        PuzzleElement(icon: Icons.shield_moon_rounded, color: Colors.cyanAccent, x: 0.2, y: 0.7, size: 42),
        PuzzleElement(icon: Icons.airline_stops_rounded, color: Colors.white, x: 0.8, y: 0.2, size: 40),
        PuzzleElement(icon: Icons.verified_user_rounded, color: Colors.amber, x: 0.8, y: 0.7, size: 38),
      ],
    ),
    // Level 20: القلعة الذهبية الكبرى
    const PuzzleScene(
      level: 20,
      titleAr: 'القلعة الذهبية الكبرى',
      titleEn: 'Grand Golden Palace',
      mainIcon: Icons.workspace_premium_rounded,
      backgroundGradient: [Color(0xFF3D2600), Color(0xFF8A5A00)],
      elements: [
        PuzzleElement(icon: Icons.workspace_premium_rounded, color: Color(0xFFFFD54F), x: 0.5, y: 0.35, size: 68),
        PuzzleElement(icon: Icons.castle_rounded, color: Colors.white, x: 0.5, y: 0.75, size: 50),
        PuzzleElement(icon: Icons.diamond_rounded, color: Colors.cyanAccent, x: 0.18, y: 0.3, size: 40),
        PuzzleElement(icon: Icons.military_tech_rounded, color: Colors.amberAccent, x: 0.82, y: 0.3, size: 40),
      ],
    ),
  ];

  static PuzzleScene getSceneForLevel(int level) {
    if (level < 1) return scenes.first;
    if (level > scenes.length) return scenes.last;
    return scenes[level - 1];
  }
}

