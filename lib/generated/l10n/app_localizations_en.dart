// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Mini Genius';

  @override
  String get settings => 'Settings';

  @override
  String get darkMode => 'Dark Mode';

  @override
  String get language => 'Language';

  @override
  String get arabic => 'Arabic';

  @override
  String get english => 'English';

  @override
  String get privacyPolicy => 'Privacy Policy';

  @override
  String get play => 'Play';

  @override
  String get worlds => 'Worlds';

  @override
  String get dailyChallenge => 'Daily Challenge';

  @override
  String get parentDashboard => 'Parent Dashboard';

  @override
  String get shop => 'Shop';

  @override
  String get achievements => 'Achievements';

  @override
  String get timeLimitReached => 'Time limit reached! Go to Parent Dashboard?';

  @override
  String get gameRestricted => 'This game is restricted by parents.';

  @override
  String get appearance => 'Appearance';

  @override
  String get legal => 'Legal';

  @override
  String get about => 'About';

  @override
  String get deleteAccount => 'Delete Account Data';

  @override
  String get deleteAccountConfirmTitle => 'Delete All Data?';

  @override
  String get deleteAccountConfirmMessage =>
      'This will permanently delete all your progress, achievements, and purchased items. This action cannot be undone.';

  @override
  String get deleteAccountConfirmButton => 'Delete';

  @override
  String get cancel => 'Cancel';
}
