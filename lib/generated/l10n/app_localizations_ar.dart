// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get appTitle => 'عبقري صغير';

  @override
  String get settings => 'الإعدادات';

  @override
  String get darkMode => 'الوضع الليلي';

  @override
  String get language => 'اللغة';

  @override
  String get arabic => 'العربية';

  @override
  String get english => 'الإنجليزية';

  @override
  String get privacyPolicy => 'سياسة الخصوصية';

  @override
  String get play => 'لعب';

  @override
  String get worlds => 'العوالم';

  @override
  String get dailyChallenge => 'التحدي اليومي';

  @override
  String get parentDashboard => 'لوحة الآباء';

  @override
  String get shop => 'المتجر';

  @override
  String get achievements => 'الإنجازات';

  @override
  String get timeLimitReached =>
      'تم الوصول للحد الأقصى للوقت! هل تود الذهاب للوحة الوالدين؟';

  @override
  String get gameRestricted => 'هذه اللعبة مقيدة من قبل الوالدين.';

  @override
  String get appearance => 'المظهر';

  @override
  String get legal => 'قانوني';

  @override
  String get about => 'حول التطبيق';

  @override
  String get deleteAccount => 'حذف بيانات الحساب';

  @override
  String get deleteAccountConfirmTitle => 'حذف جميع البيانات؟';

  @override
  String get deleteAccountConfirmMessage =>
      'سيؤدي هذا إلى حذف جميع بيانات التقدم والإنجازات والمشتريات بشكل دائم. لا يمكن التراجع عن هذا الإجراء.';

  @override
  String get deleteAccountConfirmButton => 'حذف';

  @override
  String get cancel => 'إلغاء';

  @override
  String streakDays(int count) {
    return '$count يوم متتالي';
  }

  @override
  String challengeGoal(int score) {
    return 'الهدف: $score نقطة';
  }

  @override
  String get challengeCompleted => 'تم إكمال التحدي!';

  @override
  String get rewards => 'المكافآت';

  @override
  String rewardStars(int stars) {
    return '$stars نجوم';
  }

  @override
  String rewardCoins(int coins) {
    return '$coins عملة';
  }

  @override
  String get startGame => 'ابدأ اللعب';

  @override
  String get enterPassword => 'يرجى إدخال كلمة المرور';

  @override
  String get incorrectPassword => 'كلمة المرور غير صحيحة';

  @override
  String get setPassword => 'إعداد كلمة المرور';

  @override
  String get changePassword => 'تغيير كلمة المرور';

  @override
  String get password => 'كلمة المرور';

  @override
  String get confirmPassword => 'تأكيد كلمة المرور';

  @override
  String get enterStrongPassword => 'أدخل كلمة مرور قوية';

  @override
  String get reenterPassword => 'أعد إدخال كلمة المرور';

  @override
  String get save => 'حفظ';

  @override
  String get passwordsDoNotMatch => 'كلمات المرور غير متطابقة';

  @override
  String get passwordTooShort => 'كلمة المرور يجب أن تكون 4 أحرف على الأقل';

  @override
  String get passwordSetSuccess => 'تم إعداد كلمة المرور بنجاح';

  @override
  String get oldPassword => 'كلمة المرور القديمة';

  @override
  String get newPassword => 'كلمة المرور الجديدة';

  @override
  String get confirmNewPassword => 'تأكيد كلمة المرور الجديدة';

  @override
  String get fillAllFields => 'يرجى ملء جميع الحقول';

  @override
  String get newPasswordsDoNotMatch => 'كلمات المرور الجديدة غير متطابقة';

  @override
  String get passwordChangeSuccess => 'تم تغيير كلمة المرور بنجاح';

  @override
  String get playTimeToday => 'وقت اللعب اليوم';

  @override
  String get minutes => 'دقيقة';

  @override
  String get minutesUnit => 'دقيقة';

  @override
  String maxPlayTimeLimit(int limit) {
    return 'الحد الأقصى: $limit دقيقة';
  }

  @override
  String get noLimit => 'لا يوجد حد';

  @override
  String get notSet => 'غير محدد';

  @override
  String get games => 'الألعاب';

  @override
  String get levels => 'المستويات';

  @override
  String get stars => 'النجوم';

  @override
  String get playTime => 'وقت اللعب';

  @override
  String get charts => 'الرسوم البيانية';

  @override
  String get exportPdf => 'تصدير PDF';

  @override
  String get playCountPerGame => 'عدد مرات اللعب لكل لعبة';

  @override
  String get gameDistribution => 'توزيع الألعاب';

  @override
  String get noStatsYet => 'لا توجد إحصائيات بعد';

  @override
  String get gameStatistics => 'إحصائيات الألعاب';

  @override
  String get timesUnit => 'مرات';

  @override
  String averageScore(String score) {
    return 'متوسط: $score';
  }

  @override
  String get enableParentMode => 'تفعيل وضع الوالدين';

  @override
  String get dailyPlayTimeLimit => 'حد وقت اللعب اليومي';

  @override
  String get allowedGames => 'الألعاب المسموحة';

  @override
  String get allGamesAllowed => 'جميع الألعاب';

  @override
  String get ageGroup => 'الفئة العمرية';

  @override
  String get yearsUnit => 'سنوات';

  @override
  String get achievementAlerts => 'تنبيهات الإنجازات';

  @override
  String get notifyNewAchievement => 'إشعار عند فتح إنجاز جديد';

  @override
  String get passwordIsSet => 'تم إعداد كلمة المرور';

  @override
  String get passwordNotSet => 'لم يتم إعداد كلمة المرور';

  @override
  String get passwordNotSetYet => 'لم يتم إعداد كلمة المرور بعد';

  @override
  String get enter => 'دخول';

  @override
  String get allGamesEnabledSuccess => 'تم تفعيل جميع الألعاب';

  @override
  String get allowedGamesUpdatedSuccess => 'تم تحديث الألعاب المسموحة';

  @override
  String get childAgeGroupTitle => 'الفئة العمرية للطفل';

  @override
  String yearsRange(int min, int max) {
    return '$min-$max سنوات';
  }

  @override
  String ageRangeAbove(int age) {
    return '$age+ سنة';
  }

  @override
  String get gameNameMemoryCards => 'بطاقات الذاكرة';

  @override
  String get gameNameFindDifference => 'إيجاد الفروقات';

  @override
  String get gameNameShapeMatcher => 'مطابقة الأشكال';

  @override
  String get gameNamePatternLogic => 'منطق الأنماط';

  @override
  String get gameNameQuickMath => 'الرياضيات السريعة';

  @override
  String get gameNameColorMemory => 'ذاكرة الألوان';

  @override
  String get gameNameWordPuzzle => 'ألغاز الكلمات';

  @override
  String get gameNameMazeRunner => 'متاهة';

  @override
  String get gameNameSortingGame => 'لعبة الترتيب';

  @override
  String get gameNameJigsawPuzzle => 'بازل';

  @override
  String get childProgressReportTitle => 'تقرير تقدم الطفل - MiniGenius';

  @override
  String get reportDate => 'تاريخ التقرير';

  @override
  String get pdfTableGame => 'اللعبة';

  @override
  String get pdfTableTimes => 'عدد المرات';

  @override
  String get pdfTableAvgScore => 'متوسط النقاط';

  @override
  String get star => 'نجمة';

  @override
  String worldLockedMessage(int stars) {
    return 'هذا العالم مقفل. تحتاج $stars نجمة لفتحه.';
  }

  @override
  String levelsCount(int count) {
    return '$count مستويات';
  }

  @override
  String chooseGameForLevel(int level) {
    return 'اختر اللعبة - المستوى $level';
  }

  @override
  String get worldLockedPrompt => 'هذا العالم مقفل. يرجى فتحه أولاً.';
}
