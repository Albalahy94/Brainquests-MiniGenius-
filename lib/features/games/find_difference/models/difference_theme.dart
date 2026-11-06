import 'package:flutter/material.dart';

class DifferenceElement {
  final IconData icon;
  final Color color;
  final double x; // 0.0 - 1.0 (relative width)
  final double y; // 0.0 - 1.0 (relative height)
  final double size;

  const DifferenceElement({
    required this.icon,
    required this.color,
    required this.x,
    required this.y,
    this.size = 32,
  });
}

class DifferenceSpot {
  final int id;
  final double x; // 0.0 - 1.0
  final double y; // 0.0 - 1.0
  final IconData icon;
  final Color color;
  final double size;
  final String hintAr;
  final String hintEn;
  bool isFound;

  DifferenceSpot({
    required this.id,
    required this.x,
    required this.y,
    required this.icon,
    required this.color,
    this.size = 34,
    required this.hintAr,
    required this.hintEn,
    this.isFound = false,
  });

  DifferenceSpot clone() {
    return DifferenceSpot(
      id: id,
      x: x,
      y: y,
      icon: icon,
      color: color,
      size: size,
      hintAr: hintAr,
      hintEn: hintEn,
      isFound: false,
    );
  }
}

class DifferenceScene {
  final int level;
  final String titleAr;
  final String titleEn;
  final IconData mainIcon;
  final String? imageAsset;
  final List<Color> backgroundGradient;
  final List<DifferenceElement> baseElements;
  final List<DifferenceSpot> differences;

  const DifferenceScene({
    required this.level,
    required this.titleAr,
    required this.titleEn,
    required this.mainIcon,
    this.imageAsset,
    required this.backgroundGradient,
    required this.baseElements,
    required this.differences,
  });
}

class DifferenceLibrary {
  static final List<DifferenceScene> scenes = [
    // Level 1: حديقة الأشجار والطبيعة (Sunny Park & Trees) - 3 differences
    DifferenceScene(
      level: 1,
      titleAr: 'حديقة الأشجار والطبيعة',
      titleEn: 'Sunny Nature Park',
      mainIcon: Icons.park_rounded,
      imageAsset: 'assets/images/cartoon_park.png',
      backgroundGradient: [const Color(0xFF81D4FA), const Color(0xFFA5D6A7)],
      baseElements: const [
        DifferenceElement(icon: Icons.wb_sunny_rounded, color: Colors.amber, x: 0.82, y: 0.15, size: 44),
        DifferenceElement(icon: Icons.cloud_rounded, color: Colors.white, x: 0.22, y: 0.18, size: 38),
        DifferenceElement(icon: Icons.local_florist_rounded, color: Colors.pink, x: 0.85, y: 0.78, size: 30),
      ],
      differences: [
        DifferenceSpot(id: 0, x: 0.52, y: 0.22, icon: Icons.cloud_outlined, color: Colors.white, size: 36, hintAr: 'سحابة بيضاء في السماء', hintEn: 'White cloud in sky'),
        DifferenceSpot(id: 1, x: 0.28, y: 0.75, icon: Icons.local_florist_rounded, color: Colors.orange, size: 30, hintAr: 'زهرة برتقالية على العشب', hintEn: 'Orange flower on grass'),
        DifferenceSpot(id: 2, x: 0.72, y: 0.45, icon: Icons.flutter_dash_rounded, color: Colors.blueAccent, size: 32, hintAr: 'عصفور أزرق بين الأشجار', hintEn: 'Blue bird among trees'),
      ],
    ),

    // Level 2: الفضاء الخارق والكواكب (Space Odyssey & Stars) - 3 differences
    DifferenceScene(
      level: 2,
      titleAr: 'رحلة الصاروخ إلى الفضاء',
      titleEn: 'Space Odyssey & Stars',
      mainIcon: Icons.rocket_launch_rounded,
      backgroundGradient: [const Color(0xFF0F2027), const Color(0xFF203A43), const Color(0xFF2C5364)],
      baseElements: const [
        DifferenceElement(icon: Icons.rocket_launch_rounded, color: Colors.deepOrangeAccent, x: 0.5, y: 0.45, size: 54),
        DifferenceElement(icon: Icons.public_rounded, color: Colors.lightBlueAccent, x: 0.2, y: 0.25, size: 44),
        DifferenceElement(icon: Icons.brightness_3_rounded, color: Colors.amberAccent, x: 0.82, y: 0.2, size: 38),
        DifferenceElement(icon: Icons.star_rounded, color: Colors.yellow, x: 0.25, y: 0.78, size: 26),
      ],
      differences: [
        DifferenceSpot(id: 0, x: 0.78, y: 0.68, icon: Icons.satellite_alt_rounded, color: Colors.tealAccent, size: 32, hintAr: 'قمر صناعي', hintEn: 'Satellite'),
        DifferenceSpot(id: 1, x: 0.4, y: 0.82, icon: Icons.auto_awesome_rounded, color: Colors.cyanAccent, size: 28, hintAr: 'نجم مشع', hintEn: 'Shining star'),
        DifferenceSpot(id: 2, x: 0.65, y: 0.28, icon: Icons.stars_rounded, color: Colors.pinkAccent, size: 30, hintAr: 'شهاب ملون', hintEn: 'Shooting star'),
      ],
    ),

    // Level 3: أعماق البحار والشعب المرجانية (Ocean Reef & Fishes) - 4 differences
    DifferenceScene(
      level: 3,
      titleAr: 'أعماق البحار والشعب المرجانية',
      titleEn: 'Ocean Reef & Fishes',
      mainIcon: Icons.phishing_rounded,
      backgroundGradient: [const Color(0xFF0077B6), const Color(0xFF023E8A), const Color(0xFF03045E)],
      baseElements: const [
        DifferenceElement(icon: Icons.phishing_rounded, color: Colors.orangeAccent, x: 0.45, y: 0.45, size: 48),
        DifferenceElement(icon: Icons.bubble_chart_rounded, color: Colors.white70, x: 0.2, y: 0.3, size: 30),
        DifferenceElement(icon: Icons.anchor_rounded, color: Colors.blueGrey, x: 0.8, y: 0.75, size: 42),
        DifferenceElement(icon: Icons.water_rounded, color: Colors.cyanAccent, x: 0.22, y: 0.75, size: 36),
      ],
      differences: [
        DifferenceSpot(id: 0, x: 0.25, y: 0.52, icon: Icons.cruelty_free_rounded, color: Colors.pinkAccent, size: 30, hintAr: 'سمكة نجمية وردية', hintEn: 'Pink starfish'),
        DifferenceSpot(id: 1, x: 0.72, y: 0.35, icon: Icons.bubble_chart_rounded, color: Colors.cyanAccent, size: 26, hintAr: 'فقاعات مائية', hintEn: 'Water bubbles'),
        DifferenceSpot(id: 2, x: 0.55, y: 0.8, icon: Icons.diamond_rounded, color: Colors.amber, size: 28, hintAr: 'لؤلؤة ثمينة', hintEn: 'Precious pearl'),
        DifferenceSpot(id: 3, x: 0.82, y: 0.2, icon: Icons.sailing_rounded, color: Colors.white, size: 32, hintAr: 'قارب صغير في السطح', hintEn: 'Surface boat'),
      ],
    ),

    // Level 4: المزرعة السعيدة والجرار (Green Farm & Barn) - 4 differences
    DifferenceScene(
      level: 4,
      titleAr: 'المزرعة الخضراء السعيدة',
      titleEn: 'Green Farm & Barn',
      mainIcon: Icons.agriculture_rounded,
      imageAsset: 'assets/images/cartoon_park.png',
      backgroundGradient: [const Color(0xFFE9EDC9), const Color(0xFFCCD5AE), const Color(0xFF588157)],
      baseElements: const [
        DifferenceElement(icon: Icons.cottage_rounded, color: Colors.redAccent, x: 0.5, y: 0.42, size: 52),
        DifferenceElement(icon: Icons.wb_sunny_rounded, color: Colors.amber, x: 0.82, y: 0.15, size: 42),
        DifferenceElement(icon: Icons.agriculture_rounded, color: Colors.green, x: 0.2, y: 0.68, size: 40),
        DifferenceElement(icon: Icons.cruelty_free_rounded, color: Colors.brown, x: 0.75, y: 0.7, size: 36),
      ],
      differences: [
        DifferenceSpot(id: 0, x: 0.5, y: 0.24, icon: Icons.flutter_dash_rounded, color: Colors.red, size: 28, hintAr: 'ديك على السطح', hintEn: 'Rooster on roof'),
        DifferenceSpot(id: 1, x: 0.38, y: 0.78, icon: Icons.local_florist_rounded, color: Colors.yellow, size: 26, hintAr: 'زهرة عباد الشمس', hintEn: 'Sunflower'),
        DifferenceSpot(id: 2, x: 0.25, y: 0.2, icon: Icons.cloud_rounded, color: Colors.white, size: 34, hintAr: 'سحابة قطنية', hintEn: 'Cotton cloud'),
        DifferenceSpot(id: 3, x: 0.85, y: 0.82, icon: Icons.grass_rounded, color: Colors.lightGreenAccent, size: 28, hintAr: 'حزمة قش', hintEn: 'Haystack'),
      ],
    ),

    // Level 5: غابة السفاري الاستوائية (Safari Jungle) - 4 differences
    DifferenceScene(
      level: 5,
      titleAr: 'سفاري الحيوانات البرية',
      titleEn: 'Wild Safari Expedition',
      mainIcon: Icons.forest_rounded,
      imageAsset: 'assets/images/cartoon_park.png',
      backgroundGradient: [const Color(0xFF556B2F), const Color(0xFF2E8B57), const Color(0xFF1B4332)],
      baseElements: const [
        DifferenceElement(icon: Icons.forest_rounded, color: Colors.green, x: 0.18, y: 0.4, size: 50),
        DifferenceElement(icon: Icons.forest_rounded, color: Colors.lightGreen, x: 0.82, y: 0.45, size: 46),
        DifferenceElement(icon: Icons.wb_sunny_rounded, color: Colors.deepOrange, x: 0.5, y: 0.18, size: 42),
        DifferenceElement(icon: Icons.pets_rounded, color: Colors.amber, x: 0.48, y: 0.7, size: 44),
      ],
      differences: [
        DifferenceSpot(id: 0, x: 0.15, y: 0.78, icon: Icons.bug_report_rounded, color: Colors.redAccent, size: 28, hintAr: 'خنفساء ملونة', hintEn: 'Color beetle'),
        DifferenceSpot(id: 1, x: 0.32, y: 0.3, icon: Icons.flutter_dash_rounded, color: Colors.cyanAccent, size: 30, hintAr: 'ببغاء استوائي', hintEn: 'Tropical parrot'),
        DifferenceSpot(id: 2, x: 0.72, y: 0.75, icon: Icons.grass_rounded, color: Colors.limeAccent, size: 30, hintAr: 'أعشاب كثيفة', hintEn: 'Tall grass'),
        DifferenceSpot(id: 3, x: 0.85, y: 0.22, icon: Icons.cloud_queue_rounded, color: Colors.white60, size: 32, hintAr: 'غيمة رقيقة', hintEn: 'Thin cloud'),
      ],
    ),

    // Level 6: مدينة الملاهي والكرنفال (Carnival & Ferris Wheel) - 4 differences
    DifferenceScene(
      level: 6,
      titleAr: 'مدينة الملاهي والكرنفال',
      titleEn: 'Carnival & Amusement Park',
      mainIcon: Icons.attractions_rounded,
      backgroundGradient: [const Color(0xFFFF9A9E), const Color(0xFFFECFEF), const Color(0xFFA1C4FD)],
      baseElements: const [
        DifferenceElement(icon: Icons.attractions_rounded, color: Colors.purple, x: 0.5, y: 0.42, size: 56),
        DifferenceElement(icon: Icons.celebration_rounded, color: Colors.deepOrange, x: 0.2, y: 0.3, size: 38),
        DifferenceElement(icon: Icons.star_rounded, color: Colors.yellow, x: 0.8, y: 0.2, size: 32),
        DifferenceElement(icon: Icons.festival_rounded, color: Colors.redAccent, x: 0.22, y: 0.7, size: 44),
      ],
      differences: [
        DifferenceSpot(id: 0, x: 0.75, y: 0.65, icon: Icons.icecream_rounded, color: Colors.pinkAccent, size: 32, hintAr: 'مثلجات ملونة', hintEn: 'Ice cream cone'),
        DifferenceSpot(id: 1, x: 0.35, y: 0.18, icon: Icons.flight_takeoff_rounded, color: Colors.blueAccent, size: 30, hintAr: 'طائرة استعراضية', hintEn: 'Air stunt plane'),
        DifferenceSpot(id: 2, x: 0.52, y: 0.8, icon: Icons.music_note_rounded, color: Colors.amber, size: 28, hintAr: 'نغمة موسيقية', hintEn: 'Music note'),
        DifferenceSpot(id: 3, x: 0.85, y: 0.45, icon: Icons.auto_awesome_rounded, color: Colors.purpleAccent, size: 28, hintAr: 'بريق الألعاب النارية', hintEn: 'Fireworks sparkle'),
      ],
    ),

    // Level 7: محطة القطار السريع (Express Train) - 5 differences
    DifferenceScene(
      level: 7,
      titleAr: 'محطة القطار البخاري السريع',
      titleEn: 'Express Train Station',
      mainIcon: Icons.train_rounded,
      backgroundGradient: [const Color(0xFF4CA1AF), const Color(0xFFC4E0E5)],
      baseElements: const [
        DifferenceElement(icon: Icons.train_rounded, color: Colors.indigo, x: 0.5, y: 0.55, size: 56),
        DifferenceElement(icon: Icons.tram_rounded, color: Colors.blueGrey, x: 0.2, y: 0.75, size: 40),
        DifferenceElement(icon: Icons.cloud_rounded, color: Colors.white, x: 0.75, y: 0.2, size: 38),
        DifferenceElement(icon: Icons.wb_sunny_rounded, color: Colors.amber, x: 0.2, y: 0.2, size: 40),
      ],
      differences: [
        DifferenceSpot(id: 0, x: 0.48, y: 0.35, icon: Icons.air_rounded, color: Colors.grey, size: 32, hintAr: 'دخان القطار', hintEn: 'Train steam'),
        DifferenceSpot(id: 1, x: 0.82, y: 0.68, icon: Icons.luggage_rounded, color: Colors.brown, size: 30, hintAr: 'حقيبة سفر', hintEn: 'Travel suitcase'),
        DifferenceSpot(id: 2, x: 0.35, y: 0.28, icon: Icons.alarm_rounded, color: Colors.redAccent, size: 28, hintAr: 'ساعة المحطة', hintEn: 'Station clock'),
        DifferenceSpot(id: 3, x: 0.15, y: 0.48, icon: Icons.traffic_rounded, color: Colors.greenAccent, size: 30, hintAr: 'إشارة مرور', hintEn: 'Traffic signal'),
        DifferenceSpot(id: 4, x: 0.65, y: 0.82, icon: Icons.confirmation_number_rounded, color: Colors.amber, size: 26, hintAr: 'تذكرة قطار', hintEn: 'Train ticket'),
      ],
    ),

    // Level 8: قلعة الفرسان والرايات (Knights Castle) - 5 differences
    DifferenceScene(
      level: 8,
      titleAr: 'قلعة الفرسان والرايات',
      titleEn: 'Royal Knights Castle',
      mainIcon: Icons.castle_rounded,
      backgroundGradient: [const Color(0xFF2C3E50), const Color(0xFF4CA1AF)],
      baseElements: const [
        DifferenceElement(icon: Icons.castle_rounded, color: Colors.blueGrey, x: 0.5, y: 0.45, size: 58),
        DifferenceElement(icon: Icons.shield_rounded, color: Colors.amber, x: 0.2, y: 0.7, size: 42),
        DifferenceElement(icon: Icons.flag_rounded, color: Colors.redAccent, x: 0.5, y: 0.18, size: 34),
        DifferenceElement(icon: Icons.landscape_rounded, color: Colors.green, x: 0.8, y: 0.72, size: 44),
      ],
      differences: [
        DifferenceSpot(id: 0, x: 0.28, y: 0.38, icon: Icons.military_tech_rounded, color: Colors.amberAccent, size: 30, hintAr: 'وسام الفارس', hintEn: 'Knight medal'),
        DifferenceSpot(id: 1, x: 0.72, y: 0.25, icon: Icons.flutter_dash_rounded, color: Colors.white, size: 28, hintAr: 'حمامة السلام', hintEn: 'Dove'),
        DifferenceSpot(id: 2, x: 0.62, y: 0.78, icon: Icons.vpn_key_rounded, color: Colors.yellow, size: 28, hintAr: 'مفتاح البوابة', hintEn: 'Castle key'),
        DifferenceSpot(id: 3, x: 0.18, y: 0.25, icon: Icons.brightness_6_rounded, color: Colors.orangeAccent, size: 30, hintAr: 'مشعل ناري', hintEn: 'Torch'),
        DifferenceSpot(id: 4, x: 0.85, y: 0.52, icon: Icons.auto_awesome_rounded, color: Colors.cyanAccent, size: 26, hintAr: 'جوهرة لامعة', hintEn: 'Shiny gem'),
      ],
    ),

    // Level 9: شاطئ الجزيرة الاستوائية (Tropical Beach) - 5 differences
    DifferenceScene(
      level: 9,
      titleAr: 'شاطئ الجزيرة الاستوائية',
      titleEn: 'Tropical Island Beach',
      mainIcon: Icons.beach_access_rounded,
      backgroundGradient: [const Color(0xFFF7971E), const Color(0xFFFFD200), const Color(0xFF48CAE4)],
      baseElements: const [
        DifferenceElement(icon: Icons.beach_access_rounded, color: Colors.redAccent, x: 0.5, y: 0.6, size: 48),
        DifferenceElement(icon: Icons.wb_sunny_rounded, color: Colors.amber, x: 0.82, y: 0.15, size: 46),
        DifferenceElement(icon: Icons.park_rounded, color: Colors.green, x: 0.18, y: 0.5, size: 48),
        DifferenceElement(icon: Icons.water_rounded, color: Colors.blueAccent, x: 0.75, y: 0.78, size: 40),
      ],
      differences: [
        DifferenceSpot(id: 0, x: 0.35, y: 0.72, icon: Icons.sports_volleyball_rounded, color: Colors.orangeAccent, size: 30, hintAr: 'كرة الشاطئ', hintEn: 'Beach ball'),
        DifferenceSpot(id: 1, x: 0.65, y: 0.42, icon: Icons.surfing_rounded, color: Colors.deepPurpleAccent, size: 32, hintAr: 'لوح ركوب الأمواج', hintEn: 'Surfboard'),
        DifferenceSpot(id: 2, x: 0.45, y: 0.22, icon: Icons.cloud_rounded, color: Colors.white70, size: 30, hintAr: 'سحابة استوائية', hintEn: 'Tropical cloud'),
        DifferenceSpot(id: 3, x: 0.22, y: 0.82, icon: Icons.water_rounded, color: Colors.tealAccent, size: 28, hintAr: 'صدفة بحرية', hintEn: 'Sea shell'),
        DifferenceSpot(id: 4, x: 0.88, y: 0.55, icon: Icons.sailing_rounded, color: Colors.white, size: 32, hintAr: 'مركب شراعي بعيد', hintEn: 'Distant yacht'),
      ],
    ),

    // Level 10: حفلة عيد الميلاد السعيدة (Birthday Celebration) - 5 differences
    DifferenceScene(
      level: 10,
      titleAr: 'حفلة عيد الميلاد السعيدة',
      titleEn: 'Happy Birthday Celebration',
      mainIcon: Icons.cake_rounded,
      backgroundGradient: [const Color(0xFFFF758C), const Color(0xFFFF7EB3)],
      baseElements: const [
        DifferenceElement(icon: Icons.cake_rounded, color: Colors.amber, x: 0.5, y: 0.5, size: 54),
        DifferenceElement(icon: Icons.celebration_rounded, color: Colors.purple, x: 0.2, y: 0.25, size: 42),
        DifferenceElement(icon: Icons.card_giftcard_rounded, color: Colors.teal, x: 0.78, y: 0.72, size: 44),
        DifferenceElement(icon: Icons.star_rounded, color: Colors.yellow, x: 0.8, y: 0.2, size: 32),
      ],
      differences: [
        DifferenceSpot(id: 0, x: 0.5, y: 0.28, icon: Icons.local_fire_department_rounded, color: Colors.deepOrange, size: 30, hintAr: 'شعلة الشمعة', hintEn: 'Candle flame'),
        DifferenceSpot(id: 1, x: 0.22, y: 0.72, icon: Icons.card_giftcard_rounded, color: Colors.indigoAccent, size: 34, hintAr: 'صندوق هدية إضافي', hintEn: 'Extra gift box'),
        DifferenceSpot(id: 2, x: 0.38, y: 0.18, icon: Icons.favorite_rounded, color: Colors.redAccent, size: 28, hintAr: 'قلب زينة', hintEn: 'Party heart'),
        DifferenceSpot(id: 3, x: 0.65, y: 0.32, icon: Icons.music_note_rounded, color: Colors.blueAccent, size: 26, hintAr: 'نوتة احتفال', hintEn: 'Music note'),
        DifferenceSpot(id: 4, x: 0.5, y: 0.82, icon: Icons.auto_awesome_rounded, color: Colors.yellowAccent, size: 30, hintAr: 'شرائط ملونة', hintEn: 'Party confetti'),
      ],
    ),

    // Level 11 [VIP]: المستعمرة القمرية (Lunar Research Base) - 5 differences
    DifferenceScene(
      level: 11,
      titleAr: 'المستعمرة القمرية المضيئة',
      titleEn: 'Lunar Space Base',
      mainIcon: Icons.brightness_3_rounded,
      backgroundGradient: [const Color(0xFF141E30), const Color(0xFF243B55)],
      baseElements: const [
        DifferenceElement(icon: Icons.brightness_3_rounded, color: Colors.amberAccent, x: 0.5, y: 0.3, size: 54),
        DifferenceElement(icon: Icons.satellite_alt_rounded, color: Colors.cyanAccent, x: 0.2, y: 0.35, size: 44),
        DifferenceElement(icon: Icons.solar_power_rounded, color: Colors.blueAccent, x: 0.8, y: 0.65, size: 42),
        DifferenceElement(icon: Icons.star_rounded, color: Colors.white, x: 0.35, y: 0.15, size: 26),
      ],
      differences: [
        DifferenceSpot(id: 0, x: 0.5, y: 0.68, icon: Icons.flag_rounded, color: Colors.amber, size: 32, hintAr: 'علم رواد الفضاء', hintEn: 'Astronaut flag'),
        DifferenceSpot(id: 1, x: 0.25, y: 0.75, icon: Icons.directions_car_rounded, color: Colors.tealAccent, size: 34, hintAr: 'مركبة استكشاف قمرية', hintEn: 'Lunar rover'),
        DifferenceSpot(id: 2, x: 0.75, y: 0.2, icon: Icons.public_rounded, color: Colors.lightBlue, size: 36, hintAr: 'كوكب الأرض البعيد', hintEn: 'Earth view'),
        DifferenceSpot(id: 3, x: 0.62, y: 0.45, icon: Icons.radar_rounded, color: Colors.orangeAccent, size: 30, hintAr: 'رادار الاتصال', hintEn: 'Comm radar'),
        DifferenceSpot(id: 4, x: 0.85, y: 0.85, icon: Icons.diamond_rounded, color: Colors.purpleAccent, size: 28, hintAr: 'صخرة نيزكية كريستالية', hintEn: 'Crystal meteorite'),
      ],
    ),

    // Level 12 [VIP]: مدينة المستقبل الطائرة (Futuristic Flying City) - 6 differences
    DifferenceScene(
      level: 12,
      titleAr: 'مدينة المستقبل والسايبر',
      titleEn: 'Futuristic Cyber City',
      mainIcon: Icons.location_city_rounded,
      backgroundGradient: [const Color(0xFF0F0C29), const Color(0xFF302B63), const Color(0xFF24243E)],
      baseElements: const [
        DifferenceElement(icon: Icons.location_city_rounded, color: Colors.cyan, x: 0.5, y: 0.48, size: 58),
        DifferenceElement(icon: Icons.wifi_tethering_rounded, color: Colors.pinkAccent, x: 0.2, y: 0.22, size: 40),
        DifferenceElement(icon: Icons.memory_rounded, color: Colors.amber, x: 0.8, y: 0.3, size: 40),
        DifferenceElement(icon: Icons.electric_bolt_rounded, color: Colors.yellowAccent, x: 0.5, y: 0.18, size: 36),
      ],
      differences: [
        DifferenceSpot(id: 0, x: 0.32, y: 0.68, icon: Icons.flight_rounded, color: Colors.tealAccent, size: 32, hintAr: 'سيارة طائرة', hintEn: 'Hover car'),
        DifferenceSpot(id: 1, x: 0.68, y: 0.68, icon: Icons.smart_toy_rounded, color: Colors.purpleAccent, size: 32, hintAr: 'روبوت ذكي', hintEn: 'Cyber bot'),
        DifferenceSpot(id: 2, x: 0.18, y: 0.6, icon: Icons.blur_on_rounded, color: Colors.lightGreenAccent, size: 30, hintAr: 'بوابة ضوئية', hintEn: 'Light portal'),
        DifferenceSpot(id: 3, x: 0.82, y: 0.6, icon: Icons.terminal_rounded, color: Colors.cyanAccent, size: 28, hintAr: 'شاشة بيانات', hintEn: 'Holo screen'),
        DifferenceSpot(id: 4, x: 0.5, y: 0.82, icon: Icons.cable_rounded, color: Colors.pink, size: 30, hintAr: 'مسار طاقة ضوئي', hintEn: 'Neon conduit'),
        DifferenceSpot(id: 5, x: 0.75, y: 0.15, icon: Icons.auto_awesome_rounded, color: Colors.yellow, size: 26, hintAr: 'شريحة ذكاء اصطناعي', hintEn: 'AI node'),
      ],
    ),

    // Level 13 [VIP]: سفينة القراصنة وجزيرة الكنز (Pirate Galleon & Treasure) - 6 differences
    DifferenceScene(
      level: 13,
      titleAr: 'سفينة القراصنة وجزيرة الكنز',
      titleEn: 'Pirate Galleon & Treasure',
      mainIcon: Icons.sailing_rounded,
      backgroundGradient: [const Color(0xFF1F4037), const Color(0xFF99F2C8)],
      baseElements: const [
        DifferenceElement(icon: Icons.sailing_rounded, color: Colors.brown, x: 0.5, y: 0.45, size: 56),
        DifferenceElement(icon: Icons.map_rounded, color: Colors.amber, x: 0.2, y: 0.72, size: 42),
        DifferenceElement(icon: Icons.visibility_rounded, color: Colors.white, x: 0.8, y: 0.25, size: 38),
        DifferenceElement(icon: Icons.water_rounded, color: Colors.teal, x: 0.5, y: 0.78, size: 44),
      ],
      differences: [
        DifferenceSpot(id: 0, x: 0.78, y: 0.72, icon: Icons.savings_rounded, color: Colors.amber, size: 34, hintAr: 'صندوق الذهب', hintEn: 'Gold chest'),
        DifferenceSpot(id: 1, x: 0.48, y: 0.22, icon: Icons.flag_rounded, color: Colors.black, size: 30, hintAr: 'راية القراصنة', hintEn: 'Jolly Roger'),
        DifferenceSpot(id: 2, x: 0.25, y: 0.35, icon: Icons.explore_rounded, color: Colors.deepOrange, size: 30, hintAr: 'بوصلة الكنز', hintEn: 'Compass'),
        DifferenceSpot(id: 3, x: 0.22, y: 0.85, icon: Icons.key_rounded, color: Colors.yellowAccent, size: 28, hintAr: 'مفتاح الصندوق', hintEn: 'Chest key'),
        DifferenceSpot(id: 4, x: 0.68, y: 0.38, icon: Icons.monetization_on_rounded, color: Colors.amberAccent, size: 28, hintAr: 'عملة ذهبية', hintEn: 'Gold doubloon'),
        DifferenceSpot(id: 5, x: 0.85, y: 0.5, icon: Icons.anchor_rounded, color: Colors.blueGrey, size: 32, hintAr: 'مرساة السفينة', hintEn: 'Iron anchor'),
      ],
    ),

    // Level 14 [VIP]: مملكة السكاكر والحلويات (Sweet Candy Kingdom) - 6 differences
    DifferenceScene(
      level: 14,
      titleAr: 'مملكة السكاكر والحلويات',
      titleEn: 'Sweet Candy Kingdom',
      mainIcon: Icons.cookie_rounded,
      backgroundGradient: [const Color(0xFFFC5C7D), const Color(0xFF6A82FB)],
      baseElements: const [
        DifferenceElement(icon: Icons.cookie_rounded, color: Colors.amber, x: 0.5, y: 0.45, size: 54),
        DifferenceElement(icon: Icons.cake_rounded, color: Colors.pinkAccent, x: 0.22, y: 0.65, size: 44),
        DifferenceElement(icon: Icons.icecream_rounded, color: Colors.tealAccent, x: 0.78, y: 0.62, size: 46),
        DifferenceElement(icon: Icons.star_rounded, color: Colors.yellow, x: 0.8, y: 0.2, size: 32),
      ],
      differences: [
        DifferenceSpot(id: 0, x: 0.35, y: 0.25, icon: Icons.bubble_chart_rounded, color: Colors.pink, size: 32, hintAr: 'حلوى مارشميلو', hintEn: 'Marshmallow'),
        DifferenceSpot(id: 1, x: 0.65, y: 0.25, icon: Icons.favorite_rounded, color: Colors.redAccent, size: 30, hintAr: 'مصاصة قلب', hintEn: 'Heart lollipop'),
        DifferenceSpot(id: 2, x: 0.5, y: 0.78, icon: Icons.bakery_dining_rounded, color: Colors.brown, size: 34, hintAr: 'دونات الشوكولاتة', hintEn: 'Choco donut'),
        DifferenceSpot(id: 3, x: 0.2, y: 0.38, icon: Icons.auto_awesome_rounded, color: Colors.amberAccent, size: 28, hintAr: 'بريق سكري', hintEn: 'Sugar sparkle'),
        DifferenceSpot(id: 4, x: 0.85, y: 0.8, icon: Icons.local_florist_rounded, color: Colors.purpleAccent, size: 30, hintAr: 'زهرة سكاكر', hintEn: 'Candy flower'),
        DifferenceSpot(id: 5, x: 0.5, y: 0.18, icon: Icons.celebration_rounded, color: Colors.white, size: 30, hintAr: 'شريطة حلوى', hintEn: 'Candy ribbon'),
      ],
    ),

    // Level 15 [VIP]: القطب المتجمد ودببة الجليد (Arctic Frozen Realm) - 6 differences
    DifferenceScene(
      level: 15,
      titleAr: 'مملكة الجليد والقطب المتجمد',
      titleEn: 'Arctic Frozen Realm',
      mainIcon: Icons.ac_unit_rounded,
      backgroundGradient: [const Color(0xFFE0EAFC), const Color(0xFFCFDEF3), const Color(0xFF89F7FE)],
      baseElements: const [
        DifferenceElement(icon: Icons.ac_unit_rounded, color: Colors.blueAccent, x: 0.5, y: 0.3, size: 54),
        DifferenceElement(icon: Icons.landscape_rounded, color: Colors.white, x: 0.2, y: 0.65, size: 48),
        DifferenceElement(icon: Icons.pets_rounded, color: Colors.grey, x: 0.78, y: 0.68, size: 44),
        DifferenceElement(icon: Icons.wb_sunny_rounded, color: Colors.orangeAccent, x: 0.8, y: 0.15, size: 38),
      ],
      differences: [
        DifferenceSpot(id: 0, x: 0.35, y: 0.75, icon: Icons.flutter_dash_rounded, color: Colors.indigo, size: 32, hintAr: 'بطريق لطيف', hintEn: 'Cute penguin'),
        DifferenceSpot(id: 1, x: 0.55, y: 0.65, icon: Icons.cottage_rounded, color: Colors.lightBlueAccent, size: 36, hintAr: 'كوخ إسكيمو جليدي', hintEn: 'Ice igloo'),
        DifferenceSpot(id: 2, x: 0.2, y: 0.25, icon: Icons.cloud_rounded, color: Colors.white, size: 32, hintAr: 'سحابة ثلجية', hintEn: 'Snow cloud'),
        DifferenceSpot(id: 3, x: 0.68, y: 0.42, icon: Icons.ac_unit_rounded, color: Colors.cyan, size: 28, hintAr: 'بلورة ثلج إضافية', hintEn: 'Snow crystal'),
        DifferenceSpot(id: 4, x: 0.5, y: 0.85, icon: Icons.phishing_rounded, color: Colors.teal, size: 28, hintAr: 'سمكة قطبية مجمدة', hintEn: 'Polar fish'),
        DifferenceSpot(id: 5, x: 0.85, y: 0.48, icon: Icons.auto_awesome_rounded, color: Colors.amber, size: 26, hintAr: 'شفق قطبي متوهج', hintEn: 'Aurora glow'),
      ],
    ),

    // Level 16 [VIP]: مهرجان المناطيد الملونة (Hot Air Balloon Festival) - 6 differences
    DifferenceScene(
      level: 16,
      titleAr: 'واحة المناطيد الملونة',
      titleEn: 'Hot Air Balloon Festival',
      mainIcon: Icons.air_rounded,
      backgroundGradient: [const Color(0xFF43C6AC), const Color(0xFFF8FFAE)],
      baseElements: const [
        DifferenceElement(icon: Icons.air_rounded, color: Colors.deepOrange, x: 0.5, y: 0.35, size: 54),
        DifferenceElement(icon: Icons.cloud_rounded, color: Colors.white, x: 0.2, y: 0.2, size: 40),
        DifferenceElement(icon: Icons.cloud_rounded, color: Colors.white, x: 0.8, y: 0.28, size: 44),
        DifferenceElement(icon: Icons.landscape_rounded, color: Colors.green, x: 0.5, y: 0.78, size: 52),
      ],
      differences: [
        DifferenceSpot(id: 0, x: 0.25, y: 0.48, icon: Icons.air_rounded, color: Colors.purpleAccent, size: 36, hintAr: 'منطاد بنفسجي', hintEn: 'Purple balloon'),
        DifferenceSpot(id: 1, x: 0.75, y: 0.52, icon: Icons.air_rounded, color: Colors.teal, size: 34, hintAr: 'منطاد أزرق بحري', hintEn: 'Teal balloon'),
        DifferenceSpot(id: 2, x: 0.5, y: 0.15, icon: Icons.wb_sunny_rounded, color: Colors.amber, size: 38, hintAr: 'شمس مشرقة دافئة', hintEn: 'Warm sun'),
        DifferenceSpot(id: 3, x: 0.35, y: 0.75, icon: Icons.park_rounded, color: Color(0xFF1B5E20), size: 32, hintAr: 'شجرة صنوبر خضراء', hintEn: 'Pine tree'),
        DifferenceSpot(id: 4, x: 0.65, y: 0.75, icon: Icons.cottage_rounded, color: Colors.brown, size: 30, hintAr: 'كوخ في الوادي', hintEn: 'Valley cabin'),
        DifferenceSpot(id: 5, x: 0.82, y: 0.85, icon: Icons.flight_rounded, color: Colors.blueAccent, size: 28, hintAr: 'طائر محلق', hintEn: 'Gliding bird'),
      ],
    ),

    // Level 17 [VIP]: الغابة السحرية المضيئة (Enchanted Magic Grove) - 7 differences
    DifferenceScene(
      level: 17,
      titleAr: 'الغابة المسحورة والمخلوقات اللطيفة',
      titleEn: 'Enchanted Magic Woods',
      mainIcon: Icons.auto_awesome_rounded,
      imageAsset: 'assets/images/cartoon_park.png',
      backgroundGradient: [const Color(0xFF134E5E), const Color(0xFF71B280)],
      baseElements: const [
        DifferenceElement(icon: Icons.forest_rounded, color: Colors.teal, x: 0.2, y: 0.48, size: 52),
        DifferenceElement(icon: Icons.forest_rounded, color: Colors.green, x: 0.8, y: 0.48, size: 50),
        DifferenceElement(icon: Icons.auto_awesome_rounded, color: Colors.amberAccent, x: 0.5, y: 0.35, size: 48),
        DifferenceElement(icon: Icons.grass_rounded, color: Colors.lightGreenAccent, x: 0.5, y: 0.78, size: 42),
      ],
      differences: [
        DifferenceSpot(id: 0, x: 0.5, y: 0.6, icon: Icons.cruelty_free_rounded, color: Colors.white, size: 34, hintAr: 'أرنب سحري أبيض', hintEn: 'Magic rabbit'),
        DifferenceSpot(id: 1, x: 0.28, y: 0.22, icon: Icons.brightness_3_rounded, color: Colors.yellow, size: 32, hintAr: 'هلال مضيء', hintEn: 'Crescent moon'),
        DifferenceSpot(id: 2, x: 0.72, y: 0.25, icon: Icons.stars_rounded, color: Colors.cyanAccent, size: 30, hintAr: 'نجمة سحرية', hintEn: 'Magic star'),
        DifferenceSpot(id: 3, x: 0.2, y: 0.78, icon: Icons.local_florist_rounded, color: Colors.purpleAccent, size: 32, hintAr: 'زهرة متوهجة', hintEn: 'Glowing blossom'),
        DifferenceSpot(id: 4, x: 0.78, y: 0.75, icon: Icons.diamond_rounded, color: Colors.pinkAccent, size: 30, hintAr: 'كريستال الغابة', hintEn: 'Forest crystal'),
        DifferenceSpot(id: 5, x: 0.5, y: 0.18, icon: Icons.pest_control_rodent_rounded, color: Colors.amber, size: 28, hintAr: 'سنجاب الغصن', hintEn: 'Branch squirrel'),
        DifferenceSpot(id: 6, x: 0.35, y: 0.42, icon: Icons.lightbulb_rounded, color: Colors.yellowAccent, size: 26, hintAr: 'فانوس سحري', hintEn: 'Magic lantern'),
      ],
    ),

    // Level 18 [VIP]: مقر الأبطال الخارقين (Superhero Sky Academy) - 7 differences
    DifferenceScene(
      level: 18,
      titleAr: 'مقر الأبطال الخارقين',
      titleEn: 'Superhero Sky Academy',
      mainIcon: Icons.shield_rounded,
      backgroundGradient: [const Color(0xFFED213A), const Color(0xFF93291E)],
      baseElements: const [
        DifferenceElement(icon: Icons.shield_rounded, color: Colors.yellow, x: 0.5, y: 0.45, size: 56),
        DifferenceElement(icon: Icons.bolt_rounded, color: Colors.amberAccent, x: 0.5, y: 0.18, size: 42),
        DifferenceElement(icon: Icons.location_city_rounded, color: Colors.black54, x: 0.2, y: 0.65, size: 46),
        DifferenceElement(icon: Icons.location_city_rounded, color: Colors.black54, x: 0.8, y: 0.65, size: 46),
      ],
      differences: [
        DifferenceSpot(id: 0, x: 0.3, y: 0.32, icon: Icons.military_tech_rounded, color: Colors.amber, size: 34, hintAr: 'شارة البطل الذهبية', hintEn: 'Hero badge'),
        DifferenceSpot(id: 1, x: 0.7, y: 0.32, icon: Icons.rocket_launch_rounded, color: Colors.cyanAccent, size: 32, hintAr: 'حزام الطيران النفاث', hintEn: 'Jetpack flight'),
        DifferenceSpot(id: 2, x: 0.5, y: 0.72, icon: Icons.security_rounded, color: Colors.white, size: 34, hintAr: 'درع الحماية المشع', hintEn: 'Force field shield'),
        DifferenceSpot(id: 3, x: 0.18, y: 0.2, icon: Icons.emergency_rounded, color: Colors.redAccent, size: 30, hintAr: 'إنذار الطوارئ', hintEn: 'Hero beacon'),
        DifferenceSpot(id: 4, x: 0.82, y: 0.2, icon: Icons.visibility_rounded, color: Colors.amberAccent, size: 30, hintAr: 'عدسة المراقبة الفائقة', hintEn: 'Vision sensor'),
        DifferenceSpot(id: 5, x: 0.35, y: 0.82, icon: Icons.electric_bolt_rounded, color: Colors.yellow, size: 28, hintAr: 'صاعقة طاقة', hintEn: 'Lightning bolt'),
        DifferenceSpot(id: 6, x: 0.65, y: 0.82, icon: Icons.smart_toy_rounded, color: Colors.tealAccent, size: 30, hintAr: 'روبوت المساعدة', hintEn: 'Hero sidekick bot'),
      ],
    ),

    // Level 19 [VIP]: وادي الكريستال والبراكين (Crystal Volcano Gorge) - 7 differences
    DifferenceScene(
      level: 19,
      titleAr: 'أعماق البركان والأحجار الكريمة',
      titleEn: 'Crystal Volcano Gorge',
      mainIcon: Icons.volcano_rounded,
      backgroundGradient: [const Color(0xFFF12711), const Color(0xFFF5AF19)],
      baseElements: const [
        DifferenceElement(icon: Icons.volcano_rounded, color: Colors.brown, x: 0.5, y: 0.5, size: 60),
        DifferenceElement(icon: Icons.local_fire_department_rounded, color: Colors.deepOrange, x: 0.5, y: 0.22, size: 44),
        DifferenceElement(icon: Icons.terrain_rounded, color: Colors.blueGrey, x: 0.2, y: 0.75, size: 46),
        DifferenceElement(icon: Icons.terrain_rounded, color: Colors.blueGrey, x: 0.8, y: 0.75, size: 46),
      ],
      differences: [
        DifferenceSpot(id: 0, x: 0.35, y: 0.38, icon: Icons.diamond_rounded, color: Colors.cyanAccent, size: 34, hintAr: 'ياقوت أزرق ناري', hintEn: 'Blue sapphire'),
        DifferenceSpot(id: 1, x: 0.65, y: 0.38, icon: Icons.diamond_rounded, color: Colors.purpleAccent, size: 34, hintAr: 'جمشت بنفسجي', hintEn: 'Amethyst jewel'),
        DifferenceSpot(id: 2, x: 0.5, y: 0.78, icon: Icons.auto_awesome_rounded, color: Colors.amberAccent, size: 32, hintAr: 'حجر الكريستال الذهبي', hintEn: 'Golden crystal'),
        DifferenceSpot(id: 3, x: 0.22, y: 0.3, icon: Icons.air_rounded, color: Colors.white70, size: 30, hintAr: 'سحابة بخار بركاني', hintEn: 'Volcanic smoke'),
        DifferenceSpot(id: 4, x: 0.78, y: 0.3, icon: Icons.whatshot_rounded, color: Colors.yellow, size: 32, hintAr: 'شرارة حمم متطايرة', hintEn: 'Lava spark'),
        DifferenceSpot(id: 5, x: 0.35, y: 0.85, icon: Icons.hardware_rounded, color: Colors.grey, size: 28, hintAr: 'فأس التنقيب عن المعادن', hintEn: 'Mining pickaxe'),
        DifferenceSpot(id: 6, x: 0.68, y: 0.85, icon: Icons.brightness_7_rounded, color: Colors.deepOrangeAccent, size: 28, hintAr: 'حجر بركاني متوهج', hintEn: 'Molten magma stone'),
      ],
    ),

    // Level 20 [VIP]: القصر الملكي الذهبي (Grand Golden Palace) - 7 differences
    DifferenceScene(
      level: 20,
      titleAr: 'القصر الملكي الذهبي الفاخر',
      titleEn: 'Grand Golden Palace',
      mainIcon: Icons.castle_rounded,
      backgroundGradient: [const Color(0xFFFFD700), const Color(0xFFFFA500), const Color(0xFF8B6508)],
      baseElements: const [
        DifferenceElement(icon: Icons.castle_rounded, color: Color(0xFF5D4037), x: 0.5, y: 0.45, size: 62),
        DifferenceElement(icon: Icons.military_tech_rounded, color: Colors.amber, x: 0.2, y: 0.25, size: 44),
        DifferenceElement(icon: Icons.stars_rounded, color: Colors.white, x: 0.8, y: 0.25, size: 44),
        DifferenceElement(icon: Icons.shield_rounded, color: Colors.deepOrange, x: 0.5, y: 0.78, size: 46),
      ],
      differences: [
        DifferenceSpot(id: 0, x: 0.5, y: 0.18, icon: Icons.workspace_premium_rounded, color: Colors.yellowAccent, size: 38, hintAr: 'التاج الملكي المرصع', hintEn: 'Royal crown'),
        DifferenceSpot(id: 1, x: 0.25, y: 0.5, icon: Icons.auto_awesome_rounded, color: Colors.white, size: 32, hintAr: 'بريق الذهب الخالص', hintEn: 'Pure gold gleam'),
        DifferenceSpot(id: 2, x: 0.75, y: 0.5, icon: Icons.diamond_rounded, color: Colors.cyanAccent, size: 34, hintAr: 'الماسة الإمبراطورية', hintEn: 'Imperial diamond'),
        DifferenceSpot(id: 3, x: 0.32, y: 0.78, icon: Icons.flag_rounded, color: Colors.redAccent, size: 32, hintAr: 'راية النصر الذهبية', hintEn: 'Golden victory banner'),
        DifferenceSpot(id: 4, x: 0.68, y: 0.78, icon: Icons.monetization_on_rounded, color: Colors.amber, size: 32, hintAr: 'كنز القصر الملكي', hintEn: 'Palace treasure'),
        DifferenceSpot(id: 5, x: 0.18, y: 0.78, icon: Icons.wb_sunny_rounded, color: Colors.yellow, size: 30, hintAr: 'شمس المجد الذهبية', hintEn: 'Golden sun emblem'),
        DifferenceSpot(id: 6, x: 0.82, y: 0.78, icon: Icons.star_rounded, color: Colors.amberAccent, size: 30, hintAr: 'نجمة المملكة العظمى', hintEn: 'Kingdom grand star'),
      ],
    ),
  ];

  static DifferenceScene getSceneForLevel(int level) {
    if (level < 1) return scenes.first;
    if (level > scenes.length) return scenes.last;
    return scenes[level - 1];
  }
}
